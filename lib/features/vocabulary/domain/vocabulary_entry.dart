import '../../../core/utils/search_normalizer.dart';

/// Origin of a vocabulary term in the aggregated lexicon.
///
/// Every term comes verbatim from existing Zarbulmasal content. No word
/// splitting or invented definitions are introduced by the aggregator.
enum VocabularyKind { proverb, history, literaryAuthor }

/// A single trace back to the content a vocabulary term was aggregated from.
///
/// The route is the existing app route for the source record (a proverb,
/// history entry, or literary author dossier). Context strings are real
/// metadata pulled from the source model, never synthesised.
class VocabularySource {
  final VocabularyKind kind;
  final String sourceId;
  final String route;
  final String contextTj;
  final String? contextPersian;

  /// Category id for proverb sources, resolved to a label by the UI.
  final String? categoryId;

  const VocabularySource({
    required this.kind,
    required this.sourceId,
    required this.route,
    this.contextTj = '',
    this.contextPersian,
    this.categoryId,
  });
}

/// One distinct meaning of a lexicon term, tied to the source kind that
/// contributed it.
///
/// Merged entries carry several of these so that deduplication never discards
/// a distinct meaning: each meaning keeps the exact source text and the
/// vocabulary kind it came from.
class VocabularyMeaning {
  final String text;
  final String? persianText;
  final VocabularyKind kind;

  const VocabularyMeaning({
    required this.text,
    this.persianText,
    required this.kind,
  });

  bool get hasPersianText =>
      persianText != null && persianText!.trim().isNotEmpty;
}

/// One deduplicated lexicon entry aggregated from proverbs, history, and
/// literary-author material.
///
/// [term] and [meaning] are always the source record's own text. When several
/// source records share a normalized term they are merged into one entry whose
/// [sources] list carries every link back to the material and whose [meanings]
/// list preserves every distinct meaning the sources contributed.
class VocabularyEntry {
  final String id;
  final String term;
  final String? termPersian;
  final String meaning;
  final String? meaningPersian;

  /// Kind of the first contributing source, used for the list filter chip.
  final VocabularyKind kind;
  final List<VocabularySource> sources;

  /// Every distinct meaning of this term. Single-source entries carry one
  /// element; merged entries carry one per distinct source meaning.
  final List<VocabularyMeaning> meanings;

  const VocabularyEntry({
    required this.id,
    required this.term,
    this.termPersian,
    required this.meaning,
    this.meaningPersian,
    required this.kind,
    this.sources = const [],
    this.meanings = const [],
  });

  bool get hasPersianTerm =>
      termPersian != null && termPersian!.trim().isNotEmpty;

  bool get hasPersianMeaning =>
      meaningPersian != null && meaningPersian!.trim().isNotEmpty;

  /// The primary meaning plus any additional distinct meanings merged in.
  List<VocabularyMeaning> get distinctMeanings {
    if (meanings.isNotEmpty) return meanings;
    return [
      VocabularyMeaning(text: meaning, persianText: meaningPersian, kind: kind),
    ];
  }

  /// Matches the query against the term, its Persian form, and every meaning.
  /// Meaning matches are included so learners can search by definition.
  bool matches(String query) {
    return SearchNormalizer.matchesAny([
      term,
      termPersian ?? '',
      meaning,
      meaningPersian ?? '',
      ...distinctMeanings.expand(
        (meaning) => [meaning.text, meaning.persianText ?? ''],
      ),
    ], query);
  }
}
