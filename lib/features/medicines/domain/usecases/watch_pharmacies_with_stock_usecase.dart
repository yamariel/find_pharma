import '../entities/inventory_item.dart';
import '../repositories/medicine_repository.dart';

/// Flux temps réel des pharmacies qui ont ce médicament en stock.
class WatchPharmaciesWithStockUsecase {
  final MedicineRepository _repo;
  const WatchPharmaciesWithStockUsecase(this._repo);

  Stream<List<InventoryItem>> call(String medicineId) =>
      _repo.watchPharmaciesWithStock(medicineId);
}
