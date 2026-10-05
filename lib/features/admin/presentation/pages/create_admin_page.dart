import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_controller.dart';
import '../../domain/entities/admin_entity.dart';
import 'package:go_router/go_router.dart';

class CreateAdminPage extends ConsumerStatefulWidget {
  const CreateAdminPage({super.key});

  @override
  ConsumerState<CreateAdminPage> createState() => _CreateAdminPageState();
}

class _CreateAdminPageState extends ConsumerState<CreateAdminPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Créer un nouvel admin")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nom complet"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 30),

            state.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                final admin = AdminEntity(
                  id: '', // Firestore va générer l’ID
                  nom: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                );

                await ref
                    .read(adminControllerProvider.notifier)
                    .createAdmin(admin);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Admin créé et email envoyé")),
                  );
                  context.pop();
                }
              },
              child: const Text("Créer l’admin"),
            ),

            const SizedBox(height: 12),

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
