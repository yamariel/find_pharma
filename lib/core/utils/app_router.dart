import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/pharmacies/presentation/pages/pharmacies_page.dart';
import '../../features/medicines/presentation/pages/search_medicines_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../features/map/presentation/pages/map_page.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/pharmacies', builder: (context, state) => const PharmaciesPage()),
    GoRoute(path: '/map', builder: (context, state) => const MapPage()),
    GoRoute(path: '/search-medicines', builder: (context, state) => const SearchMedicinesPage()),
    GoRoute(path: '/ai-chat', builder: (context, state) => const AiChatPage()),
  ],
);