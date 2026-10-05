import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/admin_entity.dart';

class AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AdminRemoteDataSource(this.firestore, this.auth);

  // CREATE ADMIN (invitation)

  Future<void> createAdmin(AdminEntity admin) async {
    try {
      // 1. Vérifier que l'utilisateur actuel est connecté
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('Vous devez être connecté.');
      }

      // 2. Appeler la fonction sécurisée côté serveur
      final callable = FirebaseFunctions.instance
          .httpsCallable('createAdmin');

      final result = await callable.call({
        'nom': admin.nom.trim(),
        'email': admin.email.trim().toLowerCase(),
      });

      debugPrint(
        'Administrateur créé : ${result.data['uid']}',
      );

      // 3. Envoyer un email de réinitialisation du mot de passe
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: admin.email.trim().toLowerCase(),
      );

      debugPrint(
        'Email de définition du mot de passe envoyé.',
      );
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('Erreur Cloud Function : ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: st);
      rethrow;
    } on FirebaseAuthException catch (e, st) {
      debugPrint('Erreur Firebase Auth : ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: st);
      rethrow;
    } catch (e, st) {
      debugPrint('Erreur createAdmin : $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  // READ ALL ADMINS
  Future<List<AdminEntity>> getAllAdmins() async {
    final snapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    return snapshot.docs
        .map((doc) => AdminEntity.fromMap(doc.id, doc.data()))
        .toList();
  }

  // READ ONE ADMIN
  Future<AdminEntity> getAdmin(String id) async {
    final doc = await firestore.collection('users').doc(id).get();
    return AdminEntity.fromMap(doc.id, doc.data()!);
  }

  // UPDATE ADMIN
  Future<void> updateAdmin(AdminEntity admin) async {
    await firestore.collection('users').doc(admin.id).update(admin.toMap());
  }

  // DELETE ADMIN
  Future<void> deleteAdmin(String id) async {
    await firestore.collection('users').doc(id).delete();
  }
}
