import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remote;

  AdminRepositoryImpl(this.remote);

  @override
  Future<void> createAdmin(AdminEntity admin) => remote.createAdmin(admin);

  @override
  Future<List<AdminEntity>> getAllAdmins() => remote.getAllAdmins();

  @override
  Future<AdminEntity> getAdmin(String id) => remote.getAdmin(id);

  @override
  Future<void> updateAdmin(AdminEntity admin) => remote.updateAdmin(admin);

  @override
  Future<void> deleteAdmin(String id) => remote.deleteAdmin(id);
}
