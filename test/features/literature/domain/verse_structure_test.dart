import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/verse_structure.dart';

void main() {
  group('coherentVerseLines', () {
    test('drops pure-parenthesis attribution lines', () {
      expect(
        coherentVerseLines(
          'Шоири фарзонаро асру замон\n'
          'Бар ниёзи хештан меоварад.\n'
          'Модаре танҳо назояд шоире,\n'
          'Халқ ӯро баҳри худ меофарад.\n'
          '(Лоиқ Шералӣ)',
        ),
        [
          'Шоири фарзонаро асру замон',
          'Бар ниёзи хештан меоварад.',
          'Модаре танҳо назояд шоире,',
          'Халқ ӯро баҳри худ меофарад.',
        ],
      );
    });

    test('drops an obvious truncated prose-gloss line', () {
      expect(
        coherentVerseLines(
          'Майлам ба шароби ноб бошад доим,\n'
          'Гӯшам ба наю рубоб бошад доим.\n'
          'Гар хоки маро кӯзагарон кӯза кунанд,\n'
          'Он кӯза пур аз шароб бошад доим.\n'
          'Хайём гуфтааст, ки агар лавҳаи қазо (тақдир, сарнавишт) дар',
        ),
        [
          'Майлам ба шароби ноб бошад доим,',
          'Гӯшам ба наю рубоб бошад доим.',
          'Гар хоки маро кӯзагарон кӯза кунанд,',
          'Он кӯза пур аз шароб бошад доим.',
        ],
      );
    });

    test('keeps parenthetical text inside a genuine hemistich', () {
      expect(
        coherentVerseLines(
          'Майлам ба шароби ноб бошад доим,\n'
          'Гӯшам ба наю рубоб бошад доим.\n'
          'Гар хоки маро (эҳ, азиз) кӯзагарон кӯза кунанд,\n'
          'Он кӯза пур аз шароб бошад доим.',
        ),
        hasLength(4),
      );
      expect(
        isAppendedNoiseLine('Гар хоки маро (эҳ, азиз) кӯзагарон кӯза кунанд,'),
        isFalse,
      );
    });

    test('keeps short legitimate verse lines', () {
      expect(
        coherentVerseLines(
          'Бӯи ҷӯи Мӯлиён ояд ҳаме,\n'
          'Ёди ёри мӯлиён ояд ҳаме,\n'
          'Абрӯи яккаи ҷаҳон ояд ҳаме.',
        ),
        hasLength(3),
      );
    });

    test('an attribution-only text yields no verse lines', () {
      expect(coherentVerseLines('(Лоиқ Шералӣ)'), isEmpty);
    });
  });
}
