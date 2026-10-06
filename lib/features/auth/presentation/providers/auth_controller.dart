
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_provider.dart';

final authControllerProvider =
StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository repo;

  AuthController(this.repo) : super(const AsyncData(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => repo.signIn(
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> signUpClient(
      String fullName,
      String email,
      String password,
      ) async {
    state = const AsyncLoading();


    state = await AsyncValue.guard(
          () => repo.registerClientUsecase(
        nom: fullName,
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> signUpPharmacy(
      String name,
      String email,
      String password,
      ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => repo.registerPharmacyUsecase(
        nom: name,
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => repo.logoutUsecase(),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => repo.signInWithGoogle(),
    );
  }

  Future<void> signUpWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => repo.signUpWithGoogle(),
    );
  }
}
