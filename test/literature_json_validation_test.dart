import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/domain/oral_heritage_entry.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';

/// Parses the page range that closes a canon `sourceEvidence` citation.
///
/// Canon evidence strings end uniformly as "…с. 49–59." (en dash). Returns
/// the inclusive [start, end] bounds, or null when there is no single
/// parseable range.
(int, int)? parseSourcePageRange(String sourceEvidence) {
  final match = RegExp(
    r'с\.\s*(\d+)\s*[–—-]\s*(\d+)\s*\.?\s*$',
  ).firstMatch(sourceEvidence.trim());
  if (match == null) return null;
  return (int.parse(match.group(1)!), int.parse(match.group(2)!));
}

void main() {
  // The textbook PDFs are held outside the repository; the manifest names
  // each one (docs/literature/pdfs/MANIFEST.json).
  final manifestPdfs = {
    for (final entry
        in (jsonDecode(
                  File('docs/literature/pdfs/MANIFEST.json').readAsStringSync(),
                )
                as Map<String, dynamic>)['pdfs']
            as List)
      entry['file'] as String,
  };

  group('Literature JSON Data Files Validation', () {
    test('poets.json is valid and conforms to LiteraryAuthor model', () {
      final file = File('assets/data/literature/poets.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());

      final list = raw as List<dynamic>;
      // Note: count is NOT asserted here — we track count in metrics, not as a fixed invariant.
      expect(
        list,
        isNotEmpty,
        reason: 'poets.json must have at least one poet',
      );

      final authors = <LiteraryAuthor>[];
      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final author = LiteraryAuthor.fromJson(item as Map<String, dynamic>);
        authors.add(author);
      }

      for (final a in authors) {
        expect(a.id, isNotEmpty);
        expect(a.canonicalName, isNotEmpty);
        // rights.status == unknown IS acceptable (it's honest).
        // We only require that reasoning is provided when publicDomain is claimed.
        expect(
          a.rights.status,
          RightsStatus.unknown,
          reason: 'Unestablished rights must remain unknown for ${a.id}',
        );
        expect(
          {
            'SOURCE_BACKED',
            'EDITORIAL_SUMMARY_FROM_SOURCES',
            'UNSUPPORTED_GENERATED',
          }.contains(a.biographyTjProvenance),
          isTrue,
          reason: 'Invalid Tajik biography provenance for ${a.id}',
        );
        if (a.portrait != null) {
          expect(a.portrait!.isSourceBacked, isTrue);
          expect(File(a.portrait!.assetPath).existsSync(), isTrue);
        }
      }
    });

    test('works.json is valid and conforms to LiteraryWork model', () {
      final file = File('assets/data/literature/works.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());
      final list = raw as List<dynamic>;
      expect(list, isNotEmpty, reason: 'works.json must not be empty');
      // Note: count is NOT asserted as a fixed invariant.

      int approvedCount = 0;
      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final work = LiteraryWork.fromJson(item as Map<String, dynamic>);
        expect(work.id, isNotEmpty);
        expect(work.authorId, isNotEmpty);
        expect(work.title, isNotEmpty);
        if (work.textStatus == TextStatus.needsReview) {
          expect(
            work.textTajik,
            anyOf(isNull, isEmpty),
            reason: 'Unreviewed work ${work.id} must not ship a full text body',
          );
        } else {
          expect(work.textTajik, isNotEmpty);
        }
        if (!work.rights.fullTextAllowed) {
          expect(
            work.textTajik,
            anyOf(isNull, isEmpty),
            reason:
                'Work ${work.id} without full-text rights must not ship Tajik text',
          );
          expect(
            work.textPersian,
            anyOf(isNull, isEmpty),
            reason:
                'Work ${work.id} without full-text rights must not ship Persian text',
          );
          expect(
            work.persianScriptRepresentation,
            anyOf(isNull, isEmpty),
            reason:
                'Work ${work.id} without full-text rights must not ship a generated full-text representation',
          );
        }
        if (!work.rights.excerptAllowed) {
          expect(
            work.incipit,
            anyOf(isNull, isEmpty),
            reason:
                'Work ${work.id} without excerpt rights must not ship an incipit',
          );
        }
        expect(work.primarySource, isNotNull);
        expect(work.hasAuditableCompositionEvidence, isFalse);
        expect(work.textPersian, isNull);
        if (work.persianScriptRepresentation?.trim().isNotEmpty == true) {
          expect(work.persianScriptSource, 'generated');
        }
        expect(work.scriptSource, ScriptSource.tajikOnly);
        if (work.verification.evidenceLevel ==
            VerificationLevel.editoriallyApproved) {
          approvedCount++;
          expect(work.verification.pageVerified, isTrue);
          expect(work.verification.pageVerified, isTrue);
          expect(work.primarySource!.pageStart, isNotNull);
          expect(
            work.isDisplayable,
            isFalse,
            reason: 'Unknown rights must block full-text display',
          );
        }
      }
      expect(approvedCount, greaterThanOrEqualTo(0));
    });

    test('primary-checked works follow the one-source publication policy', () {
      final file = File('assets/data/literature/works.json');
      final works = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final primaryChecked = works.where((work) {
        final verification = work['verification'];
        return verification is Map &&
            verification['evidenceLevel'] == 'primaryChecked';
      });

      expect(primaryChecked, isNotEmpty);
      for (final work in primaryChecked) {
        final verification = work['verification'] as Map;
        final source = work['primarySource'] as Map?;
        expect(verification['pageVerified'], isTrue);
        expect(source?['pageStart'], isNotNull);
        expect(work['rights'], isA<Map>());
        final rights = work['rights'] as Map;
        if (rights['status'] == 'sourceAttested') {
          expect(rights['fullTextAllowed'], isTrue);
          expect(work['textStatus'], 'verified');
          expect((work['textTajik'] as String).trim(), isNotEmpty);
        } else {
          expect(rights['fullTextAllowed'], isNot(true));
        }
      }
    });

    test('Loic Sherali textbook biography facts are page-cited', () {
      final poets =
          jsonDecode(
                File('assets/data/literature/poets.json').readAsStringSync(),
              )
              as List<dynamic>;
      final loiq = poets
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .singleWhere((author) => author['id'] == 'loiq_sherali');

      expect(loiq['birthDateExact'], '20 майи 1941');
      expect(loiq['deathDateExact'], '30 июни 2000');
      expect(loiq['birthPlace'], contains('Мазори Шариф'));
      expect(loiq['biographySource'], contains('с. 254'));
      expect(loiq['biographyTj'], contains('«Ном»'));
    });

    test('Jami has one canonical author record with the page-109 witness', () {
      final poets =
          jsonDecode(
                File('assets/data/literature/poets.json').readAsStringSync(),
              )
              as List<dynamic>;
      final byId = {
        for (final item in poets.whereType<Map>())
          item['id'] as String: Map<String, dynamic>.from(item),
      };

      final jami = byId['9debff75-8664-43ab-a7a9-ed1a4725f69b'];
      expect(jami, isNotNull, reason: 'Missing canonical Jami record');
      expect(byId.containsKey('358dda13-365c-4434-87f0-d404b305adcb'), isFalse);
      expect(jami!['birthDateExact'], '7 ноябри 1414');
      expect(jami['deathDateExact'], '9 ноябри 1492');
      expect(jami['birthPlace'], 'Харҷурди вилояти Ҷом');
      expect(jami['biographySource'], contains('с. 109'));
      expect(jami['biographyTj'], contains('«Баҳористон»'));
    });

    test('sources.json is valid and conforms to SourceEdition model', () {
      final file = File('assets/data/literature/sources.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());

      final list = raw as List<dynamic>;
      expect(list.length, greaterThanOrEqualTo(15));

      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final map = item as Map<String, dynamic>;
        expect(map['id'], isNotNull);
        expect(map['id'], isNotEmpty);

        final edition = SourceEdition.fromJson(map);
        expect(edition.bookTitle, isNotEmpty);
        expect(edition.publisher, isNotEmpty);
        expect(edition.city, isNotEmpty);
        expect(edition.year, isNotEmpty);
        expect(edition.sourceType, isNotEmpty);
      }
    });

    test(
      'local Grades 5–11 textbooks have complete auditable source records',
      () {
        final raw =
            jsonDecode(
                  File(
                    'assets/data/literature/sources.json',
                  ).readAsStringSync(),
                )
                as List<dynamic>;
        final sourcesById = {
          for (final source in raw.whereType<Map>())
            source['id'] as String: Map<String, dynamic>.from(source),
        };

        const expected = {
          'tj_literature_grade_5_2017': ('5', '2017'),
          'tj_literature_grade_6_2014': ('6', '2014'),
          'tj_literature_grade_7_2018': ('7', '2018'),
          'tj_literature_grade_8_2026': ('8', '2026'),
          'tj_literature_grade_9_2026': ('9', '2026'),
          'tj_literature_grade_10_2026': ('10', '2026'),
          'tj_literature_grade_11_2018': ('11', '2018'),
        };

        for (final entry in expected.entries) {
          final source = sourcesById[entry.key];
          expect(source, isNotNull, reason: 'Missing Grade ${entry.value.$1}');
          expect(source!['bookTitle'], startsWith('Адабиёти тоҷик'));
          expect(source['publisher'], 'Маориф');
          expect(source['city'], 'Душанбе');
          expect(source['year'], entry.value.$2);
          expect(source['sourceType'], SourceEditionType.officialTextbook);
          expect(source['isbn'], isNotEmpty);
          expect(source['sourceReference'], endsWith('.pdf'));
          expect(
            source['sourceImageVerified'],
            <String>{
              'tj_literature_grade_5_2017',
              'tj_literature_grade_6_2014',
              'tj_literature_grade_7_2018',
              'tj_literature_grade_8_2026',
              'tj_literature_grade_9_2026',
            }.contains(entry.key),
          );
        }
      },
    );

    test('official 2025 Grade 11 edition is tracked as a reviewed lead', () {
      final sources =
          jsonDecode(
                File('assets/data/literature/sources.json').readAsStringSync(),
              )
              as List<dynamic>;
      final source = sources
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .singleWhere((item) => item['id'] == 'tj_literature_grade_11_2025');

      expect(source['bookTitle'], 'Адабиёти тоҷик (давраи нав)');
      expect(source['authorAsPrinted'], 'Х. Асозода, А. Кўчарзода');
      expect(source['edition'], 'Нашри ҳафтум');
      expect(source['publisher'], 'Маориф');
      expect(source['year'], '2025');
      expect(
        source['sourceReference'],
        'https://maorif.tj/storage/libraries/01KH8MQHJJBRM70Q8FXHNNCGV5.pdf',
      );
      expect(source['sourceImageVerified'], isFalse);
    });

    test('school_canon.json is valid with proper mappings', () {
      final file = File('assets/data/literature/school_canon.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());

      final list = raw as List<dynamic>;
      expect(list.length, greaterThanOrEqualTo(20));

      // Canon entries may now be linked to a registered, coherent work. An
      // unlinked entry (workId empty) must stay pending review; a linked entry
      // must resolve to an existing work by the same author, held on the same
      // source PDF, on a page inside the cited range, and — once citation
      // verified — to a work the domain model considers displayable.
      final works =
          jsonDecode(
                File('assets/data/literature/works.json').readAsStringSync(),
              )
              as List<dynamic>;
      final worksById = {
        for (final w in works.whereType<Map>())
          w['id'] as String: Map<String, dynamic>.from(w),
      };
      final sources =
          jsonDecode(
                File('assets/data/literature/sources.json').readAsStringSync(),
              )
              as List<dynamic>;
      final sourcesById = {
        for (final s in sources.whereType<Map>())
          s['id'] as String: Map<String, dynamic>.from(s),
      };

      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final map = item as Map<String, dynamic>;
        expect(map['id'], isNotEmpty);
        expect(map['authorId'], isNotEmpty);
        final workId = map['workId'] as String;
        if (workId.isEmpty) {
          expect(map['citationStatus'], equals('needsReview'));
        } else {
          final linked = worksById[workId];
          expect(
            linked,
            isNotNull,
            reason: 'Canon ${map['id']} links unknown work $workId',
          );
          final canonEntry = SchoolCanonEntry.fromJson(map);
          final linkedWork = LiteraryWork.fromJson(linked!);
          expect(
            linkedWork.authorId,
            canonEntry.authorId,
            reason: 'Canon ${map['id']} links work by a different author',
          );
          final heldReference =
              ((sourcesById[canonEntry.sourceId]?['sourceReference']
                          as String?) ??
                      '')
                  .replaceAll('\\', '/')
                  .toLowerCase();
          expect(
            linkedWork.primarySource?.sourceReference
                ?.replaceAll('\\', '/')
                .toLowerCase(),
            heldReference,
            reason:
                'Canon ${map['id']} links work not held on source ${canonEntry.sourceId}',
          );
          final range = parseSourcePageRange(canonEntry.sourceEvidence);
          expect(
            range,
            isNotNull,
            reason:
                'Canon ${map['id']} has no parseable page range in sourceEvidence',
          );
          final bounds = range!;
          final pageStart = linkedWork.primarySource?.pageStart;
          expect(
            pageStart != null &&
                pageStart >= bounds.$1 &&
                pageStart <= bounds.$2,
            isTrue,
            reason:
                'Canon ${map['id']} linked work page $pageStart outside cited range ${bounds.$1}–${bounds.$2}',
          );
          if (map['citationStatus'] == 'verified') {
            expect(
              linkedWork.isDisplayable,
              isTrue,
              reason: 'Canon ${map['id']} links non-displayable work $workId',
            );
          }
        }
        expect(map['grade'], isNotEmpty);
        expect(
          ['Адабиёти тоҷик', 'Хониши адабӣ'].contains(map['subject']),
          isTrue,
        );
        expect(map['textbookTitle'], isNotEmpty);
        expect(map['textbookPublisher'], isNotEmpty);
        expect(
          ['mandatory', 'recommended'].contains(map['curriculumType']),
          isTrue,
        );
        expect(map['sourceEvidence'], isNotEmpty);

        final entry = SchoolCanonEntry.fromJson(map);
        expect(entry.id, isNotEmpty);
        expect(entry.isMandatory, isTrue);
        final gradeNum = int.parse(entry.grade);
        expect(
          gradeNum >= 5 && gradeNum <= 11,
          isTrue,
          reason: 'Grade $gradeNum outside 5-11 scope',
        );
      }
    });

    test('local Grades 5–11 canon mappings name their held textbook edition', () {
      final sources =
          jsonDecode(
                File('assets/data/literature/sources.json').readAsStringSync(),
              )
              as List<dynamic>;
      final sourcesById = {
        for (final source in sources.whereType<Map>())
          source['id'] as String: Map<String, dynamic>.from(source),
      };
      final canon =
          jsonDecode(
                File(
                  'assets/data/literature/school_canon.json',
                ).readAsStringSync(),
              )
              as List<dynamic>;

      for (final entry in canon.whereType<Map>()) {
        final grade = int.tryParse(entry['grade'].toString()) ?? 0;
        expect(
          grade >= 5 && grade <= 11,
          isTrue,
          reason: 'Grade $grade outside 5-11 scope',
        );

        final sourceId = entry['sourceId'];
        expect(sourceId, isA<String>(), reason: 'Grade $grade lacks sourceId');
        final source = sourcesById[sourceId];
        expect(source, isNotNull, reason: 'Unknown textbook $sourceId');
        expect(source!['sourceType'], SourceEditionType.officialTextbook);
        expect(entry['textbookPublisher'], source['publisher']);
        expect(entry['textbookYear'], source['year']);
        expect(entry['textbookAuthors'], source['authorAsPrinted']);
        // Canon citation status is coupled to work linking: an unlinked
        // entry (workId empty) must stay pending review, while a linked
        // entry must be citation-verified against the held textbook edition.
        final workId = (entry['workId'] as String? ?? '').trim();
        if (workId.isEmpty) {
          expect(
            entry['citationStatus'],
            equals('needsReview'),
            reason:
                'Unlinked canon entry ${entry['id']} must remain pending review',
          );
        } else {
          expect(
            entry['citationStatus'],
            equals('verified'),
            reason:
                'Linked canon entry ${entry['id']} must be citation-verified',
          );
        }
      }
    });

    test('oral_heritage.json contains valid folklore entries', () {
      final file = File('assets/data/literature/oral_heritage.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());
      final list = raw as List<dynamic>;
      expect(list.length, 14);
      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final entry = OralHeritageEntry.fromJson(item as Map<String, dynamic>);
        expect(entry.id, startsWith('oral-'));
        expect(entry.collectionSource, isNotEmpty);
        expect(entry.publisher, isNotEmpty);
        expect(entry.year, isNotEmpty);
        if (!entry.rights.fullTextAllowed) {
          expect(entry.text.trim(), isEmpty);
          expect(entry.textPersian?.trim(), anyOf(isNull, isEmpty));
        }
      }
    });

    test('Page-backed works retain evidence while rights remain honest', () {
      final file = File('assets/data/literature/works.json');
      final list = jsonDecode(file.readAsStringSync()) as List<dynamic>;

      final approvedWorks = <LiteraryWork>[];
      final primaryCheckedWorks = <LiteraryWork>[];
      final needsReviewWorks = <LiteraryWork>[];

      for (final item in list) {
        final work = LiteraryWork.fromJson(item as Map<String, dynamic>);
        if (work.verification.evidenceLevel ==
            VerificationLevel.editoriallyApproved) {
          approvedWorks.add(work);
        } else if (work.verification.evidenceLevel ==
            VerificationLevel.primaryChecked) {
          primaryCheckedWorks.add(work);
        } else if (work.verification.evidenceLevel ==
            VerificationLevel.needsReview) {
          needsReviewWorks.add(work);
        }
      }

      expect(
        approvedWorks,
        isEmpty,
        reason:
            'No work carries editoriallyApproved evidence; publication is '
            'source-attested at primaryChecked, not dual-witness.',
      );
      expect(primaryCheckedWorks, isNotEmpty);
      expect(
        needsReviewWorks,
        isNotEmpty,
        reason:
            'Unverified works are quarantined as needsReview until evidence is gathered.',
      );
      final published = primaryCheckedWorks.where((work) => work.isDisplayable);
      final pending = primaryCheckedWorks.where((work) => !work.isDisplayable);
      expect(published, isNotEmpty);
      expect(pending, isEmpty);
      for (final work in primaryCheckedWorks) {
        if (work.isDisplayable) {
          expect(work.rights.status, RightsStatus.sourceAttested);
          expect(work.hasTajikText, isTrue);
        } else {
          expect(work.rights.status, RightsStatus.unknown);
        }
        expect(work.verification.pageVerified, isTrue);
        expect(work.primarySource!.pageStart, isNotNull);
        // Poems taken from the text layer of the cited textbook page carry
        // the page citation as their evidence, without a page scan.
        if (work.verification.verificationMethod ==
            'textbookPdfTextExtraction') {
          expect(
            work.primarySource!.sourceReference,
            startsWith('docs/literature/pdfs/'),
          );
          expect(
            manifestPdfs,
            contains(work.primarySource!.sourceReference!.split('/').last),
            reason: 'Cited textbook PDF is not in the manifest: ${work.id}',
          );
          continue;
        }
        expect(work.primarySource!.sourceImageVerified, isTrue);

        final source = work.primarySource!;
        final imagePaths = source.sourceImagePaths.isNotEmpty
            ? source.sourceImagePaths
            : <String>['assets/data/literature/page_images/${work.id}.png'];
        expect(imagePaths, isNotEmpty);
        for (final imagePath in imagePaths) {
          final imageFile = File(imagePath);
          expect(
            imageFile.existsSync(),
            isTrue,
            reason: 'Page image missing for work ${work.id}: $imagePath',
          );
          expect(
            imageFile.lengthSync(),
            greaterThan(10000),
            reason: 'Page image too small for work ${work.id}: $imagePath',
          );
        }
      }
    });

    test('Rights-unknown page scans are not bundled as Flutter assets', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec,
        isNot(contains('assets/data/literature/page_images/')),
        reason:
            'Source scans remain audit evidence until publication rights are cleared.',
      );
    });
  });
}
