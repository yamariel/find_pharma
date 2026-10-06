import '../entities/pharmacy.dart';

/// Contrat d'accès aux pharmacies, tel que le domaine en a besoin.
///
/// C'est le domaine qui déclare l'interface, et la couche data qui la
/// réalise. Cette inversion est le coeur de la Clean Architecture : les use
/// cases dépendent de ce fichier, jamais de Firestore.
///
/// Toutes les méthodes lèvent une Failure en cas d'échec. Aucune ne renvoie
/// null pour signaler une erreur, et aucune ne laisse fuir une exception
/// technique de la couche data.
abstract interface class PharmacyRepository {
  /// Toutes les pharmacies connues.
  ///
  /// Le tri par distance et le filtrage sur l'ouverture ne sont pas faits
  /// ici : Firestore ne sait pas interroger un rayon géographique sans
  /// géohachage, et le calcul tient déjà dans l'entité. C'est le rôle des
  /// use cases.
  ///
  /// Lève une ServerFailure si la lecture échoue.
  Future<List<Pharmacy>> getPharmacies();

  /// La pharmacie portant cet identifiant.
  ///
  /// Lève une NotFoundFailure si aucun document ne correspond, une
  /// ServerFailure si la lecture échoue.
  Future<Pharmacy> getPharmacyById(String id);

  /// Crée la fiche si elle n'existe pas, la met à jour sinon.
  ///
  /// Lève une ServerFailure si l'écriture échoue.
  Future<void> savePharmacy(Pharmacy pharmacy);
}