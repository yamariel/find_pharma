import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FindPharma - Admin"),
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
              "Administration",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text("Pharmacies à vérifier"),
              onTap: () => context.push('/admin-verify-pharmacies'),
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Gestion des utilisateurs"),
              onTap: () => context.push('/admin-users'),
            ),

            ListTile(
              leading: const Icon(Icons.map),
              title: const Text("Carte des pharmacies"),
              onTap: () => context.push('/map'),
            ),
          ],
        ),
      ),
    );
  }
}
