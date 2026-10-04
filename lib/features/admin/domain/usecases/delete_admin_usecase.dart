import '../repositories/admin_repository.dart';

class DeleteAdminUsecase {
  final AdminRepository repo;

  DeleteAdminUsecase(this.repo);

  Future<void> call(String id) {
    return repo.deleteAdmin(id);
  }
}
