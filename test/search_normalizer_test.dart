import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/utils/search_normalizer.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/domain/literature_search.dart';

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

  group('any keyboard', () {
    test('a run of one letter finds nothing', () {
      for (final query in ['ққққққ', 'kkkkkk', 'ааааа']) {
        expect(
          SearchNormalizer.matchesOnAnyKeyboard('Калонро ҳурмат кун', query),
          isFalse,
          reason: query,
        );
      }
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Абӯабдуллоҳи Рӯдакӣ', 'Rudakki'),
        isTrue,
      );
    });

    test('only poet and poem searches forgive typos and word order', () {
      // History, vocabulary and proverbs use [matches]: «Бухоро» must not
      // find «Бухорӣ», and words must stay in order.
      expect(SearchNormalizer.matches('Имом Бухорӣ', 'Бухоро'), isFalse);
      expect(SearchNormalizer.matches('дил андар дониш', 'дониш дил'), isFalse);
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Имом Бухорӣ', 'Бухоро'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('дил андар дониш', 'дониш дил'),
        isTrue,
      );
    });

    test('a Russian keyboard finds Tajik letters it lacks', () {
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Абӯабдуллоҳи Рӯдакӣ', 'Рудаки'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Бӯйи Ҷӯйи Мулиён', 'буйи чуйи'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Умари Хайём', 'Хайям'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Абдурраҳмони Ҷомӣ', 'Джами'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Ҳофизи Шерозӣ', 'Хафиз'),
        isTrue,
      );
      expect(SearchNormalizer.matchesOnAnyKeyboard('Саъдӣ', 'Сади'), isTrue);
      expect(SearchNormalizer.matchesOnAnyKeyboard('Эй дил', 'ей дил'), isTrue);
    });

    test('Persian keyboard: Arabic letters, harakat, tatweel, ZWNJ', () {
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('سعدی شیرازی', 'سعدي'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('کمال خجندی', 'كمال'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('حافظ شیرازی', 'حافـظ'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('حافظ شیرازی', 'حافِظ'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'میرزا تورسون‌زاده',
          'تورسونزاده',
        ),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('مؤمن قناعت', 'مومن'),
        isTrue,
      );
      expect(SearchNormalizer.matchesOnAnyKeyboard('عمر خیام', 'خيام'), isTrue);
      expect(SearchNormalizer.matchesOnAnyKeyboard('موسى', 'موسی'), isTrue);
    });

    test('a Persian query finds Tajik Cyrillic text by its consonants', () {
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Бӯйи Ҷӯйи Мулиён ояд ҳаме',
          'بوی جوی مولیان',
        ),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Ба сухан монад шеъри шуаро',
          'شعر شعرا',
        ),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Абӯабдуллоҳи Рӯдакӣ', 'رودکی'),
        isTrue,
      );
      // Too short to compare by consonants alone.
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Бӯйи Ҷӯйи Мулиён', 'بو'),
        isFalse,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Бӯйи Ҷӯйи Мулиён', 'حافظ'),
        isFalse,
      );
    });

    test('Latin spellings, any case, with hyphens or apostrophes', () {
      const rudaki = 'Абӯабдуллоҳи Рӯдакӣ';
      for (final query in ['Rudaki', 'rudakiy', 'Rūdakī', 'RUDAKI']) {
        expect(
          SearchNormalizer.matchesOnAnyKeyboard(rudaki, query),
          isTrue,
          reason: query,
        );
      }
      for (final query in ['Ayni', 'Aini', 'ayniy']) {
        expect(
          SearchNormalizer.matchesOnAnyKeyboard('Садриддин Айнӣ', query),
          isTrue,
          reason: query,
        );
      }
      for (final query in ['Jomi', 'Jami', 'Djami']) {
        expect(
          SearchNormalizer.matchesOnAnyKeyboard('Абдурраҳмони Ҷомӣ', query),
          isTrue,
          reason: query,
        );
      }
      for (final query in ['Khayyom', 'Khayyam', 'Xayyom', 'khayy']) {
        expect(
          SearchNormalizer.matchesOnAnyKeyboard('Умари Хайём', query),
          isTrue,
          reason: query,
        );
      }
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Абулқосими Фирдавсӣ',
          'Ferdowsi',
        ),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Абулқосими Фирдавсӣ',
          'Firdausi',
        ),
        isTrue,
      );
      expect(SearchNormalizer.matchesOnAnyKeyboard('Саъдӣ', "Sa'di"), isTrue);
      expect(SearchNormalizer.matchesOnAnyKeyboard('Саъдӣ', 'Saadi'), isTrue);
      expect(SearchNormalizer.matchesOnAnyKeyboard('Ҳофиз', 'Hafez'), isTrue);
      expect(SearchNormalizer.matchesOnAnyKeyboard('Бедил', 'Bidel'), isTrue);
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Абуалӣ ибни Сино',
          'Abu-Ali ibn Sino',
        ),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Мир Алишер Навоӣ', 'Navai'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Лоиқ Шералӣ', 'Loiq'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Садриддин Айнӣ', 'Rudaki'),
        isFalse,
      );
    });

    test('every word of the query must be found, in part or whole', () {
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Абӯабдуллоҳи Рӯдакӣ', 'Рӯдак'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Агар он турки шерозӣ ба даст орад',
          'турк шероз',
        ),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Агар он турки шерозӣ ба даст орад',
          'турк Рӯдакӣ',
        ),
        isFalse,
      );
    });

    test('one typo is forgiven in words of five letters or more', () {
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Абӯабдуллоҳи Рӯдакӣ', 'Рудаик'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Мирзо Турсунзода', 'Турсунзада'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Мирзо Турсунзода', 'Tursunzade'),
        isTrue,
      );
      expect(
        SearchNormalizer.matchesOnAnyKeyboard(
          'Абулқосими Фирдавсӣ',
          'Firdavso',
        ),
        isTrue,
      );
      // Two typos, or one in a short word, are not.
      expect(
        SearchNormalizer.matchesOnAnyKeyboard('Абӯабдуллоҳи Рӯдакӣ', 'Рудиак'),
        isFalse,
      );
      expect(SearchNormalizer.matchesOnAnyKeyboard('Саъдӣ', 'Сода'), isFalse);
    });

    test('forgiven matches rank below exact and partial ones', () {
      final exact = SearchNormalizer.scoreMatch('Рӯдакӣ', 'Рӯдакӣ');
      final latin = SearchNormalizer.scoreMatch('Рӯдакӣ', 'Rudakiy');
      final typo = SearchNormalizer.scoreMatch('Рӯдакӣ', 'Рудаик');
      expect(exact, greaterThan(latin));
      expect(latin, greaterThan(typo));
      expect(typo, greaterThan(0));
    });
  });

  group('real queries find real poets and poems', () {
    final authors =
        (jsonDecode(
                  File('assets/data/literature/poets.json').readAsStringSync(),
                )
                as List)
            .map(
              (json) =>
                  LiteraryAuthor.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
    final works = expandRuntimeWorks(
      jsonDecode(
        File('assets/data/literature/runtime_works.json').readAsStringSync(),
      ),
    ).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

    // (query, keyboard, expected poet id or work id)
    const poets = [
      ('Рӯдакӣ', 'Tajik', 'rudaki'),
      ('Рудаки', 'Russian', 'rudaki'),
      ('Rudakiy', 'Latin', 'rudaki'),
      ('Rūdakī', 'Latin', 'rudaki'),
      ('رودکی', 'Persian', 'rudaki'),
      ('Ayni', 'Latin', '47c1dc67-363a-4506-8a9c-bbbb38f98d20'),
      ('Aini', 'Latin', '47c1dc67-363a-4506-8a9c-bbbb38f98d20'),
      ('Айни', 'Russian', '47c1dc67-363a-4506-8a9c-bbbb38f98d20'),
      ('عینی', 'Persian', '47c1dc67-363a-4506-8a9c-bbbb38f98d20'),
      ('Jami', 'Latin', '9debff75-8664-43ab-a7a9-ed1a4725f69b'),
      ('Jomi', 'Latin', '9debff75-8664-43ab-a7a9-ed1a4725f69b'),
      ('Джами', 'Russian', '9debff75-8664-43ab-a7a9-ed1a4725f69b'),
      ('جامي', 'Arabic', '9debff75-8664-43ab-a7a9-ed1a4725f69b'),
      ('Khayyam', 'Latin', '5fc69b51-c38a-4427-a362-5c8a14bca835'),
      ('Khayyom', 'Latin', '5fc69b51-c38a-4427-a362-5c8a14bca835'),
      ('Хайям', 'Russian', '5fc69b51-c38a-4427-a362-5c8a14bca835'),
      ('خیام', 'Persian', '5fc69b51-c38a-4427-a362-5c8a14bca835'),
      ('Hafez', 'Latin', 'd1abb54a-9804-4baf-b238-fd2203d7673e'),
      ('حافظ', 'Persian', 'd1abb54a-9804-4baf-b238-fd2203d7673e'),
      ('Saadi', 'Latin', '3ec91317-fcfe-4960-9ca0-fd87f3e96875'),
      ('سعدي', 'Arabic', '3ec91317-fcfe-4960-9ca0-fd87f3e96875'),
      ('Ferdowsi', 'Latin', 'a6dd1c54-753d-4a52-8e5b-5365b7908aa3'),
      ('Фирдавси', 'Russian', 'a6dd1c54-753d-4a52-8e5b-5365b7908aa3'),
      ('Tursunzoda', 'Latin', 'tursunzoda'),
      ('Турсунзаде', 'Russian', 'tursunzoda'),
      ('Kamol', 'Latin', 'kamol_khujandi'),
      ('Khujandi', 'Latin', 'kamol_khujandi'),
      ('Loiq', 'Latin', 'loiq_sherali'),
      ('Лоик', 'Russian', 'loiq_sherali'),
      ('Bedil', 'Latin', '455f0420-3834-48f0-86b9-7da673a2a684'),
      ('بیدل', 'Persian', '455f0420-3834-48f0-86b9-7da673a2a684'),
      ('Ibn Sino', 'Latin', '1a55efdd-6a1f-43b8-834f-94af060b4329'),
      ('Mavlono', 'Latin', '0b0f1032-b36a-45e4-9930-8953b067db65'),
      ('Навои', 'Russian', '228feecd-8a97-4aaf-9b92-b9896c3a7d7d'),
    ];
    const poems = [
      ('Бӯйи Ҷӯйи Мулиён', 'Tajik', 'rudaki_buyi_juyi_muliyon_grade5_2017_p54'),
      (
        'буйи чуйи мулиен',
        'Russian',
        'rudaki_buyi_juyi_muliyon_grade5_2017_p54',
      ),
      (
        'Buyi Juyi Muliyon',
        'Latin',
        'rudaki_buyi_juyi_muliyon_grade5_2017_p54',
      ),
      ('بوی جوی مولیان', 'Persian', 'rudaki_buyi_juyi_muliyon_grade5_2017_p54'),
      ('турки шерозӣ', 'Tajik', '0f48abbb-5652-4054-b518-dae7ea332240'),
      ('турки шерози', 'Russian', '0f48abbb-5652-4054-b518-dae7ea332240'),
      ('turki sherozi', 'Latin', '0f48abbb-5652-4054-b518-dae7ea332240'),
      ('ترک شیرازی', 'Persian', '0f48abbb-5652-4054-b518-dae7ea332240'),
      ('Ман бода хурам', 'Tajik', 'cd7a02a9-54cb-4d30-a915-a90a6fd9a2e9'),
      ('man boda khuram', 'Latin', 'cd7a02a9-54cb-4d30-a915-a90a6fd9a2e9'),
      ('من باده خورم', 'Persian', 'cd7a02a9-54cb-4d30-a915-a90a6fd9a2e9'),
      ('Ошӯби ҷонӣ', 'Tajik', 'poem_kamol_khujandi_7112fcf585dcfed0'),
      ('ошуби чони', 'Russian', 'poem_kamol_khujandi_7112fcf585dcfed0'),
      ('Oshubi joni', 'Latin', 'poem_kamol_khujandi_7112fcf585dcfed0'),
      ('шеъри шуаро', 'Tajik', '26604816-b082-521b-8f91-46d1d422ba03'),
      ('شعر شعرا', 'Persian', '26604816-b082-521b-8f91-46d1d422ba03'),
      ('Зан агар оташ', 'Tajik', 'f4c025e3-48a1-4bc1-8e29-cf404472e590'),
      ('zan agar otash', 'Latin', 'f4c025e3-48a1-4bc1-8e29-cf404472e590'),
    ];

    for (final (query, keyboard, id) in poets) {
      test('poet: «$query» ($keyboard)', () {
        final found = authors
            .where((a) => LiteratureSearch.matchesAuthor(a, query))
            .map((a) => a.id);
        expect(found, contains(id));
      });
    }
    for (final (query, keyboard, id) in poems) {
      test('poem: «$query» ($keyboard)', () {
        final found = works
            .where((w) => LiteratureSearch.matchesWork(w, query))
            .map((w) => w.id);
        expect(found, contains(id));
      });
    }

    test('a Latin query does not flood the list', () {
      final found = authors.where(
        (a) => LiteratureSearch.matchesAuthor(a, 'Rudaki'),
      );
      expect(found.length, lessThanOrEqualTo(3));
    });
  });
}
