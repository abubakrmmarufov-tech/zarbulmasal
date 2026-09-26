import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/source_citation.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/presentation/literary_author_display_text.dart';
import 'package:zarbulmasal/features/literature/presentation/literary_work_display_text.dart';
import 'package:zarbulmasal/features/vocabulary/domain/lexicon_index.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

/// A page number as the app used to print one: «саҳ. 25», «с. 49–56»,
/// «ص. ۴۰», «صفحه ۱۶», «(PDF 24)». Pages run to 400, so a four-digit number
/// after «с.» is a year («с. 1976» = «соли 1976»), not a page.
final _pageMarker = RegExp(
  r'(саҳ\.|(?<![А-Яа-яЁёҶҷҲҳҚқҒғӮӯӢӣ])с\.|ص\.|صفحه|PDF)\s*[0-9۰-۹]{1,3}(?![0-9۰-۹])',
);

const _languages = DisplayLanguage.values;

void main() {
  // Owner's rule (26 Sep 2026): the app shows only the book — title, then
  // grade and year — never a page. Pages stay in the data for the checks.
  group('Proverbs', () {
    test('no source line or citation names a page', () {
      for (final proverb in seedProverbs) {
        expect(
          proverb.sourceNote,
          isNot(matches(_pageMarker)),
          reason: proverb.id,
        );
        for (final source in [
          ...proverb.sources,
          ?proverb.meaningSource,
          ?proverb.exampleSource,
        ]) {
          for (final lang in _languages) {
            expect(
              formatSourceCitation(source, lang),
              isNot(matches(_pageMarker)),
              reason: proverb.id,
            );
          }
        }
      }
    });

    test('the source line is the primary book and its year', () {
      for (final proverb in seedProverbs.where((p) => p.isPageVerified)) {
        expect(
          proverb.sourceNote,
          formatSourceCitation(proverb.sources.first, DisplayLanguage.tajik),
          reason: proverb.id,
        );
      }
    });

    test('the printed page stays in the data as evidence', () {
      final verified = seedProverbs.where(
        (p) => p.sourceStatus == SourceStatus.pageVerified,
      );
      expect(verified, isNotEmpty);
      for (final proverb in verified) {
        expect(
          proverb.sources.first.printedPage,
          isNotNull,
          reason: proverb.id,
        );
      }
    });
  });

  group('Literature', () {
    final works = expandRuntimeWorks(
      jsonDecode(
        File('assets/data/literature/runtime_works.json').readAsStringSync(),
      ),
    ).map(LiteraryWork.fromJson).toList();
    final authors =
        (jsonDecode(
                  File('assets/data/literature/poets.json').readAsStringSync(),
                )
                as List)
            .cast<Map<String, dynamic>>()
            .map(LiteraryAuthor.fromJson)
            .toList();

    test('no poem citation names a page', () {
      final cited = works.where((w) => w.primarySource?.pageStart != null);
      expect(cited, isNotEmpty, reason: 'pages stay in the data');
      for (final work in works) {
        for (final lang in _languages) {
          final citation = LiteraryWorkDisplayText.shortCitation(work, lang);
          expect(citation ?? '', isNot(matches(_pageMarker)), reason: work.id);
        }
      }
    });

    test('no portrait caption names a page', () {
      final portraits = authors.map((a) => a.portrait).nonNulls.toList();
      expect(portraits, isNotEmpty);
      for (final portrait in portraits) {
        for (final lang in _languages) {
          final caption = LiteraryAuthorDisplayText.portraitCitation(
            portrait,
            lang,
          );
          expect(caption, isNotEmpty, reason: portrait.assetPath);
          expect(caption, isNot(matches(_pageMarker)));
        }
      }
    });

    test('no biography or its source line names a page', () {
      for (final author in authors) {
        expect(
          LiteraryAuthorDisplayText.biographySourceBooks(
            author.biographySource,
          ),
          isNot(matches(_pageMarker)),
          reason: author.id,
        );
        expect(
          author.biographyTj,
          isNot(matches(_pageMarker)),
          reason: author.id,
        );
        expect(
          author.biographyFa ?? '',
          isNot(matches(_pageMarker)),
          reason: author.id,
        );
      }
    });
  });

  group('Lexicon', () {
    test('no word names its page', () {
      final words =
          (jsonDecode(
                    File(
                      'assets/data/vocabulary/words.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>()
              .map(WordEntry.fromJson);
      for (final grade in words.map(LexiconIndex.gradeOf).nonNulls.toSet()) {
        for (final lang in _languages) {
          final citation = textbookCitation(grade, lang);
          expect(citation, isNotNull, reason: 'grade $grade');
          expect(citation, isNot(matches(_pageMarker)));
        }
      }
    });
  });

  group('biographySourceBooks', () {
    test('keeps the books and grades, drops the pages', () {
      expect(
        LiteraryAuthorDisplayText.biographySourceBooks(
          '«Адабиёти тоҷик», синфи 8 (2026), с. 43–64; '
          'синфи 5 (2017), с. 49–56.',
        ),
        'Адабиёти тоҷик, синфи 8 (2026); синфи 5 (2017)',
      );
    });

    test('drops the PDF page and the link of a maorif.tj book', () {
      expect(
        LiteraryAuthorDisplayText.biographySourceBooks(
          '«Адабиёти тоҷик», синфи 9 (2023), с. 12 (PDF p. 14), '
          'maorif.tj: https://maorif.tj/storage/libraries/X.pdf',
        ),
        'Адабиёти тоҷик, синфи 9 (2023)',
      );
    });

    test('takes the only year of a single-grade citation', () {
      expect(
        LiteraryAuthorDisplayText.biographySourceBooks(
          'Адабиёти тоҷик, синфи 5, Маориф, Душанбе, 2017, с. 49',
        ),
        'Адабиёти тоҷик, синфи 5 (2017)',
      );
    });

    test('a citation without a grade is just its title', () {
      expect(
        LiteraryAuthorDisplayText.biographySourceBooks(
          '«Адабиёти тоҷик», нашрияи «Маориф», Душанбе',
        ),
        'Адабиёти тоҷик',
      );
      expect(LiteraryAuthorDisplayText.biographySourceBooks('  '), '');
    });
  });
}
