import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/presentation/literary_work_display_text.dart';

void main() {
  group('LiteraryWorkDisplayText.sourceLabel', () {
    const source = SourceEdition(
      bookTitle: 'Адабиёти тоҷик',
      publisher: 'Маориф',
      city: 'Душанбе',
      year: '2017',
      pageStart: 153,
      sourceType: SourceEditionType.officialTextbook,
    );

    test('shows book title and known page numbers', () {
      expect(
        LiteraryWorkDisplayText.sourceLabel(source),
        'Адабиёти тоҷик — с. 153',
      );
    });

    test('shows only the book title when pages are unknown', () {
      const noPages = SourceEdition(
        bookTitle: 'Адабиёти тоҷик',
        publisher: 'Маориф',
        city: 'Душанбе',
        year: '2017',
        sourceType: SourceEditionType.officialTextbook,
      );
      expect(LiteraryWorkDisplayText.sourceLabel(noPages), 'Адабиёти тоҷик');
    });

    test('returns null for a missing source or blank title', () {
      expect(LiteraryWorkDisplayText.sourceLabel(null), isNull);
      const blankTitle = SourceEdition(
        bookTitle: '  ',
        publisher: 'Маориф',
        city: 'Душанбе',
        year: '2017',
        sourceType: SourceEditionType.officialTextbook,
      );
      expect(LiteraryWorkDisplayText.sourceLabel(blankTitle), isNull);
    });

    test('never emits page-missing or provenance chatter', () {
      const noPages = SourceEdition(
        bookTitle: 'Адабиёти тоҷик',
        publisher: 'Маориф',
        city: 'Душанбе',
        year: '2017',
        sourceType: SourceEditionType.officialTextbook,
      );
      final label = LiteraryWorkDisplayText.sourceLabel(noPages)!;
      expect(label.toLowerCase(), isNot(contains('page')));
      expect(label, isNot(contains('ёфт')));
      expect(label, isNot(contains('намешавад')));
      expect(label, isNot(contains('нашудааст')));
    });
  });
}
