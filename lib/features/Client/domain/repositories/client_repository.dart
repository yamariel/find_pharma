import '../entities/user_entity.dart';

abstract class ClientRepository {
  Future<UserEntity> getClient(String uid);
  Future<List<UserEntity>> getAllClients();
  Future<void> updateClient(UserEntity client);
  Future<void> deleteClient(String uid);
}
