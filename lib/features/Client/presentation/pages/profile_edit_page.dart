import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/client_controller.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    adresseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier mon profil")),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur : $e")),
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Utilisateur introuvable"));
          }

          nameCtrl.text = user.nom;
          phoneCtrl.text = user.phone ?? "";
          adresseCtrl.text = user.adresse ?? "";

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Nom complet"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Téléphone"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adresseCtrl,
                  decoration: const InputDecoration(labelText: "Adresse"),
                ),
                const SizedBox(height: 30),

                // Bouton Enregistrer
                ElevatedButton(
                  onPressed: () async {
                    final updated = UserEntity(
                      uid: user.uid,
                      nom: nameCtrl.text.trim(),
                      email: user.email,
                      role: user.role,
                      phone: phoneCtrl.text.trim(),
                      adresse: adresseCtrl.text.trim(),
                    );

                    await ref
                        .read(clientControllerProvider.notifier)
                        .updateProfile(updated);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profil mis à jour")),
                      );

                      // 🔥 Retour automatique vers ProfilePage
                      context.pop();
                    }
                  },
                  child: const Text("Enregistrer"),
                ),

                const SizedBox(height: 12),

                // Bouton Annuler
                OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Annuler"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
