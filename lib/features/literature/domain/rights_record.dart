/// Rights/copyright record for a literary author or work.
///
/// Determines what content the app is legally permitted to display under
/// the intellectual property laws of the Republic of Tajikistan (Law No. 726).
enum RightsStatus {
  publicDomain,
  permissionGranted,
  excerptOnly,
  folklore,
  blocked,
  unknown;

  /// Parses a string to [RightsStatus] matching camelCase, snake_case, or kebab-case.
  ///
  /// Falls back to [RightsStatus.unknown] if [value] is null or unrecognised.
  static RightsStatus fromString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return RightsStatus.unknown;
    }
    final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
    for (final status in RightsStatus.values) {
      if (status.name.toLowerCase() == normalized) {
        return status;
      }
    }
    return RightsStatus.unknown;
  }

  /// Whether this status allows full-text display.
  bool get allowsFullText =>
      this == RightsStatus.publicDomain ||
      this == RightsStatus.permissionGranted ||
      this == RightsStatus.folklore;

  /// Whether this status allows excerpt display.
  bool get allowsExcerpt =>
      this != RightsStatus.blocked && this != RightsStatus.unknown;
}

/// Rights/copyright record for a literary author or work.
///
/// Determines what content the app is legally permitted to display.
class RightsRecord {
  /// Year of the author's death (if applicable/known).
  final String? authorDeathYear;

  /// Legal copyright status under Tajik law.
  final RightsStatus status;

  /// Why this status was determined (legal rationale).
  final String reasoning;

  /// Legal citation (e.g. "Law No. 726, Art. 17").
  final String? rightsSource;

  /// Whether full-text display is permitted.
  final bool fullTextAllowed;

  /// Whether excerpt display is permitted.
  final bool excerptAllowed;

  /// If permission was granted, document or license reference.
  final String? permissionReference;

  const RightsRecord({
    this.authorDeathYear,
    required this.status,
    required this.reasoning,
    this.rightsSource,
    required this.fullTextAllowed,
    required this.excerptAllowed,
    this.permissionReference,
  });

  /// Creates a [RightsRecord] from a JSON map.
  factory RightsRecord.fromJson(Map<String, dynamic> json) {
    return RightsRecord(
      authorDeathYear: (json['authorDeathYear'] ?? json['author_death_year'])?.toString(),
      status: RightsStatus.fromString(
        (json['status'] ?? json['rights_status']) as String?,
      ),
      reasoning: (json['reasoning'] ?? '') as String,
      rightsSource: (json['rightsSource'] ?? json['rights_source']) as String?,
      fullTextAllowed: _parseBool(json['fullTextAllowed'] ?? json['full_text_allowed']),
      excerptAllowed: _parseBool(json['excerptAllowed'] ?? json['excerpt_allowed']),
      permissionReference: (json['permissionReference'] ?? json['permission_reference']) as String?,
    );
  }

  /// Converts this [RightsRecord] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'authorDeathYear': authorDeathYear,
      'status': status.name,
      'reasoning': reasoning,
      'rightsSource': rightsSource,
      'fullTextAllowed': fullTextAllowed,
      'excerptAllowed': excerptAllowed,
      'permissionReference': permissionReference,
    };
  }

  /// Creates a copy of this [RightsRecord] with the given fields replaced.
  RightsRecord copyWith({
    String? authorDeathYear,
    RightsStatus? status,
    String? reasoning,
    String? rightsSource,
    bool? fullTextAllowed,
    bool? excerptAllowed,
    String? permissionReference,
  }) {
    return RightsRecord(
      authorDeathYear: authorDeathYear ?? this.authorDeathYear,
      status: status ?? this.status,
      reasoning: reasoning ?? this.reasoning,
      rightsSource: rightsSource ?? this.rightsSource,
      fullTextAllowed: fullTextAllowed ?? this.fullTextAllowed,
      excerptAllowed: excerptAllowed ?? this.excerptAllowed,
      permissionReference: permissionReference ?? this.permissionReference,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RightsRecord &&
          runtimeType == other.runtimeType &&
          authorDeathYear == other.authorDeathYear &&
          status == other.status &&
          reasoning == other.reasoning &&
          rightsSource == other.rightsSource &&
          fullTextAllowed == other.fullTextAllowed &&
          excerptAllowed == other.excerptAllowed &&
          permissionReference == other.permissionReference;

  @override
  int get hashCode => Object.hash(
        authorDeathYear,
        status,
        reasoning,
        rightsSource,
        fullTextAllowed,
        excerptAllowed,
        permissionReference,
      );

  @override
  String toString() {
    return 'RightsRecord(status: ${status.name}, fullTextAllowed: $fullTextAllowed, excerptAllowed: $excerptAllowed, reasoning: $reasoning)';
  }
}
