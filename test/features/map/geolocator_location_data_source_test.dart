import 'dart:async';

import 'package:find_pharma/core/errors/failures.dart';
import 'package:find_pharma/features/map/data/datasources/geolocator_location_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class LocationPlatformFake extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.denied;
  LocationPermission requested = LocationPermission.whileInUse;
  int requests = 0;
  int positionCalls = 0;
  Object? error;
  LocationSettings? receivedSettings;
  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return requested;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    positionCalls++;
    receivedSettings = locationSettings;
    if (error != null) throw error!;
    return Position(
      latitude: -4.3,
      longitude: 15.3,
      timestamp: DateTime(2026),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

void main() {
  late GeolocatorPlatform original;
  late LocationPlatformFake platform;
  final service = GeolocatorLocationDataSource();
  setUp(() {
    original = GeolocatorPlatform.instance;
    platform = LocationPlatformFake();
    GeolocatorPlatform.instance = platform;
  });
  tearDown(() {
    GeolocatorPlatform.instance = original;
  });
  Matcher failure(LocationProblem problem) => throwsA(
    isA<LocationFailure>().having((e) => e.problem, 'problem', problem),
  );

  test(
    'requests permission once and uses a bounded foreground position',
    () async {
      final p = await service.locate();
      expect(p.latitude, -4.3);
      expect(p.longitude, 15.3);
      expect(platform.requests, 1);
      expect(platform.positionCalls, 1);
      expect(platform.receivedSettings!.timeLimit, const Duration(seconds: 15));
    },
  );
  test('disabled GPS never requests permission/position', () async {
    platform.enabled = false;
    await expectLater(service.locate(), failure(LocationProblem.disabled));
    expect(platform.requests, 0);
    expect(platform.positionCalls, 0);
  });
  test('denied and denied forever do not acquire position', () async {
    platform.requested = LocationPermission.denied;
    await expectLater(service.locate(), failure(LocationProblem.denied));
    platform.permission = LocationPermission.deniedForever;
    await expectLater(service.locate(), failure(LocationProblem.deniedForever));
    expect(platform.requests, 1);
    expect(platform.positionCalls, 0);
  });
  test(
    'permission indeterminate can be resolved by platform position request',
    () async {
      platform.permission = LocationPermission.unableToDetermine;
      await service.locate();
      expect(platform.positionCalls, 1);
    },
  );
  test(
    'position timeouts and permission revocation map to explicit errors',
    () async {
      platform.permission = LocationPermission.whileInUse;
      platform.error = TimeoutException('timeout');
      await expectLater(service.locate(), failure(LocationProblem.timeout));
      platform.error = PermissionDeniedException('denied');
      await expectLater(service.locate(), failure(LocationProblem.denied));
    },
  );
}
