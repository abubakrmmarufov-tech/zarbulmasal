// ignore_for_file: avoid_print

/// Deterministic builder for the shipped runtime literary catalog.
///
/// Reads the canonical `assets/data/literature/works.json` (the editorial
/// source of truth) and emits the dictionary-compressed runtime catalog at
/// `assets/data/literature/runtime_works.json`. The output is fully
/// deterministic: dictionary ordering is first-appearance order in the
/// canonical file, work order matches the canonical file, key order within
/// every map is fixed, and no timestamps or environment values are embedded.
///
/// Regenerating the catalog and diffing it against the committed asset is the
/// staleness guard wired into CI:
///
///     dart run tool/build_runtime_literature.dart
///     git diff --exit-code -- assets/data/literature/runtime_works.json
///
/// Usage:
///     dart run tool/build_runtime_literature.dart
///     dart run tool/build_runtime_literature.dart \
///         --canonical assets/data/literature/works.json \
///         --output /tmp/runtime_works.json
library;

import 'dart:convert';
import 'dart:io';

import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

/// Top-level keys of a canonical work map that carry over verbatim into a
/// full runtime record. Everything else is either replaced by a dictionary
/// reference or (for stubs) intentionally stripped.
const Set<String> _replacedKeys = {
  'primarySource',
  'secondarySource',
  'sourceOccurrences',
  'rights',
  'verification',
};

/// Book-level source metadata shared across works from the same edition.
/// Per-work page/image fields are kept on the work itself.
const List<String> _sourceBaseFields = [
  'bookTitle',
  'authorAsPrinted',
  'editor',
  'volume',
  'edition',
  'publisher',
  'city',
  'year',
  'isbn',
  'sourceInstitution',
  'sourceType',
  'sourceReference',
  'accessDate',
];

/// Per-work source fields that override the shared base.
const List<String> _sourceOverrideFields = [
  'pageStart',
  'pageEnd',
  'sourceImageVerified',
  'sourceImagePaths',
];

/// Fixed field order used to canonicalize rights records before deduping.
const List<String> _rightsFields = [
  'authorDeathYear',
  'status',
  'reasoning',
  'rightsSource',
  'fullTextAllowed',
  'excerptAllowed',
  'permissionReference',
];

/// Builds the runtime catalog JSON for [canonicalWorks] (decoded
/// `works.json`). Pure function so tests can regenerate and diff the asset.
String buildRuntimeCatalogJson(List<dynamic> canonicalWorks) {
  final sources = <Map<String, dynamic>>[];
  final sourceIndex = <String, int>{};
  final rightsList = <Map<String, dynamic>>[];
  final rightsIndex = <String, int>{};
  final works = <Map<String, dynamic>>[];

  for (final raw in canonicalWorks) {
    if (raw is! Map<String, dynamic>) continue;
    final work = LiteraryWork.fromJson(raw);
    final full = work.isDisplayable || work.hasAuditableReviewCitation;
    works.add(
      full
          ? _encodeFullWork(raw, sourceIndex, sources, rightsIndex, rightsList)
          : _encodeStubWork(raw),
    );
  }

  final runtime = <String, dynamic>{
    'version': runtimeCatalogVersion,
    'sources': sources,
    'rights': rightsList,
    'works': works,
  };
  return jsonEncode(runtime);
}

Map<String, dynamic> _encodeFullWork(
  Map<String, dynamic> canonical,
  Map<String, int> sourceIndex,
  List<Map<String, dynamic>> sources,
  Map<String, int> rightsIndex,
  List<Map<String, dynamic>> rightsList,
) {
  final out = <String, dynamic>{};
  canonical.forEach((key, value) {
    if (!_replacedKeys.contains(key)) {
      out[key] = value;
    }
  });

  final primary = canonical['primarySource'];
  if (primary is Map<String, dynamic>) {
    out['primarySource'] = _encodeSource(primary, sourceIndex, sources);
  }
  final secondary = canonical['secondarySource'];
  if (secondary is Map<String, dynamic>) {
    out['secondarySource'] = _encodeSource(secondary, sourceIndex, sources);
  }
  final occurrences = canonical['sourceOccurrences'];
  if (occurrences is List && occurrences.isNotEmpty) {
    out['sourceOccurrences'] = occurrences
        .whereType<Map<String, dynamic>>()
        .map((occurrence) => _encodeSource(occurrence, sourceIndex, sources))
        .toList(growable: false);
  }
  final rights = canonical['rights'];
  if (rights is Map<String, dynamic>) {
    out['rights'] = _encodeRights(rights, rightsIndex, rightsList);
  }
  // Verification stays inline: `evidenceHash` makes almost every record
  // unique, so indirection would cost bytes rather than save them. Keeping
  // the canonical map verbatim also keeps the verifier trivial.
  final verification = canonical['verification'];
  if (verification is Map<String, dynamic>) {
    out['verification'] = verification;
  }
  return out;
}

Map<String, dynamic> _encodeSource(
  Map<String, dynamic> source,
  Map<String, int> sourceIndex,
  List<Map<String, dynamic>> sources,
) {
  final base = <String, dynamic>{};
  for (final field in _sourceBaseFields) {
    final value = source[field];
    if (value != null && value != '') {
      base[field] = value;
    }
  }
  final key = jsonEncode(base);
  final existing = sourceIndex[key];
  int index;
  if (existing != null) {
    index = existing;
  } else {
    index = sources.length;
    sourceIndex[key] = index;
    sources.add(base);
  }

  final reference = <String, dynamic>{'s': index};
  for (final field in _sourceOverrideFields) {
    final value = source[field];
    if (field == 'sourceImageVerified') {
      if (value == true) reference[field] = true;
    } else if (value is List) {
      if (value.isNotEmpty) reference[field] = value;
    } else if (value != null) {
      reference[field] = value;
    }
  }
  // Normalize the legacy singular `sourceImagePath` into the list shape the
  // model exposes, so every runtime record has one canonical representation.
  // Match SourceEdition._parseImagePaths: only a non-empty plural list
  // suppresses the singular fallback; an empty `sourceImagePaths: []` must
  // not silently drop a legacy single-image witness.
  final pluralPaths = source['sourceImagePaths'];
  if (pluralPaths is! List || pluralPaths.isEmpty) {
    final legacy = source['sourceImagePath'];
    if (legacy is String && legacy.trim().isNotEmpty) {
      reference['sourceImagePaths'] = [legacy.trim()];
    }
  }
  return reference;
}

Map<String, dynamic> _encodeRights(
  Map<String, dynamic> rights,
  Map<String, int> rightsIndex,
  List<Map<String, dynamic>> rightsList,
) {
  final normalized = <String, dynamic>{};
  for (final field in _rightsFields) {
    if (rights.containsKey(field)) {
      normalized[field] = rights[field];
    }
  }
  final key = jsonEncode(normalized);
  final existing = rightsIndex[key];
  int index;
  if (existing != null) {
    index = existing;
  } else {
    index = rightsList.length;
    rightsIndex[key] = index;
    rightsList.add(normalized);
  }
  return {'r': index};
}

Map<String, dynamic> _encodeStubWork(Map<String, dynamic> canonical) {
  final out = <String, dynamic>{};
  for (final field in runtimeStubScalarFields) {
    final value = canonical[field];
    if (value != null && value != '') {
      out[field] = value;
    }
  }
  final verification = canonical['verification'];
  final evidenceLevel = verification is Map<String, dynamic>
      ? (verification['evidenceLevel'] as String? ?? 'needsReview')
      : 'needsReview';
  out['verification'] = {'evidenceLevel': evidenceLevel};
  return out;
}

String? _flag(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}

void main(List<String> args) {
  final canonicalPath =
      _flag(args, '--canonical') ?? 'assets/data/literature/works.json';
  final outputPath =
      _flag(args, '--output') ?? 'assets/data/literature/runtime_works.json';

  final canonicalFile = File(canonicalPath);
  if (!canonicalFile.existsSync()) {
    stderr.writeln('Missing canonical works file: $canonicalPath');
    exit(1);
  }

  final canonical = jsonDecode(canonicalFile.readAsStringSync()) as List;
  final output = buildRuntimeCatalogJson(canonical);

  final outputFile = File(outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(output, flush: true);

  final canonicalBytes = canonicalFile.lengthSync();
  final runtimeBytes = utf8.encode(output).length;

  var fullCount = 0;
  var stubCount = 0;
  for (final raw in canonical) {
    if (raw is! Map<String, dynamic>) continue;
    final work = LiteraryWork.fromJson(raw);
    if (work.isDisplayable || work.hasAuditableReviewCitation) {
      fullCount++;
    } else {
      stubCount++;
    }
  }

  print('Wrote $outputPath');
  print(
    '  canonical works.json : $canonicalBytes bytes '
    '(${canonical.length} works)',
  );
  print(
    '  runtime catalog      : $runtimeBytes bytes '
    '($fullCount full + $stubCount stub works)',
  );
  print(
    '  reduction            : ${canonicalBytes - runtimeBytes} bytes '
    '(${(100 * (1 - runtimeBytes / canonicalBytes)).toStringAsFixed(1)}%)',
  );
}
