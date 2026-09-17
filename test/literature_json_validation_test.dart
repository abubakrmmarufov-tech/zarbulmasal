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

void main() {
  group('Literature JSON Data Files Validation', () {
    test('poets.json is valid and conforms to LiteraryAuthor model', () {
      final file = File('assets/data/literature/poets.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());

      final list = raw as List<dynamic>;
      expect(list.length, 171);

      final authors = <LiteraryAuthor>[];
      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final author = LiteraryAuthor.fromJson(item as Map<String, dynamic>);
        authors.add(author);
      }

      for (final a in authors) {
        expect(a.id, isNotEmpty);
        expect(a.canonicalName, isNotEmpty);
        expect(a.rights.status, isNot(RightsStatus.unknown));
      }
    });

    test('works.json is valid and conforms to LiteraryWork model', () {
      final file = File('assets/data/literature/works.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());
      final list = raw as List<dynamic>;
      expect(list.length, 1472);

      int approvedCount = 0;
      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final work = LiteraryWork.fromJson(item as Map<String, dynamic>);
        expect(work.id, isNotEmpty);
        expect(work.authorId, isNotEmpty);
        expect(work.title, isNotEmpty);
        expect(work.textTajik, isNotEmpty);
        expect(work.primarySource, isNotNull);
        expect(work.hasAuditableCompositionEvidence, isFalse);
        if (work.verification.evidenceLevel == VerificationLevel.editoriallyApproved) {
          approvedCount++;
          expect(work.verification.pageVerified, isTrue);
          expect(work.verification.pageVerified, isTrue);
          expect(work.primarySource!.pageStart, isNotNull);
          expect(work.isDisplayable, isTrue);
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

    test('Jami duplicate author records agree with the page-109 witness', () {
      final poets =
          jsonDecode(
                File('assets/data/literature/poets.json').readAsStringSync(),
              )
              as List<dynamic>;
      final byId = {
        for (final item in poets.whereType<Map>())
          item['id'] as String: Map<String, dynamic>.from(item),
      };

      for (final id in [
        '358dda13-365c-4434-87f0-d404b305adcb',
        '9debff75-8664-43ab-a7a9-ed1a4725f69b',
      ]) {
        final jami = byId[id];
        expect(jami, isNotNull, reason: 'Missing Jami record $id');
        expect(jami!['birthDateExact'], '7 ноябри 1414');
        expect(jami['deathDateExact'], '9 ноябри 1492');
        expect(jami['birthPlace'], 'Харҷурди вилояти Ҷом');
        expect(jami['biographySource'], contains('с. 109'));
        expect(jami['biographyTj'], contains('«Баҳористон»'));
      }
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
            entry.key == 'tj_literature_grade_5_2017' ||
                entry.key == 'tj_literature_grade_7_2018',
          );
        }
      },
    );

    test('school_canon.json is valid with proper mappings', () {
      final file = File('assets/data/literature/school_canon.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());

      final list = raw as List<dynamic>;
      expect(list.length, greaterThanOrEqualTo(20));

      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final map = item as Map<String, dynamic>;
        expect(map['id'], isNotEmpty);
        expect(map['authorId'], isNotEmpty);
        expect(map['workId'], equals(''));
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

    test(
      'local Grades 5–11 canon mappings name their held textbook edition',
      () {
        final sources =
            jsonDecode(
                  File(
                    'assets/data/literature/sources.json',
                  ).readAsStringSync(),
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
          expect(
            sourceId,
            isA<String>(),
            reason: 'Grade $grade lacks sourceId',
          );
          final source = sourcesById[sourceId];
          expect(source, isNotNull, reason: 'Unknown textbook $sourceId');
          expect(source!['sourceType'], SourceEditionType.officialTextbook);
          expect(entry['textbookPublisher'], source['publisher']);
          expect(entry['textbookYear'], source['year']);
          expect(entry['textbookAuthors'], source['authorAsPrinted']);
          expect(entry['citationStatus'], 'needsReview');
        }
      },
    );

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
        
      }
    });
  });
}
