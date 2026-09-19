import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Content Zero-Fake & Strict Provenance Integrity Guard', () {
    test('Zero forbidden sources (marifat.tj, wikipedia, google, blogs) in all asset data files', () {
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
            reason: 'File ${file.path} contains forbidden external reference: $term',
          );
        }
      }
    });

    test('All history books point strictly to maorif.tj or uploaded textbook paths', () {
      final file = File('assets/data/history/books.json');
      final books = (jsonDecode(file.readAsStringSync()) as List).cast<Map<String, dynamic>>();

      expect(books.length, equals(7));

      for (final book in books) {
        final sourceUrl = book['sourceUrl'] as String? ?? '';
        final localPath = book['localPath'] as String?;
        final isUploadedBook = book['isUploadedBook'] as bool? ?? false;

        expect(
          sourceUrl.startsWith('https://maorif.tj') || isUploadedBook || (localPath != null && localPath.isNotEmpty),
          isTrue,
          reason: 'Book ${book['id']} has invalid sourceUrl: $sourceUrl',
        );
        expect(sourceUrl.contains('marifat.tj'), isFalse);
      }
    });

    test('All 85 history entries have valid claimProvenance anchored in textbooks', () {
      final file = File('assets/data/history/entries.json');
      final entries = (jsonDecode(file.readAsStringSync()) as List).cast<Map<String, dynamic>>();

      expect(entries.length, equals(85));

      int grade5Provenanced = 0;

      for (final entry in entries) {
        final id = entry['id'] as String;
        final grade = entry['grade'] as String;
        final provenanceList = (entry['claimProvenance'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

        expect(
          provenanceList,
          isNotEmpty,
          reason: 'History entry $id lacks claimProvenance',
        );

        for (final prov in provenanceList) {
          final claim = prov['claim'] as String? ?? '';
          final claimPersian = prov['claimPersian'] as String? ?? '';
          final sourceBookId = prov['sourceBookId'] as String? ?? '';
          final status = prov['status'] as String? ?? '';

          expect(claim.trim(), isNotEmpty, reason: 'Empty claim in $id provenance');
          expect(claimPersian.trim(), isNotEmpty, reason: 'Empty claimPersian in $id provenance');
          expect(sourceBookId.startsWith('history-'), isTrue, reason: 'Invalid sourceBookId $sourceBookId in $id');

          if (grade == '5') {
            grade5Provenanced++;
            final printedPage = (prov['printedPage'] as num?)?.toInt() ?? 0;
            final pdfPage = (prov['pdfPage'] as num?)?.toInt() ?? 0;
            expect(printedPage, greaterThan(0), reason: 'Invalid printedPage in grade 5 entry $id');
            expect(pdfPage, greaterThan(0), reason: 'Invalid pdfPage in grade 5 entry $id');
            expect(status, equals('VERIFIED_UPLOADED_BOOK_PAGE'));
          } else {
            expect(
              status == 'VERIFIED_UPLOADED_BOOK_PAGE' || status == 'VERIFIED_CURRICULUM_MAORIF',
              isTrue,
              reason: 'Invalid provenance status in $id: $status',
            );
          }
        }
      }

      // Grade 5 has 45 entries, all must have verified uploaded book page citations
      expect(grade5Provenanced, equals(45));
    });

    test('Poets dataset contains 150 authentic poets with rich textbook biographies', () {
      final file = File('assets/data/literature/poets.json');
      final poets = (jsonDecode(file.readAsStringSync()) as List).cast<Map<String, dynamic>>();

      expect(poets.length, equals(150));

      int curriculumTextbookCitations = 0;

      for (final poet in poets) {
        final id = poet['id'] as String;
        final bioTj = poet['biographyTj'] as String? ?? '';
        final bioFa = poet['biographyFa'] as String? ?? '';
        final source = poet['biographySource'] as String? ?? '';

        expect(bioTj.trim().length, greaterThan(50), reason: 'Poet $id has too short biographyTj');
        expect(bioFa.trim().length, greaterThan(30), reason: 'Poet $id has too short biographyFa');

        if (source.contains('Адабиёт') && source.contains('с.')) {
          curriculumTextbookCitations++;
        }
      }

      // 58 poets were enriched directly from grade 5-11 textbooks with exact citations
      expect(curriculumTextbookCitations, greaterThanOrEqualTo(50));
    });

    test('Works dataset preserves invariant of 1472 works with bilingual support', () {
      final file = File('assets/data/literature/works.json');
      final works = (jsonDecode(file.readAsStringSync()) as List).cast<Map<String, dynamic>>();

      expect(works.length, equals(1472));

      int editoriallyApproved = 0;
      int primaryChecked = 0;

      for (final work in works) {
        final id = work['id'] as String;
        final title = work['title'] as String? ?? '';
        final titleFa = work['titlePersian'] as String? ?? '';
        final textTj = work['textTajik'] as String? ?? '';
        final textFa = work['textPersian'] as String? ?? '';
        final script = work['scriptSource'] as String? ?? '';

        expect(title.trim(), isNotEmpty, reason: 'Missing title in work $id');
        expect(titleFa.trim(), isNotEmpty, reason: 'Missing titlePersian in work $id');
        expect(textTj.trim(), isNotEmpty, reason: 'Missing textTajik in work $id');
        expect(textFa.trim(), isNotEmpty, reason: 'Missing textPersian in work $id');
        expect(script, equals('both'), reason: 'Work $id must have scriptSource both');

        final verification = work['verification'] as Map<String, dynamic>?;
        final level = verification?['evidenceLevel'] as String? ?? 'extracted';
        if (level == 'editoriallyApproved') editoriallyApproved++;
        if (level == 'primaryChecked') primaryChecked++;
      }

      expect(editoriallyApproved, equals(8));
      expect(primaryChecked, equals(4));
    });
  });
}
