import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Client/data/models/user_model.dart';
import '../../../Client/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource(this._auth, this._firestore);

  // STREAM : écoute l'état de connexion Firebase
  Stream<UserEntity?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};

      return UserModel(
        uid: user.uid,
        nom: data['nom'] ?? user.displayName ?? '',
        email: user.email ?? data['email'] ?? '',
        role: data['role'] ?? 'client',
        phone: data['phone'],
        adresse: data['adresse'],
        token: data['token'],
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
    final uid = user.uid;

    // 1️⃣ Vérifier si un document Firestore existe déjà pour cet UID
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      // 2️⃣ Première connexion → retrouver l'admin via son email
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (query.docs.isNotEmpty) {
        final oldDoc = query.docs.first;
        final oldData = oldDoc.data();

        // 3️⃣ Associer l'UID FirebaseAuth au document Firestore existant
        await _firestore.collection('users').doc(uid).set(oldData);

        // 4️⃣ Supprimer l'ancien document Firestore (sans UID)
        await _firestore.collection('users').doc(oldDoc.id).delete();
      } else {
        // 5️⃣ Cas improbable : aucun document Firestore trouvé
        // On crée un document minimal
        await _firestore.collection('users').doc(uid).set({
          'nom': user.displayName ?? '',
          'email': user.email,
          'role': 'client',
          'phone': null,
          'adresse': null,
          'token': null,
        });
      }
    }

    // 6️⃣ Lire le document final
    final finalDoc = await _firestore.collection('users').doc(uid).get();
    final data = finalDoc.data()!;

    return UserModel(
      uid: uid,
      nom: data['nom'],
      email: data['email'],
      role: data['role'],
      phone: data['phone'],
      adresse: data['adresse'],
      token: data['token'],
    );
  }

  // SIGNUP CLIENT
  Future<UserEntity> signUpClient(
      String name, String email, String password) async {

    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user!;
    await user.updateDisplayName(name);

    final userModel = UserModel(
      uid: user.uid,
      nom: name,
      email: user.email ?? '',
      role: 'client',
      phone: null,
      adresse: null,
      token: null,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    return userModel;
  }

  // SIGNUP PHARMACY
  Future<UserEntity> signUpPharmacy(
      String name, String email, String password) async {

    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user!;
    await user.updateDisplayName(name);

    final userModel = UserModel(
      uid: user.uid,
      nom: name,
      email: user.email ?? '',
      role: 'pharmacy',
      phone: null,
      adresse: null,
      token: null,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    return userModel;
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
