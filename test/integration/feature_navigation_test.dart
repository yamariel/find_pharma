import 'package:find_pharma/features/auth/presentation/pages/visitor_page.dart';
import 'package:find_pharma/features/ai_assistant/presentation/widgets/pharmacie_card.dart';
import 'package:find_pharma/features/medicines/presentation/pages/search_medicines_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<GoRouter> showVisitor(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const VisitorHomePage()),
        GoRoute(
          path: '/map',
          builder: (_, _) => const Scaffold(body: Text('Carte des pharmacies')),
        ),
        GoRoute(
          path: '/signup/client',
          builder: (_, _) => const Scaffold(body: Text('Inscription client')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('le visiteur ouvre la carte', (tester) async {
    await showVisitor(tester);
    await tester.tap(find.text('Carte'));
    await tester.pumpAndSettle();
    expect(find.text('Carte des pharmacies'), findsOneWidget);
  });

  testWidgets('le visiteur ouvre la recherche existante', (tester) async {
    await showVisitor(tester);
    await tester.tap(find.text('Médicaments'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchMedicinesPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('les accès réservés au visiteur ouvrent la route inscription', (
    tester,
  ) async {
    final router = await showVisitor(tester);
    for (final label in ['Créer un compte', 'Assistant', 'Profil']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(router.canPop(), isTrue);
      expect(find.text('Inscription client'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('itinéraire transmet la pharmacie choisie à la carte', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: PharmacyCardWidget(
              name: 'Officine',
              district: 'Centre',
              phone: '+243123',
              pharmacyId: 'officine & centre',
            ),
          ),
        ),
        GoRoute(
          path: '/map',
          builder: (_, state) =>
              Scaffold(body: Text(state.uri.queryParameters['pharmacyId']!)),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Itinéraire'));
    await tester.pumpAndSettle();
    expect(find.text('officine & centre'), findsOneWidget);
  });
}
