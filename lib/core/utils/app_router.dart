import 'package:find_pharma/features/auth/domain/entities/user_entity.dart';
import 'package:find_pharma/features/auth/presentation/pages/register_page_client.dart';
import 'package:find_pharma/features/auth/presentation/pages/register_page_pharmacie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as Injector;
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/pharmacies/presentation/pages/pharmacies_page.dart';
import '../../features/medicines/presentation/pages/search_medicines_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import 'router_notifier.dart';



final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
      initialLocation: '/loading',

      refreshListenable: ref.watch(routerNotifierProvider),

      redirect: (context, state) {
        final user = ref.read(authStateProvider).value;
        final isFirstLaunch = ref.read(firstLaunchProvider);

        final location = state.matchedLocation;

        final isAuthPage =
            location == '/login' ||
                location == '/signup-client' ||
                location == '/signup-pharmacy';

        final isVisitorPage = location == '/visitor';

        // ============================================================
        // 1. PREMIÈRE OUVERTURE DE L'APPLICATION
        // ============================================================

        if (isFirstLaunch && user == null) {
          if (location == '/login') {
            return null;
          }

          return '/login';
        }

        // ============================================================
        // 2. UTILISATEUR NON CONNECTÉ - OUVERTURES SUIVANTES
        // ============================================================

        if (user == null) {
          // L'utilisateur peut accéder librement à :
          // - visitor
          // - login
          // - signup client
          // - signup pharmacie

          if (isVisitorPage || isAuthPage) {
            return null;
          }

          return '/visitor';
        }

        // ============================================================
        // 3. UTILISATEUR CONNECTÉ
        // ============================================================

        // Un utilisateur connecté ne doit plus voir
        // login / signup / visitor.
        if (isAuthPage || isVisitorPage) {
          switch (user.role) {
            case 'client':
              return '/search-medicines';

            case 'pharmacy':
              return '/pharmacies';

            case 'admin':
              return '/map';

            default:
              return '/search-medicines';
          }
        }

        return null;
      },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (_, __) => const SizedBox.shrink(),
      ),
      // GoRoute(
      //   path: '/visitor',
      //   builder: (context, state) => const VisitorHomePage(),
      // ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginPage(),
      ),
      GoRoute(
        path: '/signup-client',
        builder: (context, state) =>
            RegisterPageClient(),
      ),
      GoRoute(
        path: '/signup-pharmacy',
        builder: (context, state) =>
            PharmaciesPage(),
      ),
      // GoRoute(
      //   path: '/client',
      //   builder: (context, state) => const ClientHomePage(),
      // ),
      GoRoute(
        path: '/pharmacies',
        builder: (context, state) => const PharmaciesPage(),
      ),
      // GoRoute(
      //   path: '/admin',
      //   builder: (context, state) => const AdminHomePage(),
      // ),
      GoRoute(
          path: '/map',
          builder: (context, state) => const MapPage()
      ),
      GoRoute(
          path: '/search-medicines',
          builder: (context, state) => const SearchMedicinesPage()
      ),
      GoRoute(
          path: '/ai-chat',
          builder: (context, state) => const AiChatPage()
      ),
    ],
  );
});
