import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
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
      expect(list.length, 1466);

      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final work = LiteraryWork.fromJson(item as Map<String, dynamic>);
        expect(work.id, isNotEmpty);
        expect(work.authorId, isNotEmpty);
        expect(work.title, isNotEmpty);
        expect(work.textTajik, isNotEmpty);
        expect(work.primarySource, isNotNull);
        expect(work.verification.secondSourceChecked, isFalse);
        expect(work.verification.finalStatus, VerificationStatus.needsReview);
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
      }
    });

    test('oral_heritage.json is an empty array', () {
      final file = File('assets/data/literature/oral_heritage.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());
      expect((raw as List).isEmpty, isTrue);
    });
  });
}
