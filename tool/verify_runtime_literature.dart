// ignore_for_file: avoid_print

/// Semantic verifier for the runtime literary catalog.
///
/// Expands `assets/data/literature/runtime_works.json` and proves it is a
/// lossless projection of the canonical `assets/data/literature/works.json`
/// for every field any screen reads:
///
/// - every canonical work id survives exactly once;
/// - full records (displayable or auditable review citation) keep all text,
///   sources, rights, and verification data (compared through the domain
///   model, so legacy `sourceImagePath` vs `sourceImagePaths` normalizes);
/// - stub records carry only identity + evidenceLevel, and correspond to
///   works that are neither displayable nor have an auditable citation;
/// - global invariants (displayable count, auditable-citation count,
///   searchable set, per-author under-review counts) match the canonical
///   dataset.
///
/// Exit code is 0 when every check passes, 1 otherwise.
library;

import 'dart:convert';
import 'dart:io';

import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

const Set<VerificationLevel> _checkedLevels = {
  VerificationLevel.primaryChecked,
  VerificationLevel.secondWitnessLocated,
  VerificationLevel.collated,
  VerificationLevel.editoriallyApproved,
};

var _failures = 0;

void _check(bool condition, String message) {
  if (condition) return;
  _failures++;
  print('FAIL: $message');
}

bool _sourcesEqual(List<SourceEdition> left, List<SourceEdition> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _fullEquivalent(LiteraryWork canonical, LiteraryWork runtime) {
  return canonical.id == runtime.id &&
      canonical.authorId == runtime.authorId &&
      canonical.title == runtime.title &&
      canonical.titlePersian == runtime.titlePersian &&
      canonical.titlePersianSource == runtime.titlePersianSource &&
      canonical.incipit == runtime.incipit &&
      canonical.type == runtime.type &&
      canonical.scriptSource == runtime.scriptSource &&
      canonical.textTajik == runtime.textTajik &&
      canonical.textPersian == runtime.textPersian &&
      canonical.persianScriptRepresentation ==
          runtime.persianScriptRepresentation &&
      canonical.persianScriptSource == runtime.persianScriptSource &&
      canonical.textStatus == runtime.textStatus &&
      canonical.editorial == runtime.editorial &&
      canonical.editorialNotes == runtime.editorialNotes &&
      canonical.textMatchResult == runtime.textMatchResult &&
      canonical.variantNotes == runtime.variantNotes &&
      canonical.compositionDate == runtime.compositionDate &&
      canonical.compositionContext == runtime.compositionContext &&
      canonical.primarySource == runtime.primarySource &&
      canonical.secondarySource == runtime.secondarySource &&
      _sourcesEqual(canonical.sourceOccurrences, runtime.sourceOccurrences) &&
      canonical.rights == runtime.rights &&
      canonical.verification == runtime.verification;
}

bool _stubEquivalent(
  Map<String, dynamic> canonical,
  Map<String, dynamic> runtime,
) {
  // Stubs must not carry provenance payloads or prose.
  if (runtime['primarySource'] != null ||
      runtime['secondarySource'] != null ||
      runtime['sourceOccurrences'] != null ||
      runtime['rights'] != null ||
      runtime['textTajik'] != null ||
      runtime['textPersian'] != null ||
      runtime['persianScriptRepresentation'] != null) {
    return false;
  }
  for (final field in runtimeStubScalarFields) {
    final canonicalValue = canonical[field];
    final runtimeValue = runtime[field];
    final canonicalPresent = canonicalValue != null && canonicalValue != '';
    final runtimePresent = runtimeValue != null && runtimeValue != '';
    if (canonicalPresent != runtimePresent) return false;
    if (canonicalPresent && canonicalValue != runtimeValue) return false;
  }
  final canonicalVerification = canonical['verification'];
  final runtimeVerification = runtime['verification'];
  final canonicalLevel = canonicalVerification is Map
      ? (canonicalVerification['evidenceLevel'] as String? ?? 'needsReview')
      : 'needsReview';
  final runtimeLevel = runtimeVerification is Map
      ? (runtimeVerification['evidenceLevel'] as String? ?? 'needsReview')
      : 'needsReview';
  return canonicalLevel == runtimeLevel;
}

void main() {
  final canonicalFile = File('assets/data/literature/works.json');
  final runtimeFile = File('assets/data/literature/runtime_works.json');

  _check(canonicalFile.existsSync(), 'missing canonical works.json');
  _check(runtimeFile.existsSync(), 'missing runtime_works.json');
  if (!canonicalFile.existsSync() || !runtimeFile.existsSync()) {
    exit(1);
  }

  final canonicalRaw = jsonDecode(canonicalFile.readAsStringSync()) as List;
  final runtimeDecoded = jsonDecode(runtimeFile.readAsStringSync());
  final expanded = expandRuntimeWorks(runtimeDecoded);

  final canonicalById = <String, Map<String, dynamic>>{};
  for (final raw in canonicalRaw) {
    if (raw is Map<String, dynamic>) {
      canonicalById[raw['id'] as String] = raw;
    }
  }
  final runtimeById = <String, Map<String, dynamic>>{};
  for (final work in expanded) {
    runtimeById[work['id'] as String] = work;
  }

  _check(
    canonicalById.length == runtimeById.length,
    'record count mismatch: canonical ${canonicalById.length} vs runtime ${runtimeById.length}',
  );
  _check(
    canonicalById.keys.toSet().difference(runtimeById.keys.toSet()).isEmpty,
    'missing runtime ids: ${canonicalById.keys.toSet().difference(runtimeById.keys.toSet())}',
  );
  _check(
    runtimeById.keys.toSet().difference(canonicalById.keys.toSet()).isEmpty,
    'unexpected runtime ids: ${runtimeById.keys.toSet().difference(canonicalById.keys.toSet())}',
  );

  var displayableCanonical = 0;
  var displayableRuntime = 0;
  var arcCanonical = 0;
  var arcRuntime = 0;
  var searchableCanonical = 0;
  var searchableRuntime = 0;
  final reviewCountsCanonical = <String, int>{};
  final reviewCountsRuntime = <String, int>{};

  for (final entry in canonicalById.entries) {
    final id = entry.key;
    final canonicalMap = entry.value;
    final runtimeMap = runtimeById[id];
    if (runtimeMap == null) continue;

    final canonicalWork = LiteraryWork.fromJson(canonicalMap);
    final runtimeWork = LiteraryWork.fromJson(runtimeMap);

    final canonicalFull =
        canonicalWork.isDisplayable || canonicalWork.hasAuditableReviewCitation;
    final runtimeFull =
        runtimeWork.isDisplayable || runtimeWork.hasAuditableReviewCitation;

    if (canonicalFull) {
      _check(runtimeFull, 'full canonical work became a stub: $id');
      _check(
        _fullEquivalent(canonicalWork, runtimeWork),
        'full work lost data: $id',
      );
    } else {
      _check(!runtimeFull, 'stub canonical work became full: $id');
      _check(
        _stubEquivalent(canonicalMap, runtimeMap),
        'stub work mismatch: $id',
      );
    }

    if (canonicalWork.isDisplayable) displayableCanonical++;
    if (runtimeWork.isDisplayable) displayableRuntime++;
    if (canonicalWork.hasAuditableReviewCitation) arcCanonical++;
    if (runtimeWork.hasAuditableReviewCitation) arcRuntime++;
    if (canonicalWork.hasAuditableReviewCitation &&
        _checkedLevels.contains(canonicalWork.verification.evidenceLevel)) {
      searchableCanonical++;
    }
    if (runtimeWork.hasAuditableReviewCitation &&
        _checkedLevels.contains(runtimeWork.verification.evidenceLevel)) {
      searchableRuntime++;
    }

    if (!canonicalWork.isDisplayable &&
        canonicalWork.verification.evidenceLevel !=
            VerificationLevel.rejected) {
      reviewCountsCanonical[canonicalWork.authorId] =
          (reviewCountsCanonical[canonicalWork.authorId] ?? 0) + 1;
    }
    if (!runtimeWork.isDisplayable &&
        runtimeWork.verification.evidenceLevel != VerificationLevel.rejected) {
      reviewCountsRuntime[runtimeWork.authorId] =
          (reviewCountsRuntime[runtimeWork.authorId] ?? 0) + 1;
    }
  }

  _check(
    displayableCanonical == displayableRuntime,
    'displayable count mismatch: canonical $displayableCanonical vs runtime $displayableRuntime',
  );
  _check(
    arcCanonical == arcRuntime,
    'auditable-citation count mismatch: canonical $arcCanonical vs runtime $arcRuntime',
  );
  _check(
    searchableCanonical == searchableRuntime,
    'searchable count mismatch: canonical $searchableCanonical vs runtime $searchableRuntime',
  );
  _check(
    reviewCountsCanonical.length == reviewCountsRuntime.length &&
        reviewCountsCanonical.keys.every(
          (author) =>
              reviewCountsCanonical[author] == reviewCountsRuntime[author],
        ),
    'per-author under-review counts diverged',
  );

  // No stub may silently lose a field a public screen renders. In the current
  // dataset the only such getters that read provenance/prose are dead on stubs
  // by construction; enforce that so a future content edit cannot regress it.
  for (final entry in canonicalById.entries) {
    final canonicalWork = LiteraryWork.fromJson(entry.value);
    if (canonicalWork.isDisplayable ||
        canonicalWork.hasAuditableReviewCitation) {
      continue;
    }
    _check(
      !canonicalWork.hasAuditableCompositionEvidence,
      'stub would lose composition evidence (canonical only): ${entry.key}',
    );
    _check(
      !canonicalWork.isExcerptDisplayable,
      'stub would lose excerpt display (canonical only): ${entry.key}',
    );
  }

  // Cross-reference integrity: every school-canon curriculum entry and every
  // history relatedWorkIds reference must resolve in the runtime catalog, and
  // history-linked works must stay displayable. A dropped or demoted work
  // anywhere in these reference sets is a user-visible regression.
  final schoolCanonFile = File('assets/data/literature/school_canon.json');
  if (schoolCanonFile.existsSync()) {
    final canon = jsonDecode(schoolCanonFile.readAsStringSync()) as List;
    for (final entry in canon) {
      final workId = (entry as Map)['workId'];
      if (workId == null || workId.toString().trim().isEmpty) continue;
      _check(
        runtimeById.containsKey(workId),
        'school canon references missing runtime work $workId',
      );
    }
  } else {
    _check(false, 'missing school_canon.json');
  }

  final historyFile = File('assets/data/history/entries.json');
  if (historyFile.existsSync()) {
    final history = jsonDecode(historyFile.readAsStringSync()) as List;
    for (final entry in history) {
      final related = (entry as Map)['relatedWorkIds'];
      if (related is! List) continue;
      for (final workId in related.whereType<String>()) {
        final runtimeMap = runtimeById[workId];
        _check(
          runtimeMap != null,
          'history references missing runtime work $workId',
        );
        if (runtimeMap != null) {
          _check(
            LiteraryWork.fromJson(runtimeMap).isDisplayable,
            'history-linked work no longer displayable: $workId',
          );
        }
      }
    }
  } else {
    _check(false, 'missing history entries.json');
  }

  final canonicalBytes = canonicalFile.lengthSync();
  final runtimeBytes = runtimeFile.lengthSync();
  print('=== Runtime catalog verification ===');
  print(
    'works         : ${canonicalById.length} (${canonicalById.length == runtimeById.length ? 'match' : 'MISMATCH'})',
  );
  print(
    'displayable   : $displayableCanonical (canonical) == $displayableRuntime (runtime)',
  );
  print('auditable cite: $arcCanonical (canonical) == $arcRuntime (runtime)');
  print(
    'searchable    : $searchableCanonical (canonical) == $searchableRuntime (runtime)',
  );
  print(
    'bytes         : $canonicalBytes -> $runtimeBytes '
    '(${(100 * (1 - runtimeBytes / canonicalBytes)).toStringAsFixed(1)}% reduction)',
  );
  print(
    _failures == 0
        ? 'RESULT: PASS'
        : 'RESULT: FAIL ($_failures check(s) failed)',
  );

  exit(_failures == 0 ? 0 : 1);
}
