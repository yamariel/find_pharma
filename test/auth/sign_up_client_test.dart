import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';
import 'package:find_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_pharma/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late RegisterClientUsecase usecase;

  setUp(() {
    repo = MockAuthRepository();
    usecase = RegisterClientUsecase(repo);
  });

  test('SignUpClient creates a new user', () async {
    final user = UserEntity(
      uid: '123',
      nom: 'Doe',
      prenom: 'John',
      email: 'john@example.com',
      role: 'client',
    );

    when(() => repo.registerClientUsecase(
      nom: any(named: 'nom'),
      prenom: any(named: 'prenom'),
      email: any(named: 'email'),
      password: any(named: 'password'),
      phone: any(named: 'phone'),
      adresse: any(named: 'adresse'),
    )).thenAnswer((_) async => user);

    final result = await usecase(
      nom: 'Doe',
      prenom: 'John',
      email: 'john@example.com',
      password: '123456',
    );

    expect(result.uid, '123');
    expect(result.role, 'client');
  });
}

