import 'package:find_pharma/core/errors/failures.dart';
import 'package:find_pharma/features/map/domain/entities/map_pharmacy.dart';
import 'package:find_pharma/features/map/domain/entities/road_route.dart';
import 'package:find_pharma/features/map/domain/repositories/location_repository.dart';
import 'package:find_pharma/features/map/domain/repositories/routing_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';



/// Screen-scoped state. No database writes, position history or subscriptions.
class PharmacyMapController extends ChangeNotifier {
  PharmacyMapController({
    required this.locationRepository,
    required this.routingRepository,
  });
  final LocationRepository locationRepository;
  final RoutingRepository routingRepository;
  List<MapPharmacy> _pharmacies = const [];
  List<MapPharmacy> get pharmacies => _pharmacies;
  MapPharmacy? selected;
  LatLng? position;
  RoadRoute? roadRoute;
  LocationFailure? locationFailure;
  String? routeError;
  bool locating = false;
  bool routing = false;
  bool _disposed = false;
  int _routeVersion = 0;
  Future<LatLng?>? _pendingLocation;

  void setPharmacies(List<MapPharmacy> items) {
    final ids = <String>{};
    if (items.any((p) => !ids.add(p.id))) {
      throw ArgumentError(
        'Les identifiants des pharmacies doivent être uniques.',
      );
    }
    final selectedId = selected?.id;
    _pharmacies = List.unmodifiable(items);
    selected = null;
    for (final p in items) {
      if (p.id == selectedId) selected = p;
    }
    clearRoute();
  }

  void select(String? id) {
    selected = null;
    for (final p in pharmacies) {
      if (p.id == id) selected = p;
    }
    clearRoute();
  }

  void clearRoute() {
    _routeVersion++;
    roadRoute = null;
    routeError = null;
    routing = false;
    if (!_disposed) notifyListeners();
  }

  Future<LatLng?> locate() {
    return _pendingLocation ??= _locate().whenComplete(
      () => _pendingLocation = null,
    );
  }

  Future<LatLng?> _locate() async {
    locating = true;
    locationFailure = null;
    notifyListeners();
    try {
      final result = await locationRepository.locate();
      if (_disposed) return null;
      position = result;
      return result;
    } on LocationFailure catch (error) {
      if (!_disposed) {
        locationFailure = error;
        position = null;
      }
      return null;
    } catch (_) {
      if (!_disposed) {
        locationFailure = LocationFailure(LocationProblem.unavailable);
        position = null;
      }
      return null;
    } finally {
      if (!_disposed) {
        locating = false;
        notifyListeners();
      }
    }
  }

  Future<void> requestRoute() async {
    final destination = selected;
    if (destination == null || routing) return;
    final version = ++_routeVersion;
    roadRoute = null;
    routeError = null;
    routing = true;
    notifyListeners();
    try {
      // Refresh for each explicit route request; never use a persisted position.
      final origin = await locate();
      if (_disposed || version != _routeVersion || origin == null) return;
      final result = await routingRepository.route(origin, destination.point);
      if (_disposed || version != _routeVersion) return;
      roadRoute = result;
    } on RoutingFailure catch (error) {
      if (!_disposed && version == _routeVersion) routeError = error.message;
    } catch (_) {
      if (!_disposed && version == _routeVersion) {
        routeError = 'Le trajet n’a pas pu être calculé. Vérifiez la connexion et réessayez.';
      }
    } finally {
      if (!_disposed && version == _routeVersion) {
        routing = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _routeVersion++;
    // Injected services are owned by the caller, not this controller.
    super.dispose();
  }
}
