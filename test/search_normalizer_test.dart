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
  });
}
