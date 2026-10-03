import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminUsecase {
  final AdminRepository repo;

  GetAdminUsecase(this.repo);

  Future<AdminEntity> call(String id) {
    return repo.getAdmin(id);
  }
}
