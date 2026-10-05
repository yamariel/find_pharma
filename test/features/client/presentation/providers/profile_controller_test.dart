import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';
import 'package:find_pharma/features/Client/domain/usecases/update_client_usecase.dart';
import 'package:find_pharma/features/Client/presentation/providers/client_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateUserUsecase extends Mock implements UpdateClientUsecase {}

void main() {
  test("ProfileController.updateProfile met l'état en AsyncLoading puis AsyncData", () async {
    final usecase = MockUpdateUserUsecase();

    final user = UserEntity(
      uid: "1",
      nom: "Jean",
      email: "jean@test.com",
      role: "client",
    );

    when(() => usecase(user)).thenAnswer((_) async => {});

    final container = ProviderContainer(
      overrides: [
        clientControllerProvider.overrideWith(
              (ref) => ProfileController(usecase),
        ),
      ],
    );

    final controller = container.read(clientControllerProvider.notifier);

    expect(container.read(clientControllerProvider).isLoading, false);

    final future = controller.updateProfile(user);

    expect(container.read(clientControllerProvider).isLoading, true);

    await future;

    expect(container.read(clientControllerProvider).isLoading, false);
  });
}
