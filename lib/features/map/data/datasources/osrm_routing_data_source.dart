import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/coordinates.dart';
import '../../domain/entities/road_route.dart';
import '../../domain/repositories/routing_repository.dart';

/// Itinéraires automobiles calculés par un serveur OSRM.
///
/// Le profil « driving » est le seul utilisé : changer de nom de profil ne
/// change pas le jeu de données du serveur.
class OsrmRoutingDataSource implements RoutingRepository {
  OsrmRoutingDataSource({
    required String baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
    this.userAgent = 'org.findpharma.app',
  }) : _base = Uri.parse(baseUrl),
       _client = client ?? http.Client() {
    if (_base.scheme != 'https' ||
        _base.host.isEmpty ||
        _base.hasQuery ||
        _base.hasFragment ||
        _base.userInfo.isNotEmpty) {
      throw ArgumentError('Une URL racine HTTPS de routage est requise.');
    }
  }

  final Uri _base;
  final http.Client _client;
  final Duration timeout;
  final String userAgent;

  static final Stopwatch _clock = Stopwatch()..start();

  /// Partagé entre instances : rouvrir l'écran ne doit pas contourner la
  /// limite de débit des serveurs publics.
  static final Map<String, int> _lastRequests = <String, int>{};

  Uri routeUri(LatLng origin, LatLng destination) {
    validateCoordinates(origin.latitude, origin.longitude);
    validateCoordinates(destination.latitude, destination.longitude);

    final String root = _base.path.replaceAll(RegExp(r'/+$'), '');
    return _base.replace(
      path:
          '$root/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
      queryParameters: <String, String>{
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'false',
        'alternatives': 'false',
      },
    );
  }

  @override
  Future<RoadRoute> route(LatLng origin, LatLng destination) async {
    final Uri uri = routeUri(origin, destination);

    if (_base.host == 'router.project-osrm.org' ||
        _base.host == 'routing.openstreetmap.de') {
      final int now = _clock.elapsedMilliseconds;
      final int? last = _lastRequests[_base.host];
      if (last != null && now - last < 1000) {
        throw const RoutingFailure(
          'Veuillez patienter une seconde avant de recalculer.',
        );
      }
      _lastRequests[_base.host] = now;
    }

    try {
      final http.Response response = await _client
          .get(uri, headers: kIsWeb ? null : <String, String>{
            'User-Agent': userAgent,
          })
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw const RoutingFailure(
          'Service de routage indisponible. Réessayez.',
        );
      }
      return parseResponse(jsonDecode(response.body));
    } on TimeoutException {
      throw const RoutingFailure(
        'Le calcul a expiré. Vérifiez la connexion et réessayez.',
      );
    } on http.ClientException {
      throw const RoutingFailure(
        'Connexion au routage impossible. Vérifiez votre connexion.',
      );
    } on FormatException {
      throw const RoutingFailure('Réponse du service de routage invalide.');
    }
  }

  static RoadRoute parseResponse(dynamic body) {
    const RoutingFailure invalid = RoutingFailure(
      'Réponse du service de routage invalide.',
    );

    if (body is! Map) {
      throw invalid;
    }
    if (body['code'] == 'NoRoute' || body['code'] == 'NoSegment') {
      throw const RoutingFailure('Aucun itinéraire automobile trouvé.');
    }
    if (body['code'] != 'Ok') {
      throw invalid;
    }

    final Object? routes = body['routes'];
    if (routes is! List) {
      throw invalid;
    }
    if (routes.isEmpty) {
      throw const RoutingFailure('Aucun itinéraire automobile trouvé.');
    }

    final Object? route = routes.first;
    if (route is! Map) {
      throw invalid;
    }

    final Object? distance = route['distance'];
    final Object? duration = route['duration'];
    if (distance is! num ||
        duration is! num ||
        !distance.isFinite ||
        !duration.isFinite ||
        distance < 0 ||
        duration < 0) {
      throw invalid;
    }

    final Object? geometry = route['geometry'];
    if (geometry is! Map || geometry['type'] != 'LineString') {
      throw invalid;
    }

    final Object? coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) {
      throw invalid;
    }

    final List<LatLng> points = <LatLng>[];
    for (final Object? pair in coordinates) {
      if (pair is! List ||
          pair.length < 2 ||
          pair[0] is! num ||
          pair[1] is! num) {
        throw invalid;
      }
      final double longitude = (pair[0] as num).toDouble();
      final double latitude = (pair[1] as num).toDouble();
      try {
        validateCoordinates(latitude, longitude);
      } on ArgumentError {
        throw invalid;
      }
      points.add(LatLng(latitude, longitude));
    }

    return RoadRoute(
      points: points,
      distanceMeters: distance.toDouble(),
      durationSeconds: duration.toDouble(),
    );
  }

  @override
  void dispose() => _client.close();
}