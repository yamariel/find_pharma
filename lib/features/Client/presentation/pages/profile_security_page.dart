import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileSecurityPage extends ConsumerWidget {
  const ProfileSecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sécurité du compte")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Réinitialiser le mot de passe",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Nous allons envoyer un lien de réinitialisation à votre adresse e-mail.",
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final email = auth.currentUser?.email;
                if (email == null) return;

                await auth.sendPasswordResetEmail(email: email);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Email envoyé à $email")),
                  );

                  // 🔥 Retour automatique vers la page précédente (ProfilePage)
                  context.pop();
                }
              },
              child: const Text("Envoyer le lien"),
            ),

            const SizedBox(height: 12),

            // Bouton Annuler / Retour
            OutlinedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Annuler"),
            ),
          ],
        ),
      ),
    );
  }
}
