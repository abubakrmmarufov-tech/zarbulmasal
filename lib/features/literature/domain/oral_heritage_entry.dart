import 'verification_record.dart';
import 'rights_record.dart';

/// Folklore genres of the Tajik oral literary tradition.
enum OralHeritageType {
  zarbulmasal,
  maqol,
  chiston,
  dubaytiKhalqi,
  rubaiKhalqi,
  afsona,
  other;

  /// Parses a string into [OralHeritageType] matching camelCase, snake_case, or kebab-case.
  static OralHeritageType fromString(String? value) {
    if (value == null || value.trim().isEmpty) return OralHeritageType.other;
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    for (final type in OralHeritageType.values) {
      if (type.name.toLowerCase() == normalized) return type;
    }
    return OralHeritageType.other;
  }
}

/// An entry from the Tajik oral literary heritage.
///
/// Encapsulates proverbs, sayings, riddles, folk dubaytis, and folk tales
/// collected and recorded by academic folklorists.
class OralHeritageEntry {
  /// Unique entry identifier (e.g. "folk-maqol-001").
  final String id;

  /// Folklore text in Tajik Cyrillic.
  final String text;

  /// Folklore text in Persian Arabic script (if verified).
  final String? textPersian;

  /// Folklore genre type.
  final OralHeritageType type;

  /// Regional origin or dialect zone (e.g. "Бадахшон", "Кӯлоб", "Суғд", "Ҳисор").
  final String? region;

  /// Published collection or archive title (e.g. "Фолкори тоҷик", "Зарбулмасалҳои тоҷикӣ").
  final String collectionSource;

  /// Field folklorist or researcher who recorded the entry (e.g. "Б. Шермуҳаммадов").
  final String? collector;

  /// Publishing house (e.g. "Дониш", "Ирфон").
  final String publisher;

  /// Publication year of the collection.
  final String year;

  /// Page or item number in the printed volume.
  final String? page;

  /// Verification and audit record confirming source fidelity.
  final VerificationRecord verification;

  /// Copyright and publication clearance for this recorded entry.
  final RightsRecord rights;

  const OralHeritageEntry({
    required this.id,
    required this.text,
    this.textPersian,
    required this.type,
    this.region,
    required this.collectionSource,
    this.collector,
    required this.publisher,
    required this.year,
    this.page,
    required this.verification,
    required this.rights,
  });

  /// Whether this folklore entry has passed full verification audit.
  bool get isVerified =>
      verification.finalStatus == VerificationStatus.approved;

  /// Whether this entry is both verified and cleared for full-text display.
  bool get isDisplayable =>
      isVerified && rights.status.allowsFullText && rights.fullTextAllowed;

  /// Formatted source citation.
  String get citation {
    final buffer = StringBuffer();
    if (collector != null && collector!.trim().isNotEmpty) {
      buffer.write('${collector!.trim()}. ');
    }
    buffer.write(collectionSource.trim());
    buffer.write(' — $publisher, $year.');
    if (page != null && page!.trim().isNotEmpty) {
      buffer.write(' — с. ${page!.trim()}.');
    }
    return buffer.toString();
  }

  /// Creates an [OralHeritageEntry] from a JSON map.
  factory OralHeritageEntry.fromJson(Map<String, dynamic> json) {
    final verificationJson = json['verification'];
    return OralHeritageEntry(
      id: (json['id'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      textPersian: (json['textPersian'] ?? json['text_persian']) as String?,
      type: OralHeritageType.fromString((json['type']) as String?),
      region: (json['region']) as String?,
      collectionSource:
          (json['collectionSource'] ?? json['collection_source'] ?? '')
              as String,
      collector: (json['collector']) as String?,
      publisher: (json['publisher'] ?? '') as String,
      year: (json['year'] ?? '').toString(),
      page: (json['page'])?.toString(),
      verification: verificationJson is Map<String, dynamic>
          ? VerificationRecord.fromJson(verificationJson)
          : const VerificationRecord(),
      rights: json['rights'] is Map<String, dynamic>
          ? RightsRecord.fromJson(json['rights'] as Map<String, dynamic>)
          : const RightsRecord(
              status: RightsStatus.unknown,
              reasoning: 'Missing rights payload',
              fullTextAllowed: false,
              excerptAllowed: false,
            ),
    );
  }

  /// Converts this [OralHeritageEntry] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'textPersian': textPersian,
      'type': type.name,
      'region': region,
      'collectionSource': collectionSource,
      'collector': collector,
      'publisher': publisher,
      'year': year,
      'page': page,
      'verification': verification.toJson(),
      'rights': rights.toJson(),
    };
  }

  /// Creates a copy of this [OralHeritageEntry] with given fields replaced.
  OralHeritageEntry copyWith({
    String? id,
    String? text,
    String? textPersian,
    OralHeritageType? type,
    String? region,
    String? collectionSource,
    String? collector,
    String? publisher,
    String? year,
    String? page,
    VerificationRecord? verification,
    RightsRecord? rights,
  }) {
    return OralHeritageEntry(
      id: id ?? this.id,
      text: text ?? this.text,
      textPersian: textPersian ?? this.textPersian,
      type: type ?? this.type,
      region: region ?? this.region,
      collectionSource: collectionSource ?? this.collectionSource,
      collector: collector ?? this.collector,
      publisher: publisher ?? this.publisher,
      year: year ?? this.year,
      page: page ?? this.page,
      verification: verification ?? this.verification,
      rights: rights ?? this.rights,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OralHeritageEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OralHeritageEntry(id: $id, type: ${type.name}, text: $text)';
  }
}
