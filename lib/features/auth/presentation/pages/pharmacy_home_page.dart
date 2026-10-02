import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

class PharmacyHomePage extends ConsumerWidget {
  const PharmacyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FindPharma - Pharmacie"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Tableau de bord pharmacie",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Gérer le stock"),
              onTap: () => context.push('/pharmacy-stock'),
            ),

            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Documents de vérification"),
              onTap: () => context.push('/pharmacy-documents'),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Localisation de la pharmacie"),
              onTap: () => context.push('/pharmacy-location'),
            ),
          ],
        ),
      ),
    );
  }
}
