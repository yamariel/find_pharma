// Couleurs et fonctions de formatage propres à la feature médicaments.
import 'package:flutter/material.dart';

/// Couleurs reprises de la maquette FindPharma.
class MedicineColors {
  static const primary = Color(0xFF0B6B52);
  static const primaryLight = Color(0xFFD6F0E6);
  static const background = Color(0xFFF1FAF6);
  static const surface = Colors.white;
  static const tileGrey = Color(0xFFEEF3F1);
  static const textMuted = Color(0xFF5E6B66);
  static const success = Color(0xFF1E8E5A);
}

/// 1250 -> "1 250 CFA"
String formatCfa(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '$b CFA';
}

/// Duration -> "il y a 3 h"
String timeAgo(Duration d) {
  if (d.inMinutes < 60) return 'il y a ${d.inMinutes < 1 ? 1 : d.inMinutes} min';
  if (d.inHours < 24) return 'il y a ${d.inHours} h';
  return 'il y a ${d.inDays} j';
}

/// 0.65 -> "650 m", 1.4 -> "1.4 km"
String formatDistance(double km) =>
    km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';
