
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../pharmacies/domain/entities/pharmacy.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<UserEntity?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return UserEntity.fromMap(doc.data()!, user.uid);
    });
  }

  @override
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (!doc.exists) return null;

    return UserEntity.fromMap(doc.data()!, cred.user!.uid);
  }

  @override
  Future<UserEntity> registerClientUsecase({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? phone,
    String? adresse,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserEntity(
      uid: cred.user!.uid,
      nom: nom,
      prenom: prenom,
      email: email,
      role: 'client',
      phone: phone,
      adresse: adresse,
    );

    await _db.collection('users').doc(user.uid).set(user.toMap());

    return user;
  }

  // @override
  // Future<Pharmacy> signUpPharmacy({
  //   required String nom,
  //   required String responsable,
  //   required String contact,
  //   required String localisation,
  //   required String email,
  //   required String password,
  //   required String verificationDocumentPath,
  // }) async {
  //   final cred = await _auth.createUserWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  //
  //   // Upload du document
  //   final file = File(verificationDocumentPath);
  //   final ref = _storage
  //       .ref('pharmacy_docs/${cred.user!.uid}/verification.pdf');
  //   final upload = await ref.putFile(file);
  //   final url = await upload.ref.getDownloadURL();
  //
  //   final pharmacy = Pharmacy(
  //     uid: cred.user!.uid,
  //     nom: nom,
  //     responsable: responsable,
  //     contact: contact,
  //     localisation: localisation,
  //     verificationDocument: url,
  //     isVerified: false,
  //     createdAt: DateTime.now(),
  //   );
  //
  //   await _db.collection('pharmacies').doc(pharmacy.uid).set(pharmacy.toMap());
  //
  //   // On crée aussi un user minimal pour la connexion
  //   await _db.collection('users').doc(pharmacy.uid).set({
  //     'email': email,
  //     'role': 'pharmacy',
  //     'nom': nom,
  //     'prenom': responsable,
  //   });
  //
  //   return pharmacy;
  // }

  @override
  Future<void> logoutUsecase() => _auth.signOut();
}
