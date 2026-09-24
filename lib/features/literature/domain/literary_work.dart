import 'rights_record.dart';
import 'source_edition.dart';
import 'verification_record.dart';
import 'verse_structure.dart';

/// Poetic or literary genre/form of the work.
enum WorkType {
  ghazal,
  rubai,
  qasida,
  poem,
  fragment,
  folk,
  anthem,
  epic,
  other;

  /// Parses a string into [WorkType] matching camelCase, snake_case, or kebab-case.
  static WorkType fromString(String? value) {
    if (value == null || value.trim().isEmpty) return WorkType.other;
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    for (final type in WorkType.values) {
      if (type.name.toLowerCase() == normalized) return type;
    }
    return WorkType.other;
  }
}

/// Text verification and publication readiness status.
///
/// Newly created works start with [needsReview]. A page-checked occurrence in
/// an uploaded textbook/PDF or on maorif.tj is sufficient for ordinary
/// publication; a second witness is useful evidence, but is not mandatory.
enum TextStatus {
  verified,
  partial,
  needsReview,
  blocked;

  /// Parses a string into [TextStatus]. Defaults to [needsReview].
  static TextStatus fromString(String? value) {
    if (value == null || value.trim().isEmpty) return TextStatus.needsReview;
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    for (final status in TextStatus.values) {
      if (status.name.toLowerCase() == normalized) return status;
    }
    return TextStatus.needsReview;
  }
}

/// Primary script encoding available for this work.
///
/// - [tajikOnly]: Source text is Tajik Cyrillic only; any Persian-script text is
///   a mechanically generated representation, NOT an original source witness.
/// - [both]: Genuine dual-script source evidence exists (both scripts attested
///   in verified printed sources).
/// - [persianArabic]: Source is Persian/Arabic script only.
enum ScriptSource {
  tajikCyrillic,
  tajikOnly,
  persianArabic,
  both;

  /// Parses a string into [ScriptSource]. Defaults to [tajikCyrillic].
  static ScriptSource fromString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ScriptSource.tajikCyrillic;
    }
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    for (final s in ScriptSource.values) {
      if (s.name.toLowerCase() == normalized) return s;
    }
    return ScriptSource.tajikCyrillic;
  }
}

/// Editorial transformation applied to the source text.
enum EditorialTransformation {
  none,
  transliteration,
  orthographicNormalization;

  /// Parses a string into [EditorialTransformation]. Defaults to [none].
  static EditorialTransformation fromString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return EditorialTransformation.none;
    }
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    for (final t in EditorialTransformation.values) {
      if (t.name.toLowerCase() == normalized) return t;
    }
    return EditorialTransformation.none;
  }
}

/// A literary work with full source provenance and verification.
///
/// Contains the poetic text in Tajik Cyrillic and Persian Arabic scripts,
/// bibliographic primary/secondary witnesses, and audit status.
class LiteraryWork {
  /// Unique work identifier (e.g. "rudaki-boyi-juyi-muliyon").
  final String id;

  /// ID of the author in the author registry.
  final String authorId;

  /// Canonical title in Tajik Cyrillic (e.g. "Бӯи ҷӯи Мӯлиён").
  final String title;

  /// Canonical title in Persian Arabic script if verified (e.g. "بوی جوی مولیان").
  final String? titlePersian;

  /// Origin of [titlePersian]. Current records use "generated" for a
  /// mechanical representation derived from Tajik Cyrillic.
  final String? titlePersianSource;

  /// Opening line / first hemistich (incipit) of the work.
  final String? incipit;

  /// Poetic or literary genre.
  final WorkType type;

  /// Script source availability.
  final ScriptSource scriptSource;

  /// Full text in Tajik Cyrillic (must be null or empty until verified).
  final String? textTajik;

  /// Full text in Persian Arabic script (must be null or empty until verified).
  final String? textPersian;

  /// Generated Persian-script representation (mechanical Tajik Cyrillic → Arabic script
  /// conversion). Distinct from [textPersian] which should only hold a genuine Persian
  /// source text or verified semantic translation.
  final String? persianScriptRepresentation;

  /// Origin of the Persian-script content.
  /// - "generated": Mechanically converted from Tajik Cyrillic (not a source witness).
  /// - "source": Present in a verified permitted source in Persian script.
  /// - "translation": A semantic Persian translation of the Tajik original.
  final String? persianScriptSource;

  /// Verification status of the text content.
  final TextStatus textStatus;

  /// Editorial transformation applied (if any).
  final EditorialTransformation editorial;

  /// Notes detailing any normalization, metre corrections, or orthographic notes.
  final String? editorialNotes;

  /// Primary Tier A printed source witness.
  final SourceEdition? primarySource;

  /// Secondary corroborating printed witness.
  final SourceEdition? secondarySource;

  /// Every distinct source occurrence found during corpus extraction.
  ///
  /// [primarySource] and [secondarySource] remain the editorial roles used by
  /// the reader. This list preserves additional textbook occurrences without
  /// creating duplicate canonical poems.
  final List<SourceEdition> sourceOccurrences;

  /// Collation result between witnesses (e.g. "exact", "minor-variant", "significant-variant").
  final String? textMatchResult;

  /// Detailed notes regarding variants between witnesses.
  final String? variantNotes;

  /// Rights and copyright clearance record.
  final RightsRecord rights;

  /// Date or year of composition if attested (e.g. "15 октябри 1948", "1954", "асри X").
  final String? compositionDate;

  /// Historical, geographic or social context of composition (e.g. "Дар шаҳри Душанбе").
  final String? compositionContext;

  /// Philological verification and collation audit record.
  final VerificationRecord verification;

  const LiteraryWork({
    required this.id,
    required this.authorId,
    required this.title,
    this.titlePersian,
    this.titlePersianSource,
    this.incipit,
    this.type = WorkType.other,
    this.scriptSource = ScriptSource.tajikCyrillic,
    this.textTajik,
    this.textPersian,
    this.persianScriptRepresentation,
    this.persianScriptSource,
    this.textStatus = TextStatus.needsReview,
    this.editorial = EditorialTransformation.none,
    this.editorialNotes,
    this.primarySource,
    this.secondarySource,
    this.sourceOccurrences = const [],
    this.textMatchResult,
    this.variantNotes,
    this.compositionDate,
    this.compositionContext,
    required this.rights,
    required this.verification,
  });

  /// Whether the work meets one of the supported publication paths.
  ///
  /// The legacy path retains explicit editorial and rights approval. The
  /// source-attested path implements Zarbulmasal's publication policy: one
  /// exact, page-checked occurrence in an uploaded textbook/PDF or maorif.tj
  /// is enough. This does not rewrite or overstate the separate rights record.
  bool get isDisplayable {
    if (textStatus != TextStatus.verified ||
        (!hasTajikText && !hasPersianText) ||
        !verification.pageVerified ||
        primarySource?.pageStart == null) {
      return false;
    }

    final traditionallyApproved =
        verification.isFullyVerified &&
        rights.status.allowsFullText &&
        rights.fullTextAllowed;
    return traditionallyApproved || isPermittedSourceAttested;
  }

  /// Whether a checked source satisfies the project's one-source policy.
  bool get isPermittedSourceAttested {
    const checkedLevels = {
      VerificationLevel.primaryChecked,
      VerificationLevel.secondWitnessLocated,
      VerificationLevel.collated,
      VerificationLevel.editoriallyApproved,
    };
    final reference = primarySource?.sourceReference?.trim() ?? '';
    if (!checkedLevels.contains(verification.evidenceLevel) ||
        reference.isEmpty) {
      return false;
    }

    final normalized = reference.replaceAll('\\', '/').toLowerCase();
    if (normalized.startsWith('docs/literature/pdfs/') ||
        normalized.startsWith('pdf books/')) {
      return normalized.endsWith('.pdf');
    }

    final uri = Uri.tryParse(reference);
    final host = uri?.host.toLowerCase();
    return uri?.scheme == 'https' &&
        (host == 'maorif.tj' || host?.endsWith('.maorif.tj') == true);
  }

  /// Whether a source-page facsimile may be bundled and shown to users.
  ///
  /// A page image is provenance evidence, not publication permission. Keep
  /// it unavailable until the work itself has passed the full editorial and
  /// rights gate.
  bool get isPageImageDisplayable =>
      isDisplayable && hasVerifiedPrimaryPageImage;

  /// Whether the primary witness has both an inspected image flag and a
  /// concrete local asset path. A flag without a path must never make the UI
  /// guess a filename or advertise a broken facsimile action.
  bool get hasVerifiedPrimaryPageImage {
    final source = primarySource;
    return source != null &&
        source.sourceImageVerified &&
        source.sourceImagePaths.isNotEmpty;
  }

  /// Whether this work can be shown as an excerpt.
  bool get isExcerptDisplayable =>
      isDisplayable ||
      (rights.excerptAllowed &&
          textStatus == TextStatus.verified &&
          (hasTajikText || hasPersianText));

  /// Whether verified Tajik Cyrillic text is present.
  bool get hasTajikText => textTajik != null && textTajik!.trim().isNotEmpty;

  /// Whether a genuine Persian Arabic source text is present.
  ///
  /// Returns false when [persianScriptSource] is "generated" — a mechanical
  /// Cyrillic→Arabic transliteration is NOT a source witness and must NOT
  /// be treated as equivalent to an original Persian text.
  bool get hasPersianText {
    if (persianScriptSource == 'generated') return false;
    return textPersian != null && textPersian!.trim().isNotEmpty;
  }

  /// Whether a Persian-script representation (including generated) exists for display.
  bool get hasPersianDisplay =>
      (textPersian != null && textPersian!.trim().isNotEmpty) ||
      (persianScriptRepresentation != null &&
          persianScriptRepresentation!.trim().isNotEmpty);

  /// Whether the shipped text is a coherent verse work rather than a fragment,
  /// one-word/single-line snippet, or a stitching of unrelated pages.
  ///
  /// Phase-2 audit rule: a source-attested "readable" item must be a genuine
  /// poem/work. A single bayt (<=2 hemistiches), a single-word text, and text
  /// carrying page/stitching markers (## N, "(Page N)", "***") all fail this
  /// check and must never ship as a readable work.
  ///
  /// Appended editorial noise is ignored before counting: a pure-parenthesis
  /// author attribution («(Лоиқ Шералӣ)») or an obvious truncated prose-gloss
  /// line (one ending in a bare preposition such as «... (тақдир, сарнавишт)
  /// дар») does not add a hemistich. Parenthetical text inside a genuine
  /// hemistich is preserved.
  bool get hasCoherentVerseStructure {
    final text = (textTajik ?? textPersian)?.trim() ?? '';
    if (text.isEmpty) return false;
    if (RegExp(r'##\s*\d+|\(Page \d+\)|\*\*\*').hasMatch(text)) return false;
    final lines = coherentVerseLines(text);
    if (lines.isEmpty) return false;
    final words = lines
        .join('\n')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (words <= 2) return false;
    return lines.length >= 3;
  }

  /// Whether composition metadata has a page-checked primary source.
  ///
  /// A date or context imported without a printed page is only a lead. Keep
  /// it out of user-facing literature records until an editor verifies the
  /// exact source location.
  bool get hasAuditableCompositionEvidence {
    final source = primarySource;
    final hasMetadata =
        (compositionDate?.trim().isNotEmpty ?? false) ||
        (compositionContext?.trim().isNotEmpty ?? false);
    return hasMetadata &&
        source != null &&
        source.pageStart != null &&
        verification.pageVerified;
  }

  /// Whether the pending record has enough primary-source location data to
  /// be safely named in a public review list.
  ///
  /// A title without both a source reference and a printed page is only an
  /// extraction lead. Keep it in the audit dataset, but do not present it as
  /// a source-backed work under an author's name.
  bool get hasAuditableReviewCitation {
    final source = primarySource;
    return source != null &&
        source.sourceReference?.trim().isNotEmpty == true &&
        source.pageStart != null;
  }

  /// Creates a [LiteraryWork] from a JSON map.
  factory LiteraryWork.fromJson(Map<String, dynamic> json) {
    final primaryJson = json['primarySource'] ?? json['primary_source'];
    final secondaryJson = json['secondarySource'] ?? json['secondary_source'];
    final rightsJson = json['rights'];
    final verificationJson = json['verification'];

    return LiteraryWork(
      id: (json['id'] ?? '') as String,
      authorId: (json['authorId'] ?? json['author_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      titlePersian: (json['titlePersian'] ?? json['title_persian']) as String?,
      titlePersianSource: json['titlePersianSource'] as String?,
      incipit: (json['incipit']) as String?,
      type: WorkType.fromString(json['type'] as String?),
      scriptSource: ScriptSource.fromString(
        (json['scriptSource'] ?? json['script_source']) as String?,
      ),
      textTajik: (json['textTajik'] ?? json['text_tajik']) as String?,
      textPersian: (json['textPersian'] ?? json['text_persian']) as String?,
      persianScriptRepresentation:
          json['persianScriptRepresentation'] as String?,
      persianScriptSource: json['persianScriptSource'] as String?,
      textStatus: TextStatus.fromString(
        (json['textStatus'] ?? json['text_status']) as String?,
      ),
      editorial: EditorialTransformation.fromString(
        json['editorial'] as String?,
      ),
      editorialNotes:
          (json['editorialNotes'] ?? json['editorial_notes']) as String?,
      primarySource: primaryJson is Map<String, dynamic>
          ? SourceEdition.fromJson(primaryJson)
          : null,
      secondarySource: secondaryJson is Map<String, dynamic>
          ? SourceEdition.fromJson(secondaryJson)
          : null,
      sourceOccurrences: _parseSourceList(json['sourceOccurrences']),
      textMatchResult:
          (json['textMatchResult'] ?? json['text_match_result']) as String?,
      variantNotes: (json['variantNotes'] ?? json['variant_notes']) as String?,
      compositionDate:
          (json['compositionDate'] ?? json['composition_date']) as String?,
      compositionContext:
          (json['compositionContext'] ?? json['composition_context'])
              as String?,
      rights: rightsJson is Map<String, dynamic>
          ? RightsRecord.fromJson(rightsJson)
          : const RightsRecord(
              status: RightsStatus.unknown,
              reasoning: 'Missing rights payload',
              fullTextAllowed: false,
              excerptAllowed: false,
            ),
      verification: verificationJson is Map<String, dynamic>
          ? VerificationRecord.fromJson(verificationJson)
          : const VerificationRecord(),
    );
  }

  /// Converts this [LiteraryWork] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'titlePersian': titlePersian,
      if (titlePersianSource != null) 'titlePersianSource': titlePersianSource,
      'incipit': incipit,
      'type': type.name,
      'scriptSource': scriptSource.name,
      'textTajik': textTajik,
      'textPersian': textPersian,
      if (persianScriptRepresentation != null)
        'persianScriptRepresentation': persianScriptRepresentation,
      if (persianScriptSource != null)
        'persianScriptSource': persianScriptSource,
      'textStatus': textStatus.name,
      'editorial': editorial.name,
      'editorialNotes': editorialNotes,
      'primarySource': primarySource?.toJson(),
      'secondarySource': secondarySource?.toJson(),
      if (sourceOccurrences.isNotEmpty)
        'sourceOccurrences': sourceOccurrences
            .map((source) => source.toJson())
            .toList(growable: false),
      'textMatchResult': textMatchResult,
      'variantNotes': variantNotes,
      if (compositionDate != null) 'compositionDate': compositionDate,
      if (compositionContext != null) 'compositionContext': compositionContext,
      'rights': rights.toJson(),
      'verification': verification.toJson(),
    };
  }

  /// Creates a copy of this [LiteraryWork] with given fields replaced.
  LiteraryWork copyWith({
    String? id,
    String? authorId,
    String? title,
    String? titlePersian,
    String? titlePersianSource,
    String? incipit,
    WorkType? type,
    ScriptSource? scriptSource,
    String? textTajik,
    String? textPersian,
    String? persianScriptRepresentation,
    String? persianScriptSource,
    TextStatus? textStatus,
    EditorialTransformation? editorial,
    String? editorialNotes,
    SourceEdition? primarySource,
    SourceEdition? secondarySource,
    List<SourceEdition>? sourceOccurrences,
    String? textMatchResult,
    String? variantNotes,
    String? compositionDate,
    String? compositionContext,
    RightsRecord? rights,
    VerificationRecord? verification,
  }) {
    return LiteraryWork(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      titlePersian: titlePersian ?? this.titlePersian,
      titlePersianSource: titlePersianSource ?? this.titlePersianSource,
      incipit: incipit ?? this.incipit,
      type: type ?? this.type,
      scriptSource: scriptSource ?? this.scriptSource,
      textTajik: textTajik ?? this.textTajik,
      textPersian: textPersian ?? this.textPersian,
      persianScriptRepresentation:
          persianScriptRepresentation ?? this.persianScriptRepresentation,
      persianScriptSource: persianScriptSource ?? this.persianScriptSource,
      textStatus: textStatus ?? this.textStatus,
      editorial: editorial ?? this.editorial,
      editorialNotes: editorialNotes ?? this.editorialNotes,
      primarySource: primarySource ?? this.primarySource,
      secondarySource: secondarySource ?? this.secondarySource,
      sourceOccurrences: sourceOccurrences ?? this.sourceOccurrences,
      textMatchResult: textMatchResult ?? this.textMatchResult,
      variantNotes: variantNotes ?? this.variantNotes,
      compositionDate: compositionDate ?? this.compositionDate,
      compositionContext: compositionContext ?? this.compositionContext,
      rights: rights ?? this.rights,
      verification: verification ?? this.verification,
    );
  }

  static List<SourceEdition> _parseSourceList(dynamic value) {
    if (value is! List) return const [];
    return List.unmodifiable(
      value.whereType<Map<String, dynamic>>().map(SourceEdition.fromJson),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiteraryWork &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LiteraryWork(id: $id, title: $title, authorId: $authorId, status: ${textStatus.name})';
  }
}
