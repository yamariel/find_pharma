import 'package:intl/intl.dart';

class DateFormatter {
  // formate une date au format court
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // formate une heure
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // formate une date avec l'heure
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(date);
  }

  // transforme une chaîne de caractères en DateTime de manière sécurisée
  static DateTime? parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}