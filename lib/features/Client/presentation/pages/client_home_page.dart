import 'package:find_pharma/features/Client/presentation/pages/profile_page.dart';
import 'package:find_pharma/features/ai_assistant/presentation/pages/ai_chat_page.dart';
import 'package:find_pharma/features/map/presentation/pages/map_page.dart';
import 'package:find_pharma/features/medicines/presentation/pages/search_medicines_page.dart';
import 'package:find_pharma/features/pharmacies/presentation/pages/on_duty_pharmacies_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shell du client connecté : les mêmes fonctions que chez le visiteur, plus
/// l'assistant et le profil.
class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack garde les cinq onglets montés : la caméra de la carte et
      // la recherche en cours survivent à un aller-retour.
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: const <Widget>[
            MapPage(), // 0 : Carte
            SearchMedicinesPage(), // 1 : Médicaments
            OnDutyPharmaciesPage(), // 2 : Garde
            AiChatPage(), // 3 : Assistant IA
            ProfilePage(), // 4 : Profil
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
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
            label: 'Assistant IA',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}