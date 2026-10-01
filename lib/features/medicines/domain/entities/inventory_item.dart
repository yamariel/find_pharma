class InventoryItem {
  final String pharmacyId;
  final String medicineId;
  final String medicineName;
  final String dci;
  final int quantity;
  final int price; // en FCFA (entier = pas de problème d'arrondi)
  final DateTime updatedAt;
  final String updatedBy;

  const InventoryItem({
    required this.pharmacyId,
    required this.medicineId,
    required this.medicineName,
    required this.dci,
    required this.quantity,
    required this.price,
    required this.updatedAt,
    required this.updatedBy,
  });

  bool get inStock => quantity > 0;
  bool isFresh({Duration maxAge = const Duration(hours: 24)}) =>
      DateTime.now().difference(updatedAt) <= maxAge;

  Duration get age => DateTime.now().difference(updatedAt);
}
