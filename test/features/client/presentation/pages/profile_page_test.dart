import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';
import 'package:find_pharma/features/Client/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:find_pharma/features/auth/presentation/providers/auth_state_provider.dart';

void main() {
  testWidgets("ProfilePage affiche les infos utilisateur", (tester) async {
    final user = UserEntity(
      uid: "1",
      nom: "Jean-Marc",
      email: "jean@test.com",
      role: "client",
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.pump();

    expect(find.text("Jean-Marc"), findsOneWidget);
    expect(find.text("jean@test.com"), findsOneWidget);
    expect(find.text("Compte client"), findsOneWidget);
  });
}
