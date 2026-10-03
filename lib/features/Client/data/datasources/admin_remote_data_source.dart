import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_pharma/features/admin/domain/entities/admin_entity.dart';


class AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSource(this.firestore);

  // CREATE
  Future<void> createAdmin(AdminEntity admin) async {
    await firestore.collection('admins').add(admin.toMap());
  }

  // READ ALL
  Future<List<AdminEntity>> getAllAdmins() async {
    final snapshot = await firestore.collection('admins').get();
    return snapshot.docs
        .map((doc) => AdminEntity.fromMap(doc.id, doc.data()))
        .toList();
  }

  // READ ONE
  Future<AdminEntity> getAdmin(String id) async {
    final doc = await firestore.collection('admins').doc(id).get();
    return AdminEntity.fromMap(doc.id, doc.data()!);
  }

  // UPDATE
  Future<void> updateAdmin(AdminEntity admin) async {
    await firestore.collection('admins').doc(admin.id).update(admin.toMap());
  }

  // DELETE
  Future<void> deleteAdmin(String id) async {
    await firestore.collection('admins').doc(id).delete();
  }
}
