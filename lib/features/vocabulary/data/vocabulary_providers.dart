import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../history/data/history_providers.dart';
import '../../literature/data/literature_providers.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/vocabulary_entry.dart';
import 'vocabulary_aggregator.dart';

/// Aggregated, deduplicated vocabulary lexicon.
///
/// Lazy and memoized: the [FutureProvider] only computes when watched, and
/// stays cached until one of its source providers is invalidated.
final vocabularyProvider = FutureProvider<List<VocabularyEntry>>((ref) async {
  final proverbs = ref.watch(proverbsProvider);
  final history = await ref.watch(historyEntriesProvider.future);
  final authors = await ref.watch(literaryAuthorsProvider.future);
  return const VocabularyAggregator().aggregate(
    proverbs: proverbs,
    history: history,
    authors: authors,
  );
});

/// Looks up a single lexicon entry by its stable id.
final vocabularyEntryProvider = FutureProvider.family<VocabularyEntry?, String>(
  (ref, id) async {
    final entries = await ref.watch(vocabularyProvider.future);
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  },
);
