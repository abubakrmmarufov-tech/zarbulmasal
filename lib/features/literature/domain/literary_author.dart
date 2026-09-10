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

  /// List of IDs of major canonical works by this author.
  final List<String> majorWorkIds;

  /// Official state and academic honors (e.g. "Шоири халқии Тоҷикистон", "Қаҳрамони Тоҷикистон").
  final List<String> officialTitles;

  /// School curriculum grades where this author's works are taught (e.g. ["5", "8", "10"]).
  final List<String> educationGrades;

  /// Intellectual property and copyright clearance record.
  final RightsRecord rights;

  const LiteraryAuthor({
    required this.id,
    required this.canonicalName,
    this.canonicalNamePersian,
    this.aliases = const [],
    this.birthYear,
    this.deathYear,
    this.birthPlace,
    required this.literaryPeriod,
    required this.biographyTj,
    this.biographyFa,
    required this.biographySource,
    this.majorWorkIds = const [],
    this.officialTitles = const [],
    this.educationGrades = const [],
    required this.rights,
  });

  /// Whether the author is deceased.
  bool get isDeceased => deathYear != null && deathYear!.trim().isNotEmpty;

  /// Formatted lifespan representation (e.g. "858 – 941", "1947 – ҳоло").
  String get lifespan {
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
      canonicalName: (json['canonicalName'] ?? json['canonical_name'] ?? '') as String,
      canonicalNamePersian: (json['canonicalNamePersian'] ?? json['canonical_name_persian']) as String?,
      aliases: _parseStringList(json['aliases']),
      birthYear: (json['birthYear'] ?? json['birth_year'])?.toString(),
      deathYear: (json['deathYear'] ?? json['death_year'])?.toString(),
      birthPlace: (json['birthPlace'] ?? json['birth_place']) as String?,
      literaryPeriod: (json['literaryPeriod'] ?? json['literary_period'] ?? '') as String,
      biographyTj: (json['biographyTj'] ?? json['biography_tj'] ?? '') as String,
      biographyFa: (json['biographyFa'] ?? json['biography_fa']) as String?,
      biographySource: (json['biographySource'] ?? json['biography_source'] ?? '') as String,
      majorWorkIds: _parseStringList(json['majorWorkIds'] ?? json['major_work_ids']),
      officialTitles: _parseStringList(json['officialTitles'] ?? json['official_titles']),
      educationGrades: _parseStringList(json['educationGrades'] ?? json['education_grades']),
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
      'birthPlace': birthPlace,
      'literaryPeriod': literaryPeriod,
      'biographyTj': biographyTj,
      'biographyFa': biographyFa,
      'biographySource': biographySource,
      'majorWorkIds': majorWorkIds,
      'officialTitles': officialTitles,
      'educationGrades': educationGrades,
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
    String? birthPlace,
    String? literaryPeriod,
    String? biographyTj,
    String? biographyFa,
    String? biographySource,
    List<String>? majorWorkIds,
    List<String>? officialTitles,
    List<String>? educationGrades,
    RightsRecord? rights,
  }) {
    return LiteraryAuthor(
      id: id ?? this.id,
      canonicalName: canonicalName ?? this.canonicalName,
      canonicalNamePersian: canonicalNamePersian ?? this.canonicalNamePersian,
      aliases: aliases ?? this.aliases,
      birthYear: birthYear ?? this.birthYear,
      deathYear: deathYear ?? this.deathYear,
      birthPlace: birthPlace ?? this.birthPlace,
      literaryPeriod: literaryPeriod ?? this.literaryPeriod,
      biographyTj: biographyTj ?? this.biographyTj,
      biographyFa: biographyFa ?? this.biographyFa,
      biographySource: biographySource ?? this.biographySource,
      majorWorkIds: majorWorkIds ?? this.majorWorkIds,
      officialTitles: officialTitles ?? this.officialTitles,
      educationGrades: educationGrades ?? this.educationGrades,
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
