import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:find_pharma/features/auth/presentation/providers/auth_controller.dart';
import 'package:find_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test("authControllerProvider signUpClient fonctionne", () async {
    final repo = MockAuthRepository();

    // Mock de registerClientUsecase()
    when(() => repo.registerClientUsecase(
      nom: "Marc",
      email: "marc@test.com",
      password: "123456",
    )).thenAnswer(
          (_) async => UserEntity(
        uid: "1",
        nom: "Marc",
        email: "marc@test.com",
        role: "client",
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith((ref) {
          return AuthController(repo);
        }),
      ],
    );

    final controller = container.read(authControllerProvider.notifier);

    // Exécution
    await controller.signUpClient("Marc", "marc@test.com", "123456");

    // Vérification : l'état final n'est pas loading
    expect(container.read(authControllerProvider).isLoading, false);

    // Vérification : la méthode du repo a bien été appelée
    verify(() => repo.registerClientUsecase(
      nom: "Marc",
      email: "marc@test.com",
      password: "123456",
    )).called(1);
  });
}
