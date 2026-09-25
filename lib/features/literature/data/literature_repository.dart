import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

List<dynamic> _decodeJsonList(String source) {
  final decoded = jsonDecode(source);
  return decoded is List<dynamic> ? decoded : const <dynamic>[];
}

/// Repository responsible for loading and querying literary heritage data.
///
/// Loads verified author biographies, literary works, source editions,
/// school canon curriculum mappings, and folklore oral heritage records
/// from bundled asset JSON files.
class LiteratureRepository {
  /// The asset bundle used to load JSON assets.
  final AssetBundle _bundle;

  /// Default asset paths for literary heritage data.
  static const String authorsAssetPath = 'assets/data/literature/poets.json';
  static const String worksAssetPath = 'assets/data/literature/works.json';
  static const String sourcesAssetPath = 'assets/data/literature/sources.json';
  static const String schoolCanonAssetPath =
      'assets/data/literature/school_canon.json';
  static const String oralHeritageAssetPath =
      'assets/data/literature/oral_heritage.json';
  static final _searchMarks = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  // `works.json` is the largest shipped literature asset. Keep one successful
  // parse per repository instance so author/detail/search lookups do not
  // repeatedly allocate and decode the same catalog. Failed loads are evicted
  // so UI retry actions still have a chance to recover from transient errors.
  Future<List<LiteraryWork>>? _worksFuture;
  Future<List<LiteraryAuthor>>? _authorsFuture;

  LiteratureRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  /// Normalizes common Persian keyboard variants for tolerant local search.
  static String normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(_searchMarks, '')
        .replaceAll('\u200c', '')
        .replaceAll('\u200d', '')
        .replaceAll('ي', 'ی')
        .replaceAll('ى', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Loads verified literary authors from [authorsAssetPath].
  Future<List<LiteraryAuthor>> loadAuthors() async {
    final cached = _authorsFuture;
    if (cached != null) return cached;

    final future = _loadAuthors();
    _authorsFuture = future;
    try {
      return await future;
    } catch (_) {
      if (identical(_authorsFuture, future)) {
        _authorsFuture = null;
      }
      rethrow;
    }
  }

  Future<List<LiteraryAuthor>> _loadAuthors() async {
    final jsonString = await _bundle.loadString(authorsAssetPath);
    final decoded = await compute(
      _decodeJsonList,
      jsonString,
      debugLabel: 'decode-literary-authors',
    );
    return List.unmodifiable(
      decoded.whereType<Map>().map(
        (json) => LiteraryAuthor.fromJson(Map<String, dynamic>.from(json)),
      ),
    );
  }

  /// Loads literary works from [worksAssetPath].
  Future<List<LiteraryWork>> loadWorks() async {
    final cached = _worksFuture;
    if (cached != null) return cached;

    final future = _loadWorks();
    _worksFuture = future;
    try {
      return await future;
    } catch (_) {
      if (identical(_worksFuture, future)) {
        _worksFuture = null;
      }
      rethrow;
    }
  }

  Future<List<LiteraryWork>> _loadWorks() async {
    final jsonString = await _bundle.loadString(worksAssetPath);
    final decoded = await compute(
      _decodeJsonList,
      jsonString,
      debugLabel: 'decode-literary-works',
    );
    return List.unmodifiable(
      decoded.whereType<Map>().map(
        (json) => LiteraryWork.fromJson(Map<String, dynamic>.from(json)),
      ),
    );
  }

  /// Loads source editions and bibliographic witnesses from [sourcesAssetPath].
  Future<List<SourceEdition>> loadSources() async {
    final jsonString = await _bundle.loadString(sourcesAssetPath);
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((json) => SourceEdition.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Loads official school canon curriculum mappings from [schoolCanonAssetPath].
  Future<List<SchoolCanonEntry>> loadSchoolCanon() async {
    final jsonString = await _bundle.loadString(schoolCanonAssetPath);
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (json) => SchoolCanonEntry.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  /// Loads verified folklore oral heritage entries from [oralHeritageAssetPath].
  Future<List<OralHeritageEntry>> loadOralHeritage() async {
    final jsonString = await _bundle.loadString(oralHeritageAssetPath);
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (json) => OralHeritageEntry.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  /// Filters works based on [LiteraryWork.isDisplayable].
  ///
  /// If [works] is provided, filters that list directly; otherwise loads
  /// works via [loadWorks] and filters the loaded list.
  Future<List<LiteraryWork>> getApprovedWorks([
    List<LiteraryWork>? works,
  ]) async {
    final source = works ?? await loadWorks();
    return source.where((w) => w.isDisplayable).toList();
  }

  /// Synchronously filters a provided list of works based on [LiteraryWork.isDisplayable].
  List<LiteraryWork> filterApprovedWorks(List<LiteraryWork> works) {
    return works.where((w) => w.isDisplayable).toList();
  }

  /// Deterministically selects a work based on [date] from approved works.
  ///
  /// Filters [works] to those where [LiteraryWork.isDisplayable] is true,
  /// and returns `null` if no displayable works exist.
  LiteraryWork? getDailyVerse(DateTime date, List<LiteraryWork> works) {
    final approved = works.where((w) => w.isDisplayable).toList();
    if (approved.isEmpty) {
      return null;
    }
    final dayIndex = (date.year * 365 + date.month * 31 + date.day).abs();
    return approved[dayIndex % approved.length];
  }

  /// Finds an author by their unique [id].
  Future<LiteraryAuthor?> getAuthorById(String id) async {
    final authors = await loadAuthors();
    for (final author in authors) {
      if (author.id == id) return author;
    }
    return null;
  }

  /// Loads all works attributed to [authorId].
  Future<List<LiteraryWork>> getWorksByAuthor(String authorId) async {
    final works = await loadWorks();
    return works.where((w) => w.authorId == authorId).toList();
  }

  /// Loads all school canon entries referencing [authorId].
  Future<List<SchoolCanonEntry>> getCanonByAuthor(String authorId) async {
    final canon = await loadSchoolCanon();
    return canon.where((entry) => entry.authorId == authorId).toList();
  }
}
