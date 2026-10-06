import '../../../Client/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Stream<UserEntity?> authStateChanges() {
    return remote.authStateChanges();
  }

  @override
  Future<void> logoutUsecase() {
    return remote.signOut();
  }

  @override
  Future<UserEntity> signInWithGoogle() {
    return remote.signInWithGoogle();
  }

  @override
  Future<UserEntity?> signUpWithGoogle() {
    return remote.signInWithGoogle();
  }

  @override
  Future<UserEntity> registerClientUsecase({required String nom, required String email, required String password, String? phone, String? adresse}) {
    return remote.signUpClient(nom, email, password);
  }

  @override
  Future<UserEntity> registerPharmacyUsecase({
    required String nom,
    required String email,
    required String password,
  }) {
    return remote.signUpPharmacy(nom, email, password);
  }

  @override
  Future<UserEntity?> signIn({required String email, required String password}) {
    return remote.signIn(email, password);
  }
}
