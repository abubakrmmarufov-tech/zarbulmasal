import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';

void main() {
  test('Month boundary skip fix', () {
    final jan31 = DateTime(2024, 1, 31);
    final feb1 = DateTime(2024, 2, 1);
    final feb29 = DateTime(2024, 2, 29);
    final mar1 = DateTime(2024, 3, 1);

    int getIndex(DateTime date, int length) {
      return (DateTime(
                date.year,
                date.month,
                date.day,
              ).millisecondsSinceEpoch ~/
              86400000) %
          length;
    }

    final len = seedProverbs.length;

    final iJan31 = getIndex(jan31, len);
    final iFeb1 = getIndex(feb1, len);
    final iFeb29 = getIndex(feb29, len);
    final iMar1 = getIndex(mar1, len);

    expect((iFeb1 - iJan31) % len, 1);
    expect((iMar1 - iFeb29) % len, 1);
  });
}
