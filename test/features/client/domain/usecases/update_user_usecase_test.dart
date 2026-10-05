import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';
import 'package:find_pharma/features/Client/domain/repositories/client_repository.dart';
import 'package:find_pharma/features/Client/domain/usecases/update_client_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  test("UpdateUserUsecase appelle repository.updateClient", () async {
    final repo = MockClientRepository();
    final usecase = UpdateClientUsecase(repo);

    final user = UserEntity(
      uid: "123",
      nom: "Marc",
      email: "marc@test.com",
      role: "client",
      phone: "0600000000",
      adresse: "Douala",
    );

    when(() => repo.updateClient(user)).thenAnswer((_) async => {});

    await usecase(user);

    verify(() => repo.updateClient(user)).called(1);
  });
}
