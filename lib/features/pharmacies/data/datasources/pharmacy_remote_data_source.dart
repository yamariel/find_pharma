import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/pharmacy_model.dart';

/// Accès brut à la collection Firestore des pharmacies.
///
/// Cette couche ne connaît que des modèles et des exceptions techniques.
/// La traduction en entités et en Failures est le travail du repository.
abstract interface class PharmacyRemoteDataSource {
  /// Tous les documents exploitables de la collection.
  ///
  /// Lève une ServerException si Firestore est injoignable.
  Future<List<PharmacyModel>> fetchPharmacies();

  /// Le document portant cet identifiant, ou null s'il n'existe pas.
  ///
  /// Lève une ServerException si Firestore est injoignable, une
  /// ValidationException si le document existe mais est malformé.
  Future<PharmacyModel?> fetchPharmacyById(String id);

  /// Crée le document s'il n'existe pas, le met à jour sinon.
  ///
  /// Lève une ServerException si l'écriture échoue.
  Future<void> savePharmacy(PharmacyModel pharmacy);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  const PharmacyRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  static const String collectionPath = 'pharmacies';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  @override
  Future<List<PharmacyModel>> fetchPharmacies() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _collection.get();
    } on FirebaseException catch (error) {
      throw ServerException(
        'Lecture des pharmacies impossible (${error.code}).',
      );
    }

    // Un document malformé ne doit pas vider la liste entière : on l'écarte
    // et on journalise. Un patient qui cherche une pharmacie à 2h du matin
    // doit voir les 47 fiches valides, pas un écran vide à cause d'une.
    final List<PharmacyModel> pharmacies = <PharmacyModel>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      try {
        pharmacies.add(
          PharmacyModel.fromFirestore(document.data(), document.id),
        );
      } on ValidationException catch (error) {
        developer.log(
          'Document pharmacie ignoré : ${error.message}',
          name: 'PharmacyRemoteDataSource',
        );
      }
    }
    return pharmacies;
  }

  @override
  Future<PharmacyModel?> fetchPharmacyById(String id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> document =
          await _collection.doc(id).get();

      // data() renvoie null exactement quand le document n'existe pas :
      // inutile de tester exists en plus.
      final Map<String, dynamic>? data = document.data();
      if (data == null) {
        return null;
      }
      return PharmacyModel.fromFirestore(data, document.id);
    } on FirebaseException catch (error) {
      throw ServerException(
        'Lecture de la pharmacie $id impossible (${error.code}).',
      );
    }
  }

  @override
  Future<void> savePharmacy(PharmacyModel pharmacy) async {
    try {
      await _collection
          .doc(pharmacy.id)
          .set(pharmacy.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw ServerException(
        'Écriture de la pharmacie ${pharmacy.id} impossible (${error.code}).',
      );
    }
  }
}