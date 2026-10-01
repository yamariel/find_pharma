import 'package:latlong2/latlong.dart';

enum OpeningStatus { open, closed, unknown }

enum MedicineAvailability { available, unavailable, unknown }

/// Public projection only. Coordinates are WGS84, latitude then longitude.
class MapPharmacy {
  MapPharmacy({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.opening = OpeningStatus.unknown,
    List<String>? presentSellerNames,
    this.availability = MedicineAvailability.unknown,
    this.priceLabel,
  }) : presentSellerNames = presentSellerNames == null
           ? null
           : List.unmodifiable(presentSellerNames) {
    if (id.isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Identifiant et nom requis.');
    }
    validateCoordinates(latitude, longitude);
  }

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final OpeningStatus opening;

  /// null = presence unknown; [] = no seller declared present.
  final List<String>? presentSellerNames;
  final MedicineAvailability availability;

  /// Public selling price formatted by the business module, including currency.
  /// null means unknown; do not derive it from costs or stock data.
  final String? priceLabel;
  LatLng get point => LatLng(latitude, longitude);
}

class MedicineContext {
  const MedicineContext({required this.id, required this.label});
  final String id;
  final String label;
}

void validateCoordinates(double latitude, double longitude) {
  if (!latitude.isFinite ||
      !longitude.isFinite ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180) {
    throw ArgumentError('Coordonnées WGS84 invalides.');
  }
}
