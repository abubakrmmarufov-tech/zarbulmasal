import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/presentation/literary_work_display_text.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  group('LiteraryWorkDisplayText.sourceCitation', () {
    const source = SourceEdition(
      bookTitle: 'Адабиёти тоҷик',
      publisher: 'Маориф',
      city: 'Душанбе',
      year: '2017',
      pageStart: 153,
      pageEnd: 154,
      sourceType: SourceEditionType.officialTextbook,
      sourceReference: 'docs/literature/pdfs/adabiet sinfi 5.pdf',
    );

    test('shows the book, grade and year but never the page', () {
      expect(
        LiteraryWorkDisplayText.sourceCitation(source, DisplayLanguage.tajik),
        'Адабиёти тоҷик, синфи 5 (2017)',
      );
      // The page stays on the record for the checks.
      expect(source.formattedPages, 'с. 153–154');
    });

    test('in Persian, labels the grade and uses Persian digits', () {
      expect(
        LiteraryWorkDisplayText.sourceCitation(source, DisplayLanguage.persian),
        'Адабиёти тоҷик، صنف ۵ (۲۰۱۷)',
      );
    });

    test('a book that is not a textbook PDF shows title and year', () {
      const book = SourceEdition(
        bookTitle: 'Девони Рӯдакӣ',
        publisher: 'Адиб',
        city: 'Душанбе',
        year: '2015',
        pageStart: 12,
        sourceType: SourceEditionType.printedBookScan,
      );
      expect(
        LiteraryWorkDisplayText.sourceCitation(book, DisplayLanguage.tajik),
        'Девони Рӯдакӣ (2015)',
      );
    });

    test('returns null for a missing source or blank title', () {
      expect(
        LiteraryWorkDisplayText.sourceCitation(null, DisplayLanguage.tajik),
        isNull,
      );
      const blankTitle = SourceEdition(
        bookTitle: '  ',
        publisher: 'Маориф',
        city: 'Душанбе',
        year: '2017',
        sourceType: SourceEditionType.officialTextbook,
      );
      expect(
        LiteraryWorkDisplayText.sourceCitation(
          blankTitle,
          DisplayLanguage.tajik,
        ),
        isNull,
      );
    });

    test('never emits page-missing or provenance chatter', () {
      const noPages = SourceEdition(
        bookTitle: 'Адабиёти тоҷик',
        publisher: 'Маориф',
        city: 'Душанбе',
        year: '2017',
        sourceType: SourceEditionType.officialTextbook,
      );
      final label = LiteraryWorkDisplayText.sourceCitation(
        noPages,
        DisplayLanguage.tajik,
      )!;
      expect(label.toLowerCase(), isNot(contains('page')));
      expect(label, isNot(contains('с. ')));
      expect(label, isNot(contains('ёфт')));
      expect(label, isNot(contains('намешавад')));
      expect(label, isNot(contains('нашудааст')));
    });
  });
}
