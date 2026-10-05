import '../models/map_pharmacy.dart';

/// Deliberately fictional public projections, never written to Firebase.
final demoPharmacies = List<MapPharmacy>.unmodifiable([
  MapPharmacy(
    id: 'demo-1',
    name: 'Pharmacie Démo Gombe',
    latitude: -4.305,
    longitude: 15.305,
    address: 'Adresse fictive — Gombe',
    opening: OpeningStatus.open,
    presentSellerNames: ['Vendeur Démo'],
    availability: MedicineAvailability.available,
    priceLabel: '2 500 CDF (fictif)',
  ),
  MapPharmacy(
    id: 'demo-2',
    name: 'Pharmacie Démo Centre',
    latitude: -4.325,
    longitude: 15.322,
    address: 'Adresse fictive — Centre',
    opening: OpeningStatus.closed,
    availability: MedicineAvailability.available,
  ),
  MapPharmacy(
    id: 'demo-3',
    name: 'Pharmacie Démo voisine',
    latitude: -4.325,
    longitude: 15.322,
    availability: MedicineAvailability.available,
  ),
  MapPharmacy(
    id: 'demo-4',
    name: 'Pharmacie Démo Sud',
    latitude: -4.35,
    longitude: 15.31,
  ),
]);
