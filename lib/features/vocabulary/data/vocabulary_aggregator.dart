import '../../../core/utils/search_normalizer.dart';
import '../../../data/models/proverb.dart';
import '../../history/domain/history_entry.dart';
import '../../literature/domain/literary_author.dart';
import '../domain/vocabulary_entry.dart';

/// Pure aggregation of existing glossary entries across the app's content.
///
/// Terms are the source records' own phrases and names; meanings are their own
/// explanations. The function never splits words, never invents a definition,
/// and never changes source text. It only groups records by a normalized term
/// so that exact duplicates collapse into a single entry that still links back
/// to every contributing source.
class VocabularyAggregator {
  const VocabularyAggregator();

  List<VocabularyEntry> aggregate({
    required List<Proverb> proverbs,
    required List<HistoryEntry> history,
    required List<LiteraryAuthor> authors,
  }) {
    final grouped = <String, List<VocabularyEntry>>{};

    void add(VocabularyEntry entry) {
      final key = SearchNormalizer.normalize(entry.term);
      if (key.isEmpty) return;
      if (entry.meaning.trim().isEmpty) return;
      (grouped[key] ??= <VocabularyEntry>[]).add(entry);
    }

    for (final proverb in proverbs) {
      add(_fromProverb(proverb));
    }
    for (final entry in history) {
      add(_fromHistory(entry));
    }
    for (final author in authors) {
      add(_fromAuthor(author));
    }

    final entries = <VocabularyEntry>[];
    grouped.forEach((_, matches) {
      entries.add(matches.length == 1 ? matches.first : _merge(matches));
    });
    entries.sort((a, b) {
      final left = SearchNormalizer.normalize(a.term);
      final right = SearchNormalizer.normalize(b.term);
      return left.compareTo(right);
    });
    return List.unmodifiable(entries);
  }

  VocabularyEntry _fromProverb(Proverb proverb) {
    return VocabularyEntry(
      id: 'vocab-proverb-${proverb.id}',
      term: proverb.tajikCyrillic.trim(),
      termPersian: _nonEmpty(proverb.persianText),
      meaning: _prefer(proverb.meaningTj, proverb.simpleExplanationTj),
      kind: VocabularyKind.proverb,
      meanings: [
        VocabularyMeaning(
          text: _prefer(proverb.meaningTj, proverb.simpleExplanationTj),
          kind: VocabularyKind.proverb,
        ),
      ],
      sources: [
        VocabularySource(
          kind: VocabularyKind.proverb,
          sourceId: proverb.id,
          route: '/proverb/${proverb.id}',
          contextTj: proverb.sourceNote,
          categoryId: proverb.categoryId,
        ),
      ],
    );
  }

  VocabularyEntry _fromHistory(HistoryEntry entry) {
    return VocabularyEntry(
      id: 'vocab-history-${entry.id}',
      term: entry.title.trim(),
      termPersian: _nonEmpty(entry.titlePersian),
      meaning: entry.summary.trim(),
      meaningPersian: _nonEmpty(entry.summaryPersian),
      kind: VocabularyKind.history,
      meanings: [
        VocabularyMeaning(
          text: entry.summary.trim(),
          persianText: _nonEmpty(entry.summaryPersian),
          kind: VocabularyKind.history,
        ),
      ],
      sources: [
        VocabularySource(
          kind: VocabularyKind.history,
          sourceId: entry.id,
          route: '/history/${entry.id}',
          contextTj: entry.period,
          contextPersian: _nonEmpty(entry.periodPersian),
        ),
      ],
    );
  }

  VocabularyEntry _fromAuthor(LiteraryAuthor author) {
    if (!author.hasCanonicalName) {
      return _emptyAuthorPlaceholder(author);
    }
    final biography = author.biographyTj.trim();
    if (biography.isEmpty) {
      return _emptyAuthorPlaceholder(author);
    }
    return VocabularyEntry(
      id: 'vocab-author-${author.id}',
      term: author.canonicalName.trim(),
      termPersian: _nonEmpty(author.canonicalNamePersian),
      meaning: biography,
      meaningPersian: author.hasAuditablePersianBiography
          ? _nonEmpty(author.biographyFa)
          : null,
      kind: VocabularyKind.literaryAuthor,
      meanings: [
        VocabularyMeaning(
          text: biography,
          persianText: author.hasAuditablePersianBiography
              ? _nonEmpty(author.biographyFa)
              : null,
          kind: VocabularyKind.literaryAuthor,
        ),
      ],
      sources: [
        VocabularySource(
          kind: VocabularyKind.literaryAuthor,
          sourceId: author.id,
          route: '/literature/poet/${author.id}',
          contextTj: author.literaryPeriod,
          contextPersian: _nonEmpty(author.literaryPeriodPersian),
        ),
      ],
    );
  }

  /// Placeholder that is filtered out by [add] because its meaning is empty.
  VocabularyEntry _emptyAuthorPlaceholder(LiteraryAuthor author) {
    return VocabularyEntry(
      id: 'vocab-author-${author.id}',
      term: author.canonicalName.trim(),
      meaning: '',
      kind: VocabularyKind.literaryAuthor,
      sources: const [],
    );
  }

  VocabularyEntry _merge(List<VocabularyEntry> matches) {
    final first = matches.first;
    final sources = <VocabularySource>[];
    final meanings = <VocabularyMeaning>[];
    final seenMeaning = <String>{};
    for (final match in matches) {
      for (final source in match.sources) {
        sources.add(source);
      }
      // Preserve every distinct meaning, not just the first match's. Two
      // meanings are distinct when either the Tajik or the Persian text
      // differs after normalization; the same meaning from two sources is
      // kept once while both sources stay in [sources].
      for (final meaning in match.distinctMeanings) {
        final key = SearchNormalizer.normalize(
          '${meaning.text}\u0000${meaning.persianText ?? ''}',
        );
        if (seenMeaning.add(key)) {
          meanings.add(meaning);
        }
      }
    }
    return VocabularyEntry(
      id: first.id,
      term: first.term,
      termPersian: first.termPersian,
      meaning: first.meaning,
      meaningPersian: first.meaningPersian,
      kind: first.kind,
      sources: List.unmodifiable(sources),
      meanings: List.unmodifiable(meanings),
    );
  }

  static String _nonEmpty(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '' : trimmed;
  }

  static String _prefer(String primary, String fallback) {
    final trimmed = primary.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return fallback.trim();
  }
}
