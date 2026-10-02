
import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';

import '../repositories/auth_repository.dart';

class RegisterClientUsecase {
  final AuthRepository repository;

  RegisterClientUsecase(this.repository);

  Future<UserEntity> call({
    required String nom,
    required String email,
    required String password,
    String? phone,
    String? adresse,
  }) {
    return repository.registerClientUsecase(
      nom: nom,
      email: email,
      password: password,
      phone: phone,
      adresse: adresse,
    );
  }
}
