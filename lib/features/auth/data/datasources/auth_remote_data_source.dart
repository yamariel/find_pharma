import 'package:firebase_auth/firebase_auth.dart';
import '../../../Client/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;

  AuthRemoteDataSource(this._auth);

  // STREAM : écoute l'état de connexion Firebase
  Stream<UserEntity?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;

      return UserEntity(
        uid: user.uid,
        nom: user.displayName ?? '',
        email: user.email ?? '',
        role: 'client', // tu peux adapter selon Firestore
      );
    });
  }

  // LOGIN EMAIL
  Future<UserEntity> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user!;
    return UserEntity(
      uid: user.uid,
      nom: user.displayName ?? '',
      email: user.email ?? '',
      role: 'client',
    );
  }

  // SIGNUP CLIENT
  Future<UserEntity> signUpClient(
      String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.user!.updateDisplayName(name);

    final user = result.user!;
    return UserEntity(
      uid: user.uid,
      nom: name,
      email: user.email ?? '',
      role: 'client',
    );
  }

  // SIGNUP PHARMACY
  Future<UserEntity> signUpPharmacy(
      String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.user!.updateDisplayName(name);

    final user = result.user!;
    return UserEntity(
      uid: user.uid,
      nom: name,
      email: user.email ?? '',
      role: 'pharmacy',
    );
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserEntity> signInWithGoogle() async {
    throw UnimplementedError();
  }

  Future<UserEntity> signUpWithGoogle() async {
    throw UnimplementedError();
  }
}
