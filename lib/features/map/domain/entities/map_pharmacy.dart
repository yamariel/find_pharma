import 'package:find_pharma/features/map/domain/entities/coordinates.dart';
import 'package:latlong2/latlong.dart';

/// Statut d'ouverture d'une pharmacie sur la carte.
enum OpeningStatus { open, closed, unknown }

/// Disponibilité d'un médicament dans une pharmacie.
enum MedicineAvailability { available, unavailable, unknown }

/// Projection d'une pharmacie destinée à l'affichage cartographique.
///
/// Coordonnées WGS84, latitude puis longitude.
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

  /// `null` = présence inconnue ; `[]` = aucun vendeur déclaré présent.
  final List<String>? presentSellerNames;
  final MedicineAvailability availability;

  /// Prix public formaté par le module métier, devise comprise.
  /// `null` = inconnu ; ne jamais le déduire des coûts ou du stock.
  final String? priceLabel;

  LatLng get point => LatLng(latitude, longitude);
}

/// Médicament recherché, transmis à la carte pour contextualiser l'affichage.
class MedicineContext {
  const MedicineContext({required this.id, required this.label});

  final String id;
  final String label;
}