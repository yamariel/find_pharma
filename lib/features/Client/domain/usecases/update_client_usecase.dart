import '../entities/user_entity.dart';
import '../repositories/client_repository.dart';

class UpdateClientUsecase {
  final ClientRepository repository;

  UpdateClientUsecase(this.repository);

  Future<void> call(UserEntity client) {
    return repository.updateClient(client);
  }
}
