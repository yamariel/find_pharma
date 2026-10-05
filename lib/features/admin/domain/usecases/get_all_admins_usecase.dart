import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllAdminsUsecase {
  final AdminRepository repo;

  GetAllAdminsUsecase(this.repo);

  Future<List<AdminEntity>> call() {
    return repo.getAllAdmins();
  }
}
