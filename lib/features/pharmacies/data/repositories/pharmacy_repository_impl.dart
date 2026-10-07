import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_remote_data_source.dart';
import '../models/pharmacy_model.dart';

/// Réalise le contrat du domaine à partir du datasource Firestore.
///
/// Sa seule responsabilité est la traduction : exceptions techniques vers
/// Failures métier, modèles vers entités, absence de document vers
/// NotFoundFailure. Aucune règle métier ici.
class PharmacyRepositoryImpl implements PharmacyRepository {
  const PharmacyRepositoryImpl(this._remoteDataSource);

  final PharmacyRemoteDataSource _remoteDataSource;

  @override
  Future<List<Pharmacy>> getPharmacies() async {
    try {
      final List<PharmacyModel> models =
          await _remoteDataSource.fetchPharmacies();
      return List<Pharmacy>.of(models);
    } on ServerException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<Pharmacy> getPharmacyById(String id) async {
    final PharmacyModel? model;
    try {
      model = await _remoteDataSource.fetchPharmacyById(id);
    } on ServerException catch (error) {
      throw ServerFailure(error.message);
    } on ValidationException catch (error) {
      throw ServerFailure('Fiche pharmacie $id illisible : ${error.message}');
    }

    if (model == null) {
      throw NotFoundFailure('Aucune pharmacie avec cet identifiant : $id.');
    }
    return model;
  }

  @override
  Future<void> savePharmacy(Pharmacy pharmacy) async {
    try {
      await _remoteDataSource.savePharmacy(PharmacyModel.fromEntity(pharmacy));
    } on ServerException catch (error) {
      throw ServerFailure(error.message);
    }
  }
}