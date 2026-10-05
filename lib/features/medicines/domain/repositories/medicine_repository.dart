import '../entities/inventory_item.dart';
import '../entities/medicine.dart';

/// CONTRAT abstrait : dit CE QU'ON PEUT FAIRE, pas COMMENT.
/// UTILITÉ : les usecases dépendent de ce contrat, pas de Firestore.
/// On peut donc tester avec un faux repository, sans internet.
abstract class MedicineRepository {
  Future<List<Medicine>> searchMedicines(String query);

  /// Même DCI + même dosage + même forme, hors le médicament lui-même.
  Future<List<Medicine>> getGenericAlternatives(Medicine medicine);

  /// Flux temps réel des pharmacies qui ont ce médicament en stock.
  Stream<List<InventoryItem>> watchPharmaciesWithStock(String medicineId);

  Future<void> addMedicine(Medicine medicine);

  /// delta > 0 : entrée de stock, delta < 0 : vente / sortie.
  Future<void> adjustStock({
    required String pharmacyId,
    required Medicine medicine,
    required int delta,
    required String userId,
    required String reason, // 'sale' | 'restock' | 'adjustment'
    int? newPrice,
  });
}
