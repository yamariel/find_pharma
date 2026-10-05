import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationProblem {
  denied,
  deniedForever,
  disabled,
  unsupported,
  timeout,
  unavailable,
}

class LocationFailure implements Exception {
  const LocationFailure(this.problem);
  final LocationProblem problem;
  String get message => switch (problem) {
    LocationProblem.denied =>
      'Localisation refusée. La carte reste accessible.',
    LocationProblem.deniedForever => 'Localisation bloquée. Autorisez-la dans les réglages de l’application ou du navigateur.',
    LocationProblem.disabled =>
      'Le service de localisation est désactivé. Activez-le dans les réglages.',
    LocationProblem.unsupported => 'La localisation n’est pas prise en charge sur cette plateforme. La carte reste accessible.',
    LocationProblem.timeout =>
      'Position introuvable dans le délai imparti. Réessayez à l’extérieur.',
    LocationProblem.unavailable =>
      'Position indisponible. Vérifiez la localisation et votre connexion.',
  };
}

abstract interface class LocationService {
  Future<LatLng> locate();
  Future<bool> openSettings({required bool locationSettings});
}

class DeviceLocationService implements LocationService {
  @override
  Future<LatLng> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationFailure(LocationProblem.disabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !kIsWeb) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationFailure(LocationProblem.deniedForever);
      }
      if (permission == LocationPermission.denied && !kIsWeb) {
        throw const LocationFailure(LocationProblem.denied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      ).timeout(const Duration(seconds: 18));
      return LatLng(position.latitude, position.longitude);
    } on LocationFailure {
      rethrow;
    } on TimeoutException {
      throw const LocationFailure(LocationProblem.timeout);
    } on PermissionDeniedException {
      throw const LocationFailure(LocationProblem.denied);
    } on LocationServiceDisabledException {
      throw const LocationFailure(LocationProblem.disabled);
    } catch (_) {
      throw const LocationFailure(LocationProblem.unavailable);
    }
  }

  @override
  Future<bool> openSettings({required bool locationSettings}) async {
    if (kIsWeb) return false;
    try {
      return locationSettings
          ? await Geolocator.openLocationSettings()
          : await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}
