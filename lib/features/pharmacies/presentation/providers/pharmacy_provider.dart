import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/geo/user_position.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/datasources/pharmacy_remote_data_source.dart';
import '../../data/repositories/pharmacy_repository_impl.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../../domain/usecases/get_pharmacies_usecase.dart';

final Provider<PharmacyRemoteDataSource> pharmacyRemoteDataSourceProvider =
    Provider<PharmacyRemoteDataSource>(
      (Ref ref) => PharmacyRemoteDataSourceImpl(ref.watch(firestoreProvider)),
    );

/// Exposé sous le type du contrat : l'interface ne peut pas atteindre
/// Firestore, même par accident.
final Provider<PharmacyRepository> pharmacyRepositoryProvider =
    Provider<PharmacyRepository>(
      (Ref ref) =>
          PharmacyRepositoryImpl(ref.watch(pharmacyRemoteDataSourceProvider)),
    );

final Provider<GetPharmaciesUseCase> getPharmaciesUseCaseProvider =
    Provider<GetPharmaciesUseCase>(
      (Ref ref) => GetPharmaciesUseCase(ref.watch(pharmacyRepositoryProvider)),
    );

/// Liste consommée par l'interface. Les Failures remontent en
/// `AsyncValue.error`, sans try/catch dans les widgets.
final FutureProvider<List<Pharmacy>> pharmaciesProvider =
    FutureProvider<List<Pharmacy>>((Ref ref) {
      final GetPharmaciesUseCase getPharmacies = ref.watch(
        getPharmaciesUseCaseProvider,
      );
      return getPharmacies(from: ref.watch(userPositionProvider));
    });