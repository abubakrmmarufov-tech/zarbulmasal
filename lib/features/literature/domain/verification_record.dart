/// Verification audit trail for a literary work.
///
/// Tracks the philological collation and editorial sign-off status.
enum VerificationStatus {
  approved,
  rejected,
  needsReview;

  /// Parses a string to [VerificationStatus] matching camelCase, snake_case, or kebab-case.
  ///
  /// Defaults to [VerificationStatus.needsReview] if null or unrecognised.
  static VerificationStatus fromString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return VerificationStatus.needsReview;
    }
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    for (final status in VerificationStatus.values) {
      if (status.name.toLowerCase() == normalized) {
        return status;
      }
    }
    return VerificationStatus.needsReview;
  }
}

/// Verification audit trail for a literary work.
///
/// Enforces dual-witness philological collation, orthographic checks,
/// copyright clearance, and editorial sign-off.
class VerificationRecord {
  /// Name or identifier of the editor who performed the verification.
  final String? verifiedBy;

  /// Date when the verification was signed off (e.g. "YYYY-MM-DD").
  final String? verifiedDate;

  /// Whether the primary Tier A source witness was verified.
  final bool primarySourceChecked;

  /// Whether a corroborating second source witness was verified.
  final bool secondSourceChecked;

  /// Whether the title was verified against the canonical edition.
  final bool titleChecked;

  /// Whether authorship attribution was verified.
  final bool authorshipChecked;

  /// Whether the page numbers in the source edition were confirmed.
  final bool pageChecked;

  /// Whether the text was collated line-by-line against the physical scan.
  final bool textLineByLineChecked;

  /// Whether Cyrillic diacritics and/or Persian Arabic orthography were audited.
  final bool scriptChecked;

  /// Whether copyright clearance was validated under Law No. 726.
  final bool copyrightChecked;

  /// Final editorial status.
  final VerificationStatus finalStatus;

  /// Reason for rejection if [finalStatus] is [VerificationStatus.rejected].
  final String? rejectionReason;

  const VerificationRecord({
    this.verifiedBy,
    this.verifiedDate,
    this.primarySourceChecked = false,
    this.secondSourceChecked = false,
    this.titleChecked = false,
    this.authorshipChecked = false,
    this.pageChecked = false,
    this.textLineByLineChecked = false,
    this.scriptChecked = false,
    this.copyrightChecked = false,
    this.finalStatus = VerificationStatus.needsReview,
    this.rejectionReason,
  });

  /// Convenience getter: returns true only when all 8 checks pass and status is approved.
  bool get isFullyVerified =>
      primarySourceChecked &&
      secondSourceChecked &&
      titleChecked &&
      authorshipChecked &&
      pageChecked &&
      textLineByLineChecked &&
      scriptChecked &&
      copyrightChecked &&
      finalStatus == VerificationStatus.approved;

  /// Creates a [VerificationRecord] from a JSON map.
  factory VerificationRecord.fromJson(Map<String, dynamic> json) {
    return VerificationRecord(
      verifiedBy: (json['verifiedBy'] ?? json['verified_by']) as String?,
      verifiedDate: (json['verifiedDate'] ?? json['verified_date']) as String?,
      primarySourceChecked: _parseBool(
        json['primarySourceChecked'] ?? json['primary_source_checked'],
      ),
      secondSourceChecked: _parseBool(
        json['secondSourceChecked'] ?? json['second_source_checked'],
      ),
      titleChecked: _parseBool(json['titleChecked'] ?? json['title_checked']),
      authorshipChecked: _parseBool(
        json['authorshipChecked'] ?? json['authorship_checked'],
      ),
      pageChecked: _parseBool(json['pageChecked'] ?? json['page_checked']),
      textLineByLineChecked: _parseBool(
        json['textLineByLineChecked'] ?? json['text_line_by_line_checked'],
      ),
      scriptChecked: _parseBool(
        json['scriptChecked'] ?? json['script_checked'],
      ),
      copyrightChecked: _parseBool(
        json['copyrightChecked'] ?? json['copyright_checked'],
      ),
      finalStatus: VerificationStatus.fromString(
        (json['finalStatus'] ?? json['final_status'] ?? json['status'])
            as String?,
      ),
      rejectionReason:
          (json['rejectionReason'] ?? json['rejection_reason']) as String?,
    );
  }

  /// Converts this [VerificationRecord] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'verifiedBy': verifiedBy,
      'verifiedDate': verifiedDate,
      'primarySourceChecked': primarySourceChecked,
      'secondSourceChecked': secondSourceChecked,
      'titleChecked': titleChecked,
      'authorshipChecked': authorshipChecked,
      'pageChecked': pageChecked,
      'textLineByLineChecked': textLineByLineChecked,
      'scriptChecked': scriptChecked,
      'copyrightChecked': copyrightChecked,
      'finalStatus': finalStatus.name,
      'rejectionReason': rejectionReason,
    };
  }

  /// Creates a copy of this [VerificationRecord] with the given fields replaced.
  VerificationRecord copyWith({
    String? verifiedBy,
    String? verifiedDate,
    bool? primarySourceChecked,
    bool? secondSourceChecked,
    bool? titleChecked,
    bool? authorshipChecked,
    bool? pageChecked,
    bool? textLineByLineChecked,
    bool? scriptChecked,
    bool? copyrightChecked,
    VerificationStatus? finalStatus,
    String? rejectionReason,
  }) {
    return VerificationRecord(
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedDate: verifiedDate ?? this.verifiedDate,
      primarySourceChecked: primarySourceChecked ?? this.primarySourceChecked,
      secondSourceChecked: secondSourceChecked ?? this.secondSourceChecked,
      titleChecked: titleChecked ?? this.titleChecked,
      authorshipChecked: authorshipChecked ?? this.authorshipChecked,
      pageChecked: pageChecked ?? this.pageChecked,
      textLineByLineChecked:
          textLineByLineChecked ?? this.textLineByLineChecked,
      scriptChecked: scriptChecked ?? this.scriptChecked,
      copyrightChecked: copyrightChecked ?? this.copyrightChecked,
      finalStatus: finalStatus ?? this.finalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
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
      other is VerificationRecord &&
          runtimeType == other.runtimeType &&
          verifiedBy == other.verifiedBy &&
          verifiedDate == other.verifiedDate &&
          primarySourceChecked == other.primarySourceChecked &&
          secondSourceChecked == other.secondSourceChecked &&
          titleChecked == other.titleChecked &&
          authorshipChecked == other.authorshipChecked &&
          pageChecked == other.pageChecked &&
          textLineByLineChecked == other.textLineByLineChecked &&
          scriptChecked == other.scriptChecked &&
          copyrightChecked == other.copyrightChecked &&
          finalStatus == other.finalStatus &&
          rejectionReason == other.rejectionReason;

  @override
  int get hashCode => Object.hash(
    verifiedBy,
    verifiedDate,
    primarySourceChecked,
    secondSourceChecked,
    titleChecked,
    authorshipChecked,
    pageChecked,
    textLineByLineChecked,
    scriptChecked,
    copyrightChecked,
    finalStatus,
    rejectionReason,
  );

  @override
  String toString() {
    return 'VerificationRecord(status: ${finalStatus.name}, isFullyVerified: $isFullyVerified, verifiedBy: $verifiedBy)';
  }
}
