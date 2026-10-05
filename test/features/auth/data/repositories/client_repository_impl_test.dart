import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';
import 'package:find_pharma/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:find_pharma/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockRemote extends Mock implements AuthRemoteDataSource {}

void main() {
  test("ClientRepositoryImpl.signUpClient appelle remote.signUpClient", () async {
    final remote = MockRemote();
    final repo = AuthRepositoryImpl(remote);

    when(() => remote.signUpClient("Marc", "marc@test.com", "123456"))
        .thenAnswer((_) async => UserEntity(
      uid: "1",
      nom: "Marc",
      email: "marc@test.com",
      role: "client",
    ));

    final user = await repo.registerClientUsecase(nom: 'Marc', email: 'marc@test.com', password: '123456');

    expect(user.nom, "Marc");
    verify(() => remote.signUpClient("Marc", "marc@test.com", "123456"))
        .called(1);
  });
}
