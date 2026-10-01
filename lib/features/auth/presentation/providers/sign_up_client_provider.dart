import 'package:find_pharma/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';


final signUpClientProvider = Provider((ref) {
  return RegisterClientUsecase(ref.watch(authProvider));
});
