import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Literary content: collated witnesses', () {
    late List poets;
    late List works;
    late List canon;

    setUpAll(() {
      poets =
          jsonDecode(
                File('assets/data/literature/poets.json').readAsStringSync(),
              )
              as List;
      works =
          jsonDecode(
                File('assets/data/literature/works.json').readAsStringSync(),
              )
              as List;
      canon =
          jsonDecode(
                File(
                  'assets/data/literature/school_canon.json',
                ).readAsStringSync(),
              )
              as List;
    });

    test('Rudaki poem keeps the line-collated Maorif 2025 witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'rudaki_buyi_juyi_muliyon_grade5_2017_p54',
      );

      expect(work['authorId'], 'rudaki');
      expect(work['title'], 'Бӯйи Ҷӯйи Мулиён');
      expect(work['primarySource']['pageStart'], 54);
      expect(work['secondarySource']['pageStart'], 56);
      expect(work['secondarySource']['pageEnd'], 56);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01K6HGRAG6CPT6S1XBVK6KBPJT.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/rudaki_buyi_muliyon_maorif_2025_p56.png',
      );
      expect(work['textMatchResult'], 'minor-variant');
      expect(work['variantNotes'], contains('Дувоздаҳ мисраъ'));
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
      expect(work['textPersian'], isNull);
    });

    test('Lo(iq) mother qasida records a title-only Maorif occurrence', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == '49a09b23-21e1-47a0-9cec-c5ae9c98b06b',
      );

      expect(work['authorId'], 'loiq_sherali');
      expect(work['secondarySource'], isNull);
      expect(work['sourceOccurrences'], hasLength(1));
      final occurrence = work['sourceOccurrences'].single;
      expect(occurrence['pageStart'], 304);
      expect(occurrence['pageEnd'], 304);
      expect(
        occurrence['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F02T45W6EQD3B5FPGGTTXJ.pdf',
      );
      // The grade 11 book names the poem on p. 296 but does not print it.
      expect(work['primarySource']['pageStart'], 296);
      expect(
        work['primarySource']['sourceReference'],
        'docs/literature/pdfs/adabiyet sinfi 11.pdf',
      );
      expect(work['textStatus'], 'needsReview');
      expect(work['verification']['evidenceLevel'], 'needsReview');
      expect(work['rights']['fullTextAllowed'], isFalse);
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Халилӣ keeps the mother poem that was filed under Лоиқ', () {
      final khalili = works.firstWhere(
        (entry) =>
            entry['id'] ==
            'poem_fd212071-6a30-4b8d-870a-ae784002e8f2_af106dc3d6c291df',
      );
      expect(khalili['title'], 'Ҳадя ба модарон');
      expect(
        khalili['textTajik'] as String,
        contains('Гуфт: «Аз як қатра ашки модарам,'),
      );
      final loiqText = works
          .where((entry) => entry['authorId'] == 'loiq_sherali')
          .map((entry) => (entry['textTajik'] as String?) ?? '')
          .join('\n');
      expect(loiqText, isNot(contains('Аз як қатра ашки модарам')));
    });

    test('Lo(iq) four-line poem keeps the exact Maorif 2025 witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'b262d381-d677-47f7-8074-12f7bf1267da',
      );

      expect(work['authorId'], 'loiq_sherali');
      expect(work['title'], 'Шоири фарзонаро асру замон');
      expect(work['primarySource']['pageStart'], 288);
      expect(work['secondarySource']['pageStart'], 288);
      expect(work['secondarySource']['pageEnd'], 288);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01KH8MQHJJBRM70Q8FXHNNCGV5.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/loiq_shoiri_farzonaro_maorif_2025_p288.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
      expect(work['textPersian'], isNull);
    });

    test('Hafez ghazal keeps the exact Maorif 2023 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == '0f48abbb-5652-4054-b518-dae7ea332240',
      );

      expect(work['authorId'], 'd1abb54a-9804-4baf-b238-fd2203d7673e');
      expect(work['title'], 'Агар он турки шерозӣ ба даст орад дили моро');
      expect(work['sourceOccurrences'], hasLength(1));
      final occurrence = work['sourceOccurrences'].single;
      expect(occurrence['pageStart'], 201);
      expect(occurrence['pageEnd'], 201);
      expect(
        occurrence['sourceReference'],
        'docs/literature/pdfs/adabiet sinfi 10.pdf',
      );
      expect(occurrence['sourceImageVerified'], isTrue);
      expect(
        occurrence['sourceImagePath'],
        'assets/data/literature/page_images/hafez_agar_on_turki_grade10_2026_p201.png',
      );
      expect(work['secondarySource']['pageStart'], 173);
      expect(work['secondarySource']['pageEnd'], 173);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F20TCS153WXVYZ6XFCVGXM.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/hafez_agar_maorif_2023_p173.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
    });

    test('Tursunzoda poem keeps the exact Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'f4c025e3-48a1-4bc1-8e29-cf404472e590',
      );

      expect(work['authorId'], 'tursunzoda');
      expect(work['title'], 'Зан агар оташ намешуд...');
      expect(work['primarySource']['pageStart'], 161);
      expect(work['secondarySource']['pageStart'], 160);
      expect(work['secondarySource']['pageEnd'], 160);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F02T45W6EQD3B5FPGGTTXJ.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/tursunzoda_zan_agar_maorif_2022_p160.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
      expect(work['textPersian'], isNull);
    });

    test('Bozor poem keeps the exact Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'ced3e012-00e7-4c97-bb64-61d3045459b2',
      );

      expect(work['authorId'], 'bozor_sobir');
      expect(work['title'], 'Забони модарӣ');
      expect(work['primarySource']['pageStart'], 313);
      expect(work['secondarySource']['pageStart'], 313);
      expect(work['secondarySource']['pageEnd'], 313);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F02T45W6EQD3B5FPGGTTXJ.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/bozor_zaboni_modari_maorif_2022_p313.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
      expect(work['textPersian'], isNull);
    });

    test('Rabi’a qasida keeps the exact Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'f0d76502-0ef6-4660-856c-26d27e9baee9',
      );

      expect(work['authorId'], '3d5d70c0-6294-4b7d-b830-79db08edd6b8');
      expect(work['title'], 'Фишонд аз савсану гул симу зар бод');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['primarySource']['pageStart'], 60);
      expect(work['secondarySource']['pageStart'], 61);
      expect(work['secondarySource']['pageEnd'], 62);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F0Y279HFXYHRM4396KWW0C.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(work['secondarySource']['sourceImagePaths'], hasLength(2));
      expect(work['textMatchResult'], 'exact');
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
      expect(work['textPersian'], isNull);
    });

    test('Ayni poem keeps the line-collated Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == '0136bbcb-75f0-4e53-b66f-1b4a12f6b211',
      );

      expect(work['authorId'], '47c1dc67-363a-4506-8a9c-bbbb38f98d20');
      expect(work['title'], 'Биёед, эй рафиқон, дарс хонем');
      expect(work['primarySource']['pageStart'], 153);
      expect(work['secondarySource']['pageStart'], 132);
      expect(work['secondarySource']['pageEnd'], 132);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F0Y279HFXYHRM4396KWW0C.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/ayni_biyod_maorif_2022_p132.png',
      );
      expect(work['textMatchResult'], 'minor-variant');
      expect(work['variantNotes'], contains('бекориву'));
      expect(work['variantNotes'], contains('бекорию'));
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
      expect(work['textPersian'], isNull);
    });

    test(
      'Kamol Khujandi second witnesses stay attached to the correct ghazals',
      () {
        final oshubi = works.firstWhere(
          (entry) =>
              entry['id'] == 'kamol_khujandi_oshubi_joni_grade7_2018_p106',
        );
        final dust = works.firstWhere(
          (entry) =>
              entry['id'] ==
              'kamol_khujandi_dust_medorad_dilam_grade7_2018_p106_107',
        );

        expect(oshubi['title'], 'Ошӯби ҷонӣ');
        expect(oshubi['primarySource']['pageStart'], 106);
        expect(oshubi['primarySource']['pageEnd'], 106);
        expect(oshubi['secondarySource'], isNull);
        expect(oshubi['textStatus'], 'needsReview');

        expect(dust['title'], 'Дӯст медорад дилам ҷавру ҷафои дӯстро');
        expect(dust['primarySource']['pageStart'], 106);
        expect(dust['primarySource']['pageEnd'], 107);
        expect(dust['secondarySource']['pageStart'], 102);
        expect(dust['secondarySource']['pageEnd'], 103);
        expect(
          dust['secondarySource']['sourceReference'],
          'https://maorif.tj/storage/libraries/01KH604RAK569PDJBYDN82T6WE.pdf',
        );
        expect(dust['textStatus'], 'verified');
        expect(dust['rights']['status'], 'sourceAttested');
        expect((dust['textTajik'] as String).trim(), isNotEmpty);
      },
    );

    test('Qanoat poem keeps the explicit textbook title and page span', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'qanoat_mavj_dar_sahro_grade6_2014_p147_148',
      );

      expect(work['authorId'], 'qanoat');
      expect(work['title'], 'Мавҷ дар саҳро');
      expect(work['type'], 'poem');
      expect(work['primarySource']['pageStart'], 147);
      expect(work['primarySource']['pageEnd'], 148);
      expect(
        work['primarySource']['sourceReference'],
        'docs/literature/pdfs/adabiet sinfi 6.pdf',
      );
      expect(work['primarySource']['sourceImageVerified'], isTrue);
      expect(work['primarySource']['sourceImagePaths'], hasLength(2));
      expect(work['secondarySource']['pageStart'], 148);
      expect(work['secondarySource']['pageEnd'], 148);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F1F8T37FBPNG27VF4N5P15.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/qanoat_mavj_maorif_2022_p148.png',
      );
      expect(work['textMatchResult'], 'minor-variant');
      expect(work['variantNotes'], contains('Украина.Мавҷи'));
      expect(work['variantNotes'], contains('Украина! Мавҷи'));
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['verification']['pageVerified'], isTrue);
      expect(work['rights']['status'], 'sourceAttested');
      expect((work['textTajik'] as String).trim(), isNotEmpty);
      expect(work['textPersian'], isNull);
    });

    test('Qanoat multi-page poem titles remain distinct canonical works', () {
      final expected = {
        'qanoat_mavji_odam_grade6_2014_p149_150': (149, 150, 'Мавҷи одам'),
        'qanoat_mavji_barodari_grade6_2014_p150_151': (
          150,
          151,
          'Мавҷи бародарӣ',
        ),
      };

      for (final entry in expected.entries) {
        final work = works.firstWhere(
          (candidate) => candidate['id'] == entry.key,
        );
        expect(work['authorId'], 'qanoat');
        expect(work['title'], entry.value.$3);
        expect(work['primarySource']['pageStart'], entry.value.$1);
        expect(work['primarySource']['pageEnd'], entry.value.$2);
        expect(work['primarySource']['sourceImageVerified'], isTrue);
        expect(work['primarySource']['sourceImagePaths'], hasLength(2));
        expect(work['sourceOccurrences'], hasLength(1));
        expect(work['sourceOccurrences'].single['pageStart'], 278);
        expect(
          work['sourceOccurrences'].single['sourceReference'],
          'docs/literature/pdfs/adabiyet sinfi 11.pdf',
        );
        expect(work['sourceOccurrences'].single['sourceImageVerified'], isTrue);
        expect(work['secondarySource']['pageStart'], entry.value.$1);
        expect(work['secondarySource']['pageEnd'], entry.value.$2);
        expect(
          work['secondarySource']['sourceReference'],
          'https://maorif.tj/storage/libraries/01J3F1F8T37FBPNG27VF4N5P15.pdf',
        );
        expect(work['secondarySource']['sourceImageVerified'], isTrue);
        expect(work['secondarySource']['sourceImagePaths'], hasLength(2));
        expect(work['textMatchResult'], 'exact');
        expect(work['verification']['evidenceLevel'], 'primaryChecked');
        expect(work['verification']['pageVerified'], isTrue);
        expect(work['rights']['status'], 'sourceAttested');
        expect((work['textTajik'] as String).trim(), isNotEmpty);
      }
    });

    test('All works referenced by school canon exist', () {
      final workIds = works.map((w) => w['id']).toSet();
      for (final entry in canon) {
        if (entry['workId'] != null && entry['workId'].toString().isNotEmpty) {
          expect(
            workIds.contains(entry['workId']),
            isTrue,
            reason:
                "Canon entry ${entry['id']} references unknown work ${entry['workId']}",
          );
        }
      }
    });

    test('Editorially approved works have required provenance and rights', () {
      for (final work in works) {
        final verification = work['verification'] ?? {};
        if (verification['evidenceLevel'] == 'editoriallyApproved') {
          expect(
            work['primarySource'],
            isNotNull,
            reason: "Approved work ${work['id']} missing primarySource",
          );
          expect(
            work['textStatus'],
            equals('verified'),
            reason: "Approved work ${work['id']} must have verified textStatus",
          );
          final primarySource = work['primarySource'] as Map<String, dynamic>;
          expect(
            primarySource['pageStart'],
            isA<int>(),
            reason:
                "Approved work ${work['id']} needs a documented source page",
          );
          expect(
            verification['pageVerified'],
            isTrue,
            reason: "Approved work ${work['id']} must confirm its source page",
          );

          final rights = work['rights'];
          expect(
            rights,
            isNotNull,
            reason: "Work ${work['id']} missing rights",
          );
          expect(
            rights['status'],
            isNot(equals('unknown')),
            reason: "Approved work ${work['id']} has unknown rights",
          );
          expect(
            rights['status'],
            isNot(equals('blocked')),
            reason: "Approved work ${work['id']} has blocked rights",
          );
        }
      }
    });

    test('All works use the canonical verification schema', () {
      const evidenceLevels = {
        'extracted',
        'sourceLocated',
        'primaryChecked',
        'secondWitnessLocated',
        'collated',
        'editoriallyApproved',
        'rejected',
        'needsReview',
      };

      for (final work in works) {
        final verification = work['verification'];
        expect(verification, isA<Map>());
        expect(evidenceLevels, contains(verification['evidenceLevel']));
        final pageVerified = verification['pageVerified'];
        if (pageVerified != null) {
          expect(pageVerified, isA<bool>());
        }
        if (verification['evidenceLevel'] == 'primaryChecked' ||
            verification['evidenceLevel'] == 'editoriallyApproved') {
          expect(pageVerified, isTrue);
        }
        expect(verification, isNot(contains('finalStatus')));
        expect(verification, isNot(contains('pageChecked')));
      }
    });

    test(
      'Rejected extraction candidates carry an explicit quarantine reason',
      () {
        final rejected = works
            .where(
              (work) => work['verification']['evidenceLevel'] == 'rejected',
            )
            .toList();

        expect(rejected, isNotEmpty);
        final expectedDuplicateTargets = {
          'f577d913-68cf-4868-9f1c-20873b27586a':
              '7673c21c-eabd-4f67-954c-99af1028a7a7',
          'poem_3ec91317-fcfe-4960-9ca0-fd87f3e96875_80be041bf488740f':
              'd02917e3-6e5f-4f65-9166-ad705decb7be',
          '365b30a4-10ac-411c-918b-c5081254acc2':
              'd02917e3-6e5f-4f65-9166-ad705decb7be',
          'poem_tursunzoda_37aea1e9bce734d9':
              'f4c025e3-48a1-4bc1-8e29-cf404472e590',
          'poem_f09073cb-33b4-4fcc-abf8-75959350245c_44051f759d121097':
              'f9f475b2-5a47-4128-8c13-16d828359c3f',
          'poem_9ab32712-ce1d-4054-a7cc-163ca4a8f11f_28a16b52c71a8979':
              'fd2474e2-427e-4c38-8a72-4fe9b3581779',
          'poem_a6dd1c54-753d-4a52-8e5b-5365b7908aa3_a9179064e19a1450':
              'c03e8139-0ed8-4167-9ded-212ba3c7c564',
          'poem_5fc69b51-c38a-4427-a362-5c8a14bca835_def097ba98516b2e':
              'f3088f90-d92d-4008-83a8-a1963f50a717',
          // Phase 8: grade 9, p. 310 prints the opening of Ҳилолӣ's qit'a
          // that grade 5, pp. 149–150 prints in full.
          '8db2433e-82b4-5a70-90b5-204385aa76ad':
              'poem_f09073cb-33b4-4fcc-abf8-75959350245c_61fd5ec10e2a853c',
          // Grade 5, pp. 275–278: two pieces of Миршакар's «Ленин дар
          // Помир» (фасли нахуст), now one passage.
          'poem_a7feaa09-c83f-44f2-a69e-0a46ba957dbc_da64ab2ee3ff5cff':
              'poem_a7feaa09-c83f-44f2-a69e-0a46ba957dbc_eca93af5527d4f40',
          'poem_a7feaa09-c83f-44f2-a69e-0a46ba957dbc_3ad8a490343d82d3':
              'poem_a7feaa09-c83f-44f2-a69e-0a46ba957dbc_eca93af5527d4f40',
          // Grade 7, p. 222 quotes the opening of Аминзода's «Имзо мекунем»
          // (pp. 227–229).
          'poem_12fb0e82-f108-4e71-8207-74d0540639d3_3f89fb0bcd1bec1f':
              'poem_12fb0e82-f108-4e71-8207-74d0540639d3_f398887d5a62325b',
        };
        for (final work in rejected) {
          final verification = work['verification'] as Map<String, dynamic>;
          final reason = verification['rejectionReason'] as String;
          if (reason.startsWith('duplicate_canonical_work:')) {
            final expectedCanonical = expectedDuplicateTargets[work['id']];
            expect(expectedCanonical, isNotNull);
            expect(reason, 'duplicate_canonical_work:$expectedCanonical');
            expect(
              verification['verificationMethod'],
              'manualCanonicalDuplicateReview',
            );
            final canonicalWork = works.firstWhere(
              (candidate) => candidate['id'] == expectedCanonical,
            );
            expect(
              canonicalWork['verification']['evidenceLevel'],
              anyOf('primaryChecked', 'editoriallyApproved', 'needsReview'),
              reason:
                  'Duplicate ${work['id']} must point to a non-rejected canonical work',
            );
          } else {
            expect(
              reason,
              startsWith('extraction_false_positive:'),
              reason: 'Rejected work ${work['id']} needs an auditable reason',
            );
            expect(
              verification['verificationMethod'],
              anyOf(
                'conservativeFalseCandidateQuarantine',
                'manualContentTypeReview',
                'manualAttributionReview',
              ),
            );
          }
          expect(work['textTajik'], isNull);
          expect(work['textPersian'], isNull);
        }
      },
    );

    test('Newly promoted biographies cite the exact textbook pages', () {
      final expected = {
        'juma_odina': '«Адабиёти тоҷик», синфи 6 (2014), с. 155',
        'nasrulloh': '«Адабиёти тоҷик», синфи 8 (2026), с. 220–221',
        'faromuz': '«Адабиёти тоҷик», синфи 8 (2026), с. 226',
        'mirzosodiq': '«Адабиёти тоҷик», синфи 10 (2026), с. 163–165',
        'gulkhani': '«Адабиёти тоҷик», синфи 10 (2026), с. 207–209',
        'qooni': '«Адабиёти тоҷик», синфи 10 (2026), с. 216–217',
        'savdo': '«Адабиёти тоҷик», синфи 10 (2026), с. 270–272',
        'karomatullohi_mirzo': '«Адабиёти тоҷик», синфи 11 (2026), с. 390–392',
        'sayf_rahimzod': '«Адабиёти тоҷик», синфи 11 (2026), с. 317–318',
        'buzurgmehr': '«Адабиёти тоҷик», синфи 8 (2026), с. 19–21',
        'hoziq': '«Адабиёти тоҷик», синфи 10 (2026), с. 185–189',
        'vozeh': '«Адабиёти тоҷик», синфи 10 (2026), с. 319–322',
        'kangurti': '«Адабиёти тоҷик», синфи 11 (2026), с. 40–44',
        'sattor_tursun': '«Адабиёти тоҷик», синфи 11 (2026), с. 326–327',
        'mehmon_bakhti': '«Адабиёти тоҷик», синфи 11 (2026), с. 355–357',
        'abdulhamid_samad': '«Адабиёти тоҷик», синфи 11 (2026), с. 381–382',
      };
      for (final entry in expected.entries) {
        final poet = poets.firstWhere(
          (candidate) => candidate['id'] == entry.key,
        );
        expect(poet['biographyTj'], isNotEmpty);
        expect(poet['biographyTjProvenance'], 'SOURCE_BACKED');
        expect(poet['biographySource'], entry.value);
        expect(poet['biographyFaProvenance'], 'EDITORIAL_TRANSLATION');
      }
    });

    test('Pending page records use the exact textbook witness', () {
      final expected = {
        'b743e878-8215-4727-b67e-ad56dfccfbbe': (
          290,
          'docs/literature/pdfs/adabiyet sinfi 11.pdf',
          'Адабиёти тоҷик (давраи нав)',
        ),
        '0c468886-d790-46eb-bc2c-07ce1f306f8a': (
          298,
          'docs/literature/pdfs/adabiyet sinfi 11.pdf',
          'Адабиёти тоҷик (давраи нав)',
        ),
        '01c92ca0-db0b-4993-ad30-93ee6fc9126f': (
          12,
          'docs/literature/pdfs/adabiet sinfi 6.pdf',
          'Адабиёти тоҷик',
        ),
      };

      for (final entry in expected.entries) {
        final work = works.firstWhere(
          (candidate) => candidate['id'] == entry.key,
        );
        final source = work['primarySource'] as Map<String, dynamic>;
        expect(source['pageStart'], entry.value.$1);
        expect(source['pageEnd'], entry.value.$1);
        expect(source['sourceReference'], entry.value.$2);
        expect(source['bookTitle'], entry.value.$3);
        expect(source['sourceImageVerified'], isFalse);
      }
    });
  });
}
