import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

/// Alternatives équivalentes à un médicament : même DCI, même dosage, même forme.
/// Alimente la section "Alternatives économiques".
class GetCheaperAlternativeUsecase {
  final MedicineRepository _repo;
  const GetCheaperAlternativeUsecase(this._repo);

  Future<List<Medicine>> call(Medicine medicine) =>
      _repo.getGenericAlternatives(medicine);
}
