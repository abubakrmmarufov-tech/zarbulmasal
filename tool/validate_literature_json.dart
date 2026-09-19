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
  // NOTE: Count is not asserted as a fixed invariant (use PROVENANCE_PAGE_AUDIT.md for metrics)
  assert(poetsList.isNotEmpty, 'poets.json must not be empty');

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
    // NOTE: rights.status == unknown IS acceptable — do NOT assert against it.
    // An honest "unknown" is better than a fabricated "publicDomain".
    assert(
      author.rights.status != RightsStatus.publicDomain,
      'Poet ${author.id} claims publicDomain without attached supporting evidence.',
    );
    assert(
      {
        'SOURCE_BACKED',
        'EDITORIAL_SUMMARY_FROM_SOURCES',
        'UNSUPPORTED_GENERATED',
      }.contains(author.biographyTjProvenance),
      'Poet ${author.id} has invalid biography provenance.',
    );
    if (author.biographyTjProvenance == 'UNSUPPORTED_GENERATED') {
      assert(
        author.biographyTj.trim().isEmpty,
        'Unsupported biography ${author.id} must be quarantined from active content.',
      );
    }

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
  // NOTE: Count is not asserted as a fixed invariant.
  assert(worksList.isNotEmpty, 'works.json must not be empty');

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

    assert(
      work.textPersian == null,
      'Generated text must not remain in textPersian for ${work.id}',
    );
    assert(
      work.persianScriptSource == 'generated',
      'Work ${work.id} must label its Persian-script representation',
    );
    assert(
      work.persianScriptRepresentation?.trim().isNotEmpty == true,
      'Work ${work.id} has no generated Persian-script representation',
    );
    assert(
      work.scriptSource != ScriptSource.both,
      'Generated Persian representation cannot be labeled as both scripts',
    );

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
      // Evidence verification and rights clearance are separate. An approved
      // source page is not permission to publish its text.
      assert(!work.isDisplayable || work.rights.status != RightsStatus.unknown);
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
  // Counts are reported as metrics only. The validator checks consistency,
  // not a target number of records or an artificial approval quota.
  print('  ✓ Total works: ${worksList.length}');
  print('  ✓ Approved poetic works: $approvedCount');
  print(
    '  ✓ Primary checked works (curriculum provenance): $primaryCheckedCount',
  );
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
  assert(canonList.isNotEmpty, 'school canon must not be empty');

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
  assert(oralList.isNotEmpty, 'oral heritage must not be empty');

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
    assert(
      entry.verification.evidenceLevel !=
              VerificationLevel.editoriallyApproved ||
          entry.isDisplayable,
      'Approved oral entry ${entry.id} must have rights and verification clearance',
    );
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
  // NOTE: Count is not asserted as a fixed invariant.
  assert(historyList.isNotEmpty, 'entries.json must not be empty');

  int totalHistoryAuthors = 0;
  int totalHistoryWorks = 0;
  for (final item in historyList) {
    final map = item as Map<String, dynamic>;
    assert(map['id'] is String && (map['id'] as String).isNotEmpty);
    // Actual JSON uses 'title' and 'titlePersian' (not 'titleTj'/'titleFa')
    assert(
      map['title'] is String && (map['title'] as String).isNotEmpty,
      'History entry ${map['id']} missing title field',
    );
    // 'summary' is required; 'titlePersian' and 'summaryPersian' are optional bilingual fields
    assert(
      map['summary'] is String && (map['summary'] as String).isNotEmpty,
      'History entry ${map['id']} missing summary field',
    );

    final sourceBookId = map['sourceBookId'] as String?;
    if (sourceBookId != null && sourceBookId.isNotEmpty) {
      assert(
        bookIds.contains(sourceBookId),
        'History entry ${map['id']} points to unknown sourceBookId: $sourceBookId',
      );
    }

    final claims = (map['claimProvenance'] as List<dynamic>?) ?? const [];
    for (final rawClaim in claims) {
      final claim = rawClaim as Map<String, dynamic>;
      final status = claim['status'] as String? ?? '';
      const validStatuses = {
        'VERIFIED_UPLOADED_BOOK_PAGE',
        'VERIFIED_MAORIF_PAGE',
        'VERIFIED_DOCUMENT',
        'SOURCE_LOCATED',
        'GENERATED_TRANSFORMATION',
        'EDITORIAL_TRANSLATION',
        'PARTIAL',
        'NEEDS_REVIEW',
        'UNSUPPORTED',
      };
      assert(
        validStatuses.contains(status),
        'History entry ${map['id']} has invalid claim status $status',
      );
      final printedPage = (claim['printedPage'] as num?)?.toInt();
      final pdfPage = (claim['pdfPage'] as num?)?.toInt();
      assert(
        printedPage == null || printedPage > 0,
        'History entry ${map['id']} has invalid printedPage',
      );
      assert(
        pdfPage == null || pdfPage > 0,
        'History entry ${map['id']} has invalid pdfPage',
      );
      if (status == 'VERIFIED_UPLOADED_BOOK_PAGE' ||
          status == 'VERIFIED_MAORIF_PAGE') {
        assert(
          printedPage != null || pdfPage != null,
          'Page-verified history entry ${map['id']} has no page',
        );
      }
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

  print('\n✅ Cultural heritage consistency validation completed.');
  print(
    '   This validator does not imply that every record is source-verified.',
  );
}
