import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/oral_heritage_entry.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';

void main() {
  group('Oral heritage display gate', () {
    test(
      'exposes exactly 12 source-attested entries and hides 2 quarantined',
      () {
        final file = File('assets/data/literature/oral_heritage.json');
        expect(file.existsSync(), isTrue);

        final list = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
            .cast<Map<String, dynamic>>();
        expect(list, hasLength(14));

        final entries = list.map(OralHeritageEntry.fromJson).toList();
        final displayable = entries.where((e) => e.isDisplayable).toList();
        final hidden = entries.where((e) => !e.isDisplayable).toList();

        expect(displayable, hasLength(12));
        expect(hidden, hasLength(2));

        final displayableIds = displayable.map((e) => e.id).toSet();
        expect(displayableIds, isNot(contains('oral-afsona-001')));
        expect(displayableIds, isNot(contains('oral-afsona-002')));

        for (final entry in displayable) {
          expect(entry.isPermittedSourceAttested, isTrue);
          expect(entry.verification.pageVerified, isTrue);
          expect(entry.rights.status, RightsStatus.sourceAttested);
          expect(entry.rights.fullTextAllowed, isTrue);
          expect(entry.text.trim(), isNotEmpty);
        }
        for (final entry in hidden) {
          expect(entry.id, startsWith('oral-afsona-'));
          expect(
            entry.verification.evidenceLevel,
            VerificationLevel.needsReview,
          );
          expect(entry.rights.status, RightsStatus.unknown);
          expect(entry.rights.fullTextAllowed, isFalse);
        }
      },
    );

    test(
      'accepts a held PDF under docs/literature/pdfs/ as a permitted source',
      () {
        const entry = OralHeritageEntry(
          id: 'oral-maqol-001',
          text: 'То меҳнат накунӣ, роҳат набинӣ',
          type: OralHeritageType.maqol,
          collectionSource: 'Адабиёти тоҷик, синфи 5',
          publisher: 'Маориф',
          year: '2017',
          page: '38',
          sourceReference: 'docs/literature/pdfs/adabiet sinfi 5.pdf',
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.primaryChecked,
            pageVerified: true,
          ),
          rights: RightsRecord(
            status: RightsStatus.sourceAttested,
            reasoning: 'Exact text verified on a held printed page',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );

        expect(entry.isDisplayable, isTrue);
        expect(entry.isPermittedSourceAttested, isTrue);
      },
    );

    test('accepts an https source on maorif.tj as a permitted source', () {
      const entry = OralHeritageEntry(
        id: 'oral-maqol-003',
        text: 'То меҳнат накунӣ, роҳат набинӣ',
        type: OralHeritageType.maqol,
        collectionSource: 'Адабиёти тоҷик, синфи 5',
        publisher: 'Маориф',
        year: '2025',
        sourceReference:
            'https://maorif.tj/storage/libraries/01K6HGRAG6CPT6S1XBVK6KBPJT.pdf',
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.primaryChecked,
          pageVerified: true,
        ),
        rights: RightsRecord(
          status: RightsStatus.sourceAttested,
          reasoning: 'Exact text verified on an official maorif.tj PDF page',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
      );

      expect(entry.isDisplayable, isTrue);
      expect(entry.isPermittedSourceAttested, isTrue);
    });

    test(
      'rejects a disallowed source even when rights and text look cleared',
      () {
        const entry = OralHeritageEntry(
          id: 'oral-disallowed-001',
          text: 'Сабт нашуда',
          type: OralHeritageType.other,
          collectionSource: 'Random web page',
          publisher: 'Example',
          year: '2026',
          sourceReference: 'https://en.wikipedia.org/wiki/Proverb',
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.primaryChecked,
            pageVerified: true,
          ),
          rights: RightsRecord(
            status: RightsStatus.sourceAttested,
            reasoning:
                'Rights claimed but source is outside the permitted policy',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );

        expect(entry.isPermittedSourceAttested, isFalse);
        expect(entry.isDisplayable, isFalse);
      },
    );

    test('rejects a non-PDF local reference under docs/literature/pdfs/', () {
      const entry = OralHeritageEntry(
        id: 'oral-disallowed-002',
        text: 'Нодуруст',
        type: OralHeritageType.other,
        collectionSource: 'Some text file',
        publisher: 'Example',
        year: '2026',
        sourceReference: 'docs/literature/pdfs/notes.txt',
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.primaryChecked,
          pageVerified: true,
        ),
        rights: RightsRecord(
          status: RightsStatus.sourceAttested,
          reasoning: 'Not a held PDF',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
      );

      expect(entry.isPermittedSourceAttested, isFalse);
      expect(entry.isDisplayable, isFalse);
    });
  });
}
