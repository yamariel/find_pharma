import '../repositories/client_repository.dart';

class DeleteClientUsecase {
  final ClientRepository repository;

  DeleteClientUsecase(this.repository);

  Future<void> call(String uid) {
    return repository.deleteClient(uid);
  }
}
