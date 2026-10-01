import '../entities/inventory_item.dart';
import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

class SearchMedicines {
  final MedicineRepository _repo;
  const SearchMedicines(this._repo);

  Future<List<Medicine>> call(String query) {
    final q = query.trim();
    if (q.length < 2) return Future.value([]); // évite des requêtes inutiles
    return _repo.searchMedicines(q);
  }
}

class GetGenericAlternatives {
  final MedicineRepository _repo;
  const GetGenericAlternatives(this._repo);

  Future<List<Medicine>> call(Medicine medicine) =>
      _repo.getGenericAlternatives(medicine);
}

class WatchPharmaciesWithStock {
  final MedicineRepository _repo;
  const WatchPharmaciesWithStock(this._repo);

  Stream<List<InventoryItem>> call(String medicineId) =>
      _repo.watchPharmaciesWithStock(medicineId);
}

class AddMedicine {
  final MedicineRepository _repo;
  const AddMedicine(this._repo);

  Future<void> call(Medicine medicine) {
    if (medicine.name.trim().isEmpty || medicine.dci.trim().isEmpty) {
      throw ArgumentError('Nom et DCI obligatoires.');
    }
    return _repo.addMedicine(medicine);
  }
}

class AdjustStock {
  final MedicineRepository _repo;
  const AdjustStock(this._repo);

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
