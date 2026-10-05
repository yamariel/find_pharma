import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VisitorHomePage extends StatefulWidget {
  const VisitorHomePage({super.key});

  @override
  State<VisitorHomePage> createState() => _VisitorHomePageState();
}

class _VisitorHomePageState extends State<VisitorHomePage> {
  int currentIndex = 0;

  // Pages affichées selon l’onglet
  late final List<Widget> pages = [
    _welcomePage(),      // Onglet 0 : Accueil visiteur
    _medicamentsPage(),  // Onglet 1
    _gardePage(),        // Onglet 2
    _assistantPage(),    // Onglet 3 (redirige vers création compte)
    _profilePage(),      // Onglet 4 (redirige vers création compte)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          // 🔥 Visiteur : accès limité
          if (i == 3 || i == 4) {
            context.push('/create-account');
            return;
          }
          setState(() => currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Carte",
          ),
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
            label: "Assistant",
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
  // PAGES VISITEUR
  // ------------------------------

  /// Onglet 0 : Accueil visiteur (ton contenu actuel)
  Widget _welcomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset('assets/images/find_pharma_icon.png'),
            ),

            const SizedBox(height: 10),
            const Text(
              "FindPharma",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Bienvenue sur FindPharma",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),
            const Text(
              "Recherchez des médicaments, trouvez des pharmacies\net découvrez nos services.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Se connecter"),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () => context.push('/signup-client'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Créer un compte"),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () => context.push('/signup-pharmacy'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Inscription pharmacie"),
            ),

            const Spacer(),

            const Text(
              "Accédez à plus de fonctionnalités en créant un compte.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _medicamentsPage() {
    return const Center(child: Text("Recherche de médicaments"));
  }

  Widget _gardePage() {
    return const Center(child: Text("Pharmacies de garde"));
  }

  Widget _assistantPage() {
    return const Center(child: Text("Créer un compte pour accéder à l'assistance"));
  }

  Widget _profilePage() {
    return const Center(child: Text("Créer un compte pour accéder au profil"));
  }
}
