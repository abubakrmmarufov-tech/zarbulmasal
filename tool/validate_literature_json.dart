// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';
import 'package:zarbulmasal/features/literature/domain/oral_heritage_entry.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';

void requireCondition(bool condition, [String? message]) {
  if (!condition) {
    throw FormatException(message ?? 'Literature JSON validation failed');
  }
}

void main() {
  print('=== Running Comprehensive Cultural Heritage Validation ===');

  // 1. Validate poets.json
  print('\n[1/5] Validating poets.json...');
  final poetsFile = File('assets/data/literature/poets.json');
  requireCondition(poetsFile.existsSync(), 'poets.json does not exist');
  final poetsList = jsonDecode(poetsFile.readAsStringSync()) as List<dynamic>;
  // NOTE: Count is not asserted as a fixed invariant (use PROVENANCE_PAGE_AUDIT.md for metrics)
  requireCondition(poetsList.isNotEmpty, 'poets.json must not be empty');

  final authorIds = <String>{};
  final rejectedAuthorIds = <String>{};
  final reviewAuthorIds = <String>{};
  int tajikBios = 0;
  int persianBios = 0;
  int persianCanonicalNames = 0;
  int portraits = 0;

  for (var i = 0; i < poetsList.length; i++) {
    final map = poetsList[i] as Map<String, dynamic>;
    final author = LiteraryAuthor.fromJson(map);
    requireCondition(author.id.isNotEmpty, 'Poet $i has empty id');
    requireCondition(
      !authorIds.contains(author.id),
      'Duplicate poet ID: ${author.id}',
    );
    authorIds.add(author.id);

    requireCondition(
      {'active', 'review', 'rejected'}.contains(author.recordStatus),
      'Poet ${author.id} has invalid recordStatus: ${author.recordStatus}',
    );
    if (author.recordStatus == 'rejected') {
      rejectedAuthorIds.add(author.id);
    } else if (author.recordStatus == 'review') {
      reviewAuthorIds.add(author.id);
    }

    requireCondition(
      author.canonicalName.isNotEmpty,
      'Poet ${author.id} has empty canonicalName',
    );
    requireCondition(
      author.rights.reasoning.isNotEmpty,
      'Poet ${author.id} rights reasoning should not be empty',
    );
    // NOTE: rights.status == unknown IS acceptable — do NOT assert against it.
    // An honest "unknown" is better than a fabricated "publicDomain".
    requireCondition(
      author.rights.status != RightsStatus.publicDomain,
      'Poet ${author.id} claims publicDomain without attached supporting evidence.',
    );
    requireCondition(
      {
        'SOURCE_BACKED',
        'EDITORIAL_SUMMARY_FROM_SOURCES',
        'UNSUPPORTED_GENERATED',
      }.contains(author.biographyTjProvenance),
      'Poet ${author.id} has invalid biography provenance.',
    );
    if (author.biographyTjProvenance == 'UNSUPPORTED_GENERATED') {
      requireCondition(
        author.biographyTj.trim().isEmpty,
        'Unsupported biography ${author.id} must be quarantined from active content.',
      );
    }
    if (author.biographyTjProvenance == 'UNSUPPORTED_GENERATED' ||
        author.biographyFaProvenance == 'UNSUPPORTED_GENERATED') {
      requireCondition(
        author.biographyQuarantineNote?.trim().isNotEmpty == true,
        'Unsupported biography ${author.id} must explain its quarantine.',
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
    final portrait = author.portrait;
    if (portrait != null) {
      requireCondition(
        portrait.isSourceBacked,
        'Poet ${author.id} has an invalid portrait provenance record.',
      );
      requireCondition(
        File(portrait.assetPath).existsSync(),
        'Poet ${author.id} portrait asset is missing: ${portrait.assetPath}',
      );
      portraits++;
    }
  }
  print('  ✓ Total poets: ${poetsList.length}');
  print('  ✓ Authentic Tajik biographies: $tajikBios');
  print('  ✓ Persian biographies: $persianBios (honest unverified metric)');
  print('  ✓ Classical Persian canonical names: $persianCanonicalNames');
  print('  ✓ Source-backed portraits: $portraits');
  print(
    '  ✓ Public authors: ${poetsList.length - rejectedAuthorIds.length - reviewAuthorIds.length}',
  );
  print('  ✓ Rejected author artifacts: ${rejectedAuthorIds.length}');
  print('  ✓ Authors pending review: ${reviewAuthorIds.length}');

  // 2. Validate works.json
  print('\n[2/5] Validating works.json...');
  final worksFile = File('assets/data/literature/works.json');
  requireCondition(worksFile.existsSync(), 'works.json does not exist');
  final worksList = jsonDecode(worksFile.readAsStringSync()) as List<dynamic>;
  // NOTE: Count is not asserted as a fixed invariant.
  requireCondition(worksList.isNotEmpty, 'works.json must not be empty');

  final workIds = <String>{};
  int approvedCount = 0;
  int primaryCheckedCount = 0;
  int needsReviewCount = 0;
  int textTajikCount = 0;
  int textPersianCount = 0;
  int sourceAttestedCount = 0;

  for (final item in worksList) {
    final map = item as Map<String, dynamic>;
    final work = LiteraryWork.fromJson(map);
    requireCondition(work.id.isNotEmpty, 'Work has empty id');
    requireCondition(
      !workIds.contains(work.id),
      'Duplicate work ID: ${work.id}',
    );
    workIds.add(work.id);

    requireCondition(
      work.authorId.isNotEmpty,
      'Work ${work.id} has empty authorId',
    );
    requireCondition(
      authorIds.contains(work.authorId),
      'Work ${work.id} points to unknown author: ${work.authorId}',
    );
    requireCondition(
      !rejectedAuthorIds.contains(work.authorId) &&
          !reviewAuthorIds.contains(work.authorId),
      'Work ${work.id} points to quarantined author: ${work.authorId}',
    );
    requireCondition(work.title.isNotEmpty, 'Work ${work.id} has empty title');
    final hasTajikText = work.textTajik?.trim().isNotEmpty == true;
    final hasPersianText = work.textPersian?.trim().isNotEmpty == true;
    final hasGeneratedRepresentation =
        work.persianScriptRepresentation?.trim().isNotEmpty == true;
    final hasIncipit = work.incipit?.trim().isNotEmpty == true;
    if (hasTajikText) textTajikCount++;
    if (hasPersianText) textPersianCount++;
    if (work.rights.status == RightsStatus.sourceAttested) {
      sourceAttestedCount++;
    }

    requireCondition(
      work.textPersian == null || work.persianScriptSource != 'generated',
      'Generated text must not remain in textPersian for ${work.id}',
    );
    if (!work.rights.fullTextAllowed) {
      requireCondition(
        !hasTajikText && !hasPersianText && !hasGeneratedRepresentation,
        'Work without full-text rights ships text content: ${work.id}',
      );
    }
    if (!work.rights.excerptAllowed) {
      requireCondition(
        !hasIncipit,
        'Work without excerpt rights ships an incipit: ${work.id}',
      );
    }
    if (work.textStatus == TextStatus.verified) {
      requireCondition(
        work.rights.fullTextAllowed && hasTajikText,
        'Verified work must have full-text rights and Tajik text: ${work.id}',
      );
    }
    requireCondition(
      work.scriptSource != ScriptSource.both,
      'Generated Persian representation cannot be labeled as both scripts',
    );

    requireCondition(
      work.primarySource != null,
      'Work ${work.id} is missing primarySource',
    );
    requireCondition(
      work.rights.reasoning.isNotEmpty,
      'Work ${work.id} rights reasoning is empty',
    );

    if (work.verification.evidenceLevel ==
        VerificationLevel.editoriallyApproved) {
      approvedCount++;
      requireCondition(
        work.verification.pageVerified,
        'Approved work ${work.id} is missing a second witness',
      );
      requireCondition(
        work.primarySource!.pageStart != null,
        'Approved work ${work.id} missing page number',
      );
      // Evidence verification and rights clearance are separate. An approved
      // source page is not permission to publish its text.
      requireCondition(
        !work.isDisplayable || work.rights.status != RightsStatus.unknown,
      );
    } else if (work.verification.evidenceLevel ==
        VerificationLevel.primaryChecked) {
      primaryCheckedCount++;
      requireCondition(
        !work.isDisplayable || work.isPermittedSourceAttested,
        'Primary checked work ${work.id} must use the permitted-source publication path',
      );
      requireCondition(
        work.verification.pageVerified,
        'Primary checked work ${work.id} must have pageVerified: true',
      );
    } else if (work.verification.evidenceLevel ==
        VerificationLevel.needsReview) {
      needsReviewCount++;
      requireCondition(
        !work.isDisplayable,
        'Quarantined work ${work.id} must not be displayable',
      );
    }
  }
  // Counts are reported as metrics only. The validator checks consistency,
  // not a target number of records or an artificial approval quota.
  print('  ✓ Total works: ${worksList.length}');
  print('  ✓ Editorially approved poetic works: $approvedCount');
  print('  ✓ Source-attested readable works: $sourceAttestedCount');
  print(
    '  ✓ Primary checked works (curriculum provenance): $primaryCheckedCount',
  );
  print('  ✓ Quarantined needsReview items: $needsReviewCount');
  print('  ✓ Works with Tajik text: $textTajikCount');
  print('  ✓ Works with Persian text: $textPersianCount');

  // 3. Validate sources.json & school_canon.json
  print('\n[3/5] Validating school_canon.json & sources.json...');
  final sourcesFile = File('assets/data/literature/sources.json');
  requireCondition(sourcesFile.existsSync(), 'sources.json does not exist');
  final sourcesList =
      jsonDecode(sourcesFile.readAsStringSync()) as List<dynamic>;
  final sourceIds = <String>{};
  for (final s in sourcesList) {
    final map = s as Map<String, dynamic>;
    sourceIds.add(map['id'] as String);
  }

  final canonFile = File('assets/data/literature/school_canon.json');
  requireCondition(canonFile.existsSync(), 'school_canon.json does not exist');
  final canonList = jsonDecode(canonFile.readAsStringSync()) as List<dynamic>;
  requireCondition(canonList.isNotEmpty, 'school canon must not be empty');

  for (final item in canonList) {
    final map = item as Map<String, dynamic>;
    final entry = SchoolCanonEntry.fromJson(map);
    requireCondition(entry.id.isNotEmpty, 'Canon entry has empty id');
    final gradeNum = int.tryParse(entry.grade) ?? 0;
    requireCondition(
      gradeNum >= 5 && gradeNum <= 11,
      'Canon entry ${entry.id} grade $gradeNum is outside the 5-11 school scope',
    );
    requireCondition(
      authorIds.contains(entry.authorId),
      'Canon entry ${entry.id} has unknown authorId: ${entry.authorId}',
    );
    requireCondition(
      sourceIds.contains(entry.sourceId),
      'Canon entry ${entry.id} has unknown sourceId: ${entry.sourceId}',
    );
    requireCondition(
      entry.isMandatory,
      'Canon entry ${entry.id} must be mandatory',
    );
  }
  print('  ✓ School canon entries: ${canonList.length} (Grades 5–11 strictly)');

  // 4. Validate oral_heritage.json
  print('\n[4/5] Validating oral_heritage.json...');
  final oralFile = File('assets/data/literature/oral_heritage.json');
  requireCondition(oralFile.existsSync(), 'oral_heritage.json does not exist');
  final oralList = jsonDecode(oralFile.readAsStringSync()) as List<dynamic>;
  requireCondition(oralList.isNotEmpty, 'oral heritage must not be empty');

  final oralIds = <String>{};
  for (final item in oralList) {
    final map = item as Map<String, dynamic>;
    final entry = OralHeritageEntry.fromJson(map);
    requireCondition(
      entry.id.startsWith('oral-'),
      'Oral entry ${entry.id} must start with oral-',
    );
    requireCondition(
      !oralIds.contains(entry.id),
      'Duplicate oral ID: ${entry.id}',
    );
    oralIds.add(entry.id);
    final hasText = entry.text.trim().isNotEmpty;
    final hasPersianText = entry.textPersian?.trim().isNotEmpty ?? false;
    if (!entry.rights.fullTextAllowed) {
      requireCondition(
        !hasText && !hasPersianText,
        'Oral entry ${entry.id} without full-text rights ships text',
      );
    } else {
      requireCondition(
        entry.rights.status.allowsFullText,
        'Oral entry ${entry.id} has inconsistent full-text rights',
      );
      requireCondition(
        hasText,
        'Cleared oral entry ${entry.id} is missing text',
      );
    }
    requireCondition(
      entry.collectionSource.isNotEmpty,
      'Oral entry ${entry.id} missing collectionSource',
    );
    requireCondition(
      entry.publisher.isNotEmpty,
      'Oral entry ${entry.id} missing publisher',
    );
    requireCondition(
      entry.year.isNotEmpty,
      'Oral entry ${entry.id} missing year',
    );
    requireCondition(
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
  requireCondition(historyBooksFile.existsSync(), 'books.json does not exist');
  final booksList =
      jsonDecode(historyBooksFile.readAsStringSync()) as List<dynamic>;
  final bookIds = <String>{};
  for (final b in booksList) {
    final map = b as Map<String, dynamic>;
    bookIds.add(map['id'] as String);
  }

  final historyEntriesFile = File('assets/data/history/entries.json');
  requireCondition(
    historyEntriesFile.existsSync(),
    'entries.json does not exist',
  );
  final historyList =
      jsonDecode(historyEntriesFile.readAsStringSync()) as List<dynamic>;
  // NOTE: Count is not asserted as a fixed invariant.
  requireCondition(historyList.isNotEmpty, 'entries.json must not be empty');

  int totalHistoryAuthors = 0;
  int totalHistoryWorks = 0;
  for (final item in historyList) {
    final map = item as Map<String, dynamic>;
    requireCondition(map['id'] is String && (map['id'] as String).isNotEmpty);
    // Actual JSON uses 'title' and 'titlePersian' (not 'titleTj'/'titleFa')
    requireCondition(
      map['title'] is String && (map['title'] as String).isNotEmpty,
      'History entry ${map['id']} missing title field',
    );
    // 'summary' is required; 'titlePersian' and 'summaryPersian' are optional bilingual fields
    requireCondition(
      map['summary'] is String && (map['summary'] as String).isNotEmpty,
      'History entry ${map['id']} missing summary field',
    );

    final sourceBookId = map['sourceBookId'] as String?;
    if (sourceBookId != null && sourceBookId.isNotEmpty) {
      requireCondition(
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
      requireCondition(
        validStatuses.contains(status),
        'History entry ${map['id']} has invalid claim status $status',
      );
      final printedPage = (claim['printedPage'] as num?)?.toInt();
      final pdfPage = (claim['pdfPage'] as num?)?.toInt();
      requireCondition(
        printedPage == null || printedPage > 0,
        'History entry ${map['id']} has invalid printedPage',
      );
      requireCondition(
        pdfPage == null || pdfPage > 0,
        'History entry ${map['id']} has invalid pdfPage',
      );
      if (status == 'VERIFIED_UPLOADED_BOOK_PAGE' ||
          status == 'VERIFIED_MAORIF_PAGE') {
        requireCondition(
          printedPage != null || pdfPage != null,
          'Page-verified history entry ${map['id']} has no page',
        );
      }
    }

    final relatedAuthorIds =
        (map['relatedAuthorIds'] as List<dynamic>?)?.cast<String>() ?? [];
    for (final authorId in relatedAuthorIds) {
      requireCondition(
        authorIds.contains(authorId),
        'History entry ${map['id']} points to unknown authorId: $authorId',
      );
      totalHistoryAuthors++;
    }

    final relatedWorkIds =
        (map['relatedWorkIds'] as List<dynamic>?)?.cast<String>() ?? [];
    for (final workId in relatedWorkIds) {
      requireCondition(
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
