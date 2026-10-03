import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_pharma/core/errors/medicine_exceptions.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_remote_data_source.dart';

/// IMPLÉMENTATION du contrat avec Firestore.
/// UTILITÉ : transforme les erreurs techniques en MedicineException lisibles.
class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource _ds;
  MedicineRepositoryImpl(this._ds);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on MedicineException {
      rethrow; // déjà une erreur métier
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const MedicineException("Vous n'avez pas l'autorisation.");
      }
      if (e.code == 'unavailable') {
        throw const MedicineException('Pas de connexion. Réessayez.');
      }
      throw MedicineException('Erreur serveur (${e.code}).');
    }
  }

  @override
  Future<List<Medicine>> searchMedicines(String query) =>
      _guard(() => _ds.search(query));

  @override
  Future<List<Medicine>> getGenericAlternatives(Medicine medicine) =>
      _guard(() => _ds.genericAlternatives(medicine));

  @override
  Stream<List<InventoryItem>> watchPharmaciesWithStock(String medicineId) =>
      _ds.watchStock(medicineId);

  @override
  Future<void> addMedicine(Medicine medicine) =>
      _guard(() => _ds.add(medicine));

  @override
  Future<void> adjustStock({
    required String pharmacyId,
    required Medicine medicine,
    required int delta,
    required String userId,
    required String reason,
    int? newPrice,
  }) =>
      _guard(() => _ds.adjustStock(
            pharmacyId: pharmacyId,
            medicine: medicine,
            delta: delta,
            userId: userId,
            reason: reason,
            newPrice: newPrice,
          ));
}
