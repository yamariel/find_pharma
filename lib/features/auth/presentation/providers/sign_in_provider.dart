import 'package:find_pharma/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';


final signInProvider = Provider((ref) {
  return LoginUsecase(ref.watch(authProvider));
});
