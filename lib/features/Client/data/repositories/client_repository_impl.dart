import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/user_remote_data_source.dart';

class ClientRepositoryImpl implements ClientRepository {
  final UserRemoteDataSource remote;

  ClientRepositoryImpl(this.remote);

  @override
  Future<UserEntity> getClient(String uid) {
    return remote.getClient(uid);
  }

  @override
  Future<List<UserEntity>> getAllClients() {
    return remote.getAllClients();
  }

  @override
  Future<void> updateClient(UserEntity client) {
    return remote.updateClient(client);
  }

  @override
  Future<void> deleteClient(String uid) {
    return remote.deleteClient(uid);
  }
}
