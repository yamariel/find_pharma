/// Une ligne de stock : "la pharmacie X a N boîtes du médicament Y à P FCFA".
class InventoryItem {
  final String pharmacyId;
  final String medicineId;
  final String medicineName;
  final String dci;
  final int quantity;
  final int price; // en FCFA (entier = pas de problème d'arrondi)
  final DateTime updatedAt;
  final String updatedBy;

  /// Nom de la pharmacie (dénormalisé dans l'inventaire pour l'affichage).
  final String pharmacyName;

  /// Distance en km. Non stockée : calculée côté app avec la position du client.
  final double? distanceKm;

  const InventoryItem({
    required this.pharmacyId,
    required this.medicineId,
    required this.medicineName,
    required this.dci,
    required this.quantity,
    required this.price,
    required this.updatedAt,
    required this.updatedBy,
    this.pharmacyName = '',
    this.distanceKm,
  });

  bool get inStock => quantity > 0;

  /// Sert au badge "Vérifié il y a 3h" ou "Disponibilité non confirmée".
  bool isFresh({Duration maxAge = const Duration(hours: 24)}) =>
      DateTime.now().difference(updatedAt) <= maxAge;

  Duration get age => DateTime.now().difference(updatedAt);
}
