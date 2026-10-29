import 'package:flutter/material.dart';

class WarningZone extends StatelessWidget {
  const WarningZone({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(Icons.privacy_tip, color: colorScheme.error),
        title: const Text("Avertissement déontologique"),
        titleTextStyle: TextStyle(color: colorScheme.error),
        subtitle: const Text(
          "Cet assistant fournit des informations générales et vous oriente vers les officines disponibles. "
          "Il ne pose aucun diagnostic médical ni ne remplace une consultation d'urgence.",
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
