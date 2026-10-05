import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

/// Entrée ou sortie de stock d'une pharmacie.
/// delta > 0 : entrée (livraison) ; delta < 0 : sortie (vente).
class AdjustStockUsecase {
  final MedicineRepository _repo;
  const AdjustStockUsecase(this._repo);

  Future<void> call({
    required String pharmacyId,
    required Medicine medicine,
    required int delta,
    required String userId,
    required String reason,
    int? newPrice,
  }) {
    if (delta == 0) throw ArgumentError('La variation ne peut pas être 0.');
    return _repo.adjustStock(
      pharmacyId: pharmacyId,
      medicine: medicine,
      delta: delta,
      userId: userId,
      reason: reason,
      newPrice: newPrice,
    );
  }
}
