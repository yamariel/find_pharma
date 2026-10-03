import '../entities/user_entity.dart';
import '../repositories/client_repository.dart';

class GetClientUsecase {
  final ClientRepository repository;

  GetClientUsecase(this.repository);

  Future<UserEntity> call(String uid) {
    return repository.getClient(uid);
  }
}
