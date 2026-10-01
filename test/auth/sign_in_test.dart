import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';
import 'package:find_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_pharma/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late LoginUsecase usecase;

  setUp(() {
    repo = MockAuthRepository();
    usecase = LoginUsecase(repo);
  });

  test('SignIn returns AppUser', () async {
    final user = UserEntity(
      uid: '123',
      nom: 'Doe',
      prenom: 'John',
      email: 'john@example.com',
      role: 'client',
    );

    when(() => repo.signIn(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => user);

    final result = await usecase(email: 'john@example.com', password: '123456');

    expect(result, isA<UserEntity>());
    expect(result!.email, 'john@example.com');
  });
}
