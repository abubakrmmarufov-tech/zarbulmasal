import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Provenance Integrity Guard', () {
    late List<dynamic> works;

    setUpAll(() {
      final worksFile = File('assets/data/literature/works.json');
      works = jsonDecode(worksFile.readAsStringSync()) as List<dynamic>;
    });

    test(
      'Works with exact page numbers must have photographic or high-quality source evidence',
      () {
        for (final work in works) {
          final w = work as Map<String, dynamic>;
          final p = w['primarySource'] as Map<String, dynamic>?;

          if (p != null && p['pageBoundary'] != null) {
            final verification = w['verification'] as Map<String, dynamic>?;
            final level =
                verification?['evidenceLevel'] as String? ?? 'extracted';

            // If we claim to know the page number, the level MUST be sourceLocated or higher
            // and we MUST NOT just have a placeholder
            expect(
              level,
              isNot(equals('extracted')),
              reason:
                  'Work ${w['id']} claims page ${p['pageBoundary']} but evidence level is only extracted.',
            );
          }
        }
      },
    );

    test('No generic secondary source spam', () {
      int commonSecondaryCount = 0;

      for (final work in works) {
        final w = work as Map<String, dynamic>;
        final s = w['secondWitness'] as Map<String, dynamic>?;

        if (s != null && s['description'] == 'Academic collation source') {
          commonSecondaryCount++;
        }
      }

      // If someone mass-added "Academic collation source" to more than 100 works, it's a hallucination
      expect(
        commonSecondaryCount,
        lessThan(100),
        reason:
            'Detected massive generic secondary source usage ($commonSecondaryCount instances). This indicates fake verification.',
      );
    });

    test(
      'Kamol textbook witnesses keep source pages, images, and variants aligned',
      () {
        final work = works.cast<Map<String, dynamic>>().firstWhere(
          (item) =>
              item['id'] == 'kamol_khujandi_guftam_ba_chashm_grade7_2018_p105',
        );
        final primary = work['primarySource'] as Map<String, dynamic>;
        final secondary = work['secondarySource'] as Map<String, dynamic>;
        final rights = work['rights'] as Map<String, dynamic>;

        expect(
          primary['sourceReference'],
          'docs/literature/pdfs/adabiyot sinfi 7.pdf',
        );
        expect(primary['pageStart'], 105);
        expect(primary['pageEnd'], 105);
        expect(
          primary['sourceImagePath'],
          'assets/data/literature/page_images/kamol_khujandi_guftam_ba_chashm_grade7_2018_p105.png',
        );
        expect(
          secondary['sourceReference'],
          'docs/literature/pdfs/adabiyet sinfi 9.pdf',
        );
        expect(secondary['pageStart'], 197);
        expect(secondary['pageEnd'], 197);
        expect(
          secondary['sourceImagePath'],
          'assets/data/literature/page_images/kamol_khujandi_guftam_ba_chashm_grade9_2026_p197.png',
        );
        expect(work['textMatchResult'], 'minor-variant');
        expect(work['textTajik'], isNull);
        expect(work['variantNotes'], contains('сӯзони оҳ'));
        expect(work['variantNotes'], contains('гиря тар'));
        expect(rights['status'], 'unknown');
        expect(rights['fullTextAllowed'], isFalse);
        expect(rights['excerptAllowed'], isFalse);
      },
    );

    test('Kamol continuation records every inspected page image', () {
      final work = works.cast<Map<String, dynamic>>().firstWhere(
        (item) =>
            item['id'] ==
            'kamol_khujandi_dust_medorad_dilam_grade7_2018_p106_107',
      );
      final primary = work['primarySource'] as Map<String, dynamic>;
      final verification = work['verification'] as Map<String, dynamic>;

      expect(primary['pageStart'], 106);
      expect(primary['pageEnd'], 107);
      expect(primary['sourceImageVerified'], isTrue);
      expect(primary['sourceImagePaths'], [
        'assets/data/literature/page_images/kamol_khujandi_dust_medorad_dilam_grade7_2018_p106.png',
        'assets/data/literature/page_images/kamol_khujandi_dust_medorad_dilam_grade7_2018_p107.png',
      ]);
      expect(verification['evidenceLevel'], 'primaryChecked');
      expect(verification['pageVerified'], isTrue);
    });

    test('Kamol ghazal has a complete current Maorif secondary witness', () {
      final work = works.cast<Map<String, dynamic>>().firstWhere(
        (item) =>
            item['id'] ==
            'kamol_khujandi_dust_medorad_dilam_grade7_2018_p106_107',
      );
      final secondary = work['secondarySource'] as Map<String, dynamic>;

      expect(secondary['bookTitle'], 'Адабиёти тоҷик');
      expect(secondary['edition'], 'Нашри шашум');
      expect(secondary['year'], '2025');
      expect(secondary['pageStart'], 102);
      expect(secondary['pageEnd'], 103);
      expect(
        secondary['sourceReference'],
        'https://maorif.tj/storage/libraries/01KH604RAK569PDJBYDN82T6WE.pdf',
      );
      expect(secondary['sourceImageVerified'], isTrue);
      expect(secondary['sourceImagePaths'], [
        'assets/data/literature/page_images/kamol_khujandi_dust_medorad_dilam_maorif_2025_p102.png',
        'assets/data/literature/page_images/kamol_khujandi_dust_medorad_dilam_maorif_2025_p103.png',
      ]);
      for (final path in (secondary['sourceImagePaths'] as List<dynamic>)) {
        expect(File(path as String).existsSync(), isTrue);
      }
      expect(work['textMatchResult'], 'exact');
      expect(work['variantNotes'], contains('Complete 8-line ghazal witness'));
    });

    test('Firdausi and Kamol couplets retain verified second witnesses', () {
      final expected = {
        'c03e8139-0ed8-4167-9ded-212ba3c7c564': {
          'page': 46,
          'image':
              'assets/data/literature/page_images/firdavsi_pandu_maorif_2025_p46.png',
          'match': 'minor-variant',
        },
        '385117c7-814a-480e-8959-5dd84b006a81': {
          'page': 272,
          'image':
              'assets/data/literature/page_images/kamol_maorif_2025_p272.png',
          'match': 'exact',
        },
      };

      for (final entry in expected.entries) {
        final work = works.cast<Map<String, dynamic>>().firstWhere(
          (item) => item['id'] == entry.key,
        );
        final secondary = work['secondarySource'] as Map<String, dynamic>;

        expect(secondary['pageStart'], entry.value['page']);
        expect(secondary['pageEnd'], entry.value['page']);
        expect(secondary['sourceImageVerified'], isTrue);
        expect(secondary['sourceImagePath'], entry.value['image']);
        expect(File(entry.value['image']! as String).existsSync(), isTrue);
        expect(secondary['sourceReference'], contains('maorif.tj'));
        expect(work['textMatchResult'], entry.value['match']);
        expect(
          (work['rights'] as Map<String, dynamic>)['fullTextAllowed'],
          isFalse,
        );
      }
    });

    test('Rudaki textbook witnesses are exactly collated', () {
      final work = works.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['id'] == '7673c21c-eabd-4f67-954c-99af1028a7a7',
      );
      final primary = work['primarySource'] as Map<String, dynamic>;
      final secondary = work['secondarySource'] as Map<String, dynamic>;
      final verification = work['verification'] as Map<String, dynamic>;
      final rights = work['rights'] as Map<String, dynamic>;

      expect(primary['pageStart'], 50);
      expect(primary['pageEnd'], 50);
      expect(secondary['pageStart'], 12);
      expect(secondary['pageEnd'], 12);
      expect(secondary['edition'], 'Нашри сеюм');
      expect(secondary['isbn'], '978-99947-1-263-2');
      expect(secondary['sourceImageVerified'], isTrue);
      expect(
        secondary['sourceImagePath'],
        'assets/data/literature/page_images/rudaki_gar_bar_sari_nafsi_grade6_2014_p12.png',
      );
      expect(File(secondary['sourceImagePath'] as String).existsSync(), isTrue);
      expect(work['textMatchResult'], 'exact');
      expect(work['variantNotes'], contains('синфи 5, с. 50'));
      expect(work['variantNotes'], contains('синфи 6, с. 12'));
      expect(
        verification['verificationMethod'],
        'primaryAndSecondaryPdfPageCollation',
      );
      expect(verification['verifiedAt'], '2026-09-20');
      expect(rights['status'], 'unknown');
      expect(rights['fullTextAllowed'], isFalse);
      expect(rights['excerptAllowed'], isFalse);
    });

    test('Saadi textbook witnesses are exactly collated', () {
      final work = works.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['id'] == 'd02917e3-6e5f-4f65-9166-ad705decb7be',
      );
      final primary = work['primarySource'] as Map<String, dynamic>;
      final secondary = work['secondarySource'] as Map<String, dynamic>;
      final verification = work['verification'] as Map<String, dynamic>;
      final rights = work['rights'] as Map<String, dynamic>;

      expect(primary['pageStart'], 111);
      expect(primary['pageEnd'], 111);
      expect(secondary['pageStart'], 39);
      expect(secondary['pageEnd'], 39);
      expect(secondary['edition'], 'Нашри панҷум');
      expect(secondary['isbn'], '978-99985-39-75-4');
      expect(secondary['sourceImageVerified'], isTrue);
      expect(
        secondary['sourceImagePath'],
        'assets/data/literature/page_images/saadi_bani_adam_grade9_2026_p39.png',
      );
      expect(File(secondary['sourceImagePath'] as String).existsSync(), isTrue);
      expect(work['textMatchResult'], 'exact');
      expect(work['variantNotes'], contains('синфи 5, с. 111'));
      expect(work['variantNotes'], contains('синфи 9, с. 39'));
      expect(
        verification['verificationMethod'],
        'primaryAndSecondaryPdfPageCollation',
      );
      expect(verification['verifiedAt'], '2026-09-20');
      expect(rights['status'], 'unknown');
      expect(rights['fullTextAllowed'], isFalse);
      expect(rights['excerptAllowed'], isFalse);
    });

    test('Ibn Sina textbook witnesses are exactly collated', () {
      final work = works.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['id'] == '2c9ccb08-a229-4770-946d-87c8047d4fee',
      );
      final primary = work['primarySource'] as Map<String, dynamic>;
      final secondary = work['secondarySource'] as Map<String, dynamic>;
      final verification = work['verification'] as Map<String, dynamic>;
      final rights = work['rights'] as Map<String, dynamic>;

      expect(primary['pageStart'], 71);
      expect(primary['pageEnd'], 71);
      expect(secondary['pageStart'], 135);
      expect(secondary['pageEnd'], 135);
      expect(secondary['edition'], 'Нашри панҷум');
      expect(secondary['isbn'], '978-99985-61-78-6');
      expect(secondary['sourceImageVerified'], isTrue);
      expect(
        secondary['sourceImagePath'],
        'assets/data/literature/page_images/ibn_sina_az_qauri_gili_grade8_2026_p135.png',
      );
      expect(File(secondary['sourceImagePath'] as String).existsSync(), isTrue);
      expect(work['textMatchResult'], 'exact');
      expect(work['variantNotes'], contains('синфи 5, с. 71'));
      expect(work['variantNotes'], contains('синфи 8, с. 135'));
      expect(
        verification['verificationMethod'],
        'primaryAndSecondaryPdfPageCollation',
      );
      expect(verification['verifiedAt'], '2026-09-20');
      expect(rights['status'], 'unknown');
      expect(rights['fullTextAllowed'], isFalse);
      expect(rights['excerptAllowed'], isFalse);
    });

    test('Incomplete second-witness records remain review-only', () {
      const unresolvedIds = {
        'cd7a02a9-54cb-4d30-a915-a90a6fd9a2e9',
        '49a09b23-21e1-47a0-9cec-c5ae9c98b06b',
        'f3088f90-d92d-4008-83a8-a1963f50a717',
        'd8035663-2d5c-46f7-bc9a-c20a98beb7b6',
        'f9f475b2-5a47-4128-8c13-16d828359c3f',
        'fd2474e2-427e-4c38-8a72-4fe9b3581779',
      };

      final actualUnresolvedIds = works
          .cast<Map<String, dynamic>>()
          .where(
            (item) =>
                (item['verification']
                        as Map<String, dynamic>?)?['evidenceLevel'] ==
                    'primaryChecked' &&
                item['secondarySource'] == null,
          )
          .map((item) => item['id'] as String)
          .toSet();
      expect(actualUnresolvedIds, unresolvedIds);

      for (final work in works.cast<Map<String, dynamic>>().where(
        (item) => unresolvedIds.contains(item['id']),
      )) {
        final verification = work['verification'] as Map<String, dynamic>;
        final rights = work['rights'] as Map<String, dynamic>;

        expect(verification['evidenceLevel'], 'primaryChecked');
        expect(work['secondarySource'], isNull, reason: work['id'] as String);
        expect(work['textTajik'], isNull, reason: work['id'] as String);
        expect(work['textPersian'], isNull, reason: work['id'] as String);
        expect(rights['fullTextAllowed'], isFalse);
        expect(rights['excerptAllowed'], isFalse);
      }

      final loiq = works.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['id'] == '49a09b23-21e1-47a0-9cec-c5ae9c98b06b',
      );
      final occurrences = loiq['sourceOccurrences'] as List<dynamic>;
      expect(occurrences, hasLength(1));
      expect((occurrences.single as Map<String, dynamic>)['pageStart'], 304);
    });

    test('No fake institutional verifiedBy names', () {
      final fakeInstitutions = [
        'Institute of Language and Literature',
        'Институти забон ва адабиёт',
        'Academy of Sciences',
        'AI Verifier',
        'Zarbulmasal System',
      ];

      for (final work in works) {
        final w = work as Map<String, dynamic>;
        final v = w['verification'] as Map<String, dynamic>?;

        if (v != null) {
          final verifiedBy =
              (v['verifiedBy'] as List<dynamic>?)?.cast<String>() ?? [];
          for (final person in verifiedBy) {
            for (final fake in fakeInstitutions) {
              expect(
                person.toLowerCase().contains(fake.toLowerCase()),
                isFalse,
                reason:
                    'Work ${w['id']} uses a fake or institutional verifiedBy: $person',
              );
            }
          }
        }
      }
    });

    test('No bulk verification of 100% of the corpus', () {
      int editoriallyApproved = 0;
      int sourceLocated = 0;

      for (final work in works) {
        final w = work as Map<String, dynamic>;
        final v = w['verification'] as Map<String, dynamic>?;
        final level = v?['evidenceLevel'] as String? ?? 'extracted';

        if (level == 'editoriallyApproved') editoriallyApproved++;
        if (level == 'sourceLocated') sourceLocated++;
      }

      // It is impossible for humans to verify 100% of the works so quickly.
      expect(
        editoriallyApproved,
        lessThan(1000),
        reason:
            'Too many works ($editoriallyApproved) claimed as editorially approved. This indicates fake bulk verification.',
      );
      expect(sourceLocated, greaterThanOrEqualTo(0));
    });
  });
}
