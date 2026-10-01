import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';


final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repo = ref.watch(authProvider);
  return repo.authStateChanges();
});
