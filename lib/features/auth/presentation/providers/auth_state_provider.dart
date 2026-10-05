import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';
import 'auth_provider.dart';

final authStateProvider = StreamProvider<UserEntity?>((ref) async* {
  final repo = ref.watch(authRepositoryProvider);

  await for (final user in repo.authStateChanges()) {
    if (user != null) {
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser != null) {
          final token = await firebaseUser.getIdToken();

          debugPrint('');
          debugPrint('==========================================');
          debugPrint('🔐 UTILISATEUR CONNECTÉ');
          debugPrint('==========================================');

          debugPrint('🆔 UID       : ${firebaseUser.uid}');
          debugPrint('👤 Nom       : ${firebaseUser.displayName}');
          debugPrint('📧 Email     : ${firebaseUser.email}');
          debugPrint('📱 Téléphone : ${firebaseUser.phoneNumber}');
          debugPrint('🔑 TOKEN     : $token');

          debugPrint('------------------------------------------');

          debugPrint('👤 UserEntity');
          debugPrint('Nom complet         : ${user.nom}');
          debugPrint('Email       : ${user.email}');
          debugPrint('Rôle        : ${user.role}');

          debugPrint('==========================================');
          debugPrint('');
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Erreur récupération token Firebase');
        debugPrint('Erreur : $e');
        debugPrint('$stackTrace');
      }
    } else {
      debugPrint('');
      debugPrint('==========================================');
      debugPrint('🚪 UTILISATEUR DÉCONNECTÉ');
      debugPrint('==========================================');
      debugPrint('');
    }

    yield user;
  }
});