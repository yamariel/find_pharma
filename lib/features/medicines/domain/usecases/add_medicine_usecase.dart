import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

/// Ajout d'un médicament au catalogue global (côté admin).
class AddMedicineUsecase {
  final MedicineRepository _repo;
  const AddMedicineUsecase(this._repo);

  Future<void> call(Medicine medicine) {
    if (medicine.name.trim().isEmpty || medicine.dci.trim().isEmpty) {
      throw ArgumentError('Nom et DCI obligatoires.');
    }
    return _repo.addMedicine(medicine);
  }
}
