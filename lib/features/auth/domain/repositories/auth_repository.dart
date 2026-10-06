import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';


abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();

  Future<UserEntity?> signIn({
    required String email,
    required String password,
  });

  Future<UserEntity> registerClientUsecase({
    required String nom,
    required String email,
    required String password,
    String? phone,
    String? adresse,
  });

  Future<UserEntity> registerPharmacyUsecase({
    required String nom,
    required String email,
    required String password,
  });

  Future<void> logoutUsecase();

  Future<UserEntity?> signInWithGoogle();

  Future<UserEntity?> signUpWithGoogle();

}
