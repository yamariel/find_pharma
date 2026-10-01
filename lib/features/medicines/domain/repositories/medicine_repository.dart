import '../entities/inventory_item.dart';
import '../entities/medicine.dart';
abstract class MedicineRepository {
  Future<List<Medicine>> searchMedicines(String query);

  /// Même DCI + même dosage + même forme, hors le médicament lui-même.
  Future<List<Medicine>> getGenericAlternatives(Medicine medicine);

  /// Flux temps réel des pharmacies qui ont ce médicament en stock.
  Stream<List<InventoryItem>> watchPharmaciesWithStock(String medicineId);

  Future<void> addMedicine(Medicine medicine);

  Future<void> adjustStock({
    required String pharmacyId,
    required Medicine medicine,
    required int delta,
    required String userId,
    required String reason, // 'sale' | 'restock' | 'adjustment'
    int? newPrice,
  });
}
