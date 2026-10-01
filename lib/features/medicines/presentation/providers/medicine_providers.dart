import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/medicine_firestore_datasource.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/usecases/medicine_usecases.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final medicineDatasourceProvider = Provider(
    (ref) => MedicineFirestoreDatasource(ref.watch(firestoreProvider)));

final medicineRepositoryProvider = Provider<MedicineRepository>(
    (ref) => MedicineRepositoryImpl(ref.watch(medicineDatasourceProvider)));

final searchMedicinesUseCaseProvider = Provider(
    (ref) => SearchMedicines(ref.watch(medicineRepositoryProvider)));

final genericAlternativesUseCaseProvider = Provider(
    (ref) => GetGenericAlternatives(ref.watch(medicineRepositoryProvider)));

final watchStockUseCaseProvider = Provider(
    (ref) => WatchPharmaciesWithStock(ref.watch(medicineRepositoryProvider)));

final addMedicineUseCaseProvider =
    Provider((ref) => AddMedicine(ref.watch(medicineRepositoryProvider)));

final adjustStockUseCaseProvider =
    Provider((ref) => AdjustStock(ref.watch(medicineRepositoryProvider)));

class MedicineSearchNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async => []; // état initial : aucun résultat

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(searchMedicinesUseCaseProvider)(query));
  }
}

final medicineSearchProvider =
    AsyncNotifierProvider<MedicineSearchNotifier, List<Medicine>>(
        MedicineSearchNotifier.new);

/// Alternatives génériques d'un médicament donné (cache automatique par médicament).
final genericAlternativesProvider =
    FutureProvider.family<List<Medicine>, Medicine>((ref, medicine) {
  return ref.watch(genericAlternativesUseCaseProvider)(medicine);
});

final pharmaciesWithStockProvider =
    StreamProvider.family<List<InventoryItem>, String>((ref, medicineId) {
  return ref.watch(watchStockUseCaseProvider)(medicineId);
});

/// Mise à jour du stock côté pharmacie (bouton "vendre" / "réapprovisionner").
class StockActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> adjust({
    required String pharmacyId,
    required Medicine medicine,
    required int delta,
    required String userId,
    required String reason,
    int? newPrice,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(adjustStockUseCaseProvider)(
          pharmacyId: pharmacyId,
          medicine: medicine,
          delta: delta,
          userId: userId,
          reason: reason,
          newPrice: newPrice,
        ));
  }
}

final stockActionProvider =
    AsyncNotifierProvider<StockActionNotifier, void>(StockActionNotifier.new);
