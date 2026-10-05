import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_provider.dart';

final adminControllerProvider =
StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AdminController(repo);
});

class AdminController extends StateNotifier<AsyncValue<void>> {
  final AdminRepository repo;

  AdminController(this.repo) : super(const AsyncData(null));

  Future<void> createAdmin(AdminEntity admin) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.createAdmin(admin));
  }
}
