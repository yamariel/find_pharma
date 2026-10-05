import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/usecases/create_admin_usecase.dart';
import '../../domain/usecases/get_admin_usecase.dart';
import '../../domain/usecases/get_all_admins_usecase.dart';
import '../../domain/usecases/update_admin_usecase.dart';
import '../../domain/usecases/delete_admin_usecase.dart';

final adminRepositoryProvider = Provider((ref) {
  return AdminRepositoryImpl(
    AdminRemoteDataSource(FirebaseFirestore.instance, FirebaseAuth.instance),
  );
});

final createAdminUsecaseProvider = Provider((ref) {
  return CreateAdminUsecase(ref.watch(adminRepositoryProvider));
});

final getAdminUsecaseProvider = Provider((ref) {
  return GetAdminUsecase(ref.watch(adminRepositoryProvider));
});

final getAllAdminsUsecaseProvider = Provider((ref) {
  return GetAllAdminsUsecase(ref.watch(adminRepositoryProvider));
});

final updateAdminUsecaseProvider = Provider((ref) {
  return UpdateAdminUsecase(ref.watch(adminRepositoryProvider));
});

final deleteAdminUsecaseProvider = Provider((ref) {
  return DeleteAdminUsecase(ref.watch(adminRepositoryProvider));
});
