import 'rights_record.dart';
import 'source_edition.dart';
import 'verification_record.dart';

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
/// Under editorial policy, newly created works MUST start with [needsReview]
/// until dual-witness collation is approved.
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
enum ScriptSource {
  tajikCyrillic,
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

  /// Collation result between witnesses (e.g. "exact", "minor-variant", "significant-variant").
  final String? textMatchResult;

  /// Detailed notes regarding variants between witnesses.
  final String? variantNotes;

  /// Rights and copyright clearance record.
  final RightsRecord rights;

  /// Philological verification and collation audit record.
  final VerificationRecord verification;

  const LiteraryWork({
    required this.id,
    required this.authorId,
    required this.title,
    this.titlePersian,
    this.incipit,
    this.type = WorkType.other,
    this.scriptSource = ScriptSource.tajikCyrillic,
    this.textTajik,
    this.textPersian,
    this.textStatus = TextStatus.needsReview,
    this.editorial = EditorialTransformation.none,
    this.editorialNotes,
    this.primarySource,
    this.secondarySource,
    this.textMatchResult,
    this.variantNotes,
    required this.rights,
    required this.verification,
  });

  /// A work is displayable only when verified AND rights permit full text.
  bool get isDisplayable =>
      verification.isFullyVerified &&
      rights.status.allowsFullText &&
      rights.fullTextAllowed &&
      textStatus == TextStatus.verified &&
      (hasTajikText || hasPersianText);

  /// Whether this work can be shown as an excerpt.
  bool get isExcerptDisplayable =>
      rights.excerptAllowed && textStatus != TextStatus.blocked;

  /// Whether verified Tajik Cyrillic text is present.
  bool get hasTajikText => textTajik != null && textTajik!.trim().isNotEmpty;

  /// Whether verified Persian Arabic text is present.
  bool get hasPersianText =>
      textPersian != null && textPersian!.trim().isNotEmpty;

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
      incipit: (json['incipit']) as String?,
      type: WorkType.fromString(json['type'] as String?),
      scriptSource: ScriptSource.fromString(
        (json['scriptSource'] ?? json['script_source']) as String?,
      ),
      textTajik: (json['textTajik'] ?? json['text_tajik']) as String?,
      textPersian: (json['textPersian'] ?? json['text_persian']) as String?,
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
      textMatchResult:
          (json['textMatchResult'] ?? json['text_match_result']) as String?,
      variantNotes: (json['variantNotes'] ?? json['variant_notes']) as String?,
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
      'incipit': incipit,
      'type': type.name,
      'scriptSource': scriptSource.name,
      'textTajik': textTajik,
      'textPersian': textPersian,
      'textStatus': textStatus.name,
      'editorial': editorial.name,
      'editorialNotes': editorialNotes,
      'primarySource': primarySource?.toJson(),
      'secondarySource': secondarySource?.toJson(),
      'textMatchResult': textMatchResult,
      'variantNotes': variantNotes,
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
    String? incipit,
    WorkType? type,
    ScriptSource? scriptSource,
    String? textTajik,
    String? textPersian,
    TextStatus? textStatus,
    EditorialTransformation? editorial,
    String? editorialNotes,
    SourceEdition? primarySource,
    SourceEdition? secondarySource,
    String? textMatchResult,
    String? variantNotes,
    RightsRecord? rights,
    VerificationRecord? verification,
  }) {
    return LiteraryWork(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      titlePersian: titlePersian ?? this.titlePersian,
      incipit: incipit ?? this.incipit,
      type: type ?? this.type,
      scriptSource: scriptSource ?? this.scriptSource,
      textTajik: textTajik ?? this.textTajik,
      textPersian: textPersian ?? this.textPersian,
      textStatus: textStatus ?? this.textStatus,
      editorial: editorial ?? this.editorial,
      editorialNotes: editorialNotes ?? this.editorialNotes,
      primarySource: primarySource ?? this.primarySource,
      secondarySource: secondarySource ?? this.secondarySource,
      textMatchResult: textMatchResult ?? this.textMatchResult,
      variantNotes: variantNotes ?? this.variantNotes,
      rights: rights ?? this.rights,
      verification: verification ?? this.verification,
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
