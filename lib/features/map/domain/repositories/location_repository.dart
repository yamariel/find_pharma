import 'package:latlong2/latlong.dart';

/// Contrat d'accès à la position de l'utilisateur.
///
/// Lève une LocationFailure quand la position ne peut pas être obtenue.
abstract interface class LocationRepository {
  /// Position courante de l'appareil.
  Future<LatLng> locate();

  /// Ouvre les réglages de localisation du système, ou ceux de l'application.
  ///
  /// Renvoie `false` si la plateforme ne le permet pas.
  Future<bool> openSettings({required bool locationSettings});
}