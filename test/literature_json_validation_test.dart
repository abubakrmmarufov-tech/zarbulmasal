import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';

void main() {
  group('Literature JSON Data Files Validation', () {
    test('poets.json is valid and conforms to LiteraryAuthor model', () {
      final file = File('assets/data/literature/poets.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());

      final list = raw as List<dynamic>;
      expect(list.length, 10);

      final expectedPoetIds = [
        'rudaki',
        'nasir_khusraw',
        'kamol_khujandi',
        'tursunzoda',
        'qanoat',
        'loiq_sherali',
        'bozor_sobir',
        'gulnazar_keldi',
        'gulrukhsor',
        'farzona',
      ];

      final authors = <LiteraryAuthor>[];
      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final author = LiteraryAuthor.fromJson(item as Map<String, dynamic>);
        authors.add(author);
      }

      expect(authors.map((a) => a.id).toList(), expectedPoetIds);

      // Check Rudaki
      final rudaki = authors.firstWhere((a) => a.id == 'rudaki');
      expect(rudaki.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');
      expect(rudaki.birthYear, '~858');
      expect(rudaki.deathYear, '~941');
      expect(rudaki.birthPlace, 'Панҷруд, Панҷакент');
      expect(rudaki.officialTitles, ['Одамушшуаро', 'Султони шоирон']);
      expect(rudaki.educationGrades, ['4', '5', '8', '10']);
      expect(rudaki.rights.status, RightsStatus.publicDomain);
      expect(rudaki.rights.fullTextAllowed, isTrue);
      expect(rudaki.rights.excerptAllowed, isTrue);

      // Check Tursunzoda (excerptOnly)
      final tursunzoda = authors.firstWhere((a) => a.id == 'tursunzoda');
      expect(tursunzoda.canonicalName, 'Мирзо Турсунзода');
      expect(tursunzoda.rights.status, RightsStatus.excerptOnly);
      expect(tursunzoda.rights.fullTextAllowed, isFalse);
      expect(tursunzoda.rights.excerptAllowed, isTrue);
      expect(tursunzoda.rights.authorDeathYear, '1977');

      // Check Gulrukhsor aliases
      final gulrukhsor = authors.firstWhere((a) => a.id == 'gulrukhsor');
      expect(gulrukhsor.aliases, ['Гулрухсор Сафиева']);
      expect(gulrukhsor.deathYear, isNull);
      expect(gulrukhsor.rights.status, RightsStatus.excerptOnly);

      // Check Farzona aliases
      final farzona = authors.firstWhere((a) => a.id == 'farzona');
      expect(farzona.aliases, ['Иноят Юнусовна Хоҷаева']);
      expect(farzona.deathYear, isNull);
      expect(farzona.rights.status, RightsStatus.excerptOnly);

      // Verify all majorWorkIds are empty
      for (final a in authors) {
        expect(a.majorWorkIds, isEmpty);
      }
    });

    test('works.json is an empty array', () {
      final file = File('assets/data/literature/works.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());
      expect((raw as List).isEmpty, isTrue);
    });

    test('sources.json is valid and conforms to SourceEdition model', () {
      final file = File('assets/data/literature/sources.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final dynamic raw = jsonDecode(content);
      expect(raw, isA<List<dynamic>>());

      final list = raw as List<dynamic>;
      expect(list.length, greaterThanOrEqualTo(15));
      expect(list.length, lessThanOrEqualTo(30));

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
