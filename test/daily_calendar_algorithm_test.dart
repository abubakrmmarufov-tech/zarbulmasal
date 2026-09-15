import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  group('Daily Calendar Algorithm (DATE-001)', () {
    const catalogSize = 150;

    test(
      'consecutive days advance index by exactly one across all month boundaries',
      () {
        // Test entire non-leap year (e.g. 2023)
        var current = DateTime(2023, 1, 1);
        final end = DateTime(2023, 12, 31);

        while (current.isBefore(end)) {
          final next = current.add(const Duration(days: 1));
          final idxCurrent = calendarDayIndex(current, catalogSize);
          final idxNext = calendarDayIndex(next, catalogSize);

          final expectedNext = (idxCurrent + 1) % catalogSize;
          expect(
            idxNext,
            expectedNext,
            reason:
                'Failed transition from $current to $next: current=$idxCurrent, next=$idxNext',
          );
          current = next;
        }
      },
    );

    test('handles leap year seamlessly (Feb 28 -> Feb 29 -> Mar 1)', () {
      final feb28 = DateTime(2024, 2, 28);
      final feb29 = DateTime(2024, 2, 29);
      final mar01 = DateTime(2024, 3, 1);

      final idx28 = calendarDayIndex(feb28, catalogSize);
      final idx29 = calendarDayIndex(feb29, catalogSize);
      final idx01 = calendarDayIndex(mar01, catalogSize);

      expect(idx29, (idx28 + 1) % catalogSize);
      expect(idx01, (idx29 + 1) % catalogSize);
    });

    test('handles year boundaries seamlessly (Dec 31 -> Jan 1)', () {
      final dec31 = DateTime(2025, 12, 31);
      final jan01 = DateTime(2026, 1, 1);

      final idxDec = calendarDayIndex(dec31, catalogSize);
      final idxJan = calendarDayIndex(jan01, catalogSize);

      expect(idxJan, (idxDec + 1) % catalogSize);
    });

    test(
      'month boundaries with 30 days do not skip proverbs (Apr 30 -> May 1)',
      () {
        final apr30 = DateTime(2026, 4, 30);
        final may01 = DateTime(2026, 5, 1);

        final idxApr = calendarDayIndex(apr30, catalogSize);
        final idxMay = calendarDayIndex(may01, catalogSize);

        expect(idxMay, (idxApr + 1) % catalogSize);
      },
    );

    test(
      'handles 31-day month boundaries (Jan 31 -> Feb 1, Jul 31 -> Aug 1)',
      () {
        final jan31 = DateTime(2026, 1, 31);
        final feb01 = DateTime(2026, 2, 1);

        final idxJan = calendarDayIndex(jan31, catalogSize);
        final idxFeb = calendarDayIndex(feb01, catalogSize);

        expect(idxFeb, (idxJan + 1) % catalogSize);

        final jul31 = DateTime(2026, 7, 31);
        final aug01 = DateTime(2026, 8, 1);

        final idxJul = calendarDayIndex(jul31, catalogSize);
        final idxAug = calendarDayIndex(aug01, catalogSize);

        expect(idxAug, (idxJul + 1) % catalogSize);
      },
    );

    test('handles empty catalog safely returning 0', () {
      expect(calendarDayIndex(DateTime.now(), 0), 0);
      expect(calendarDayIndex(DateTime.now(), -1), 0);
    });
  });
}
