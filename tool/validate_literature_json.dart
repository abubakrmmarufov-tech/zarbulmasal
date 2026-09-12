// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';

void main() {
  print('--- Validating Literature JSON Files ---');

  // 1. Validate poets.json
  print('1. Validating poets.json...');
  final poetsFile = File('assets/data/literature/poets.json');
  assert(poetsFile.existsSync(), 'poets.json does not exist');
  final poetsList = jsonDecode(poetsFile.readAsStringSync()) as List<dynamic>;
  assert(
    poetsList.length == 10,
    'poets.json should contain 10 poets, found ${poetsList.length}',
  );

  final expectedIds = [
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

  for (var i = 0; i < poetsList.length; i++) {
    final map = poetsList[i] as Map<String, dynamic>;
    final author = LiteraryAuthor.fromJson(map);
    assert(
      author.id == expectedIds[i],
      'Poet $i id mismatch: ${author.id} vs ${expectedIds[i]}',
    );
    assert(
      author.canonicalName.isNotEmpty,
      'Poet ${author.id} has empty canonicalName',
    );
    assert(
      author.biographyTj.isNotEmpty,
      'Poet ${author.id} has empty biographyTj',
    );
    assert(
      author.biographySource.isNotEmpty,
      'Poet ${author.id} has empty biographySource',
    );
    assert(
      author.majorWorkIds.isEmpty,
      'Poet ${author.id} majorWorkIds should be empty',
    );
    assert(
      author.educationGrades.isNotEmpty,
      'Poet ${author.id} educationGrades should not be empty',
    );

    // Check rights
    assert(
      author.rights.reasoning.isNotEmpty,
      'Poet ${author.id} rights reasoning should not be empty',
    );
    assert(
      author.rights.rightsSource != null,
      'Poet ${author.id} rightsSource is missing',
    );

    if (author.id == 'rudaki' ||
        author.id == 'nasir_khusraw' ||
        author.id == 'kamol_khujandi') {
      assert(
        author.rights.status == RightsStatus.publicDomain,
        '${author.id} should be publicDomain',
      );
      assert(
        author.rights.fullTextAllowed == true,
        '${author.id} fullTextAllowed should be true',
      );
    } else {
      assert(
        author.rights.status == RightsStatus.excerptOnly,
        '${author.id} should be excerptOnly',
      );
      assert(
        author.rights.fullTextAllowed == false,
        '${author.id} fullTextAllowed should be false',
      );
      assert(
        author.rights.excerptAllowed == true,
        '${author.id} excerptAllowed should be true',
      );
    }

    if (author.id == 'gulrukhsor') {
      assert(
        author.aliases.contains('Гулрухсор Сафиева'),
        'Gulrukhsor should have alias',
      );
      assert(author.deathYear == null, 'Gulrukhsor is living');
    } else if (author.id == 'farzona') {
      assert(
        author.aliases.contains('Иноят Юнусовна Хоҷаева'),
        'Farzona should have alias',
      );
      assert(author.deathYear == null, 'Farzona is living');
    } else {
      assert(
        author.aliases.isEmpty,
        'Poet ${author.id} aliases should be empty',
      );
    }
    print(
      '  ✓ Poet ${author.id}: ${author.canonicalName} (${author.lifespan}) [${author.rights.status.name}]',
    );
  }

  // 2. Validate works.json
  print('2. Validating works.json...');
  final worksFile = File('assets/data/literature/works.json');
  assert(worksFile.existsSync(), 'works.json does not exist');
  final worksList = jsonDecode(worksFile.readAsStringSync()) as List<dynamic>;
  assert(
    worksList.isEmpty,
    'works.json must be an empty array pending verification',
  );
  print('  ✓ works.json is empty array ([]) as required');

  // 3. Validate sources.json
  print('3. Validating sources.json...');
  final sourcesFile = File('assets/data/literature/sources.json');
  assert(sourcesFile.existsSync(), 'sources.json does not exist');
  final sourcesList =
      jsonDecode(sourcesFile.readAsStringSync()) as List<dynamic>;
  assert(
    sourcesList.length >= 15 && sourcesList.length <= 30,
    'sources.json should contain ~15-20 editions, found ${sourcesList.length}',
  );

  for (final item in sourcesList) {
    final map = item as Map<String, dynamic>;
    assert(
      map['id'] != null && (map['id'] as String).isNotEmpty,
      'source id is missing',
    );
    final edition = SourceEdition.fromJson(map);
    assert(
      edition.bookTitle.isNotEmpty,
      'source ${map['id']} has empty bookTitle',
    );
    assert(
      edition.publisher.isNotEmpty,
      'source ${map['id']} has empty publisher',
    );
    assert(edition.city.isNotEmpty, 'source ${map['id']} has empty city');
    assert(edition.year.isNotEmpty, 'source ${map['id']} has empty year');
    assert(
      edition.sourceType.isNotEmpty,
      'source ${map['id']} has empty sourceType',
    );
  }
  print(
    '  ✓ sources.json contains ${sourcesList.length} valid SourceEdition entries',
  );

  // 4. Validate school_canon.json
  print('4. Validating school_canon.json...');
  final canonFile = File('assets/data/literature/school_canon.json');
  assert(canonFile.existsSync(), 'school_canon.json does not exist');
  final canonList = jsonDecode(canonFile.readAsStringSync()) as List<dynamic>;
  assert(
    canonList.length >= 20,
    'school_canon.json should have at least 20 entries, found ${canonList.length}',
  );

  for (final item in canonList) {
    final map = item as Map<String, dynamic>;
    final entry = SchoolCanonEntry.fromJson(map);
    assert(entry.id.isNotEmpty, 'canon entry id is empty');
    assert(entry.authorId.isNotEmpty, 'canon entry authorId is empty');
    assert(entry.workId == '', 'canon entry workId should be empty string');
    assert(entry.grade.isNotEmpty, 'canon entry grade is empty');
    assert(
      entry.subject == 'Адабиёти тоҷик' || entry.subject == 'Хониши адабӣ',
      'unexpected subject ${entry.subject}',
    );
    assert(entry.textbookTitle.isNotEmpty, 'textbookTitle is empty');
    assert(entry.textbookPublisher.isNotEmpty, 'textbookPublisher is empty');
    assert(
      entry.curriculumType == 'mandatory' ||
          entry.curriculumType == 'recommended',
      'curriculumType is invalid',
    );
    assert(entry.sourceEvidence.isNotEmpty, 'sourceEvidence is empty');
  }
  print(
    '  ✓ school_canon.json contains ${canonList.length} valid SchoolCanonEntry entries',
  );

  // 5. Validate oral_heritage.json
  print('5. Validating oral_heritage.json...');
  final oralFile = File('assets/data/literature/oral_heritage.json');
  assert(oralFile.existsSync(), 'oral_heritage.json does not exist');
  final oralList = jsonDecode(oralFile.readAsStringSync()) as List<dynamic>;
  assert(
    oralList.isEmpty,
    'oral_heritage.json must be an empty array pending provenance',
  );
  print('  ✓ oral_heritage.json is empty array ([]) as required');

  print('\nALL 5 LITERATURE JSON FILES VALIDATED SUCCESSFULLY!');
}
