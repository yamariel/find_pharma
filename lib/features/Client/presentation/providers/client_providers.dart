import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/datasources/user_remote_data_source.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/usecases/get_client_usecase.dart';
import '../../domain/usecases/get_all_clients_usecase.dart';
import '../../domain/usecases/update_client_usecase.dart';
import '../../domain/usecases/delete_client_usecase.dart';

final clientRepositoryProvider = Provider((ref) {
  return ClientRepositoryImpl(
    UserRemoteDataSource(FirebaseAuth.instance, FirebaseFirestore.instance),
  );
});


final getClientUsecaseProvider = Provider((ref) {
  return GetClientUsecase(ref.watch(clientRepositoryProvider));
});

final getAllClientsUsecaseProvider = Provider((ref) {
  return GetAllClientsUsecase(ref.watch(clientRepositoryProvider));
});

final updateClientUsecaseProvider = Provider((ref) {
  return UpdateClientUsecase(ref.watch(clientRepositoryProvider));
});

final deleteClientUsecaseProvider = Provider((ref) {
  return DeleteClientUsecase(ref.watch(clientRepositoryProvider));
});
