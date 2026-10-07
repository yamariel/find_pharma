import '../../domain/entities/opening_hours.dart';

/// 450 -> "07h30". Minutes toujours sur deux chiffres, comme la maquette.
String clockLabel(int minuteOfDay) {
  final int hour = (minuteOfDay ~/ 60) % 24;
  final int minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}h'
      '${minute.toString().padLeft(2, '0')}';
}

/// Programme d'une journée, en toutes lettres.
///
/// `switch` exhaustif sur la classe scellée : une quatrième variante casserait
/// la compilation au lieu de tomber dans un cas par défaut silencieux.
String scheduleLabel(DaySchedule schedule) {
  return switch (schedule) {
    ClosedDay() => 'Fermé',
    AllDayOpen() => '24h/24',
    OpenRange(:final int openMinute, :final int closeMinute) =>
      '${clockLabel(openMinute)} – ${clockLabel(closeMinute)}',
  };
}

/// État d'ouverture à cet instant, pour une pastille.
String openStatusLabel(OpeningHours hours, DateTime moment) {
  final DaySchedule today = hours.scheduleFor(moment.weekday);
  if (today is AllDayOpen) return 'Ouvert 24h/24';
  if (!hours.isOpenAt(moment)) return 'Fermé';
  if (today is OpenRange) {
    return 'Ouvert jusqu\'à ${clockLabel(today.closeMinute)}';
  }
  return 'Ouvert';
}

/// Indexés par [DateTime.monday] à [DateTime.sunday], soit `weekday - 1`.
const List<String> weekdayNames = <String>[
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];