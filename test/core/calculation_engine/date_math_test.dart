import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/calculation_engine/date_math.dart';

void main() {
  group('daysBetween', () {
    test('same calendar day at different times yields 0', () {
      expect(
        daysBetween(DateTime(2024, 7, 1, 8), DateTime(2024, 7, 1, 23, 30)),
        0,
      );
    });

    test('is DST-safe across the spring-forward transition', () {
      // US spring-forward is 2024-03-10; a 23-hour local day must still count
      // as one day.
      expect(daysBetween(DateTime(2024, 3, 9), DateTime(2024, 3, 11)), 2);
    });

    test('is DST-safe across the fall-back transition', () {
      // US fall-back is 2024-11-03; a 25-hour local day must still count as one.
      expect(daysBetween(DateTime(2024, 11, 2), DateTime(2024, 11, 4)), 2);
    });

    test('counts Feb 29 in a leap year', () {
      expect(daysBetween(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 2);
    });

    test('has no Feb 29 in a non-leap year', () {
      expect(daysBetween(DateTime(2023, 2, 28), DateTime(2023, 3, 1)), 1);
    });

    test('is negative when the target is in the past', () {
      expect(daysBetween(DateTime(2024, 7, 10), DateTime(2024, 7, 5)), -5);
    });
  });

  group('lastDayOfMonth / daysRemainingInMonth', () {
    test('February has 29 days in a leap year', () {
      expect(lastDayOfMonth(DateTime(2024, 2, 10)).day, 29);
    });

    test('February has 28 days in a non-leap year', () {
      expect(lastDayOfMonth(DateTime(2023, 2, 10)).day, 28);
    });

    test('counts days left to end of month', () {
      expect(daysRemainingInMonth(DateTime(2024, 7, 22)), 9); // 31 - 22
    });

    test('is 0 on the last day of the month', () {
      expect(daysRemainingInMonth(DateTime(2024, 7, 31)), 0);
    });
  });

  group('nextReadingDate', () {
    test('returns this month when the day has not passed', () {
      expect(
        nextReadingDate(15, from: DateTime(2024, 7, 10)),
        DateTime(2024, 7, 15),
      );
    });

    test('includes today (not strictly before)', () {
      expect(
        nextReadingDate(15, from: DateTime(2024, 7, 15)),
        DateTime(2024, 7, 15),
      );
    });

    test('rolls to next month when the day has passed', () {
      expect(
        nextReadingDate(15, from: DateTime(2024, 7, 22)),
        DateTime(2024, 8, 15),
      );
    });

    test('rolls across a year boundary', () {
      expect(
        nextReadingDate(15, from: DateTime(2024, 12, 20)),
        DateTime(2025, 1, 15),
      );
    });

    test('clamps day 31 to the length of a short month', () {
      expect(
        nextReadingDate(31, from: DateTime(2024, 2, 10)),
        DateTime(2024, 2, 29), // leap February
      );
    });
  });

  group('previousReadingDate', () {
    test('returns this month when the day has already passed', () {
      expect(
        previousReadingDate(15, from: DateTime(2026, 7, 25)),
        DateTime(2026, 7, 15),
      );
    });

    test('is strictly before, so the scheduled day itself rolls back a month', () {
      // A reading taken exactly on the scheduled day closes the cycle that
      // opened the previous month; resolving to itself would be a zero span.
      expect(
        previousReadingDate(15, from: DateTime(2026, 7, 15)),
        DateTime(2026, 6, 15),
      );
    });

    test('rolls back a month when the day has not arrived yet', () {
      expect(
        previousReadingDate(15, from: DateTime(2026, 7, 10)),
        DateTime(2026, 6, 15),
      );
    });

    test('rolls back across a year boundary', () {
      expect(
        previousReadingDate(15, from: DateTime(2026, 1, 10)),
        DateTime(2025, 12, 15),
      );
    });

    test('clamps day 31 to the length of a short month', () {
      expect(
        previousReadingDate(31, from: DateTime(2026, 3, 5)),
        DateTime(2026, 2, 28),
      );
    });
  });
}
