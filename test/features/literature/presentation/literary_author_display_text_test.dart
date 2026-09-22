import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/presentation/literary_author_display_text.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  group('LiteraryAuthorDisplayText', () {
    test(
      'Persian dates localize years and do not infer an unknown death date',
      () {
        final author = LiteraryAuthor.fromJson({
          'id': 'approximate-author',
          'canonicalName': 'Шоири санҷишӣ',
          'birthYear': 'Тақрибан 1320',
          'literaryPeriod': 'Асри XIV',
          'biographyTj': '',
          'biographySource': '',
          'rights': {'status': 'unknown'},
        });

        expect(
          LiteraryAuthorDisplayText.lifespan(author, DisplayLanguage.persian),
          'ولادت: حدود ۱۳۲۰ · وفات: نامشخص',
        );
        expect(
          LiteraryAuthorDisplayText.lifespan(author, DisplayLanguage.tajik),
          'Тақрибан 1320',
        );
      },
    );

    test('Persian dates preserve conflicting catalog and source estimates', () {
      final author = LiteraryAuthor.fromJson({
        'id': 'date-conflict',
        'canonicalName': 'Камоли Хуҷандӣ',
        'birthYear': '1321',
        'deathYear': '1401',
        'birthDateExact': 'Тақрибан 1320',
        'deathDateExact': 'Тақрибан 1400',
        'literaryPeriod': 'Асри XIV',
        'biographyTj': '',
        'biographySource': '',
        'rights': {'status': 'unknown'},
      });

      expect(
        LiteraryAuthorDisplayText.lifespan(author, DisplayLanguage.persian),
        'ولادت: ۱۳۲۱ (یا حدود ۱۳۲۰) · وفات: ۱۴۰۱ (یا حدود ۱۴۰۰)',
      );
    });

    test('Persian metadata never falls back to Tajik metadata', () {
      final author = LiteraryAuthor.fromJson({
        'id': 'untranslated-author',
        'canonicalName': 'Шоири санҷишӣ',
        'birthPlace': 'Панҷрӯд',
        'literaryPeriod': 'Асри IX',
        'officialTitles': ['Устод'],
        'biographyTj': '',
        'biographySource': '',
        'rights': {'status': 'unknown'},
      });

      expect(
        LiteraryAuthorDisplayText.period(author, DisplayLanguage.persian),
        isEmpty,
      );
      expect(
        LiteraryAuthorDisplayText.birthPlace(author, DisplayLanguage.persian),
        isNull,
      );
      expect(
        LiteraryAuthorDisplayText.officialTitles(
          author,
          DisplayLanguage.persian,
        ),
        isEmpty,
      );
      expect(
        LiteraryAuthorDisplayText.period(author, DisplayLanguage.tajik),
        'Асри IX',
      );
    });
  });
}
