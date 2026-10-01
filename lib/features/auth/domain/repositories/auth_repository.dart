import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';

import '../../../pharmacies/domain/entities/pharmacy.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();

  Future<UserEntity?> signIn({
    required String email,
    required String password,
  });

  Future<UserEntity> registerClientUsecase({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? phone,
    String? adresse,
  });

  // Future<Pharmacy> registerPharmacieUsecase({
  //   required String nom,
  //   required String responsable,
  //   required String contact,
  //   required String localisation,
  //   required String email,
  //   required String password,
  //   required String verificationDocumentPath, // local file path
  // });

  Future<void> logoutUsecase();
}
