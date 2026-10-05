import '../entities/user_entity.dart';
import '../repositories/client_repository.dart';

class GetAllClientsUsecase {
  final ClientRepository repository;

  GetAllClientsUsecase(this.repository);

  Future<List<UserEntity>> call() {
    return repository.getAllClients();
  }
}
