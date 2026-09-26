import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/source_citation.dart';
import 'package:zarbulmasal/data/models/source_ref.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

/// A page number as the app used to print it: «саҳ. 25», «с. 49–56»,
/// «ص. ۴۰», «PDF 24».
final pageMarker = RegExp(r'(саҳ\.|\bс\.|ص\.|صفحه|PDF)\s*[0-9۰-۹]');

void main() {
  group('formatBookCitation', () {
    test('title, then grade and year', () {
      expect(
        formatBookCitation(
          'Адабиёти тоҷик',
          DisplayLanguage.tajik,
          grade: '5',
          year: '2017',
        ),
        'Адабиёти тоҷик, синфи 5 (2017)',
      );
    });

    test('title and year when there is no grade', () {
      expect(
        formatBookCitation(
          'Зарбулмасал ва мақолҳои тоҷикӣ',
          DisplayLanguage.tajik,
          year: '1956',
        ),
        'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
      );
    });

    test('just the title when nothing else is known', () {
      expect(
        formatBookCitation(' Фолклори тоҷик ', DisplayLanguage.tajik),
        'Фолклори тоҷик',
      );
      expect(
        formatBookCitation(
          'Фолклори тоҷик',
          DisplayLanguage.tajik,
          grade: ' ',
          year: '',
        ),
        'Фолклори тоҷик',
      );
    });

    test('Persian labels the grade and uses Persian digits and comma', () {
      expect(
        formatBookCitation(
          'Адабиёти тоҷик',
          DisplayLanguage.persian,
          grade: '5',
          year: '2017',
        ),
        'Адабиёти тоҷик، صنف ۵ (۲۰۱۷)',
      );
    });
  });

  group('formatSourceCitation', () {
    const asrori = SourceRef(
      bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
      authorEditor: 'В. Асрорӣ',
      year: 1956,
      city: 'Сталинобод',
      publisher: 'Нашриёти давлатии Тоҷикистон',
      pdfPage: 24,
      printedPage: 25,
    );

    test('shows the book and year only: no author, imprint or page', () {
      final citation = formatSourceCitation(asrori, DisplayLanguage.tajik);
      expect(citation, 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)');
      expect(citation, isNot(matches(pageMarker)));
    });

    test('keeps the page on the record for the checks', () {
      expect(asrori.printedPage, 25);
      expect(asrori.pdfPage, 24);
    });

    test('a textbook title already carries its grade', () {
      const textbook = SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        year: 2017,
        pdfPage: 40,
        printedPage: 40,
      );
      expect(
        formatSourceCitation(textbook, DisplayLanguage.tajik),
        'Адабиёти тоҷик, синфи 5 (2017)',
      );
      expect(
        formatSourceCitation(textbook, DisplayLanguage.persian),
        'ادبیات تاجیک، صنف ۵ (۲۰۱۷)',
      );
    });

    test('in Persian, a textbook of another year keeps its title', () {
      const other = SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        year: 2005,
        pdfPage: 40,
      );
      expect(
        formatSourceCitation(other, DisplayLanguage.persian),
        'Адабиёти тоҷик, синфи 5 (۲۰۰۵)',
      );
    });

    test('a source without a year is just its title', () {
      const scanOnly = SourceRef(bookTitle: 'Китоб', pdfPage: 31);
      expect(formatSourceCitation(scanOnly, DisplayLanguage.tajik), 'Китоб');
    });
  });

  group('textbooks', () {
    test('textbookGrade reads the grade from a PDF file name', () {
      expect(textbookGrade('docs/literature/pdfs/adabiet sinfi 5.pdf'), '5');
      expect(textbookGrade('adabiyet sinfi 11.pdf'), '11');
      expect(textbookGrade('https://maorif.tj/storage/libraries/x.pdf'), null);
      expect(textbookGrade(null), null);
    });

    test('textbookCitation names the edition by grade', () {
      expect(
        textbookCitation('5', DisplayLanguage.tajik),
        'Адабиёти тоҷик, синфи 5 (2017)',
      );
      expect(
        textbookCitation('11', DisplayLanguage.tajik),
        'Адабиёти тоҷик (давраи нав), синфи 11 (2018)',
      );
      expect(
        textbookCitation('9', DisplayLanguage.persian),
        'ادبیات تاجیک، صنف ۹ (۲۰۲۶)',
      );
      expect(textbookCitation('4', DisplayLanguage.tajik), isNull);
    });

    test('the editions match assets/data/literature/sources.json', () {
      final sources =
          (jsonDecode(
                    File(
                      'assets/data/literature/sources.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>();
      final local = {
        for (final source in sources)
          if ((source['sourceReference'] as String? ?? '').startsWith(
            'docs/literature/pdfs/',
          ))
            textbookGrade(source['sourceReference'] as String)!: (
              title: source['bookTitle'] as String,
              year: source['year'] as String,
            ),
      };
      expect(uploadedTextbookEditions, local);
    });
  });
}
