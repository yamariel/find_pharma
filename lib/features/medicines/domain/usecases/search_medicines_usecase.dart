import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

/// Rechercher un médicament par nom.
/// Règle métier : moins de 2 lettres = aucune requête envoyée (économise les lectures Firestore).
class SearchMedicinesUsecase {
  final MedicineRepository _repo;
  const SearchMedicinesUsecase(this._repo);

  Future<List<Medicine>> call(String query) {
    final q = query.trim();
    if (q.length < 2) return Future.value([]);
    return _repo.searchMedicines(q);
  }
}
