import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VisitorHomePage extends StatelessWidget {
  const VisitorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenue'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Bienvenue sur notre application',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                context.push('/login');
              },
              child: const Text('Se connecter'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                context.push('/signup-client');
              },
              child: const Text('Créer un compte'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                // retour / navigation visiteur
                context.pop();
              },
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}