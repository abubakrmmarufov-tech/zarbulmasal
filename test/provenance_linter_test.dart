import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Provenance linter invariants', () {
    late List<Map<String, dynamic>> works;
    late List<Map<String, dynamic>> oral;
    late List<Map<String, dynamic>> poets;
    late List<Map<String, dynamic>> history;

    setUpAll(() {
      works =
          (jsonDecode(
                    File(
                      'assets/data/literature/works.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>();
      oral =
          (jsonDecode(
                    File(
                      'assets/data/literature/oral_heritage.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>();
      poets =
          (jsonDecode(
                    File(
                      'assets/data/literature/poets.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>();
      history =
          (jsonDecode(
                    File('assets/data/history/entries.json').readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>();
    });

    test('generated script is separated from source Persian text', () {
      expect(works, isNotEmpty);
      for (final work in works) {
        if (work['persianScriptSource'] == 'generated') {
          expect(work['scriptSource'], isNot(equals('both')));
          expect(work['textPersian'], isNull);
          if (work['textStatus'] == 'needsReview') {
            expect(work['persianScriptRepresentation'], anyOf(isNull, isEmpty));
          } else {
            expect(work['persianScriptRepresentation'], isNotEmpty);
          }
        }
      }
    });

    test('page verification requires a real page and valid range', () {
      for (final entry in history) {
        for (final claim
            in (entry['claimProvenance'] as List? ?? const [])
                .cast<Map<String, dynamic>>()) {
          final status = claim['status'];
          final printed = claim['printedPage'] as num?;
          final pdf = claim['pdfPage'] as num?;
          if (status == 'VERIFIED_UPLOADED_BOOK_PAGE' ||
              status == 'VERIFIED_MAORIF_PAGE') {
            expect(
              printed != null || pdf != null,
              isTrue,
              reason: 'Page-verified claim has no page in ${entry['id']}',
            );
          }
          expect(printed == null || printed > 0, isTrue);
          expect(pdf == null || pdf > 0, isTrue);
        }
      }
    });

    test(
      'unsupported biographies are quarantined and rights are not inferred',
      () {
        for (final poet in poets) {
          final bioStatus = poet['biographyTjProvenance'];
          expect({
            'SOURCE_BACKED',
            'EDITORIAL_SUMMARY_FROM_SOURCES',
            'UNSUPPORTED_GENERATED',
          }, contains(bioStatus));
          if (bioStatus == 'UNSUPPORTED_GENERATED') {
            expect((poet['biographyTj'] as String?)?.trim(), isEmpty);
            expect(
              (poet['biographyQuarantineNote'] as String?)?.trim(),
              isNotEmpty,
            );
          }
          expect((poet['rights'] as Map?)?['status'], equals('unknown'));
        }
        for (final work in works) {
          final rights = (work['rights'] as Map?) ?? const {};
          expect({'unknown', 'sourceAttested'}, contains(rights['status']));
          if (rights['status'] == 'sourceAttested') {
            expect(rights['fullTextAllowed'], isTrue);
            expect(work['textStatus'], 'verified');
            expect((work['textTajik'] as String?)?.trim(), isNotEmpty);
            expect(
              (work['verification'] as Map?)?['evidenceLevel'],
              'primaryChecked',
            );
          }
        }
      },
    );

    test('rights-unknown oral heritage does not ship full text', () {
      expect(oral, isNotEmpty);
      for (final entry in oral) {
        final rights = (entry['rights'] as Map?) ?? const {};
        if (rights['fullTextAllowed'] != true) {
          expect((entry['text'] as String?)?.trim(), isEmpty);
          expect(
            (entry['textPersian'] as String?)?.trim(),
            anyOf(isNull, isEmpty),
          );
        }
      }
    });

    test('secondary witnesses declare an explicit line collation', () {
      for (final work in works) {
        if (work['secondarySource'] == null) {
          continue;
        }
        expect(
          {'exact', 'minor-variant'},
          contains(work['textMatchResult']),
          reason:
              'Secondary witness lacks a supported collation result for ${work['id']}',
        );
        expect(
          (work['variantNotes'] as String?)?.trim(),
          isNotEmpty,
          reason:
              'Secondary witness lacks line-collation notes for ${work['id']}',
        );
      }
    });
  });
}
