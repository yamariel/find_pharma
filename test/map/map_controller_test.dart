import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:find_pharma/map/map_controller.dart';
import 'package:find_pharma/map/models/map_pharmacy.dart';
import 'package:find_pharma/map/services/location_service.dart';
import 'package:find_pharma/map/services/routing_service.dart';

class FakeLocation implements LocationService {
  LocationFailure? failure;
  int calls = 0;
  Completer<LatLng>? pending;
  @override
  Future<LatLng> locate() async {
    calls++;
    if (failure != null) throw failure!;
    return pending?.future ?? Future.value(const LatLng(-4.3, 15.3));
  }

  @override
  Future<bool> openSettings({required bool locationSettings}) async => false;
}

class FakeRouting implements RoutingService {
  final requests = <Completer<RoadRoute>>[];
  @override
  Future<RoadRoute> route(LatLng origin, LatLng destination) {
    final c = Completer<RoadRoute>();
    requests.add(c);
    return c.future;
  }

  @override
  void dispose() {}
}

final pharmacies = [
  MapPharmacy(id: 'a', name: 'A', latitude: -4.3, longitude: 15.3),
  MapPharmacy(id: 'b', name: 'B', latitude: -4.4, longitude: 15.4),
];
RoadRoute road(double meters) => RoadRoute(
  points: [const LatLng(-4.3, 15.3), const LatLng(-4.4, 15.4)],
  distanceMeters: meters,
  durationSeconds: 60,
);
Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeLocation location;
  late FakeRouting routing;
  late PharmacyMapController controller;
  setUp(() {
    location = FakeLocation();
    routing = FakeRouting();
    controller = PharmacyMapController(
      locationService: location,
      routingService: routing,
    );
    controller.setPharmacies(pharmacies);
    controller.select('a');
  });
  tearDown(() => controller.dispose());

  test('no automatic location/network request at construction', () {
    expect(location.calls, 0);
    expect(routing.requests, isEmpty);
    expect(controller.position, isNull);
  });
  for (final problem in LocationProblem.values) {
    test(
      'location $problem leaves pharmacies browsable without a route',
      () async {
        location.failure = LocationFailure(problem);
        await controller.requestRoute();
        expect(controller.position, isNull);
        expect(controller.locationFailure!.problem, problem);
        expect(controller.routing, false);
        expect(controller.pharmacies.length, 2);
        expect(routing.requests, isEmpty);
      },
    );
  }
  test('old route cannot replace selected pharmacy route', () async {
    final first = controller.requestRoute();
    await flush();
    controller.select('b');
    final second = controller.requestRoute();
    await flush();
    routing.requests[1].complete(road(200));
    await second;
    routing.requests[0].complete(road(100));
    await first;
    expect(controller.selected!.id, 'b');
    expect(controller.roadRoute!.distanceMeters, 200);
  });
  test(
    'selection during pending location prevents obsolete network request',
    () async {
      location.pending = Completer<LatLng>();
      final request = controller.requestRoute();
      controller.select('b');
      location.pending!.complete(const LatLng(-4, 15));
      await request;
      expect(routing.requests, isEmpty);
      expect(controller.routing, false);
    },
  );
  test('clear, filtering and errors invalidate in-flight routes', () async {
    final first = controller.requestRoute();
    await flush();
    controller.clearRoute();
    routing.requests[0].complete(road(100));
    await first;
    expect(controller.roadRoute, isNull);
    final second = controller.requestRoute();
    await flush();
    controller.setPharmacies([]);
    routing.requests[1].completeError(const RoutingFailure('Ancienne erreur'));
    await second;
    expect(controller.selected, isNull);
    expect(controller.routeError, isNull);
    controller.setPharmacies(pharmacies);
    controller.select('a');
    final third = controller.requestRoute();
    await flush();
    routing.requests[2].completeError(
      const RoutingFailure('Connexion impossible'),
    );
    await third;
    expect(controller.routeError, 'Connexion impossible');
    expect(controller.routing, false);
  });
  test('duplicate IDs rejected', () {
    expect(
      () => controller.setPharmacies([pharmacies.first, pharmacies.first]),
      throwsArgumentError,
    );
  });
  test('disposing with pending requests never notifies', () async {
    final separate = PharmacyMapController(
      locationService: location,
      routingService: routing,
    );
    separate.setPharmacies(pharmacies);
    separate.select('a');
    final request = separate.requestRoute();
    await flush();
    separate.dispose();
    routing.requests.single.complete(road(100));
    await request;
  });
}
