import 'package:find_pharma/features/Client/domain/usecases/update_client_usecase.dart';
import 'package:find_pharma/features/Client/presentation/providers/client_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/user_entity.dart';

final clientControllerProvider =
StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  final updateUser = ref.watch(updateClientUsecaseProvider);
  return ProfileController(updateUser);
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final UpdateClientUsecase updateUser;

  ProfileController(this.updateUser) : super(const AsyncData(null));

  Future<void> updateProfile(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => updateUser(user));
  }
}
