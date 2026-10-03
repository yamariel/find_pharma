import 'package:find_pharma/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:find_pharma/features/Client/presentation/pages/profile_security_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  testWidgets("ProfileSecurityPage affiche le bouton de reset", (tester) async {
    final mockAuth = MockFirebaseAuth();
    final mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn("test@example.com");
    when(() => mockAuth.sendPasswordResetEmail(email: any(named: "email")))
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
        child: const MaterialApp(home: ProfileSecurityPage()),
      ),
    );

    expect(find.text("Réinitialiser le mot de passe"), findsOneWidget);
    expect(find.text("Envoyer le lien"), findsOneWidget);
  });
}
