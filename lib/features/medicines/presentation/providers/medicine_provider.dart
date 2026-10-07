import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';

export '../../../../core/providers/firebase_providers.dart' show firestoreProvider;

import '../../data/datasources/medicine_remote_data_source.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../../domain/usecases/get_cheaper_alternative_usecase.dart';
import '../../domain/usecases/search_medicines_usecase.dart';
import '../../domain/usecases/watch_pharmacies_with_stock_usecase.dart';

final medicineDatasourceProvider = Provider(
  (ref) => MedicineRemoteDataSource(ref.watch(firestoreProvider)),
);

final medicineRepositoryProvider = Provider<MedicineRepository>(
  (ref) => MedicineRepositoryImpl(ref.watch(medicineDatasourceProvider)),
);

final searchMedicinesUseCaseProvider = Provider(
  (ref) => SearchMedicinesUsecase(ref.watch(medicineRepositoryProvider)),
);

final genericAlternativesUseCaseProvider = Provider(
  (ref) => GetCheaperAlternativeUsecase(ref.watch(medicineRepositoryProvider)),
);

final watchStockUseCaseProvider = Provider(
  (ref) =>
      WatchPharmaciesWithStockUsecase(ref.watch(medicineRepositoryProvider)),
);

final addMedicineUseCaseProvider = Provider(
  (ref) => AddMedicineUsecase(ref.watch(medicineRepositoryProvider)),
);

final adjustStockUseCaseProvider = Provider(
  (ref) => AdjustStockUsecase(ref.watch(medicineRepositoryProvider)),
);

// ───────── 2. ÉTAT DE L'UI ─────────

/// Recherche : l'écran appelle `search('para')`, et écoute l'état
/// (loading / data / error) sans gérer lui-même les try/catch.
class MedicineSearchNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async => []; // état initial : aucun résultat

  Future<void> search(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(searchMedicinesUseCaseProvider)(normalizedQuery),
    );
  }
}

final medicineSearchProvider =
    AsyncNotifierProvider<MedicineSearchNotifier, List<Medicine>>(
      MedicineSearchNotifier.new,
    );

/// Alternatives génériques d'un médicament donné (cache automatique par médicament).
final genericAlternativesProvider =
    FutureProvider.family<List<Medicine>, Medicine>((ref, medicine) {
      return ref.watch(genericAlternativesUseCaseProvider)(medicine);
    });

/// Pharmacies ayant le médicament, en TEMPS RÉEL (Stream).
/// Si une pharmacie vend sa dernière boîte, la liste se met à jour toute seule.
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
    state = await AsyncValue.guard(
      () => ref.read(adjustStockUseCaseProvider)(
        pharmacyId: pharmacyId,
        medicine: medicine,
        delta: delta,
        userId: userId,
        reason: reason,
        newPrice: newPrice,
      ),
    );
  }
}

final stockActionProvider = AsyncNotifierProvider<StockActionNotifier, void>(
  StockActionNotifier.new,
);
