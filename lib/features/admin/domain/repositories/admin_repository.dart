import '../entities/admin_entity.dart';

abstract class AdminRepository {
  Future<void> createAdmin(AdminEntity admin);
  Future<List<AdminEntity>> getAllAdmins();
  Future<AdminEntity> getAdmin(String id);
  Future<void> updateAdmin(AdminEntity admin);
  Future<void> deleteAdmin(String id);
}
