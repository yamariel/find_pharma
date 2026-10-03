import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  final _medicineController = TextEditingController();

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  void _openMedicineSearch(BuildContext context) {
    final uri = Uri(
      path: '/search-medicines',
      queryParameters: {'query': _medicineController.text.trim()},
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FindPharma - Client"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Rechercher un médicament",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _medicineController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _openMedicineSearch(context),
              decoration: InputDecoration(
                hintText: "Nom du médicament...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => _openMedicineSearch(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Rechercher"),
            ),

            const SizedBox(height: 40),

            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Rechercher un médicament'),
              onTap: () => context.go('/search-medicines'),
            ),

            ListTile(
              leading: const Icon(Icons.local_pharmacy),
              title: const Text('Pharmacies'),
              onTap: () => context.go('/pharmacies'),
            ),

            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text("Mes favoris"),
              onTap: () => context.push('/favorites'),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Mon profil"),
              onTap: () => context.push('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}
