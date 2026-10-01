import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';
import 'package:find_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_pharma/features/auth/presentation/providers/auth_provider.dart';
import 'package:find_pharma/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('authStateProvider emits user', () async {
    final repo = MockAuthRepository();
    final user = UserEntity(
      uid: '1',
      nom: 'Doe',
      prenom: 'John',
      email: 'john@example.com',
      role: 'client',
    );

    when(() => repo.authStateChanges()).thenAnswer(
          (_) => Stream.value(user),
    );

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWithValue(repo),
      ],
    );

    final result = await container.read(authStateProvider.future);

    expect(result!.email, 'john@example.com');
  });
}

