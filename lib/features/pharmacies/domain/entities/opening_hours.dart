/// Ces horaires décrivent l'ouverture **habituelle**. Ils ne disent rien de la
/// garde, qui est une information temporelle portée par un calendrier séparé.
/// Ne jamais filtrer les pharmacies de garde avec ces horaires.
library;
/// Programme d'une journée : fermée, ouverte en continu, ou ouverte sur une plage.
sealed class DaySchedule {
  const DaySchedule();

  /// Vrai si la pharmacie est ouverte à cette minute de la journée courante.
  bool isOpenAt(int minuteOfDay);

  /// Vrai si cette journée déborde après minuit et couvre encore cette minute
  /// le lendemain matin.
  bool coversAfterMidnight(int minuteOfDay);
}

/// Jour de fermeture complète.
final class ClosedDay extends DaySchedule {
  const ClosedDay();

  @override
  bool isOpenAt(int minuteOfDay) => false;

  @override
  bool coversAfterMidnight(int minuteOfDay) => false;

  @override
  bool operator ==(Object other) => other is ClosedDay;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'ClosedDay()';
}

/// Ouverture continue, 24 h sur 24.
///
/// Une journée continue s'arrête quand même à minuit : c'est le programme du
/// jour suivant qui prend le relais, d'où `coversAfterMidnight` à `false`.
final class AllDayOpen extends DaySchedule {
  const AllDayOpen();

  @override
  bool isOpenAt(int minuteOfDay) => true;

  @override
  bool coversAfterMidnight(int minuteOfDay) => false;

  @override
  bool operator ==(Object other) => other is AllDayOpen;

  @override
  int get hashCode => 1;

  @override
  String toString() => 'AllDayOpen()';
}

/// Ouverture sur une plage horaire.
///
/// Si [closeMinute] est inférieure ou égale à [openMinute], la plage franchit
/// minuit — par exemple 20 h → 2 h.
final class OpenRange extends DaySchedule {
  const OpenRange({required this.openMinute, required this.closeMinute});

  /// Construction lisible depuis des heures d'horloge.
  const OpenRange.fromClock({
    required int openHour,
    required int closeHour,
    int openMinutes = 0,
    int closeMinutes = 0,
  }) : openMinute = openHour * 60 + openMinutes,
       closeMinute = closeHour * 60 + closeMinutes;

  final int openMinute;
  final int closeMinute;

  bool get spansMidnight => closeMinute <= openMinute;

  @override
  bool isOpenAt(int minuteOfDay) {
    if (spansMidnight) {
      return minuteOfDay >= openMinute || minuteOfDay < closeMinute;
    }
    return minuteOfDay >= openMinute && minuteOfDay < closeMinute;
  }

  @override
  bool coversAfterMidnight(int minuteOfDay) {
    return spansMidnight && minuteOfDay < closeMinute;
  }

  @override
  bool operator ==(Object other) {
    return other is OpenRange &&
        other.openMinute == openMinute &&
        other.closeMinute == closeMinute;
  }

  @override
  int get hashCode => Object.hash(openMinute, closeMinute);

  @override
  String toString() => 'OpenRange($openMinute, $closeMinute)';
}

/// Les sept jours de la semaine d'une pharmacie.
class OpeningHours {
  const OpeningHours(this.byWeekday);

  /// Même programme tous les jours.
  factory OpeningHours.uniform(DaySchedule schedule) {
    return OpeningHours(<int, DaySchedule>{
      DateTime.monday: schedule,
      DateTime.tuesday: schedule,
      DateTime.wednesday: schedule,
      DateTime.thursday: schedule,
      DateTime.friday: schedule,
      DateTime.saturday: schedule,
      DateTime.sunday: schedule,
    });
  }

  /// Clés : les constantes [DateTime.monday] à [DateTime.sunday], soit 1 à 7.
  /// Un jour absent est considéré comme fermé.
  final Map<int, DaySchedule> byWeekday;

  DaySchedule scheduleFor(int weekday) {
    return byWeekday[weekday] ?? const ClosedDay();
  }

  /// Vrai si la pharmacie est ouverte à cet instant, selon ses horaires
  /// habituels — la garde n'entre pas dans ce calcul.
  bool isOpenAt(DateTime moment) {
    final int minuteOfDay = moment.hour * 60 + moment.minute;

    if (scheduleFor(moment.weekday).isOpenAt(minuteOfDay)) {
      return true;
    }

    final int previousWeekday = moment.weekday == DateTime.monday
        ? DateTime.sunday
        : moment.weekday - 1;

    return scheduleFor(previousWeekday).coversAfterMidnight(minuteOfDay);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OpeningHours) return false;
    for (int weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      if (scheduleFor(weekday) != other.scheduleFor(weekday)) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hashAll(<DaySchedule>[
      for (int weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
        scheduleFor(weekday),
    ]);
  }
}