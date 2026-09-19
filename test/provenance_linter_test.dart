import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Provenance linter invariants', () {
    late List<Map<String, dynamic>> works;
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
          expect(work['persianScriptRepresentation'], isNotEmpty);
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
          }
          expect((poet['rights'] as Map?)?['status'], equals('unknown'));
        }
        for (final work in works) {
          expect((work['rights'] as Map?)?['status'], equals('unknown'));
        }
      },
    );
  });
}
