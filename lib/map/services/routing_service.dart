import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/map_pharmacy.dart';

class RoadRoute {
  RoadRoute({
    required List<LatLng> points,
    required this.distanceMeters,
    required this.durationSeconds,
  }) : points = List.unmodifiable(points);
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
}

class RoutingFailure implements Exception {
  const RoutingFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class RoutingService {
  Future<RoadRoute> route(LatLng origin, LatLng destination);
  void dispose();
}

/// Automobile only: an OSRM profile name does not change the server's dataset.
class OsrmRoutingService implements RoutingService {
  OsrmRoutingService({
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
  // Shared by instances: reopening the screen must not bypass the public limit.
  static final Map<String, int> _lastRequests = {};

  Uri routeUri(LatLng origin, LatLng destination) {
    validateCoordinates(origin.latitude, origin.longitude);
    validateCoordinates(destination.latitude, destination.longitude);
    final root = _base.path.replaceAll(RegExp(r'/+$'), '');
    return _base.replace(
      path:
          '$root/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'false',
        'alternatives': 'false',
      },
    );
  }

  @override
  Future<RoadRoute> route(LatLng origin, LatLng destination) async {
    final uri = routeUri(origin, destination);
    if (_base.host == 'router.project-osrm.org' ||
        _base.host == 'routing.openstreetmap.de') {
      final now = _clock.elapsedMilliseconds;
      final last = _lastRequests[_base.host];
      if (last != null && now - last < 1000) {
        throw const RoutingFailure(
          'Veuillez patienter une seconde avant de recalculer.',
        );
      }
      _lastRequests[_base.host] = now;
    }
    try {
      final response = await _client
          .get(uri, headers: kIsWeb ? null : {'User-Agent': userAgent})
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
    const invalid = RoutingFailure('Réponse du service de routage invalide.');
    if (body is! Map) throw invalid;
    if (body['code'] == 'NoRoute' || body['code'] == 'NoSegment') {
      throw const RoutingFailure('Aucun itinéraire automobile trouvé.');
    }
    if (body['code'] != 'Ok') throw invalid;
    final routes = body['routes'];
    if (routes is! List) throw invalid;
    if (routes.isEmpty) {
      throw const RoutingFailure('Aucun itinéraire automobile trouvé.');
    }
    final route = routes.first;
    if (route is! Map) throw invalid;
    final distance = route['distance'];
    final duration = route['duration'];
    if (distance is! num ||
        duration is! num ||
        !distance.isFinite ||
        !duration.isFinite ||
        distance < 0 ||
        duration < 0) {
      throw invalid;
    }
    final geometry = route['geometry'];
    if (geometry is! Map || geometry['type'] != 'LineString') throw invalid;
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) throw invalid;
    final points = <LatLng>[];
    for (final pair in coordinates) {
      if (pair is! List ||
          pair.length < 2 ||
          pair[0] is! num ||
          pair[1] is! num) {
        throw invalid;
      }
      final longitude = (pair[0] as num).toDouble();
      final latitude = (pair[1] as num).toDouble();
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
