import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class CreateAdminUsecase {
  final AdminRepository repo;

  CreateAdminUsecase(this.repo);

  Future<void> call({
    required String nom,
    required String email,
  }) async {
    final admin = AdminEntity(
      id: '', // Firestore génère l'id
      nom: nom,
      email: email,
    );
    await repo.createAdmin(admin);
  }
}
