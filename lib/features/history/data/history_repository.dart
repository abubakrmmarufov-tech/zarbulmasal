import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/history_domain.dart';

class HistoryRepository {
  static const booksAssetPath = 'assets/data/history/books.json';
  static const entriesAssetPath = 'assets/data/history/entries.json';
  static final _searchMarks = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  final AssetBundle _bundle;

  HistoryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  Future<List<HistoryBook>> loadBooks() async {
    final jsonString = await _bundle.loadString(booksAssetPath);
    // Offload large JSON parsing to a background isolate to prevent main thread jank.
    // In widget tests, use synchronous decoding to avoid isolate deadlock issues with tester.pumpAndSettle()
    final dynamic decoded = kIsWeb || const bool.fromEnvironment('dart.vm.product') ? await compute(jsonDecode, jsonString) : jsonDecode(jsonString);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => HistoryBook.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<HistoryEntry>> loadEntries() async {
    final jsonString = await _bundle.loadString(entriesAssetPath);
    final dynamic decoded = kIsWeb || const bool.fromEnvironment('dart.vm.product') ? await compute(jsonDecode, jsonString) : jsonDecode(jsonString);
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
  }) {
    final normalized = _normalize(query);
    return entries
        .where((entry) {
          if (grade != null && entry.grade != grade) return false;
          if (kind != null && entry.kind != kind) return false;
          if (normalized.isEmpty) return true;
          final haystack = [
            entry.title,
            entry.titlePersian,
            entry.summary,
            entry.period,
            entry.sourceSection,
            ...entry.keywords,
          ].whereType<String>().map(_normalize).join(' ');
          return haystack.contains(normalized);
        })
        .toList(growable: false);
  }

  static String _normalize(String value) {
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
}
