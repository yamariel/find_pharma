import 'package:flutter/material.dart';

import '../models/map_pharmacy.dart';
import '../pharmacy_map_screen.dart';
import 'demo_pharmacies.dart';

/// Isolated harness, not a medicine search implementation.
class MapDemoScreen extends StatefulWidget {
  const MapDemoScreen({super.key});
  @override
  State<MapDemoScreen> createState() => _MapDemoScreenState();
}

class _MapDemoScreenState extends State<MapDemoScreen> {
  String _scenario = 'all';
  @override
  Widget build(BuildContext context) => Scaffold(
    body: PharmacyMapScreen(
      isDemo: true,
      pharmacies: switch (_scenario) {
        'empty' => const [],
        'medicine' => demoPharmacies.take(3).toList(),
        _ => demoPharmacies,
      },
      medicine: _scenario == 'medicine' || _scenario == 'empty'
          ? const MedicineContext(
              id: 'demo-med',
              label: 'Médicament de démonstration',
            )
          : null,
      loading: _scenario == 'loading',
      errorMessage: _scenario == 'error'
          ? 'Démonstration : chargement des pharmacies impossible.'
          : null,
      onRetry: () => setState(() => _scenario = 'all'),
      onViewPharmacy: (p) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Callback reçu : ${p.name}. Écran détail à connecter par l’équipe.',
          ),
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _scenario,
          items: const [
            DropdownMenuItem(
              value: 'all',
              child: Text('Démo : toutes les pharmacies'),
            ),
            DropdownMenuItem(
              value: 'medicine',
              child: Text('Démo : résultats médicament'),
            ),
            DropdownMenuItem(
              value: 'empty',
              child: Text('Démo : aucun résultat'),
            ),
            DropdownMenuItem(
              value: 'loading',
              child: Text('Démo : chargement'),
            ),
            DropdownMenuItem(
              value: 'error',
              child: Text('Démo : erreur de données'),
            ),
          ],
          onChanged: (value) => setState(() => _scenario = value!),
        ),
      ),
    ),
  );
}
