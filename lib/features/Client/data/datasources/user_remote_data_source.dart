import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  UserRemoteDataSource(this.auth, this.firestore);

  // GET ONE CLIENT
  Future<UserEntity> getClient(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // GET ALL CLIENTS
  Future<List<UserEntity>> getAllClients() async {
    final snapshot = await firestore.collection('users')
        .where('role', isEqualTo: 'client')
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // UPDATE CLIENT
  Future<void> updateClient(UserEntity client) async {
    await firestore.collection('users').doc(client.uid).update({
      'nom': client.nom,
      'phone': client.phone,
      'adresse': client.adresse,
    });

    await auth.currentUser!.updateDisplayName(client.nom);

  }

  // DELETE CLIENT
  Future<void> deleteClient(String uid) async {
    await firestore.collection('users').doc(uid).delete();
  }
}
