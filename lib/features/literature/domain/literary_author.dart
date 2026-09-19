import 'rights_record.dart';

/// A verified literary author in the Tajik literary canon.
///
/// Contains canonical biographical metadata, curriculum grade associations,
/// and rights clearance records.
class LiteraryAuthor {
  /// Unique identifier (e.g. "rudaki", "kamol-khujandi", "tursunzoda").
  final String id;

  /// Canonical name in Tajik Cyrillic (e.g. "Абӯабдуллоҳи Рӯдакӣ").
  final String canonicalName;

  /// Canonical name in Persian Arabic script if verified (e.g. "ابوعبدالله رودکی").
  final String? canonicalNamePersian;

  /// Alternative names, pen names (takhallus), and orthographic variations.
  final List<String> aliases;

  /// Birth year or approximate period (e.g. "858", "c. 1320", "1911").
  final String? birthYear;

  /// Death year or approximate period (e.g. "941", "1977", null if living).
  final String? deathYear;

  /// Exact birth date if attested (e.g. "15.04.1878", "20 майи 1941").
  final String? birthDateExact;

  /// Exact death date if attested (e.g. "15.07.1954", "30 июни 2000").
  final String? deathDateExact;

  /// Verified place of birth (e.g. "Рӯдак, Панҷрӯд (ҳоло Панҷакент)").
  final String? birthPlace;

  /// Literary epoch (e.g. "Асри тиллоӣ (IX–X)", "Шӯравӣ", "Истиқлолият").
  final String literaryPeriod;

  /// Sourced biographical narrative in Tajik Cyrillic.
  final String biographyTj;

  /// Optional biographical narrative in Persian Arabic script.
  final String? biographyFa;

  /// Authoritative citation for biographical facts (Tier A / Tier B source).
  final String biographySource;

  /// Epistemic category for the Tajik biography paragraph.
  ///
  /// Supported values are SOURCE_BACKED, EDITORIAL_SUMMARY_FROM_SOURCES, and
  /// UNSUPPORTED_GENERATED.  Unsupported biographies are kept empty in the
  /// active record and may carry a quarantine note for audit purposes.
  final String biographyTjProvenance;

  /// Epistemic category for the Persian biography paragraph.
  ///
  /// Supported values are SOURCE_PERSIAN, SOURCE_TRANSLATION,
  /// EDITORIAL_TRANSLATION, and UNSUPPORTED_GENERATED.
  final String biographyFaProvenance;

  /// Optional note explaining why an unsupported paragraph was quarantined.
  final String? biographyQuarantineNote;

  /// List of IDs of major canonical works by this author.
  final List<String> majorWorkIds;

  /// Official state and academic honors (e.g. "Шоири халқии Тоҷикистон", "Қаҳрамони Тоҷикистон").
  final List<String> officialTitles;

  /// School curriculum grades where this author's works are taught (e.g. ["5", "8", "10"]).
  final List<String> educationGrades;

  /// Related history entries in the cultural knowledge graph.
  final List<String> relatedHistoryEntryIds;

  /// Intellectual property and copyright clearance record.
  final RightsRecord rights;

  const LiteraryAuthor({
    required this.id,
    required this.canonicalName,
    this.canonicalNamePersian,
    this.aliases = const [],
    this.birthYear,
    this.deathYear,
    this.birthDateExact,
    this.deathDateExact,
    this.birthPlace,
    required this.literaryPeriod,
    required this.biographyTj,
    this.biographyFa,
    required this.biographySource,
    this.biographyTjProvenance = 'EDITORIAL_SUMMARY_FROM_SOURCES',
    this.biographyFaProvenance = 'EDITORIAL_TRANSLATION',
    this.biographyQuarantineNote,
    this.majorWorkIds = const [],
    this.officialTitles = const [],
    this.educationGrades = const [],
    this.relatedHistoryEntryIds = const [],
    required this.rights,
  });

  /// Whether the author is deceased.
  bool get isDeceased =>
      (deathYear != null && deathYear!.trim().isNotEmpty) ||
      (deathDateExact != null && deathDateExact!.trim().isNotEmpty);

  /// Whether this record has a name safe to show as a public-facing author.
  ///
  /// Import pipelines may retain an unresolved placeholder while provenance
  /// work is in progress. Such records stay available for internal review but
  /// must not appear as if "Unknown" were a verified poet.
  bool get hasCanonicalName {
    final name = canonicalName.trim().toLowerCase();
    return name.isNotEmpty && name != 'unknown';
  }

  /// Whether the biography citation names a printed page that can be audited.
  ///
  /// A book title or a vague collection label is useful as a lead, but it is
  /// not enough to present the biography as page-verified textbook evidence.
  bool get hasAuditableBiographySource {
    final source = biographySource.trim();
    return RegExp(
      r'(?:с\.|ص\.|page)\s*\d+',
      caseSensitive: false,
    ).hasMatch(source);
  }

  /// Formatted lifespan representation (e.g. "15.04.1878 – 15.07.1954" or "858 – 941", "1947 – ҳоло").
  String get lifespan {
    final bExact = birthDateExact?.trim() ?? '';
    final dExact = deathDateExact?.trim() ?? '';
    if (bExact.isNotEmpty || dExact.isNotEmpty) {
      if (dExact.isEmpty) return '$bExact – дар ҳаёт';
      if (bExact.isEmpty) return 'Вафот: $dExact';
      return '$bExact – $dExact';
    }
    final b = birthYear?.trim() ?? '';
    final d = deathYear?.trim() ?? '';
    if (b.isEmpty && d.isEmpty) return '';
    if (d.isEmpty) return '$b – дар ҳаёт';
    if (b.isEmpty) return 'Вафот: $d';
    return '$b – $d';
  }

  /// Whether works by this author are in the public domain.
  bool get isPublicDomain => rights.status == RightsStatus.publicDomain;

  /// Creates a [LiteraryAuthor] from a JSON map.
  factory LiteraryAuthor.fromJson(Map<String, dynamic> json) {
    final rightsJson = json['rights'];
    return LiteraryAuthor(
      id: (json['id'] ?? '') as String,
      canonicalName:
          (json['canonicalName'] ?? json['canonical_name'] ?? '') as String,
      canonicalNamePersian:
          (json['canonicalNamePersian'] ?? json['canonical_name_persian'])
              as String?,
      aliases: _parseStringList(json['aliases']),
      birthYear: (json['birthYear'] ?? json['birth_year'])?.toString(),
      deathYear: (json['deathYear'] ?? json['death_year'])?.toString(),
      birthDateExact: (json['birthDateExact'] ?? json['birth_date_exact'])
          ?.toString(),
      deathDateExact: (json['deathDateExact'] ?? json['death_date_exact'])
          ?.toString(),
      birthPlace: (json['birthPlace'] ?? json['birth_place']) as String?,
      literaryPeriod:
          (json['literaryPeriod'] ?? json['literary_period'] ?? '') as String,
      biographyTj:
          (json['biographyTj'] ?? json['biography_tj'] ?? '') as String,
      biographyFa: (json['biographyFa'] ?? json['biography_fa']) as String?,
      biographySource:
          (json['biographySource'] ?? json['biography_source'] ?? '') as String,
      biographyTjProvenance:
          (json['biographyTjProvenance'] ?? 'EDITORIAL_SUMMARY_FROM_SOURCES')
              as String,
      biographyFaProvenance:
          (json['biographyFaProvenance'] ?? 'EDITORIAL_TRANSLATION') as String,
      biographyQuarantineNote: json['biographyQuarantineNote'] as String?,
      majorWorkIds: _parseStringList(
        json['majorWorkIds'] ?? json['major_work_ids'],
      ),
      officialTitles: _parseStringList(
        json['officialTitles'] ?? json['official_titles'],
      ),
      educationGrades: _parseStringList(
        json['educationGrades'] ?? json['education_grades'],
      ),
      relatedHistoryEntryIds: _parseStringList(
        json['relatedHistoryEntryIds'] ?? json['related_history_entry_ids'],
      ),
      rights: rightsJson is Map<String, dynamic>
          ? RightsRecord.fromJson(rightsJson)
          : const RightsRecord(
              status: RightsStatus.unknown,
              reasoning: 'Missing rights payload',
              fullTextAllowed: false,
              excerptAllowed: false,
            ),
    );
  }

  /// Converts this [LiteraryAuthor] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'canonicalName': canonicalName,
      'canonicalNamePersian': canonicalNamePersian,
      'aliases': aliases,
      'birthYear': birthYear,
      'deathYear': deathYear,
      if (birthDateExact != null) 'birthDateExact': birthDateExact,
      if (deathDateExact != null) 'deathDateExact': deathDateExact,
      'birthPlace': birthPlace,
      'literaryPeriod': literaryPeriod,
      'biographyTj': biographyTj,
      'biographyFa': biographyFa,
      'biographySource': biographySource,
      'biographyTjProvenance': biographyTjProvenance,
      'biographyFaProvenance': biographyFaProvenance,
      if (biographyQuarantineNote != null)
        'biographyQuarantineNote': biographyQuarantineNote,
      'majorWorkIds': majorWorkIds,
      'officialTitles': officialTitles,
      'educationGrades': educationGrades,
      if (relatedHistoryEntryIds.isNotEmpty)
        'relatedHistoryEntryIds': relatedHistoryEntryIds,
      'rights': rights.toJson(),
    };
  }

  /// Creates a copy of this [LiteraryAuthor] with given fields replaced.
  LiteraryAuthor copyWith({
    String? id,
    String? canonicalName,
    String? canonicalNamePersian,
    List<String>? aliases,
    String? birthYear,
    String? deathYear,
    String? birthDateExact,
    String? deathDateExact,
    String? birthPlace,
    String? literaryPeriod,
    String? biographyTj,
    String? biographyFa,
    String? biographySource,
    String? biographyTjProvenance,
    String? biographyFaProvenance,
    String? biographyQuarantineNote,
    List<String>? majorWorkIds,
    List<String>? officialTitles,
    List<String>? educationGrades,
    List<String>? relatedHistoryEntryIds,
    RightsRecord? rights,
  }) {
    return LiteraryAuthor(
      id: id ?? this.id,
      canonicalName: canonicalName ?? this.canonicalName,
      canonicalNamePersian: canonicalNamePersian ?? this.canonicalNamePersian,
      aliases: aliases ?? this.aliases,
      birthYear: birthYear ?? this.birthYear,
      deathYear: deathYear ?? this.deathYear,
      birthDateExact: birthDateExact ?? this.birthDateExact,
      deathDateExact: deathDateExact ?? this.deathDateExact,
      birthPlace: birthPlace ?? this.birthPlace,
      literaryPeriod: literaryPeriod ?? this.literaryPeriod,
      biographyTj: biographyTj ?? this.biographyTj,
      biographyFa: biographyFa ?? this.biographyFa,
      biographySource: biographySource ?? this.biographySource,
      biographyTjProvenance:
          biographyTjProvenance ?? this.biographyTjProvenance,
      biographyFaProvenance:
          biographyFaProvenance ?? this.biographyFaProvenance,
      biographyQuarantineNote:
          biographyQuarantineNote ?? this.biographyQuarantineNote,
      majorWorkIds: majorWorkIds ?? this.majorWorkIds,
      officialTitles: officialTitles ?? this.officialTitles,
      educationGrades: educationGrades ?? this.educationGrades,
      relatedHistoryEntryIds:
          relatedHistoryEntryIds ?? this.relatedHistoryEntryIds,
      rights: rights ?? this.rights,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiteraryAuthor &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LiteraryAuthor(id: $id, canonicalName: $canonicalName, period: $literaryPeriod)';
  }
}
