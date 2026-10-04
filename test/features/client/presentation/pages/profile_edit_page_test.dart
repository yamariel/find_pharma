import 'package:find_pharma/features/Client/domain/entities/user_entity.dart';
import 'package:find_pharma/features/Client/presentation/pages/profile_edit_page.dart';
import 'package:find_pharma/features/Client/presentation/providers/client_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:find_pharma/features/auth/presentation/providers/auth_state_provider.dart';

class MockProfileController extends Mock implements ProfileController {}

void main() {
  testWidgets("ProfileEditPage pré-remplit les champs", (tester) async {
    final user = UserEntity(
      uid: "1",
      nom: "Marc",
      email: "marc@test.com",
      role: "client",
      phone: "0600000000",
      adresse: "Douala",
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
          clientControllerProvider.overrideWith((ref) {
            return MockProfileController();
          }),
        ],
        child: const MaterialApp(home: ProfileEditPage()),
      ),
    );

    await tester.pump();

    expect(find.text("Marc"), findsOneWidget);
    expect(find.text("0600000000"), findsOneWidget);
    expect(find.text("Douala"), findsOneWidget);
  });
}
