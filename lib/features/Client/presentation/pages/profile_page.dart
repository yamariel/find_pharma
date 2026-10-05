import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil utilisateur"),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur : $e")),
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Aucun utilisateur connecté"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================
                // HEADER PROFIL
                // ============================
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(
                          'assets/images/profile_placeholder.png',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.nom,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified, color: Colors.green, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "Compte ${user.role}",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ============================
                // INFORMATIONS PERSONNELLES
                // ============================
                const Text(
                  "Informations personnelles",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _infoTile("Noms", user.nom),
                _infoTile("Adresse", user.adresse ?? "Non renseignée"),

                const SizedBox(height: 30),

                // ============================
                // PARAMÈTRES
                // ============================
                const Text(
                  "Paramètres du compte",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Modifier mes informations"),
                  onTap: () {
                    context.push('/profile/edit');
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Sécurité du compte"),
                  onTap: () {
                    context.push('/profile/security');
                  },
                ),

                const SizedBox(height: 30),

                // ============================
                // DÉCONNEXION
                // ============================
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).signOut();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ============================
                // VERSION APP
                // ============================
                Center(
                  child: Text(
                    "FindPharma v1.0.0\nPharmacies et officines certifiées",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
