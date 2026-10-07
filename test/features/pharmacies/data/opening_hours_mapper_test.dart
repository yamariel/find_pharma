import 'package:find_pharma/features/pharmacies/data/models/opening_hours_mapper.dart';
import 'package:find_pharma/features/pharmacies/domain/entities/opening_hours.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> rangeDay(int open, int close) => <String, dynamic>{
    DayScheduleFields.type: DayScheduleFields.rangeType,
    DayScheduleFields.openMinute: open,
    DayScheduleFields.closeMinute: close,
  };

  const Map<String, dynamic> allDay = <String, dynamic>{
    DayScheduleFields.type: DayScheduleFields.allDayType,
  };

  const Map<String, dynamic> closedDay = <String, dynamic>{
    DayScheduleFields.type: DayScheduleFields.closedType,
  };

  group('OpeningHoursMapper.fromFirestore', () {
    test('lit les trois types de programme', () {
      final OpeningHours? hours = OpeningHoursMapper.fromFirestore(
        <String, dynamic>{
          '1': rangeDay(480, 1320),
          '2': allDay,
          '7': closedDay,
        },
      );

      expect(hours, isNotNull);
      expect(
        hours!.byWeekday[DateTime.monday],
        isA<OpenRange>()
            .having((OpenRange range) => range.openMinute, 'openMinute', 480)
            .having((OpenRange range) => range.closeMinute, 'closeMinute', 1320),
      );
      expect(hours.byWeekday[DateTime.tuesday], isA<AllDayOpen>());
      expect(hours.byWeekday[DateTime.sunday], isA<ClosedDay>());
    });

    test('ignore une cle qui n est pas un entier', () {
      final OpeningHours? hours = OpeningHoursMapper.fromFirestore(
        <String, dynamic>{'lundi': allDay, '2': allDay},
      );

      expect(hours!.byWeekday.keys, <int>[DateTime.tuesday]);
    });

    test('ignore un jour hors de la semaine', () {
      final OpeningHours? hours = OpeningHoursMapper.fromFirestore(
        <String, dynamic>{'0': allDay, '8': allDay, '3': allDay},
      );

      expect(hours!.byWeekday.keys, <int>[DateTime.wednesday]);
    });

    test('ignore un type de programme inconnu', () {
      final OpeningHours? hours = OpeningHoursMapper.fromFirestore(
        <String, dynamic>{
          '1': <String, dynamic>{DayScheduleFields.type: 'brunch'},
          '2': allDay,
        },
      );

      expect(hours!.byWeekday.containsKey(DateTime.monday), isFalse);
      expect(hours.byWeekday[DateTime.tuesday], isA<AllDayOpen>());
    });

    test('ignore une plage dont les minutes ne sont pas des entiers', () {
      final OpeningHours? hours = OpeningHoursMapper.fromFirestore(
        <String, dynamic>{
          '1': <String, dynamic>{
            DayScheduleFields.type: DayScheduleFields.rangeType,
            DayScheduleFields.openMinute: '08:00',
            DayScheduleFields.closeMinute: 1320,
          },
          '2': allDay,
        },
      );

      expect(hours!.byWeekday.containsKey(DateTime.monday), isFalse);
    });

    test('renvoie null quand la donnee n est pas une map', () {
      expect(OpeningHoursMapper.fromFirestore(null), isNull);
      expect(OpeningHoursMapper.fromFirestore('8h-22h'), isNull);
    });

    test('renvoie null quand aucun jour n est exploitable', () {
      expect(
        OpeningHoursMapper.fromFirestore(<String, dynamic>{'lundi': allDay}),
        isNull,
      );
    });
  });

  group('OpeningHoursMapper.toFirestore', () {
    test('serialise les trois variantes avec des cles de type chaine', () {
      final OpeningHours hours = OpeningHours(<int, DaySchedule>{
        DateTime.monday: const OpenRange(openMinute: 480, closeMinute: 1320),
        DateTime.tuesday: const AllDayOpen(),
        DateTime.sunday: const ClosedDay(),
      });

      final Map<String, dynamic> written = OpeningHoursMapper.toFirestore(
        hours,
      );

      expect(written['1'], rangeDay(480, 1320));
      expect(written['2'], allDay);
      expect(written['7'], closedDay);
    });
  });

  test('un aller-retour conserve les programmes', () {
    final Map<String, dynamic> source = <String, dynamic>{
      '1': rangeDay(480, 1320),
      '2': allDay,
      '7': closedDay,
    };

    final OpeningHours? hours = OpeningHoursMapper.fromFirestore(source);
    final Map<String, dynamic> written = OpeningHoursMapper.toFirestore(hours!);

    expect(written, source);
  });
}