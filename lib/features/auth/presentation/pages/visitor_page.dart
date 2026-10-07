import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../map/presentation/pages/map_page.dart';
import '../../../medicines/presentation/pages/search_medicines_page.dart';
import '../../../pharmacies/presentation/pages/on_duty_pharmacies_page.dart';

class VisitorHomePage extends StatefulWidget {
  const VisitorHomePage({super.key});

  @override
  State<VisitorHomePage> createState() => _VisitorHomePageState();
}

class _VisitorHomePageState extends State<VisitorHomePage> {
  int currentIndex = 0;

  /// Un onglet, une page, dans l'ordre de la barre.
  late final List<Widget> pages = [
    const MapPage(), // 0 : Carte
    const SearchMedicinesPage(), // 1 : Médicaments
    const OnDutyPharmaciesPage(), // 2 : Garde
    _assistantPage(), // 3 : Assistant — réservé aux comptes
    _accountPage(), // 4 : Profil — connexion et inscription
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack garde les onglets montés : la caméra de la carte et la
      // recherche en cours survivent à un aller-retour entre onglets.
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          // Visiteur : l'assistant demande un compte.
          if (i == 3) {
            context.push('/signup/client');
            return;
          }
          setState(() => currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Médicaments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Garde',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  /// Onglet Profil du visiteur : les trois portes vers l'authentification.
  Widget _accountPage() {
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
              'FindPharma',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bienvenue sur FindPharma',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recherchez des médicaments, trouvez des pharmacies\n'
              'et découvrez nos services.',
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
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.push('/signup/client'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Créer un compte'),
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
              child: const Text('Inscription pharmacie'),
            ),
            const Spacer(),
            const Text(
              'Accédez à plus de fonctionnalités en créant un compte.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _assistantPage() {
    return const Center(
      child: Text("Créer un compte pour accéder à l'assistance"),
    );
  }
}