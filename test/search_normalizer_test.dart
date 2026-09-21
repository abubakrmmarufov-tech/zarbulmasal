import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/utils/search_normalizer.dart';

void main() {
  group('SearchNormalizer', () {
    test('normalizes Tajik Cyrillic letters with macrons and descenders', () {
      expect(SearchNormalizer.normalize('ЗАРБУЛМАСАЛ'), 'зарбулмасал');
      expect(SearchNormalizer.normalize('кӯҳ'), 'кух');
      expect(SearchNormalizer.normalize('модарӣ'), 'модари');
      expect(SearchNormalizer.normalize('ғайрат'), 'гайрат');
      expect(SearchNormalizer.normalize('қалам'), 'калам');
      expect(SearchNormalizer.normalize('ҷаҳон'), 'чахон');
      expect(SearchNormalizer.normalize('ҳурмат'), 'хурмат');
      expect(SearchNormalizer.normalize('ҳаёт'), 'хает'); // ё to е
    });

    test('handles Tajik apostrophe variations', () {
      expect(SearchNormalizer.normalize("маъно"), 'мано');
      expect(SearchNormalizer.normalize("ма’но"), 'мано');
      expect(SearchNormalizer.normalize("ма‘но"), 'мано');
      expect(SearchNormalizer.normalize("маʻно"), 'мано');
      expect(SearchNormalizer.normalize("баъд"), 'бад');
    });

    test('normalizes Persian ZWNJ, Arabic Yeh and Kaf', () {
      expect(SearchNormalizer.normalize('می‌شود'), 'میشود');
      expect(SearchNormalizer.normalize('ضرب‌المثل'), 'ضربالمثل');
      expect(SearchNormalizer.normalize('علي'), 'علی');
      expect(SearchNormalizer.normalize('كتاب'), 'کتاب');
      expect(SearchNormalizer.normalize('آب'), 'اب');
    });

    test('normalizes Persian digits to ASCII', () {
      expect(SearchNormalizer.normalize('۱۲۳'), '123');
      expect(SearchNormalizer.normalize('۴۵۶'), '456');
    });

    test('matches queries with and without diacritics', () {
      // User types without diacritics
      expect(SearchNormalizer.matches('Калонро ҳурмат кун', 'хурмат'), isTrue);
      expect(SearchNormalizer.matches('Калонро ҳурмат кун', 'ҳурмат'), isTrue);
      expect(
        SearchNormalizer.matches('Дониш андар дил чароғи равшан аст', 'чароги'),
        isTrue,
      );
      expect(
        SearchNormalizer.matches('Дониш андар дил чароғи равшан аст', 'диле'),
        isFalse,
      );

      // Persian without ZWNJ matches text with ZWNJ
      expect(SearchNormalizer.matches('می‌شود', 'میشود'), isTrue);
      expect(SearchNormalizer.matches('ضرب‌المثل', 'ضرب المثل'), isTrue);
      expect(SearchNormalizer.matches('کتاب', 'كتاب'), isTrue);
    });

    test('transliterates Latin queries and matches Tajik Cyrillic content', () {
      expect(SearchNormalizer.latinToTajikCyrillic('rudaki'), 'рудаки');
      expect(SearchNormalizer.latinToTajikCyrillic('khayyam'), 'хайем');
      expect(SearchNormalizer.latinToTajikCyrillic('sino'), 'сино');
      expect(SearchNormalizer.latinToTajikCyrillic('somoniyon'), 'сомониен');
      expect(
        SearchNormalizer.latinToTajikCyrillic('zarbulmasal'),
        'зарбулмасал',
      );

      // Matching target with Latin input
      expect(SearchNormalizer.matches('Абӯабдуллоҳи Рӯдакӣ', 'rudaki'), isTrue);
      expect(SearchNormalizer.matches('Умари Хайём', 'khayyam'), isTrue);
      expect(SearchNormalizer.matches('Абӯалӣ ибни Сино', 'sino'), isTrue);
      expect(SearchNormalizer.matches('Давлати Сомониён', 'somoniyon'), isTrue);
      expect(
        SearchNormalizer.matches('Зарбулмасалҳои тоҷикӣ', 'zarbulmasal'),
        isTrue,
      );
      expect(SearchNormalizer.matches('Ҳофизи Шерозӣ', 'hafiz'), isTrue);
      expect(SearchNormalizer.matches('Абдурраҳмони Ҷомӣ', 'jami'), isTrue);
    });

    test('relevance scoring ranks exact > normalized > prefix > partial', () {
      final exactScore = SearchNormalizer.scoreMatch('Рӯдакӣ', 'Рӯдакӣ');
      final normScore = SearchNormalizer.scoreMatch('Рӯдакӣ', 'рудаки');
      final prefixScore = SearchNormalizer.scoreMatch(
        'Рӯдакӣ ва замони ӯ',
        'рудаки',
      );
      final wordPrefixScore = SearchNormalizer.scoreMatch(
        'Шеъри Рӯдакӣ дар мактаб',
        'рудаки',
      );
      final midWordPartialScore = SearchNormalizer.scoreMatch(
        'Самарқандиён',
        'канд',
      );
      final noScore = SearchNormalizer.scoreMatch('Фирдавсӣ', 'рудаки');

      expect(exactScore, equals(100));
      expect(normScore, equals(90));
      expect(prefixScore, equals(65));
      expect(wordPrefixScore, equals(50));
      expect(midWordPartialScore, equals(35));
      expect(noScore, equals(0));

      expect(exactScore, greaterThan(normScore));
      expect(normScore, greaterThan(prefixScore));
      expect(prefixScore, greaterThan(wordPrefixScore));
      expect(wordPrefixScore, greaterThan(midWordPartialScore));
      expect(midWordPartialScore, greaterThan(noScore));

      // scoreMatchAny returns highest score
      expect(
        SearchNormalizer.scoreMatchAny(['Фирдавсӣ', 'Рӯдакӣ'], 'рудаки'),
        equals(90),
      );
    });
  });
}
