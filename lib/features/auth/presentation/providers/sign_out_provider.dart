import 'package:find_pharma/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';


final signOutProvider = Provider((ref) {
  return LogoutUsecase(ref.watch(authProvider));
});
