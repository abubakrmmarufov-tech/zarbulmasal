import 'source_ref.dart';

enum ProverbType { traditional, modernCustom }

enum SourceStatus { unverified, bookAttested, pageVerified, needsReview }

/// Where the Persian-script text comes from: generated from the Cyrillic, or
/// copied from a book that prints it.
enum PersianOrigin { transliteration, printed }

class Proverb {
  final String id;
  final String tajikCyrillic;
  final String persianText;
  final String simpleExplanationTj;
  final String meaningTj;
  final String exampleSentenceTj;
  final String categoryId;
  final int level;
  final ProverbType type;
  final SourceStatus sourceStatus;
  final String sourceNote;
  final String? canonicalId;

  /// IDs of the proverb records that are alternative forms of this proverb.
  final List<String> variants;

  /// The books that print this proverb, primary first. Empty when no printed
  /// source was found.
  final List<SourceRef> sources;

  /// The page the meaning is copied from; null when the meaning is editorial.
  final SourceRef? meaningSource;

  /// The page the example is copied from; null when the example is editorial.
  final SourceRef? exampleSource;

  /// The example's printed signature, e.g. an author or «Аз „Доробнома“».
  final String? exampleAttribution;

  final PersianOrigin persianOrigin;

  const Proverb({
    required this.id,
    required this.tajikCyrillic,
    required this.persianText,
    required this.simpleExplanationTj,
    required this.meaningTj,
    required this.exampleSentenceTj,
    required this.categoryId,
    required this.level,
    required this.type,
    required this.sourceStatus,
    required this.sourceNote,
    this.canonicalId,
    this.variants = const [],
    this.sources = const [],
    this.meaningSource,
    this.exampleSource,
    this.exampleAttribution,
    this.persianOrigin = PersianOrigin.transliteration,
  });

  bool get isCanonical => canonicalId == null;

  /// A printed page attests the proverb.
  bool get isPageVerified =>
      sourceStatus == SourceStatus.pageVerified && sources.isNotEmpty;

  bool get isMeaningPrinted => meaningSource != null;

  bool get isExamplePrinted => exampleSource != null;

  Proverb copyWith({
    String? id,
    String? tajikCyrillic,
    String? persianText,
    String? simpleExplanationTj,
    String? meaningTj,
    String? exampleSentenceTj,
    String? categoryId,
    int? level,
    ProverbType? type,
    SourceStatus? sourceStatus,
    String? sourceNote,
    String? canonicalId,
    List<String>? variants,
    List<SourceRef>? sources,
    SourceRef? meaningSource,
    SourceRef? exampleSource,
    String? exampleAttribution,
    PersianOrigin? persianOrigin,
  }) {
    return Proverb(
      id: id ?? this.id,
      tajikCyrillic: tajikCyrillic ?? this.tajikCyrillic,
      persianText: persianText ?? this.persianText,
      simpleExplanationTj: simpleExplanationTj ?? this.simpleExplanationTj,
      meaningTj: meaningTj ?? this.meaningTj,
      exampleSentenceTj: exampleSentenceTj ?? this.exampleSentenceTj,
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
      type: type ?? this.type,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      sourceNote: sourceNote ?? this.sourceNote,
      canonicalId: canonicalId ?? this.canonicalId,
      variants: variants ?? this.variants,
      sources: sources ?? this.sources,
      meaningSource: meaningSource ?? this.meaningSource,
      exampleSource: exampleSource ?? this.exampleSource,
      exampleAttribution: exampleAttribution ?? this.exampleAttribution,
      persianOrigin: persianOrigin ?? this.persianOrigin,
    );
  }
}
