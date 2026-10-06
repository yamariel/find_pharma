import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> callPharmacy(BuildContext context, String phone) async {
  try {
    if (await launchUrl(Uri(scheme: 'tel', path: phone))) return;
  } catch (_) {
    // Le composeur téléphonique n'est pas disponible sur toutes les plateformes.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Impossible d'ouvrir l'application téléphone."),
    ),
  );
}
