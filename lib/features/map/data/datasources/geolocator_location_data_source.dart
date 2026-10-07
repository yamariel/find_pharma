import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/location_repository.dart';

/// Localisation fournie par le GPS de l'appareil, via geolocator.
class GeolocatorLocationDataSource implements LocationRepository {
  @override
  Future<LatLng> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw LocationFailure(LocationProblem.disabled);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !kIsWeb) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw LocationFailure(LocationProblem.deniedForever);
      }
      if (permission == LocationPermission.denied && !kIsWeb) {
        throw LocationFailure(LocationProblem.denied);
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      ).timeout(const Duration(seconds: 18));

      return LatLng(position.latitude, position.longitude);
    } on LocationFailure {
      rethrow;
    } on TimeoutException {
      throw LocationFailure(LocationProblem.timeout);
    } on PermissionDeniedException {
      throw LocationFailure(LocationProblem.denied);
    } on LocationServiceDisabledException {
      throw LocationFailure(LocationProblem.disabled);
    } catch (_) {
      throw LocationFailure(LocationProblem.unavailable);
    }
  }

  @override
  Future<bool> openSettings({required bool locationSettings}) async {
    if (kIsWeb) {
      return false;
    }
    try {
      return locationSettings
          ? await Geolocator.openLocationSettings()
          : await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}