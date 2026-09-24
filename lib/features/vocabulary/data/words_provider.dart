import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/word_entry.dart';

/// The Luғатнома word list, loaded from the bundled editorial JSON.
///
/// Lazy and memoized: the [FutureProvider] only reads the asset when watched,
/// and stays cached until it is invalidated. Source metadata (`sourceBook`,
/// `pdfPage`) lives on each [WordEntry] but is not shown in the list UI.
final wordsProvider = FutureProvider<List<WordEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/vocabulary/words.json');
  final decoded = jsonDecode(raw) as List<dynamic>;
  final words = decoded
      .whereType<Map<String, dynamic>>()
      .map(WordEntry.fromJson)
      .where((w) => w.term.isNotEmpty && w.definition.isNotEmpty)
      .toList(growable: false);
  return List.unmodifiable(words);
});
