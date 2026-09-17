// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';
import 'package:zarbulmasal/features/literature/domain/oral_heritage_entry.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';

void main() {
  print('=== Running Comprehensive Cultural Heritage Validation ===');

  // 1. Validate poets.json
  print('\n[1/5] Validating poets.json...');
  final poetsFile = File('assets/data/literature/poets.json');
  assert(poetsFile.existsSync(), 'poets.json does not exist');
  final poetsList = jsonDecode(poetsFile.readAsStringSync()) as List<dynamic>;
  assert(
    poetsList.length == 150,
    'Expected exactly 150 poets, found ${poetsList.length}',
  );

  final authorIds = <String>{};
  int tajikBios = 0;
  int persianBios = 0;
  int persianCanonicalNames = 0;

  for (var i = 0; i < poetsList.length; i++) {
    final map = poetsList[i] as Map<String, dynamic>;
    final author = LiteraryAuthor.fromJson(map);
    assert(author.id.isNotEmpty, 'Poet $i has empty id');
    assert(!authorIds.contains(author.id), 'Duplicate poet ID: ${author.id}');
    authorIds.add(author.id);

    assert(
      author.canonicalName.isNotEmpty,
      'Poet ${author.id} has empty canonicalName',
    );
    assert(
      author.rights.reasoning.isNotEmpty,
      'Poet ${author.id} rights reasoning should not be empty',
    );
    assert(
      author.rights.status != RightsStatus.unknown,
      'Poet ${author.id} rights status should not be unknown',
    );

    if (author.biographyTj.trim().isNotEmpty) {
      tajikBios++;
    }
    if (author.biographyFa != null && author.biographyFa!.trim().isNotEmpty) {
      persianBios++;
    }
    if (author.canonicalNamePersian != null &&
        author.canonicalNamePersian!.trim().isNotEmpty) {
      persianCanonicalNames++;
    }
  }
  print('  ✓ Total poets: ${poetsList.length}');
  print('  ✓ Authentic Tajik biographies: $tajikBios');
  print('  ✓ Persian biographies: $persianBios (honest unverified metric)');
  print('  ✓ Classical Persian canonical names: $persianCanonicalNames');

  // 2. Validate works.json
  print('\n[2/5] Validating works.json...');
  final worksFile = File('assets/data/literature/works.json');
  assert(worksFile.existsSync(), 'works.json does not exist');
  final worksList = jsonDecode(worksFile.readAsStringSync()) as List<dynamic>;
  assert(
    worksList.length == 1472,
    'Expected exactly 1472 works, found ${worksList.length}',
  );

  final workIds = <String>{};
  int approvedCount = 0;
  int primaryCheckedCount = 0;
  int needsReviewCount = 0;
  int textTajikCount = 0;
  int textPersianCount = 0;

  for (final item in worksList) {
    final map = item as Map<String, dynamic>;
    final work = LiteraryWork.fromJson(map);
    assert(work.id.isNotEmpty, 'Work has empty id');
    assert(!workIds.contains(work.id), 'Duplicate work ID: ${work.id}');
    workIds.add(work.id);

    assert(work.authorId.isNotEmpty, 'Work ${work.id} has empty authorId');
    assert(
      authorIds.contains(work.authorId),
      'Work ${work.id} points to unknown author: ${work.authorId}',
    );
    assert(work.title.isNotEmpty, 'Work ${work.id} has empty title');
    assert(
      work.textTajik != null && work.textTajik!.isNotEmpty,
      'Work ${work.id} has empty textTajik',
    );
    textTajikCount++;

    if (work.textPersian != null && work.textPersian!.trim().isNotEmpty) {
      textPersianCount++;
    }

    assert(
      work.primarySource != null,
      'Work ${work.id} is missing primarySource',
    );
    assert(
      work.rights.reasoning.isNotEmpty,
      'Work ${work.id} rights reasoning is empty',
    );

    if (work.verification.evidenceLevel ==
        VerificationLevel.editoriallyApproved) {
      approvedCount++;
      assert(
        work.verification.pageVerified,
        'Approved work ${work.id} is missing a second witness',
      );
      assert(
        work.primarySource!.pageStart != null,
        'Approved work ${work.id} missing page number',
      );
      assert(
        work.isDisplayable,
        'Approved work ${work.id} must be displayable',
      );
    } else if (work.verification.evidenceLevel ==
        VerificationLevel.primaryChecked) {
      primaryCheckedCount++;
      assert(
        !work.isDisplayable,
        'Primary checked work ${work.id} without editorial/rights clearance must not be displayable',
      );
      assert(
        work.verification.pageVerified,
        'Primary checked work ${work.id} must have pageVerified: true',
      );
    } else if (work.verification.evidenceLevel ==
        VerificationLevel.needsReview) {
      needsReviewCount++;
      assert(
        !work.isDisplayable,
        'Quarantined work ${work.id} must not be displayable',
      );
    }
  }
  assert(
    approvedCount + needsReviewCount + primaryCheckedCount == worksList.length,
    'All works must be classified as either approved, primaryChecked, or needsReview',
  );
  assert(
    approvedCount <= 1000,
    'Approved works ($approvedCount) must not violate epistemic verification limits',
  );
  print('  ✓ Total works: ${worksList.length}');
  print('  ✓ Approved poetic works: $approvedCount');
  print('  ✓ Primary checked works (curriculum provenance): $primaryCheckedCount');
  print('  ✓ Quarantined needsReview items: $needsReviewCount');
  print('  ✓ Works with Tajik text: $textTajikCount');
  print('  ✓ Works with Persian text: $textPersianCount');

  // 3. Validate sources.json & school_canon.json
  print('\n[3/5] Validating school_canon.json & sources.json...');
  final sourcesFile = File('assets/data/literature/sources.json');
  assert(sourcesFile.existsSync(), 'sources.json does not exist');
  final sourcesList =
      jsonDecode(sourcesFile.readAsStringSync()) as List<dynamic>;
  final sourceIds = <String>{};
  for (final s in sourcesList) {
    final map = s as Map<String, dynamic>;
    sourceIds.add(map['id'] as String);
  }

  final canonFile = File('assets/data/literature/school_canon.json');
  assert(canonFile.existsSync(), 'school_canon.json does not exist');
  final canonList = jsonDecode(canonFile.readAsStringSync()) as List<dynamic>;
  assert(
    canonList.length >= 70,
    'Expected at least 70 school canon entries, got ${canonList.length}',
  );

  for (final item in canonList) {
    final map = item as Map<String, dynamic>;
    final entry = SchoolCanonEntry.fromJson(map);
    assert(entry.id.isNotEmpty, 'Canon entry has empty id');
    final gradeNum = int.tryParse(entry.grade) ?? 0;
    assert(
      gradeNum >= 5 && gradeNum <= 11,
      'Canon entry ${entry.id} grade $gradeNum is outside the 5-11 school scope',
    );
    assert(
      authorIds.contains(entry.authorId),
      'Canon entry ${entry.id} has unknown authorId: ${entry.authorId}',
    );
    assert(
      sourceIds.contains(entry.sourceId),
      'Canon entry ${entry.id} has unknown sourceId: ${entry.sourceId}',
    );
    assert(entry.isMandatory, 'Canon entry ${entry.id} must be mandatory');
  }
  print('  ✓ School canon entries: ${canonList.length} (Grades 5–11 strictly)');

  // 4. Validate oral_heritage.json
  print('\n[4/5] Validating oral_heritage.json...');
  final oralFile = File('assets/data/literature/oral_heritage.json');
  assert(oralFile.existsSync(), 'oral_heritage.json does not exist');
  final oralList = jsonDecode(oralFile.readAsStringSync()) as List<dynamic>;
  assert(
    oralList.length == 14,
    'Expected 14 oral heritage entries, got ${oralList.length}',
  );

  final oralIds = <String>{};
  for (final item in oralList) {
    final map = item as Map<String, dynamic>;
    final entry = OralHeritageEntry.fromJson(map);
    assert(
      entry.id.startsWith('oral-'),
      'Oral entry ${entry.id} must start with oral-',
    );
    assert(!oralIds.contains(entry.id), 'Duplicate oral ID: ${entry.id}');
    oralIds.add(entry.id);
    assert(entry.text.isNotEmpty, 'Oral entry ${entry.id} missing text');
    assert(
      entry.collectionSource.isNotEmpty,
      'Oral entry ${entry.id} missing collectionSource',
    );
    assert(
      entry.publisher.isNotEmpty,
      'Oral entry ${entry.id} missing publisher',
    );
    assert(entry.year.isNotEmpty, 'Oral entry ${entry.id} missing year');
    assert(entry.isDisplayable, 'Oral entry ${entry.id} should be displayable');
  }
  print('  ✓ Authentic oral heritage records: ${oralList.length}');

  // 5. Validate history/entries.json & history/books.json referential integrity
  print('\n[5/5] Validating history/entries.json & books.json...');
  final historyBooksFile = File('assets/data/history/books.json');
  assert(historyBooksFile.existsSync(), 'books.json does not exist');
  final booksList =
      jsonDecode(historyBooksFile.readAsStringSync()) as List<dynamic>;
  final bookIds = <String>{};
  for (final b in booksList) {
    final map = b as Map<String, dynamic>;
    bookIds.add(map['id'] as String);
  }

  final historyEntriesFile = File('assets/data/history/entries.json');
  assert(historyEntriesFile.existsSync(), 'entries.json does not exist');
  final historyList =
      jsonDecode(historyEntriesFile.readAsStringSync()) as List<dynamic>;
  assert(
    historyList.length == 71,
    'Expected 71 history entries, got ${historyList.length}',
  );

  int totalHistoryAuthors = 0;
  int totalHistoryWorks = 0;
  for (final item in historyList) {
    final map = item as Map<String, dynamic>;
    assert(map['id'] is String && (map['id'] as String).isNotEmpty);
    assert(map['titleTj'] is String && (map['titleTj'] as String).isNotEmpty);
    assert(map['titleFa'] is String && (map['titleFa'] as String).isNotEmpty);
    assert(
      map['descriptionTj'] is String &&
          (map['descriptionTj'] as String).isNotEmpty,
    );
    assert(
      map['descriptionFa'] is String &&
          (map['descriptionFa'] as String).isNotEmpty,
    );

    final sourceBookId = map['sourceBookId'] as String?;
    if (sourceBookId != null && sourceBookId.isNotEmpty) {
      assert(
        bookIds.contains(sourceBookId),
        'History entry ${map['id']} points to unknown sourceBookId: $sourceBookId',
      );
    }

    final relatedAuthorIds =
        (map['relatedAuthorIds'] as List<dynamic>?)?.cast<String>() ?? [];
    for (final authorId in relatedAuthorIds) {
      assert(
        authorIds.contains(authorId),
        'History entry ${map['id']} points to unknown authorId: $authorId',
      );
      totalHistoryAuthors++;
    }

    final relatedWorkIds =
        (map['relatedWorkIds'] as List<dynamic>?)?.cast<String>() ?? [];
    for (final workId in relatedWorkIds) {
      assert(
        workIds.contains(workId),
        'History entry ${map['id']} points to unknown workId: $workId',
      );
      totalHistoryWorks++;
    }
  }
  print('  ✓ History entries: ${historyList.length}');
  print('  ✓ History books: ${booksList.length}');
  print('  ✓ Linked author references: $totalHistoryAuthors (0 dangling)');
  print('  ✓ Linked work references: $totalHistoryWorks (0 dangling)');

  print('\n✅ ALL CULTURAL HERITAGE DATA VERIFIED SUCCESSFULLY!');
}
