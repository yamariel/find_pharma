import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import 'create_admin_page.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int currentIndex = 0;

  // Pages affichées dans le body selon l’index
  late final List<Widget> pages = [
    _dashboardPage(),          // Onglet 0 : Dashboard admin
    _pharmaciesPage(),         // Onglet 1
    _usersPage(),              // Onglet 2
    CreateAdminPage(),        // Onglet 3
    _profilePage(),            // Onglet 4
  ];

  @override
  Widget build(BuildContext context) {
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

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: "Pharmacies",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Utilisateurs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: "Admins",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // PAGES ADMIN
  // ------------------------------

  Widget _dashboardPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Administration",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Créer un nouvel admin"),
            onTap: () => context.push('/admin/create'),
          ),
        ],
      ),
    );
  }

  Widget _pharmaciesPage() {
    return const Center(child: Text("Liste des pharmacies"));
  }

  Widget _usersPage() {
    return const Center(child: Text("Gestion des utilisateurs"));
  }


  Widget _profilePage() {
    return const Center(child: Text("Profil admin"));
  }
}
