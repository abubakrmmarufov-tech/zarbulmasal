/// The approved origin of a literary author's portrait.
enum PortraitSourceType { uploadedBook, userProvidedPhoto, maorifTj }

extension PortraitSourceTypeParsing on PortraitSourceType {
  String get wireName {
    switch (this) {
      case PortraitSourceType.uploadedBook:
        return 'uploaded_book';
      case PortraitSourceType.userProvidedPhoto:
        return 'user_provided_photo';
      case PortraitSourceType.maorifTj:
        return 'maorif_tj';
    }
  }

  static PortraitSourceType? fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'uploaded_book':
      case 'uploadedbook':
        return PortraitSourceType.uploadedBook;
      case 'user_provided_photo':
      case 'userprovidedphoto':
        return PortraitSourceType.userProvidedPhoto;
      case 'maorif_tj':
      case 'maorif.tj':
        return PortraitSourceType.maorifTj;
      default:
        return null;
    }
  }
}

/// A local, source-backed portrait with enough information to audit it.
///
/// Portraits are deliberately local assets. A remote URL is not accepted as
/// an image source because it would make the Literature experience mutable and
/// would hide provenance behind an unavailable network request.
class PortraitRecord {
  final String assetPath;
  final PortraitSourceType sourceType;
  final String sourceReference;
  final int sourcePage;
  final String? sourceNote;
  final String rightsStatus;

  const PortraitRecord({
    required this.assetPath,
    required this.sourceType,
    required this.sourceReference,
    required this.sourcePage,
    this.sourceNote,
    this.rightsStatus = 'unknown',
  });

  /// A record is renderable only when both its asset and source citation are
  /// scoped to the portrait/source registries.
  bool get isSourceBacked {
    final assetIsLocal = assetPath.startsWith(
      'assets/data/literature/portraits/',
    );
    final referenceIsApproved =
        sourceReference.startsWith('docs/literature/pdfs/') ||
        sourceReference.startsWith('https://maorif.tj/');
    return assetIsLocal &&
        referenceIsApproved &&
        sourcePage > 0 &&
        sourceReference.trim().isNotEmpty;
  }

  /// Rights values recorded as cleared (none of the bundled records today).
  static const Set<String> clearedRightsStatuses = {
    'publicDomain',
    'permissionGranted',
    'cleared',
  };

  bool get isRightsCleared => clearedRightsStatuses.contains(rightsStatus);

  /// Whether the portrait is shown. The owner decided (24 Sep 2026) that
  /// portraits printed in the official textbooks or on maorif.tj — the two
  /// approved sources — are shown with their book and page; [rightsStatus]
  /// stays as recorded and is not implied to be cleared.
  bool get isDisplayable => isSourceBacked;

  String get citation {
    final sourceName = sourceReference.split('/').last;
    return '$sourceName, PDF p. $sourcePage';
  }

  factory PortraitRecord.fromJson(Map<String, dynamic> json) {
    return PortraitRecord(
      assetPath: (json['assetPath'] ?? json['asset_path'] ?? '') as String,
      sourceType:
          PortraitSourceTypeParsing.fromString(
            (json['sourceType'] ?? json['source_type']) as String?,
          ) ??
          PortraitSourceType.uploadedBook,
      sourceReference:
          (json['sourceReference'] ?? json['source_reference'] ?? '') as String,
      sourcePage: _parsePage(json['sourcePage'] ?? json['source_page']),
      sourceNote: (json['sourceNote'] ?? json['source_note']) as String?,
      rightsStatus:
          (json['rightsStatus'] ?? json['rights_status'] ?? 'unknown')
              as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetPath': assetPath,
      'sourceType': sourceType.wireName,
      'sourceReference': sourceReference,
      'sourcePage': sourcePage,
      if (sourceNote != null) 'sourceNote': sourceNote,
      'rightsStatus': rightsStatus,
    };
  }

  PortraitRecord copyWith({
    String? assetPath,
    PortraitSourceType? sourceType,
    String? sourceReference,
    int? sourcePage,
    String? sourceNote,
    String? rightsStatus,
  }) {
    return PortraitRecord(
      assetPath: assetPath ?? this.assetPath,
      sourceType: sourceType ?? this.sourceType,
      sourceReference: sourceReference ?? this.sourceReference,
      sourcePage: sourcePage ?? this.sourcePage,
      sourceNote: sourceNote ?? this.sourceNote,
      rightsStatus: rightsStatus ?? this.rightsStatus,
    );
  }

  static int _parsePage(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortraitRecord &&
          assetPath == other.assetPath &&
          sourceType == other.sourceType &&
          sourceReference == other.sourceReference &&
          sourcePage == other.sourcePage &&
          sourceNote == other.sourceNote &&
          rightsStatus == other.rightsStatus;

  @override
  int get hashCode => Object.hash(
    assetPath,
    sourceType,
    sourceReference,
    sourcePage,
    sourceNote,
    rightsStatus,
  );
}
