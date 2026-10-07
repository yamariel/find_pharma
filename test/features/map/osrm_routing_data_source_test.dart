import 'dart:async';
import 'dart:convert';

import 'package:find_pharma/core/errors/failures.dart';
import 'package:find_pharma/features/map/data/datasources/osrm_routing_data_source.dart';
import 'package:find_pharma/features/map/domain/entities/map_pharmacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

Map<String, dynamic> response({
  Object? coordinates,
  Object? distance = 1234,
  Object? duration = 300,
}) => {
  'code': 'Ok',
  'routes': [
    {
      'distance': distance,
      'duration': duration,
      'geometry': {
        'type': 'LineString',
        'coordinates':
            coordinates ??
            [
              [15.3, -4.3],
              [15.32, -4.32],
              [15.4, -4.4],
            ],
      },
    },
  ],
};

void main() {
  test(
    'request longitude/latitude and GeoJSON decoded as latitude/longitude',
    () async {
      final service = OsrmRoutingDataSource(
        baseUrl: 'https://routing.example/proxy/',
        client: MockClient((request) async {
          expect(
            request.url.path,
            '/proxy/route/v1/driving/15.3,-4.3;15.4,-4.4',
          );
          expect(request.url.queryParameters['geometries'], 'geojson');
          expect(request.url.queryParameters['overview'], 'full');
          return http.Response(jsonEncode(response()), 200);
        }),
      );
      addTearDown(service.dispose);
      final result = await service.route(
        const LatLng(-4.3, 15.3),
        const LatLng(-4.4, 15.4),
      );
      expect(result.points[0].latitude, -4.3);
      expect(result.points[0].longitude, 15.3);
      expect(result.points.length, 3);
      expect(result.distanceMeters, 1234);
      expect(result.durationSeconds, 300);
    },
  );

  for (final body in [
    null,
    {},
    {'code': 'Error'},
    {'code': 'NoRoute'},
    {'code': 'NoSegment'},
    {'code': 'Ok', 'routes': []},
    response(
      coordinates: [
        [15, -4],
      ],
    ),
    response(
      coordinates: [
        ['15', -4],
        [15, -4],
      ],
    ),
    response(
      coordinates: [
        [181, -4],
        [15, -4],
      ],
    ),
    response(
      coordinates: [
        [15, double.nan],
        [15, -4],
      ],
    ),
    response(distance: -1),
    response(duration: double.infinity),
    response(distance: '123'),
    response(duration: null),
  ]) {
    test('rejects malformed/no route response ${body.toString()}', () {
      expect(
        () => OsrmRoutingDataSource.parseResponse(body),
        throwsA(isA<RoutingFailure>()),
      );
    });
  }

  test(
    'HTTP, network, invalid JSON and timeout produce public errors',
    () async {
      for (final client in [
        MockClient((_) async => http.Response('unavailable', 503)),
        MockClient((_) async => http.Response('{bad json', 200)),
        MockClient((_) async => throw http.ClientException('private url')),
        MockClient((_) => Completer<http.Response>().future),
      ]) {
        final service = OsrmRoutingDataSource(
          baseUrl: 'https://routing.example',
          client: client,
          timeout: const Duration(milliseconds: 10),
        );
        await expectLater(
          service.route(const LatLng(-4, 15), const LatLng(-4.1, 15.1)),
          throwsA(isA<RoutingFailure>()),
        );
        service.dispose();
      }
    },
  );

  test('validates public coordinates and refuses insecure routing URLs', () {
    for (final pair in [
      [double.nan, 15.0],
      [-91.0, 15.0],
      [-4.0, 181.0],
    ]) {
      expect(
        () => MapPharmacy(
          id: 'p',
          name: 'P',
          latitude: pair[0],
          longitude: pair[1],
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => OsrmRoutingDataSource(baseUrl: 'http://routing.example'),
      throwsArgumentError,
    );
    final p = MapPharmacy(id: 'p', name: 'P', latitude: -4, longitude: 15);
    expect(p.opening, OpeningStatus.unknown);
    expect(p.availability, MedicineAvailability.unknown);
    expect(p.priceLabel, isNull);
    expect(p.presentSellerNames, isNull);
  });
  test('public demo rate limit spans service instances and identifies native requests', () async {
    var calls = 0;
    http.Client client() => MockClient((request) async {
      calls++;
      expect(request.headers['User-Agent'], 'org.findpharma.app');
      return http.Response(jsonEncode(response()), 200);
    });
    final first = OsrmRoutingDataSource(
      baseUrl: 'https://router.project-osrm.org',
      client: client(),
    );
    final second = OsrmRoutingDataSource(
      baseUrl: 'https://router.project-osrm.org',
      client: client(),
    );
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    final request = first.route(const LatLng(-4, 15), const LatLng(-4.1, 15.1));
    await expectLater(
      second.route(const LatLng(-4, 15), const LatLng(-4.1, 15.1)),
      throwsA(isA<RoutingFailure>()),
    );
    await request;
    expect(calls, 1);
  });
}
