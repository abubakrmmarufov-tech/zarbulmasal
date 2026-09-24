import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/data/tajikistan_day.dart';

void main() {
  group('tajikistanCalendarDay', () {
    test('rolls over at 19:00 UTC (00:00 the next day in Tajikistan)', () {
      expect(
        tajikistanCalendarDay(DateTime.utc(2026, 9, 10, 18, 59, 59)),
        DateTime.utc(2026, 9, 10),
      );
      expect(
        tajikistanCalendarDay(DateTime.utc(2026, 9, 10, 19, 0, 0)),
        DateTime.utc(2026, 9, 11),
      );
    });

    test(
      'is identical for the same absolute instant expressed in any offset',
      () {
        // 19:30 UTC on 2026-09-10 is 00:30 on 2026-09-11 in Dushanbe.
        final utc = DateTime.utc(2026, 9, 10, 19, 30);
        final expected = DateTime.utc(2026, 9, 11);
        // A device-local clock at any offset shows this same absolute instant;
        // `isUtc: false` forces the local representation on this machine.
        final localSameInstant = DateTime.fromMicrosecondsSinceEpoch(
          utc.microsecondsSinceEpoch,
          isUtc: false,
        );
        expect(tajikistanCalendarDay(utc), expected);
        expect(tajikistanCalendarDay(localSameInstant), expected);
      },
    );

    test(
      'keeps a mid-morning UTC instant on the same Tajikistan calendar day',
      () {
        expect(
          tajikistanCalendarDay(DateTime.utc(2026, 9, 10, 12, 0)),
          DateTime.utc(2026, 9, 10),
        );
      },
    );
  });

  group('tajikistanDayIndex', () {
    test('advances exactly one step across the 19:00 UTC rollover', () {
      final before = tajikistanDayIndex(
        DateTime.utc(2026, 9, 10, 18, 59, 59),
        365,
      );
      final after = tajikistanDayIndex(
        DateTime.utc(2026, 9, 10, 19, 0, 0),
        365,
      );
      expect(after, (before + 1) % 365);
    });

    test('is gapless across month and year boundaries', () {
      final endOfMonth = tajikistanDayIndex(DateTime.utc(2026, 1, 31, 12), 365);
      final startOfMonth = tajikistanDayIndex(
        DateTime.utc(2026, 2, 1, 12),
        365,
      );
      expect(startOfMonth, (endOfMonth + 1) % 365);

      final newYearEve = tajikistanDayIndex(
        DateTime.utc(2025, 12, 31, 12),
        365,
      );
      final newYear = tajikistanDayIndex(DateTime.utc(2026, 1, 1, 12), 365);
      expect(newYear, (newYearEve + 1) % 365);
    });

    test('returns zero for an empty catalog', () {
      expect(tajikistanDayIndex(DateTime.utc(2026, 9, 10, 12), 0), 0);
      expect(tajikistanDayIndex(DateTime.utc(2026, 9, 10, 12), -3), 0);
    });
  });

  group('tajikistanDayProvider', () {
    test('derives the day from the injectable clock', () {
      final container = ProviderContainer(
        overrides: [
          systemInstantClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 9, 10, 19, 0, 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(tajikistanDayProvider), DateTime.utc(2026, 9, 11));
    });

    test('falls back to the real clock when not overridden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final today = tajikistanCalendarDay(DateTime.now());
      expect(container.read(tajikistanDayProvider), today);
    });
  });
}
