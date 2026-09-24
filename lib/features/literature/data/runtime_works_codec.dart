/// Codec for the dictionary-compressed runtime literary catalog.
///
/// `assets/data/literature/works.json` remains the canonical editorial source
/// of truth (10.7 MB, 5501 records). The app ships a derived, deterministic
/// runtime catalog (`assets/data/literature/runtime_works.json`) that keeps
/// every field any screen reads while sharing the heavily repeated book
/// metadata and rights records across works.
///
/// The runtime catalog is a JSON object:
///
/// ```json
/// {
///   "version": 1,
///   "sources": [ { "bookTitle": "...", "publisher": "...", ... } ],
///   "rights":  [ { "status": "...", "reasoning": "...", ... } ],
///   "works":   [ { ...full or stub work map... } ]
/// }
/// ```
///
/// A full work map is the canonical map with `primarySource`,
/// `secondarySource`, `sourceOccurrences`, and `rights` replaced by compact
/// references into the dictionaries:
///
/// - `{"s": 3, "pageStart": 62, ...}` — source base at `sources[3]` merged
///   with the per-work fields that override it (pages, image evidence).
/// - `{"r": 2}` — the rights record at `rights[2]`.
///
/// `verification` stays inline because its `evidenceHash` makes almost every
/// record unique; indirection would add bytes rather than save them.
///
/// This library is pure Dart so it can run inside the repository's `compute()`
/// isolate and from the deterministic build/verify tools.
library;

/// Version of the runtime catalog shape. Bump only on a schema change.
const int runtimeCatalogVersion = 1;

/// Identity fields retained on stub records (works without an auditable
/// review citation). No screen renders prose or provenance for these; they
/// exist so author review counts and the under-review gate stay correct.
///
/// Shared by the builder (`tool/build_runtime_literature.dart`) and the
/// verifier (`tool/verify_runtime_literature.dart`) so the stub shape cannot
/// drift between the two.
const List<String> runtimeStubScalarFields = [
  'id',
  'authorId',
  'title',
  'titlePersian',
  'titlePersianSource',
  'incipit',
  'type',
  'scriptSource',
  'textStatus',
  'editorial',
  'persianScriptSource',
];

/// Expands a decoded runtime catalog into plain legacy-shaped work maps that
/// [LiteraryWork.fromJson] accepts directly.
///
/// A decoded top-level JSON `List` (the legacy shape used by some tests and by
/// the repository's failure-retry asset `'[]'`) is returned unchanged.
List<Map<String, dynamic>> expandRuntimeWorks(dynamic decoded) {
  if (decoded is List) {
    return decoded
        .whereType<Map>()
        .map((work) => Map<String, dynamic>.from(work))
        .toList(growable: false);
  }
  if (decoded is! Map<String, dynamic>) {
    return const <Map<String, dynamic>>[];
  }

  final sources = _asMapList(decoded['sources']);
  final rights = _asMapList(decoded['rights']);
  final rawWorks = decoded['works'];
  if (rawWorks is! List) return const <Map<String, dynamic>>[];

  final expanded = <Map<String, dynamic>>[];
  for (final raw in rawWorks) {
    if (raw is! Map) continue;
    final work = Map<String, dynamic>.from(raw);

    final primary = work['primarySource'];
    if (primary is Map<String, dynamic>) {
      work['primarySource'] = _expandSource(primary, sources);
    }
    final secondary = work['secondarySource'];
    if (secondary is Map<String, dynamic>) {
      work['secondarySource'] = _expandSource(secondary, sources);
    }
    final occurrences = work['sourceOccurrences'];
    if (occurrences is List) {
      work['sourceOccurrences'] = occurrences
          .whereType<Map>()
          .map(
            (occurrence) =>
                _expandSource(Map<String, dynamic>.from(occurrence), sources),
          )
          .toList(growable: false);
    }
    final rightsRef = work['rights'];
    if (rightsRef is Map<String, dynamic>) {
      work['rights'] = _expandRights(rightsRef, rights);
    }
    expanded.add(work);
  }
  return expanded;
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList(growable: false);
}

Map<String, dynamic> _expandSource(
  Map<String, dynamic> reference,
  List<Map<String, dynamic>> sources,
) {
  final index = reference['s'];
  if (index is int && index >= 0 && index < sources.length) {
    final base = Map<String, dynamic>.from(sources[index]);
    reference.forEach((key, value) {
      if (key != 's') base[key] = value;
    });
    return base;
  }
  // No dictionary reference (plain source map or out-of-range index). Return
  // the reference unchanged so a corrupt catalog fails loudly, not silently.
  return reference;
}

Map<String, dynamic> _expandRights(
  Map<String, dynamic> reference,
  List<Map<String, dynamic>> rights,
) {
  final index = reference['r'];
  if (index is int && index >= 0 && index < rights.length) {
    return Map<String, dynamic>.from(rights[index]);
  }
  return reference;
}
