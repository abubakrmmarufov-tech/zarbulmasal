import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';

void main() {
  final cyrillicRegex = RegExp(r'[\u0400-\u04FF]');
  final latinRegex = RegExp(r'[A-Za-z]');

  group('Persian Zero-Leak & Translation Parity', () {
    test(
      'AppTranslations.fa has 100% key symmetry with AppTranslations.tj',
      () {
        final tjKeys = AppTranslations.tj.keys.toSet();
        final faKeys = AppTranslations.fa.keys.toSet();

        final missingInFa = tjKeys.difference(faKeys);
        final extraInFa = faKeys.difference(tjKeys);

        expect(
          missingInFa,
          isEmpty,
          reason: 'Keys present in tj but missing in fa: $missingInFa',
        );
        expect(
          extraInFa,
          isEmpty,
          reason: 'Keys present in fa but missing in tj: $extraInFa',
        );
        expect(AppTranslations.fa.length, equals(AppTranslations.tj.length));
      },
    );

    test(
      'AppTranslations.fa values contain strictly 0 Cyrillic characters',
      () {
        final leaks = <String, String>{};

        for (final entry in AppTranslations.fa.entries) {
          expect(
            entry.value.trim(),
            isNotEmpty,
            reason: 'Empty translation for key ${entry.key}',
          );
          if (cyrillicRegex.hasMatch(entry.value)) {
            leaks[entry.key] = entry.value;
          }
        }

        expect(
          leaks,
          isEmpty,
          reason: 'Found Cyrillic leaks in AppTranslations.fa: $leaks',
        );
      },
    );

    test(
      'assets/data/history/books.json Persian fields contain strictly 0 Cyrillic characters',
      () {
        final file = File('assets/data/history/books.json');
        final books = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        expect(
          books.length,
          equals(10),
          reason: 'Expected 10 textbooks (7 history grades 5-11, 3 literature)',
        );

        for (final book in books) {
          final id = book['id'] as String;
          final titlePersian = book['titlePersian'] as String?;
          final authorPersian = book['authorPersian'] as String?;
          final descPersian = book['descriptionPersian'] as String?;

          expect(
            titlePersian,
            isNotNull,
            reason: 'Missing titlePersian in book $id',
          );
          expect(
            titlePersian!.trim(),
            isNotEmpty,
            reason: 'Empty titlePersian in book $id',
          );
          expect(
            cyrillicRegex.hasMatch(titlePersian),
            isFalse,
            reason: 'Cyrillic leak in book $id titlePersian: $titlePersian',
          );

          expect(
            authorPersian,
            isNotNull,
            reason: 'Missing authorPersian in book $id',
          );
          expect(
            authorPersian!.trim(),
            isNotEmpty,
            reason: 'Empty authorPersian in book $id',
          );
          expect(
            cyrillicRegex.hasMatch(authorPersian),
            isFalse,
            reason: 'Cyrillic leak in book $id authorPersian: $authorPersian',
          );

          expect(
            descPersian,
            isNotNull,
            reason: 'Missing descriptionPersian in book $id',
          );
          expect(
            descPersian!.trim(),
            isNotEmpty,
            reason: 'Empty descriptionPersian in book $id',
          );
          expect(
            cyrillicRegex.hasMatch(descPersian),
            isFalse,
            reason:
                'Cyrillic leak in book $id descriptionPersian: $descPersian',
          );
        }
      },
    );

    test(
      'assets/data/history/entries.json Persian fields contain strictly 0 Cyrillic characters',
      () {
        final file = File('assets/data/history/entries.json');
        final entries = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        expect(
          entries.length,
          equals(85),
          reason: 'Expected 85 verified history entries',
        );

        final leaks = <String>[];

        for (final entry in entries) {
          final id = entry['id'] as String;
          final titlePersian = entry['titlePersian'] as String?;
          final summaryPersian = entry['summaryPersian'] as String?;
          final periodPersian = entry['periodPersian'] as String?;
          final significancePersian = entry['significancePersian'] as String?;
          final datesPersian = entry['datesPersian'] as String?;
          final capitalPersian = entry['capitalPersian'] as String?;
          final territoryPersian = entry['territoryPersian'] as String?;
          final founderPersian = entry['founderPersian'] as String?;
          final religionPersian = entry['religionPersian'] as String?;
          final originsPersian = entry['originsPersian'] as String?;
          final culturePersian = entry['culturePersian'] as String?;
          final declinePersian = entry['declinePersian'] as String?;

          expect(
            titlePersian,
            isNotNull,
            reason: 'Missing titlePersian in entry $id',
          );
          expect(
            titlePersian!.trim(),
            isNotEmpty,
            reason: 'Empty titlePersian in entry $id',
          );
          if (cyrillicRegex.hasMatch(titlePersian)) {
            leaks.add('$id: titlePersian -> $titlePersian');
          }

          expect(
            summaryPersian,
            isNotNull,
            reason: 'Missing summaryPersian in entry $id',
          );
          expect(
            summaryPersian!.trim(),
            isNotEmpty,
            reason: 'Empty summaryPersian in entry $id',
          );
          if (cyrillicRegex.hasMatch(summaryPersian)) {
            leaks.add('$id: summaryPersian -> $summaryPersian');
          }

          if (periodPersian != null && cyrillicRegex.hasMatch(periodPersian)) {
            leaks.add('$id: periodPersian -> $periodPersian');
          }

          if (significancePersian != null &&
              cyrillicRegex.hasMatch(significancePersian)) {
            leaks.add('$id: significancePersian -> $significancePersian');
          }

          if (datesPersian != null && cyrillicRegex.hasMatch(datesPersian)) {
            leaks.add('$id: datesPersian -> $datesPersian');
          }

          if (capitalPersian != null &&
              cyrillicRegex.hasMatch(capitalPersian)) {
            leaks.add('$id: capitalPersian -> $capitalPersian');
          }

          if (territoryPersian != null &&
              cyrillicRegex.hasMatch(territoryPersian)) {
            leaks.add('$id: territoryPersian -> $territoryPersian');
          }

          if (founderPersian != null &&
              cyrillicRegex.hasMatch(founderPersian)) {
            leaks.add('$id: founderPersian -> $founderPersian');
          }

          if (religionPersian != null &&
              cyrillicRegex.hasMatch(religionPersian)) {
            leaks.add('$id: religionPersian -> $religionPersian');
          }

          if (originsPersian != null &&
              cyrillicRegex.hasMatch(originsPersian)) {
            leaks.add('$id: originsPersian -> $originsPersian');
          }

          if (culturePersian != null &&
              cyrillicRegex.hasMatch(culturePersian)) {
            leaks.add('$id: culturePersian -> $culturePersian');
          }

          if (declinePersian != null &&
              cyrillicRegex.hasMatch(declinePersian)) {
            leaks.add('$id: declinePersian -> $declinePersian');
          }

          final keyFiguresPersian =
              (entry['keyFiguresPersian'] as List<dynamic>?)?.cast<String>() ??
              [];
          for (final kf in keyFiguresPersian) {
            if (cyrillicRegex.hasMatch(kf)) {
              leaks.add('$id: keyFiguresPersian -> $kf');
            }
          }

          final rulersPersian =
              (entry['rulersPersian'] as List<dynamic>?)?.cast<String>() ?? [];
          for (final r in rulersPersian) {
            if (cyrillicRegex.hasMatch(r)) {
              leaks.add('$id: rulersPersian -> $r');
            }
          }

          final claimProvenance =
              (entry['claimProvenance'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          for (final cp in claimProvenance) {
            final claimFa = cp['claimPersian'] as String?;
            if (claimFa != null && cyrillicRegex.hasMatch(claimFa)) {
              leaks.add('$id: claimProvenance.claimPersian -> $claimFa');
            }
          }
        }

        expect(
          leaks,
          isEmpty,
          reason: 'Found Cyrillic leaks in history entries: $leaks',
        );
      },
    );

    test(
      'assets/data/literature/poets.json Persian fields contain strictly 0 Cyrillic characters',
      () {
        final file = File('assets/data/literature/poets.json');
        final poets = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        final leaks = <String>[];

        for (final poet in poets) {
          final id = poet['id'] as String;
          final namePersian = poet['canonicalNamePersian'] as String?;
          final bioFa = poet['biographyFa'] as String?;

          expect(
            namePersian,
            isNotNull,
            reason: 'Missing canonicalNamePersian in poet $id',
          );
          expect(
            namePersian!.trim(),
            isNotEmpty,
            reason: 'Empty canonicalNamePersian in poet $id',
          );
          if (cyrillicRegex.hasMatch(namePersian)) {
            leaks.add('$id: canonicalNamePersian -> $namePersian');
          }

          final bioProvenance = poet['biographyFaProvenance'] as String? ?? '';
          if (bioProvenance == 'UNSUPPORTED_GENERATED') {
            expect(
              bioFa,
              isNull,
              reason: 'Unsupported Persian biography for $id must be removed',
            );
          } else {
            expect(bioFa, isNotNull, reason: 'Missing biographyFa in poet $id');
            expect(
              bioFa!.trim(),
              isNotEmpty,
              reason: 'Empty biographyFa in poet $id',
            );
            if (cyrillicRegex.hasMatch(bioFa)) {
              leaks.add('$id: biographyFa -> $bioFa');
            }
          }

          for (final field in ['birthPlacePersian', 'literaryPeriodPersian']) {
            final value = poet[field] as String?;
            if (value == null) continue;
            expect(
              value.trim(),
              isNotEmpty,
              reason: 'Empty $field in poet $id',
            );
            if (cyrillicRegex.hasMatch(value)) {
              leaks.add('$id: $field -> $value');
            }
          }

          final titlesPersian =
              (poet['officialTitlesPersian'] as List<dynamic>?)
                  ?.cast<String>() ??
              const <String>[];
          for (final title in titlesPersian) {
            expect(
              title.trim(),
              isNotEmpty,
              reason: 'Empty officialTitlesPersian item in poet $id',
            );
            if (cyrillicRegex.hasMatch(title)) {
              leaks.add('$id: officialTitlesPersian -> $title');
            }
          }
        }

        expect(leaks, isEmpty, reason: 'Found Cyrillic leaks in poets: $leaks');
      },
    );

    test(
      'assets/data/literature/works.json labels generated Persian-script representations honestly',
      () {
        final file = File('assets/data/literature/works.json');
        final works = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        final leaks = <String>[];
        int generatedRepresentations = 0;

        for (final work in works) {
          final id = work['id'] as String;
          final titlePersian = work['titlePersian'] as String?;
          final textPersian = work['textPersian'] as String?;
          final representation = work['persianScriptRepresentation'] as String?;
          final scriptSource = work['scriptSource'] as String?;
          final representationSource = work['persianScriptSource'] as String?;

          if (titlePersian != null) {
            expect(
              titlePersian.trim(),
              isNotEmpty,
              reason: 'Empty titlePersian in work $id',
            );
            if (cyrillicRegex.hasMatch(titlePersian)) {
              leaks.add('$id: titlePersian -> $titlePersian');
            }
            if (latinRegex.hasMatch(titlePersian)) {
              leaks.add('$id: Latin in titlePersian -> $titlePersian');
            }
          }

          expect(
            textPersian,
            isNull,
            reason:
                'Generated Persian text must not masquerade as a source field in work $id',
          );
          if (work['textTajik'] != null) {
            expect(
              (work['rights'] as Map?)?['status'],
              'sourceAttested',
              reason:
                  'Only published source-attested poems may ship a representation',
            );
            if (representation != null) {
              // Any present representation must be explicitly labeled
              // generated — never accepted as an original Persian witness.
              expect(
                representationSource,
                equals('generated'),
                reason: 'Work $id has an unlabeled script transformation',
              );
              expect(
                representation.trim(),
                isNotEmpty,
                reason:
                    'Empty generated Persian-script representation in work $id',
              );
              if (cyrillicRegex.hasMatch(representation)) {
                leaks.add(
                  '$id: persianScriptRepresentation -> ${representation.substring(0, representation.length > 50 ? 50 : representation.length)}',
                );
              }
              generatedRepresentations++;
            } else {
              // Verified Tajik text may ship without any Persian-script
              // representation; when it does the provenance flag must be
              // absent too, so nothing claims a representation that does
              // not exist.
              expect(
                representationSource,
                isNull,
                reason:
                    'Verified Tajik work $id has no Persian representation but carries a stale persianScriptSource',
              );
            }
          } else {
            expect(
              representation,
              isNull,
              reason:
                  'Quarantined work $id without text must not have a Persian representation',
            );
          }
          expect(
            scriptSource,
            equals('tajikOnly'),
            reason: 'Work $id has no verified Persian source witness',
          );
          expect(
            representationSource == null || representationSource == 'generated',
            isTrue,
            reason:
                'Work $id labels a Persian-script transformation as an original source witness',
          );
        }

        expect(leaks, isEmpty, reason: 'Found Cyrillic leaks in works: $leaks');
        expect(
          generatedRepresentations,
          greaterThan(0),
          reason:
              'Published Tajik poems should expose an honestly labeled Persian-script representation',
        );
      },
    );

    test(
      'seven page-verified Tajik works ship honestly without a Persian representation',
      () {
        final file = File('assets/data/literature/works.json');
        final works = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        // Approved audit set (PROVENANCE_PAGE_AUDIT.md): these verified Tajik
        // works intentionally carry no Persian-script representation, so no
        // stale "generated" flag or source-witness claim may resurface on them.
        const auditIds = <String>{
          'f4c025e3-48a1-4bc1-8e29-cf404472e590',
          'f9f475b2-5a47-4128-8c13-16d828359c3f',
          '6686a9e9-f77a-4b7a-9cc8-f9508bece0a8',
          'ced6cb49-8ac9-4c15-a255-bc74cf50daa8',
          'qanoat_mavj_dar_sahro_grade6_2014_p147_148',
          'qanoat_mavji_odam_grade6_2014_p149_150',
          'qanoat_mavji_barodari_grade6_2014_p150_151',
        };

        final noRepresentation = <String>{};
        for (final work in works) {
          final id = work['id'] as String;
          final hasTajikText =
              (work['textTajik'] as String?)?.trim().isNotEmpty == true;
          final hasRepresentation =
              (work['persianScriptRepresentation'] as String?)
                  ?.trim()
                  .isNotEmpty ==
              true;
          if (hasTajikText && !hasRepresentation) {
            noRepresentation.add(id);
          }
        }

        expect(
          noRepresentation,
          auditIds,
          reason:
              'Verified Tajik works without a Persian representation must match the approved audit set',
        );

        final byId = {for (final work in works) work['id'] as String: work};
        for (final id in auditIds) {
          final work = byId[id]!;
          expect(
            (work['textTajik'] as String?)?.trim().isNotEmpty,
            isTrue,
            reason: 'Audit work $id must carry verified Tajik text',
          );
          expect(
            work['textStatus'],
            'verified',
            reason: 'Audit work $id must be verified',
          );
          expect(
            (work['rights'] as Map?)?['status'],
            'sourceAttested',
            reason: 'Audit work $id must be source-attested',
          );
          expect(
            work['persianScriptSource'],
            isNull,
            reason:
                'Audit work $id must not carry a stale generated-script flag without a representation',
          );
          expect(
            work['textPersian'],
            isNull,
            reason:
                'Audit work $id must not claim a Persian source text it does not have',
          );
          expect(
            work['scriptSource'],
            'tajikOnly',
            reason: 'Audit work $id must not claim a Persian source witness',
          );
        }
      },
    );

    test(
      'seedProverbs contains 150 verified proverbs with 0 Cyrillic characters in persianText',
      () {
        expect(
          seedProverbs.length,
          equals(150),
          reason: 'Expected 150 verified production proverbs',
        );

        final leaks = <String>[];

        for (final proverb in seedProverbs) {
          expect(
            proverb.persianText.trim(),
            isNotEmpty,
            reason: 'Empty persianText in proverb ${proverb.id}',
          );
          if (cyrillicRegex.hasMatch(proverb.persianText)) {
            leaks.add('${proverb.id}: ${proverb.persianText}');
          }
        }

        expect(
          leaks,
          isEmpty,
          reason: 'Found Cyrillic leaks in seedProverbs: $leaks',
        );
      },
    );
  });
}
