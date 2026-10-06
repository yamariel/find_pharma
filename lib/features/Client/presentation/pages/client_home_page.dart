import 'package:find_pharma/features/Client/presentation/pages/profile_page.dart';
import 'package:find_pharma/features/ai_assistant/presentation/pages/ai_chat_page.dart';
import 'package:find_pharma/features/map/presentation/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  int currentIndex = 0;
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

  // Pages affichées dans le body selon l’index
  List<Widget> get pages => [
    const MapPage(), // Onglet 0 : Carte
    _dashboardPage(), // Onglet 1 : Médicaments
    _gardePage(), // Onglet 2 : Pharmacies de garde
    _assistantPage(), // Onglet 3 : Assistant IA
    ProfilePage(), // Onglet 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(child:  pages[currentIndex]),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Carte"),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: "Médicaments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: "Garde",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: "Assistant IA",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // ------------------------------
  // PAGES CLIENT
  // ------------------------------

  /// Onglet 1 : Recherche de médicaments
  Widget _dashboardPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              fillColor: Colors.transparent,
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
            onTap: () => context.push('/search-medicines'),
          ),

          ListTile(
            leading: const Icon(Icons.local_pharmacy),
            title: const Text('Pharmacies'),
            onTap: () => context.push('/pharmacies'),
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
    );
  }

  Widget _gardePage() {
    return const Center(child: Text("Pharmacies de garde"));
  }

  Widget _assistantPage() {
    return const AiChatPage();
  }
}
