import 'package:find_pharma/core/errors/exceptions.dart';
import 'package:find_pharma/core/errors/failures.dart';
import 'package:find_pharma/features/pharmacies/data/datasources/pharmacy_remote_data_source.dart';
import 'package:find_pharma/features/pharmacies/data/models/pharmacy_model.dart';
import 'package:find_pharma/features/pharmacies/data/repositories/pharmacy_repository_impl.dart';
import 'package:find_pharma/features/pharmacies/domain/entities/pharmacy.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux datasource écrit à la main.
///
/// Il réalise le contrat `PharmacyRemoteDataSource` sans toucher Firestore :
/// pas de mocktail, pas de fake_cloud_firestore, aucune dépendance ajoutée au
/// pubspec partagé. C'est le bénéfice concret d'avoir abstrait le datasource.
class _FakePharmacyRemoteDataSource implements PharmacyRemoteDataSource {
  _FakePharmacyRemoteDataSource({
    this.pharmacies = const <PharmacyModel>[],
    this.pharmacyById,
    this.errorToThrow,
  });

  final List<PharmacyModel> pharmacies;
  final PharmacyModel? pharmacyById;

  /// Typé `Object?` et non `Exception?` : on ne présume pas que les
  /// exceptions du projet implémentent `Exception`.
  final Object? errorToThrow;

  /// Ce que le repository a réellement transmis — l'assertion du test
  /// d'écriture porte dessus.
  PharmacyModel? savedPharmacy;

  @override
  Future<List<PharmacyModel>> fetchPharmacies() async {
    final Object? error = errorToThrow;
    if (error != null) {
      throw error;
    }
    return pharmacies;
  }

  @override
  Future<PharmacyModel?> fetchPharmacyById(String id) async {
    final Object? error = errorToThrow;
    if (error != null) {
      throw error;
    }
    return pharmacyById;
  }

  @override
  Future<void> savePharmacy(PharmacyModel pharmacy) async {
    final Object? error = errorToThrow;
    if (error != null) {
      throw error;
    }
    savedPharmacy = pharmacy;
  }
}

PharmacyModel buildPharmacyModel({String id = 'ph_akwa_001'}) {
  return PharmacyModel(
    id: id,
    name: 'Pharmacie du Centre',
    district: 'Akwa',
    latitude: 4.0511,
    longitude: 9.7085,
    phone: '+237690000001',
    email: 'contact@pharmacieducentre.cm',
  );
}

void main() {
  group('getPharmacies', () {
    test('renvoie les pharmacies fournies par le datasource', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(
          pharmacies: <PharmacyModel>[
            buildPharmacyModel(id: 'ph_001'),
            buildPharmacyModel(id: 'ph_002'),
          ],
        ),
      );

      final List<Pharmacy> result = await repository.getPharmacies();

      expect(result, hasLength(2));
      expect(result.first.id, 'ph_001');
    });

    test('renvoie une liste vide quand la collection est vide', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(),
      );

      expect(await repository.getPharmacies(), isEmpty);
    });

    test('renvoie une liste réellement typée Pharmacy', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(
          pharmacies: <PharmacyModel>[buildPharmacyModel()],
        ),
      );

      final List<Pharmacy> result = await repository.getPharmacies();

      // Si le repository renvoyait directement la List<PharmacyModel> du
      // datasource, cet ajout lèverait un TypeError à l'exécution : la
      // covariance de Dart laisse passer l'erreur à la compilation.
      expect(
        () => result.add(
          const Pharmacy(
            id: 'ph_manuel',
            name: 'Pharmacie ajoutée à la main',
            district: 'Bonanjo',
            latitude: 4.0469,
            longitude: 9.6900,
            phone: '+237690000009',
            email: 'manuel@findpharma.cm',
          ),
        ),
        returnsNormally,
      );
    });

    test('traduit ServerException en ServerFailure', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(
          errorToThrow: ServerException('Firestore injoignable'),
        ),
      );

      await expectLater(
        repository.getPharmacies(),
        throwsA(
          isA<ServerFailure>().having(
            (ServerFailure failure) => failure.message,
            'message',
            contains('Firestore injoignable'),
          ),
        ),
      );
    });
  });

  group('getPharmacyById', () {
    test('renvoie la pharmacie trouvée', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(
          pharmacyById: buildPharmacyModel(id: 'ph_007'),
        ),
      );

      final Pharmacy result = await repository.getPharmacyById('ph_007');

      expect(result.id, 'ph_007');
    });

    test('lève NotFoundFailure quand le document est absent', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(),
      );

      await expectLater(
        repository.getPharmacyById('ph_inconnu'),
        throwsA(
          isA<NotFoundFailure>().having(
            (NotFoundFailure failure) => failure.message,
            'message',
            contains('ph_inconnu'),
          ),
        ),
      );
    });

    test('traduit ServerException en ServerFailure', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(
          errorToThrow: ServerException('Firestore injoignable'),
        ),
      );

      await expectLater(
        repository.getPharmacyById('ph_007'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('traduit ValidationException en ServerFailure', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(
          errorToThrow: ValidationException('champ phone manquant'),
        ),
      );

      await expectLater(
        repository.getPharmacyById('ph_007'),
        throwsA(
          isA<ServerFailure>().having(
            (ServerFailure failure) => failure.message,
            'message',
            contains('ph_007'),
          ),
        ),
      );
    });
  });

  group('savePharmacy', () {
    test('convertit l entité en modèle avant de la transmettre', () async {
      final _FakePharmacyRemoteDataSource dataSource =
          _FakePharmacyRemoteDataSource();
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        dataSource,
      );

      const Pharmacy entity = Pharmacy(
        id: 'ph_bonanjo_002',
        name: 'Pharmacie de Bonanjo',
        district: 'Bonanjo',
        latitude: 4.0469,
        longitude: 9.6900,
        phone: '+237690000003',
        email: 'bonanjo@findpharma.cm',
      );

      await repository.savePharmacy(entity);

      expect(dataSource.savedPharmacy, isA<PharmacyModel>());
      expect(dataSource.savedPharmacy, equals(entity));
    });

    test('traduit ServerException en ServerFailure', () async {
      final PharmacyRepositoryImpl repository = PharmacyRepositoryImpl(
        _FakePharmacyRemoteDataSource(
          errorToThrow: ServerException('Ecriture refusée'),
        ),
      );

      await expectLater(
        repository.savePharmacy(buildPharmacyModel()),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}