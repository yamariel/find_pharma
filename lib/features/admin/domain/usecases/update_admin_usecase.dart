import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class UpdateAdminUsecase {
  final AdminRepository repo;

  UpdateAdminUsecase(this.repo);

  Future<void> call(AdminEntity admin) {
    return repo.updateAdmin(admin);
  }
}
