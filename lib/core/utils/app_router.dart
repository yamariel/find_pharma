import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/Client/presentation/pages/profile_edit_page.dart';
import '../../features/Client/presentation/pages/profile_page.dart';
import '../../features/Client/presentation/pages/profile_security_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/visitor_page.dart';
import '../../features/auth/presentation/pages/register_page_client.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/pharmacies/presentation/pages/pharmacies_page.dart';
import '../../features/medicines/presentation/pages/search_medicines_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/Client/presentation/pages/client_home_page.dart';
import 'router_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/loading',
    refreshListenable: ref.watch(routerNotifierProvider),

    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final user = authState.value;
      final location = state.matchedLocation;

      final isLoading = authState.isLoading;
      final isLogin = location == '/login';
      final isVisitor = location == '/visitor';

      final isSignup =
          location == '/signup/client' || location == '/signup/pharmacy';

      // Attendre la résolution de l'authentification Firebase.
      if (isLoading) {
        return location == '/loading' ? null : '/loading';
      }

      // Pages accessibles sans compte.
      const publicRoutes = {
        '/visitor',
        '/login',
        '/signup/client',
        '/signup/pharmacy',
        '/search-medicines',
        '/pharmacies',
        '/map',
        '/ai-chat',
      };

      // Utilisateur non connecté.
      if (user == null) {
        if (location == '/loading') {
          return '/login';
        }

        if (publicRoutes.contains(location)) {
          return null;
        }

        return '/visitor';
      }

      // Utilisateur connecté : empêcher le retour vers
      // les pages d'authentification ou le mode visiteur.
      if (isLogin || isSignup || isVisitor || location == '/loading') {
        switch (user.role) {
          case 'client':
            return '/client';
          case 'pharmacy':
            return '/pharmacies';
          case 'admin':
            return '/map';
          default:
            return '/client';
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/visitor', builder: (context, state) => VisitorHomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/signup/client',
        builder: (context, state) => const RegisterPageClient(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/profile/security',
        builder: (context, state) => const ProfileSecurityPage(),
      ),

      GoRoute(
        path: '/client',
        builder: (context, state) => const ClientHomePage(),
      ),
      GoRoute(
        path: '/pharmacies',
        builder: (context, state) => const PharmaciesPage(),
      ),
      GoRoute(path: '/map', builder: (context, state) => const MapPage()),
      GoRoute(
        path: '/search-medicines',
        builder: (context, state) => SearchMedicinesPage(
          initialQuery: state.uri.queryParameters['query'] ?? '',
        ),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
