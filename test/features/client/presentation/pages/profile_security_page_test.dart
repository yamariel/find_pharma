import 'package:find_pharma/features/Client/presentation/pages/profile_security_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets("ProfileSecurityPage affiche le bouton de reset", (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileSecurityPage()),
      ),
    );

    expect(find.text("Réinitialiser le mot de passe"), findsOneWidget);
    expect(find.text("Envoyer le lien"), findsOneWidget);
  });
}
