import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/lexicon_index.dart';
import '../domain/word_entry.dart';
import '../../../core/utils/json_off_thread.dart';

/// The Luғатнома word list, loaded from the bundled editorial JSON.
///
/// Lazy and memoized: the [FutureProvider] only reads the asset when watched,
/// and stays cached until it is invalidated. Source metadata (`sourceBook`,
/// `pdfPage`) lives on each [WordEntry] but is not shown in the list UI.
final wordsProvider = FutureProvider<List<WordEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/vocabulary/words.json');
  final decoded = await decodeJsonOffThread(raw) as List<dynamic>;
  final words = decoded
      .whereType<Map<String, dynamic>>()
      .map(WordEntry.fromJson)
      .where((w) => w.term.isNotEmpty && w.definition.isNotEmpty)
      .toList(growable: false);
  return List.unmodifiable(words);
});

/// The Lexicon keyed for looking up words tapped in a poem.
final lexiconIndexProvider = FutureProvider<LexiconIndex>((ref) async {
  return LexiconIndex(await ref.watch(wordsProvider.future));
});
