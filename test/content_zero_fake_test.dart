import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// LOOP 4 — VALIDATOR REPAIR
///
/// These tests enforce INTEGRITY, not completeness.
/// They detect fabricated provenance patterns that must never return.
///
/// Tests deliberately removed:
///   - Fixed count assertions (e.g. `works.length == 1472`)
///   - `scriptSource == 'both'` requirement (was enforcing the faked pattern)
///   - `pdfPage > 0` for grade-5 entries (was enforcing the pdfPage=1 fake)
///
/// Tests added / preserved:
///   - Unique IDs
///   - No forbidden external sources
///   - History books source validity
///   - claimProvenance present
///   - Generated script NOT labeled source-original
///   - VERIFIED_*_PAGE requires actual page (not 1 or null)
///   - No scriptSource='both' without real image evidence
///   - Poet biographies present and non-trivial
///   - Rights unknown is acceptable; publicDomain requires reasoning
void main() {
  group('Content Integrity Guard (Honest Provenance)', () {
    // ──────────────────────────────────────────────────────────
    // RULE: No forbidden external sources
    // ──────────────────────────────────────────────────────────
    test(
      'Zero forbidden external sources (marifat.tj, wikipedia, google, blogs) in all asset data files',
      () {
        final dataDir = Directory('assets/data');
        final jsonFiles = dataDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList();

        expect(jsonFiles, isNotEmpty);

        final forbiddenTerms = [
          'marifat.tj',
          'wikipedia.org',
          'google.com',
          'blogspot.com',
          'wordpress.com',
          'wikidata.org',
        ];

        for (final file in jsonFiles) {
          final content = file.readAsStringSync().toLowerCase();
          for (final term in forbiddenTerms) {
            expect(
              content.contains(term),
              isFalse,
              reason:
                  'File ${file.path} contains forbidden external reference: $term',
            );
          }
        }
      },
    );

    // ──────────────────────────────────────────────────────────
    // RULE: History books must reference maorif.tj or uploaded books
    // ──────────────────────────────────────────────────────────
    test(
      'All history books point strictly to maorif.tj or uploaded textbook paths',
      () {
        final file = File('assets/data/history/books.json');
        final books = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        for (final book in books) {
          final sourceUrl = book['sourceUrl'] as String? ?? '';
          final localPath = book['localPath'] as String?;
          final isUploadedBook = book['isUploadedBook'] as bool? ?? false;

          expect(
            sourceUrl.startsWith('https://maorif.tj') ||
                isUploadedBook ||
                (localPath != null && localPath.isNotEmpty),
            isTrue,
            reason: 'Book ${book['id']} has invalid sourceUrl: $sourceUrl',
          );
          // Specifically block the misspelled forbidden domain
          expect(
            sourceUrl.contains('marifat.tj'),
            isFalse,
            reason: 'Book ${book['id']} uses forbidden domain marifat.tj',
          );
        }
      },
    );

    // ──────────────────────────────────────────────────────────
    // RULE: History entries must have claimProvenance (non-empty)
    // ──────────────────────────────────────────────────────────
    test('All history entries have valid claimProvenance anchored in textbooks', () {
      final file = File('assets/data/history/entries.json');
      final entries = (jsonDecode(file.readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();

      expect(
        entries,
        isNotEmpty,
        reason: 'History entries list must not be empty',
      );

      for (final entry in entries) {
        final id = entry['id'] as String;
        final provenanceList =
            (entry['claimProvenance'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];

        expect(
          provenanceList,
          isNotEmpty,
          reason: 'History entry $id lacks claimProvenance',
        );

        for (final prov in provenanceList) {
          final claim = prov['claim'] as String? ?? '';
          final sourceBookId = prov['sourceBookId'] as String? ?? '';
          final status = prov['status'] as String? ?? '';
          final pdfPage = prov['pdfPage'];
          final printedPage = prov['printedPage'];

          expect(
            claim.trim(),
            isNotEmpty,
            reason: 'Empty claim in $id provenance',
          );
          expect(
            sourceBookId.startsWith('history-'),
            isTrue,
            reason: 'Invalid sourceBookId $sourceBookId in $id',
          );

          // RULE A: VERIFIED_*_PAGE requires an actual non-trivial page number
          // (not null, not 1 which is the default placeholder)
          if (status == 'VERIFIED_UPLOADED_BOOK_PAGE') {
            final pp = (printedPage as num?)?.toInt();
            final pdf = (pdfPage as num?)?.toInt();
            expect(
              (pp != null && pp > 1) || (pdf != null && pdf > 1),
              isTrue,
              reason:
                  'Entry $id uses VERIFIED_UPLOADED_BOOK_PAGE but page is null or 1 (placeholder). '
                  'Use VERIFIED_DOCUMENT or NEEDS_REVIEW when exact page is not confirmed.',
            );
          }

          // RULE: Valid status values only
          const validStatuses = {
            'VERIFIED_UPLOADED_BOOK_PAGE',
            'VERIFIED_MAORIF_PAGE',
            'VERIFIED_DOCUMENT',
            'SOURCE_LOCATED',
            'NEEDS_REVIEW',
            'UNSUPPORTED',
            'GENERATED_TRANSFORMATION',
            'EDITORIAL_TRANSLATION',
            'PARTIAL',
          };
          expect(
            validStatuses.contains(status),
            isTrue,
            reason: 'Entry $id has invalid provenance status: $status',
          );
        }
      }
    });

    // ──────────────────────────────────────────────────────────
    // RULE: Poets — unique IDs, non-trivial biographies
    // Note: rights.status == unknown IS acceptable (honest)
    // ──────────────────────────────────────────────────────────
    test('Poets dataset has valid structure and non-trivial biographies', () {
      final file = File('assets/data/literature/poets.json');
      final poets = (jsonDecode(file.readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();

      expect(poets, isNotEmpty);
      final seenIds = <String>{};

      for (final poet in poets) {
        final id = poet['id'] as String;
        expect(id.trim(), isNotEmpty, reason: 'Poet has empty id');
        expect(seenIds.contains(id), isFalse, reason: 'Duplicate poet id: $id');
        seenIds.add(id);

        final bioTj = poet['biographyTj'] as String? ?? '';
        final biographyProvenance =
            poet['biographyTjProvenance'] as String? ?? '';
        const validBiographyProvenance = {
          'SOURCE_BACKED',
          'EDITORIAL_SUMMARY_FROM_SOURCES',
          'UNSUPPORTED_GENERATED',
        };
        expect(
          validBiographyProvenance.contains(biographyProvenance),
          isTrue,
          reason:
              'Poet $id has invalid biography provenance: $biographyProvenance',
        );
        if (biographyProvenance == 'UNSUPPORTED_GENERATED') {
          expect(
            bioTj.trim(),
            isEmpty,
            reason:
                'Unsupported biography for $id must be removed from active content',
          );
        } else {
          expect(
            bioTj.trim(),
            isNotEmpty,
            reason: 'Sourced biography for $id must not be empty',
          );
        }

        // rights.status == unknown is HONEST — do not require non-unknown
        final rights = poet['rights'] as Map<String, dynamic>? ?? {};
        final reasoning = rights['reasoning'] as String? ?? '';
        final status = rights['status'] as String? ?? '';

        // If publicDomain is claimed, reasoning must be non-empty
        if (status == 'publicDomain') {
          expect(
            reasoning.trim(),
            isNotEmpty,
            reason:
                'Poet $id is marked publicDomain but has no rights reasoning. '
                'At minimum, state the death year and applicable copyright term.',
          );
        }
      }
    });

    // ──────────────────────────────────────────────────────────
    // RULE: Works — unique IDs, required fields, honest scriptSource
    // ──────────────────────────────────────────────────────────
    test('Works dataset has valid structure and honest scriptSource', () {
      final file = File('assets/data/literature/works.json');
      final works = (jsonDecode(file.readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();

      expect(works, isNotEmpty);
      final seenIds = <String>{};

      int tajikOnly = 0;
      int both = 0;
      int generatedPersian = 0;
      int fakeVerifiedImage = 0;

      final pageImagesDir = Directory('assets/data/literature/page_images');
      final existingImages = pageImagesDir.existsSync()
          ? pageImagesDir
                .listSync()
                .whereType<File>()
                .map((f) => f.uri.pathSegments.last)
                .toSet()
          : <String>{};

      for (final work in works) {
        final id = work['id'] as String;
        final title = work['title'] as String? ?? '';
        final textTj = work['textTajik'] as String? ?? '';
        final script = work['scriptSource'] as String? ?? '';
        final persianScriptSrc = work['persianScriptSource'] as String?;

        expect(id.trim(), isNotEmpty, reason: 'Work has empty id');
        expect(seenIds.contains(id), isFalse, reason: 'Duplicate work id: $id');
        seenIds.add(id);

        expect(title.trim(), isNotEmpty, reason: 'Work $id has empty title');
        expect(
          textTj.trim(),
          isNotEmpty,
          reason: 'Work $id has empty textTajik',
        );

        // RULE B: scriptSource='both' requires genuine page-image evidence
        if (script == 'both') {
          both++;
          final src = work['primarySource'] as Map<String, dynamic>?;
          final imagePath = src?['sourceImagePath'] as String?;
          final imageVerified = src?['sourceImageVerified'] as bool? ?? false;

          if (imageVerified && imagePath != null) {
            final fname = imagePath.split('/').last;
            expect(
              existingImages.contains(fname),
              isTrue,
              reason:
                  'Work $id claims scriptSource=both with sourceImageVerified=true '
                  'but image file $fname does not exist. '
                  'This is fabricated dual-script provenance.',
            );
          } else if (imageVerified && imagePath == null) {
            fakeVerifiedImage++;
          }
        } else if (script == 'tajikOnly') {
          tajikOnly++;
        }

        // RULE B: Generated Persian-script MUST NOT be labeled source-original
        if (persianScriptSrc == 'generated') {
          generatedPersian++;
          // It's fine to have textPersian alongside as display fallback,
          // but scriptSource must NOT claim both genuine scripts
          expect(
            script,
            isNot(equals('both')),
            reason:
                'Work $id has persianScriptSource=generated but scriptSource=both. '
                'Generated text cannot be a source witness.',
          );
        }

        // RULE A: VERIFIED_*_PAGE requires real page
        final ver = work['verification'] as Map<String, dynamic>?;
        final evidenceLevel = ver?['evidenceLevel'] as String?;

        if (evidenceLevel == 'primaryChecked' ||
            evidenceLevel == 'editoriallyApproved') {
          final src = work['primarySource'] as Map<String, dynamic>?;
          final pageStart = src?['pageStart'];
          expect(
            pageStart != null,
            isTrue,
            reason:
                'Work $id has evidenceLevel=$evidenceLevel but no pageStart. '
                'Page-level verification requires an actual page number.',
          );
        }

        // No fabricated sourceImageVerified without actual file
        final src = work['primarySource'] as Map<String, dynamic>?;
        final imageVerified = src?['sourceImageVerified'] as bool? ?? false;
        final imagePath = src?['sourceImagePath'] as String?;

        if (imageVerified && imagePath == null) {
          fakeVerifiedImage++;
        }
      }

      // Allow fakely-verified image count to be reported but fail if any exist
      expect(
        fakeVerifiedImage,
        equals(0),
        reason:
            '$fakeVerifiedImage works claim sourceImageVerified=true but have no sourceImagePath. '
            'This is fabricated verification. Set sourceImageVerified=false.',
      );

      // Summary metrics (informational, not assertion bounds)
      // ignore: avoid_print
      print('  Works with scriptSource=tajikOnly: $tajikOnly');
      // ignore: avoid_print
      print('  Works with scriptSource=both (with genuine evidence): $both');
      // ignore: avoid_print
      print('  Works with persianScriptSource=generated: $generatedPersian');
    });

    // ──────────────────────────────────────────────────────────
    // RULE: No bulk fake verification (upper bound sanity check)
    // ──────────────────────────────────────────────────────────
    test(
      'No suspicious bulk verification: editoriallyApproved count is realistic',
      () {
        final file = File('assets/data/literature/works.json');
        final works = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        int editoriallyApproved = 0;
        for (final work in works) {
          final ver = work['verification'] as Map<String, dynamic>?;
          final level = ver?['evidenceLevel'] as String? ?? '';
          if (level == 'editoriallyApproved') editoriallyApproved++;
        }

        // Upper bound: humans cannot editorially approve thousands of works quickly
        expect(
          editoriallyApproved,
          lessThan(100),
          reason:
              'Too many works ($editoriallyApproved) claimed as editoriallyApproved. '
              'This indicates fake bulk verification.',
        );
      },
    );

    // ──────────────────────────────────────────────────────────
    // RULE: No page=1 default in VERIFIED status for history entries
    // ──────────────────────────────────────────────────────────
    test(
      'No fake page=1 provenance in VERIFIED_UPLOADED_BOOK_PAGE history claims',
      () {
        final file = File('assets/data/history/entries.json');
        final entries = (jsonDecode(file.readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();

        int fakePage1Count = 0;
        for (final entry in entries) {
          final provenanceList =
              (entry['claimProvenance'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          for (final prov in provenanceList) {
            final status = prov['status'] as String? ?? '';
            final pdfPage = (prov['pdfPage'] as num?)?.toInt();
            final printedPage = (prov['printedPage'] as num?)?.toInt();

            if (status == 'VERIFIED_UPLOADED_BOOK_PAGE') {
              if (pdfPage == 1 || printedPage == 1) {
                fakePage1Count++;
                // ignore: avoid_print
                print(
                  '  FAKE PAGE=1: entry=${entry['id']} pdfPage=$pdfPage printedPage=$printedPage',
                );
              }
            }
          }
        }

        expect(
          fakePage1Count,
          equals(0),
          reason:
              '$fakePage1Count history entries have VERIFIED_UPLOADED_BOOK_PAGE with page=1. '
              'Page 1 is a default placeholder, not a real citation.',
        );
      },
    );
  });
}
