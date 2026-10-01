import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';

import '../repositories/auth_repository.dart';


class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}
