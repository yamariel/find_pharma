import 'package:find_pharma/features/pharmacies/domain/entities/opening_hours.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClosedDay', () {
    const ClosedDay closed = ClosedDay();

    test("n'est jamais ouverte", () {
      expect(closed.isOpenAt(0), isFalse);
      expect(closed.isOpenAt(600), isFalse);
      expect(closed.isOpenAt(1439), isFalse);
    });

    test('ne déborde jamais après minuit', () {
      expect(closed.coversAfterMidnight(0), isFalse);
      expect(closed.coversAfterMidnight(60), isFalse);
    });
  });

  group('AllDayOpen', () {
    const AllDayOpen allDay = AllDayOpen();

    test('est ouverte à toute heure', () {
      expect(allDay.isOpenAt(0), isTrue);
      expect(allDay.isOpenAt(720), isTrue);
      expect(allDay.isOpenAt(1439), isTrue);
    });

    test("ne déborde pas après minuit : la journée suivante prend le relais", () {
      expect(allDay.coversAfterMidnight(0), isFalse);
      expect(allDay.coversAfterMidnight(60), isFalse);
    });
  });

  group('OpenRange sans franchissement de minuit, 8 h → 22 h', () {
    const OpenRange range = OpenRange(openMinute: 480, closeMinute: 1320);

    test('ne franchit pas minuit', () {
      expect(range.spansMidnight, isFalse);
    });

    test("est ouverte dès la minute d'ouverture", () {
      expect(range.isOpenAt(480), isTrue);
    });

    test('est encore ouverte une minute avant la fermeture', () {
      expect(range.isOpenAt(1319), isTrue);
    });

    test('est fermée à la minute de fermeture exacte', () {
      expect(range.isOpenAt(1320), isFalse);
    });

    test("est fermée une minute avant l'ouverture", () {
      expect(range.isOpenAt(479), isFalse);
    });

    test('ne déborde pas après minuit', () {
      expect(range.coversAfterMidnight(60), isFalse);
    });
  });

  group('OpenRange franchissant minuit, 20 h → 2 h', () {
    const OpenRange range = OpenRange(openMinute: 1200, closeMinute: 120);

    test('franchit minuit', () {
      expect(range.spansMidnight, isTrue);
    });

    test('est ouverte le soir', () {
      expect(range.isOpenAt(1200), isTrue);
      expect(range.isOpenAt(1439), isTrue);
    });

    test('est ouverte après minuit', () {
      expect(range.isOpenAt(0), isTrue);
      expect(range.isOpenAt(119), isTrue);
    });

    test('est fermée à la minute de fermeture exacte', () {
      expect(range.isOpenAt(120), isFalse);
    });

    test("est fermée en pleine journée", () {
      expect(range.isOpenAt(600), isFalse);
    });

    test('déborde après minuit, mais seulement avant la fermeture', () {
      expect(range.coversAfterMidnight(0), isTrue);
      expect(range.coversAfterMidnight(119), isTrue);
      expect(range.coversAfterMidnight(120), isFalse);
      expect(range.coversAfterMidnight(1300), isFalse);
    });
  });

  group('OpenRange.fromClock', () {
    test('convertit les heures en minutes depuis minuit', () {
      const OpenRange range = OpenRange.fromClock(openHour: 8, closeHour: 22);

      expect(range.openMinute, 480);
      expect(range.closeMinute, 1320);
    });

    test('tient compte des minutes', () {
      const OpenRange range = OpenRange.fromClock(
        openHour: 8,
        openMinutes: 30,
        closeHour: 19,
        closeMinutes: 45,
      );

      expect(range.openMinute, 510);
      expect(range.closeMinute, 1185);
    });

    test('produit un objet égal au constructeur direct', () {
      expect(
        const OpenRange.fromClock(openHour: 8, closeHour: 22),
        const OpenRange(openMinute: 480, closeMinute: 1320),
      );
    });
  });

  group('OpeningHours', () {
    test('un jour absent de la map est considéré comme fermé', () {
      const OpeningHours hours = OpeningHours(<int, DaySchedule>{});

      expect(hours.scheduleFor(DateTime.monday), const ClosedDay());
    });

    test('uniform applique le même programme aux sept jours', () {
      final OpeningHours hours = OpeningHours.uniform(const AllDayOpen());

      for (int weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
        expect(hours.scheduleFor(weekday), const AllDayOpen());
      }
    });

    test('est ouverte pendant la plage du jour courant', () {
      final OpeningHours hours = OpeningHours.uniform(
        const OpenRange.fromClock(openHour: 8, closeHour: 22),
      );

      // Mardi 6 octobre 2026, 10 h.
      expect(hours.isOpenAt(DateTime(2026, 10, 6, 10)), isTrue);
    });

    test('est fermée en dehors de la plage du jour courant', () {
      final OpeningHours hours = OpeningHours.uniform(
        const OpenRange.fromClock(openHour: 8, closeHour: 22),
      );

      expect(hours.isOpenAt(DateTime(2026, 10, 6, 23)), isFalse);
    });

    test(
      "à 1 h du matin, c'est la plage de la veille qui décide quand elle franchit minuit",
      () {
        const OpeningHours hours = OpeningHours(<int, DaySchedule>{
          DateTime.monday: OpenRange(openMinute: 1200, closeMinute: 120),
          DateTime.tuesday: ClosedDay(),
        });

        // Mardi 6 octobre 2026, 1 h — la pharmacie a ouvert lundi à 20 h.
        expect(hours.isOpenAt(DateTime(2026, 10, 6, 1)), isTrue);
      },
    );

    test(
      "une veille ouverte 24 h ne rend pas le lendemain ouvert",
      () {
        const OpeningHours hours = OpeningHours(<int, DaySchedule>{
          DateTime.monday: AllDayOpen(),
          DateTime.tuesday: ClosedDay(),
        });

        expect(hours.isOpenAt(DateTime(2026, 10, 6, 1)), isFalse);
      },
    );

    test('deux horaires identiques sont égaux et partagent leur hashCode', () {
      final OpeningHours first = OpeningHours.uniform(const AllDayOpen());
      final OpeningHours second = OpeningHours.uniform(const AllDayOpen());

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('un jour différent casse l\'égalité', () {
      const OpeningHours first = OpeningHours(<int, DaySchedule>{
        DateTime.monday: AllDayOpen(),
      });
      const OpeningHours second = OpeningHours(<int, DaySchedule>{
        DateTime.monday: ClosedDay(),
      });

      expect(first, isNot(second));
    });
  });
}