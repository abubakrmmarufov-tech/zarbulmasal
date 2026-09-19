import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/search_normalizer.dart';
import '../domain/history_domain.dart';

class HistoryRepository {
  static const booksAssetPath = 'assets/data/history/books.json';
  static const entriesAssetPath = 'assets/data/history/entries.json';

  final AssetBundle _bundle;

  HistoryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  Future<List<HistoryBook>> loadBooks() async {
    // Optimization: Offload large JSON parsing to background isolate to prevent UI jank
    final jsonString = await _bundle.loadString(booksAssetPath);
    final decoded = await compute(jsonDecode, jsonString);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => HistoryBook.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<HistoryEntry>> loadEntries() async {
    // Optimization: Offload large JSON parsing to background isolate to prevent UI jank
    final jsonString = await _bundle.loadString(entriesAssetPath);
    final decoded = await compute(jsonDecode, jsonString);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => HistoryEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  List<HistoryEntry> search(
    List<HistoryEntry> entries,
    String query, {
    String? grade,
    HistoryEntryKind? kind,
    HistoryEpoch? epoch,
  }) {
    final cleanQuery = query.trim();
    return entries
        .where((entry) {
          if (grade != null && entry.grade != grade) return false;
          if (kind != null && entry.kind != kind) return false;
          if (epoch != null && entry.epoch != epoch) return false;
          if (cleanQuery.isEmpty) return true;
          final searchFields = [
            entry.title,
            if (entry.titlePersian != null) entry.titlePersian!,
            entry.summary,
            if (entry.summaryPersian != null) entry.summaryPersian!,
            entry.period,
            entry.sourceSection,
            if (entry.capital != null) entry.capital!,
            if (entry.capitalPersian != null) entry.capitalPersian!,
            if (entry.territory != null) entry.territory!,
            if (entry.territoryPersian != null) entry.territoryPersian!,
            if (entry.significance != null) entry.significance!,
            if (entry.significancePersian != null) entry.significancePersian!,
            if (entry.dates != null) entry.dates!,
            if (entry.datesPersian != null) entry.datesPersian!,
            ...entry.keywords,
            ...entry.keyFigures,
            ...entry.keyFiguresPersian,
          ];
          return SearchNormalizer.matchesAny(searchFields, cleanQuery);
        })
        .toList(growable: false);
  }
}
