import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/map_config.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/map_pharmacy.dart';
import '../../domain/entities/road_route.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/routing_repository.dart';
import '../controllers/pharmacy_map_controller.dart';
import 'pharmacy_markers.dart';
import 'pharmacy_summary.dart';

class PharmacyMapView extends StatefulWidget {
  const PharmacyMapView({
    super.key,
    required this.pharmacies,
    this.medicine,
    this.selectedPharmacyId,
    this.onSelectionChanged,
    this.onViewPharmacy,
    this.onRetry,
    this.loading = false,
    this.errorMessage,
    this.isDemo = false,
    this.config = const MapConfig(),
    required this.locationRepository,
    required this.routingRepository,
    this.tileProvider,
  });
  final List<MapPharmacy> pharmacies;
  final MedicineContext? medicine;
  final String? selectedPharmacyId;
  final ValueChanged<MapPharmacy?>? onSelectionChanged;
  final ValueChanged<MapPharmacy>? onViewPharmacy;
  final VoidCallback? onRetry;
  final bool loading;

  /// Host supplies a public message (never a raw Firebase exception).
  final String? errorMessage;
  final bool isDemo;
  final MapConfig config;
  final LocationRepository locationRepository;
  final RoutingRepository routingRepository;

  /// Optional for tests/custom tile providers; FlutterMap owns its lifecycle.
  final TileProvider? tileProvider;

  @override
  State<PharmacyMapView> createState() => _PharmacyMapViewState();
}

class _PharmacyMapViewState extends State<PharmacyMapView> {
  final _camera = MapController();
  late PharmacyMapController _state;
  late RoutingRepository _routingRepository;
  bool _ready = false;
  bool _tileError = false;
  int _tileRevision = 0;
  RoadRoute? _lastFitted;

  @override
  void initState() {
    super.initState();
    _createState();
  }

  void _createState() {
    _routingRepository =
        widget.routingRepository;
    _state = PharmacyMapController(
      locationRepository: widget.locationRepository,
      routingRepository: _routingRepository,
    );
    _state.setPharmacies(_visibleResults);
    _state.select(widget.selectedPharmacyId);
    _state.addListener(_changed);
  }

  List<MapPharmacy> get _visibleResults =>
      widget.loading || widget.errorMessage != null
      ? const []
      : widget.pharmacies;

  @override
  void didUpdateWidget(covariant PharmacyMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routingRepository != widget.routingRepository ||
        oldWidget.locationRepository != widget.locationRepository ||
        oldWidget.config.routingUrl != widget.config.routingUrl) {
      _disposeState();
      _lastFitted = null;
      _createState();
    }
    if (!listEquals(oldWidget.pharmacies, widget.pharmacies) ||
        oldWidget.medicine?.id != widget.medicine?.id ||
        oldWidget.loading != widget.loading ||
        oldWidget.errorMessage != widget.errorMessage) {
      _state.setPharmacies(_visibleResults);
      if (_ready && _visibleResults.isNotEmpty) _fitResults();
    }
    if (oldWidget.selectedPharmacyId != widget.selectedPharmacyId) {
      _state.select(widget.selectedPharmacyId);
    } else if ((oldWidget.loading || oldWidget.errorMessage != null) &&
        !widget.loading && widget.errorMessage == null) {
      // La destination du lien peut précéder le chargement des pharmacies.
      _state.select(widget.selectedPharmacyId);
    }
  }

  void _changed() {
    if (!mounted) return;
    final route = _state.roadRoute;
    if (route != null && route != _lastFitted && _ready) {
      _lastFitted = route;
      // Metrics change the available map height. Fit only after that layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_ready || _state.roadRoute != route) return;
        _camera.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(route.points),
            padding: const EdgeInsets.all(48),
            maxZoom: 17,
          ),
        );
      });
    }
    setState(() {});
  }

  void _fitResults() {
    if (_state.pharmacies.isEmpty) return;
    _camera.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(
          _state.pharmacies.map((p) => p.point).toList(),
        ),
        padding: const EdgeInsets.all(60),
        maxZoom: 16,
      ),
    );
  }

  void _select(MapPharmacy? pharmacy) {
    _state.select(pharmacy?.id);
    if (pharmacy != null && _ready) {
      _camera.move(pharmacy.point, _camera.camera.zoom);
    }
    widget.onSelectionChanged?.call(pharmacy);
  }

  Future<void> _choose(List<MapPharmacy> group) async {
    if (group.length == 1) {
      _select(group.first);
      return;
    }
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Choisir une pharmacie'),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: group
                    .map(
                      (p) => ListTile(
                        leading: Icon(
                          openingIcon(p.opening),
                          color: openingColor(p.opening),
                        ),
                        title: Text(p.name),
                        subtitle: Text(openingLabel(p.opening)),
                        onTap: () => Navigator.pop(context, p.id),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || chosen == null) return;
    for (final p in _state.pharmacies) {
      if (p.id == chosen) {
        _select(p);
        break;
      }
    }
  }

  Future<void> _locate() async {
    _state.clearRoute();
    final point = await _state.locate();
    if (mounted && point != null && _ready) _camera.move(point, 15);
  }

  Future<void> _settings() async {
    final opened = await _state.locationRepository.openSettings(
      locationSettings:
          _state.locationFailure?.problem == LocationProblem.disabled,
    );
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ouvrez les réglages de localisation de votre appareil ou les permissions de ce site, puis réessayez.',
        ),
      ),
    );
  }

  Future<void> _attribution([String? target]) async {
    final url = target ?? widget.config.tileAttributionUrl;
    try {
      if (await launchUrl(Uri.parse(url))) return;
    } catch (_) {
      /* The text attribution remains visible. */
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(url)));
    }
  }

  void _tileFailed() {
    if (_tileError || !mounted) return;
    // A tile may fail during the render phase; defer UI mutation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_tileError) setState(() => _tileError = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _state.selected;
    final route = _state.roadRoute;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des pharmacies'),
        actions: [
          IconButton(
            tooltip: 'Liste des pharmacies',
            onPressed: _state.pharmacies.isEmpty
                ? null
                : () => _choose(_state.pharmacies),
            icon: const Icon(Icons.list),
          ),
          IconButton(
            tooltip: 'Voir tous les résultats',
            onPressed: _state.pharmacies.isEmpty ? null : _fitResults,
            icon: const Icon(Icons.zoom_out_map),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              // Bounded scrolling prevents status/selection content hiding the map on
              // small screens, in landscape, or with large accessibility text.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * .28,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.isDemo)
                        _notice(
                          'DÉMONSTRATION — pharmacies et offres fictives',
                        ),
                      if (widget.medicine != null)
                        _notice('Recherche : ${widget.medicine!.label}'),
                      if (_state.position == null)
                        _notice(
                          'Position non disponible • itinéraire indisponible',
                        ),
                      if (widget.loading)
                        const LinearProgressIndicator(
                          semanticsLabel: 'Chargement des pharmacies',
                        ),
                      if (widget.errorMessage != null)
                        _notice(
                          widget.errorMessage!,
                          action: widget.onRetry,
                          actionLabel: 'Réessayer',
                        ),
                      if (!widget.loading &&
                          widget.errorMessage == null &&
                          _state.pharmacies.isEmpty)
                        _notice(
                          widget.medicine == null
                              ? 'Aucune pharmacie à afficher.'
                              : 'Aucun résultat pour ce médicament.',
                        ),
                      if (_state.locationFailure != null)
                        _notice(
                          _state.locationFailure!.message,
                          action:
                              _state.locationFailure!.problem ==
                                      LocationProblem.disabled ||
                                  _state.locationFailure!.problem ==
                                      LocationProblem.deniedForever
                              ? _settings
                              : _locate,
                          actionLabel:
                              _state.locationFailure!.problem ==
                                      LocationProblem.disabled ||
                                  _state.locationFailure!.problem ==
                                      LocationProblem.deniedForever
                              ? 'Réglages'
                              : 'Réessayer',
                        ),
                      if (_tileError)
                        _notice(
                          'Fond de carte indisponible. Vérifiez votre connexion.',
                          action: () => setState(() {
                            _tileError = false;
                            _tileRevision++;
                          }),
                          actionLabel: 'Réessayer',
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _camera,
                      options: MapOptions(
                        initialCenter: LatLng(
                          widget.config.fallbackLatitude,
                          widget.config.fallbackLongitude,
                        ),
                        initialZoom: widget.config.fallbackZoom,
                        minZoom: 3,
                        maxZoom: 19,
                        onMapReady: () {
                          _ready = true;
                          _fitResults();
                        },
                      ),
                      children: [
                        TileLayer(
                          key: ValueKey(_tileRevision),
                          urlTemplate: widget.config.tileUrl,
                          userAgentPackageName: widget.config.userAgent,
                          maxNativeZoom: 19,
                          tileProvider: widget.tileProvider,
                          errorTileCallback: (_, _, _) => _tileFailed(),
                        ),
                        if (route != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: route.points,
                                strokeWidth: 5,
                                color: Colors.indigo,
                                borderStrokeWidth: 2,
                                borderColor: Colors.white,
                              ),
                            ],
                          ),
                        PharmacyMarkers(
                          pharmacies: _state.pharmacies,
                          selectedId: selected?.id,
                          onChoose: _choose,
                        ),
                        if (_state.position != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _state.position!,
                                width: 28,
                                height: 28,
                                child: const Tooltip(
                                  message: 'Votre position relevée',
                                  child: Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: FloatingActionButton.small(
                        heroTag: null,
                        tooltip: 'Me localiser et recentrer',
                        onPressed: _state.locating ? null : _locate,
                        child: _state.locating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),
              // Attribution is always visible, never under a sheet or a toggle.
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: InkWell(
                  onTap: () => _attribution(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.config.tileAttribution,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new, size: 12),
                        IconButton(
                          tooltip: 'Signaler une erreur cartographique',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _attribution(
                            'https://www.openstreetmap.org/fixthemap',
                          ),
                          icon: const Icon(
                            Icons.edit_location_alt_outlined,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (selected != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * .4,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_state.routeError != null)
                          _notice(_state.routeError!),
                        if (_state.routing || route != null)
                          _notice(
                            route == null
                                ? 'Calcul du trajet automobile…'
                                : 'Voiture • ${(route.distanceMeters / 1000).toStringAsFixed(1)} km par la route • '
                                      '${(route.durationSeconds / 60).ceil()} min estimées\nSans trafic en temps réel\nOSRM • © OpenStreetMap contributors (ODbL)',
                            action: _state.clearRoute,
                            actionLabel: 'Effacer le trajet',
                          ),
                        PharmacySummary(
                          pharmacy: selected,
                          position: _state.position,
                          medicine: widget.medicine,
                          routing: _state.routing,
                          onRoute: _state.requestRoute,
                          onClose: () => _select(null),
                          onView: widget.onViewPharmacy == null
                              ? null
                              : () => widget.onViewPharmacy!(selected),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notice(String message, {VoidCallback? action, String? actionLabel}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(message)),
            if (action != null)
              TextButton(onPressed: action, child: Text(actionLabel!)),
          ],
        ),
      );

  void _disposeState() {
    _state.removeListener(_changed);
    _state.dispose();
  }

  @override
  void dispose() {
    _disposeState();
    _camera.dispose();
    super.dispose();
  }
}
