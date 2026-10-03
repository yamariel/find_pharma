import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';
import 'package:find_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:find_pharma/features/auth/presentation/providers/auth_controller.dart';
import 'package:find_pharma/features/auth/domain/usecases/register_client_usecase.dart';

class MockRegisterClientUsecase extends Mock implements RegisterClientUsecase {}

void main() {
  test("authControllerProvider signUpClient fonctionne", () async {
    final usecase = MockRegisterClientUsecase();

    when(() => usecase(
      nom: "Marc",
      email: "marc@test.com",
      password: "123456",
    )).thenAnswer((_) async => UserEntity(
      uid: "1",
      nom: "Marc",
      email: "marc@test.com",
      role: "client",
    ));

    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith((ref) {
          return AuthController(usecase as AuthRepository);
        }),
      ],
    );

    final controller = container.read(authControllerProvider.notifier);

    await controller.signUpClient("Marc", "marc@test.com", "123456");

    expect(container.read(authControllerProvider).isLoading, false);
  });
}
