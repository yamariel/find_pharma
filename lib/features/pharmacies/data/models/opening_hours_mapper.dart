import '../../domain/entities/opening_hours.dart';

/// Noms des champs d'un programme journalier dans Firestore.
abstract final class DayScheduleFields {
  static const String type = 'type';
  static const String openMinute = 'openMinute';
  static const String closeMinute = 'closeMinute';

  static const String closedType = 'closed';
  static const String allDayType = 'allDay';
  static const String rangeType = 'range';
}

/// Traduit [OpeningHours] entre le domaine et Firestore.
abstract final class OpeningHoursMapper {
  /// Renvoie `null` si la donnée est absente ou illisible : horaires
  /// **inconnus**, ce qui n'est pas la même chose que fermé.
  static OpeningHours? fromFirestore(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }

    final Map<int, DaySchedule> byWeekday = <int, DaySchedule>{};
    for (final MapEntry<String, dynamic> entry in raw.entries) {
      final int? weekday = int.tryParse(entry.key);
      if (weekday == null ||
          weekday < DateTime.monday ||
          weekday > DateTime.sunday) {
        continue;
      }
      final DaySchedule? schedule = _scheduleFromFirestore(entry.value);
      if (schedule != null) {
        byWeekday[weekday] = schedule;
      }
    }

    if (byWeekday.isEmpty) {
      return null;
    }
    return OpeningHours(byWeekday);
  }

  static Map<String, dynamic> toFirestore(OpeningHours openingHours) {
    return <String, dynamic>{
      for (final MapEntry<int, DaySchedule> entry
          in openingHours.byWeekday.entries)
        entry.key.toString(): _scheduleToFirestore(entry.value),
    };
  }

  static DaySchedule? _scheduleFromFirestore(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }

    switch (raw[DayScheduleFields.type]) {
      case DayScheduleFields.closedType:
        return const ClosedDay();
      case DayScheduleFields.allDayType:
        return const AllDayOpen();
      case DayScheduleFields.rangeType:
        final Object? open = raw[DayScheduleFields.openMinute];
        final Object? close = raw[DayScheduleFields.closeMinute];
        if (open is! int || close is! int) {
          return null;
        }
        return OpenRange(openMinute: open, closeMinute: close);
      default:
        return null;
    }
  }

  static Map<String, dynamic> _scheduleToFirestore(DaySchedule schedule) {
    return switch (schedule) {
      ClosedDay() => <String, dynamic>{
        DayScheduleFields.type: DayScheduleFields.closedType,
      },
      AllDayOpen() => <String, dynamic>{
        DayScheduleFields.type: DayScheduleFields.allDayType,
      },
      OpenRange(:final int openMinute, :final int closeMinute) =>
        <String, dynamic>{
          DayScheduleFields.type: DayScheduleFields.rangeType,
          DayScheduleFields.openMinute: openMinute,
          DayScheduleFields.closeMinute: closeMinute,
        },
    };
  }
}