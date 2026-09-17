/// Verification levels representing explicit evidence levels for provenance.
enum VerificationLevel {
  /// Text was extracted from a textbook/PDF. Does NOT mean correct.
  extracted,

  /// Exact source book and page located.
  sourceLocated,

  /// Text manually/programmatically compared against primary page image/text with reliable evidence.
  primaryChecked,

  /// An independent second edition contains the work.
  secondWitnessLocated,

  /// The two witnesses were compared.
  collated,

  /// A real documented editorial review occurred.
  editoriallyApproved,

  /// Indicates the record requires review.
  rejected,
  needsReview;

  static VerificationLevel fromString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return VerificationLevel.needsReview;
    }
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    for (final status in VerificationLevel.values) {
      if (status.name.toLowerCase() == normalized) return status;
    }
    // Fallback mapping for old 'approved' -> extracted or something,
    // but the reset script sets everything to needsReview.
    if (normalized == 'approved') return VerificationLevel.extracted;
    return VerificationLevel.needsReview;
  }
}

/// Verification audit trail for a literary work enforcing strict epistemic provenance.
class VerificationRecord {
  /// The final appropriate stage that may be shown publicly.
  final VerificationLevel evidenceLevel;

  /// The method by which this check was performed, e.g. "automatedCandidateExtraction"
  final String? verificationMethod;

  /// Date when the verification was signed off (e.g. "YYYY-MM-DD").
  final String? verifiedAt;

  /// Whether the page numbers in the source edition were confirmed with evidence.
  final bool pageVerified;

  /// A reproducible reference to the inspected source material.
  final String? evidenceHash;

  /// Reason for rejection or needs review note.
  final String? rejectionReason;

  const VerificationRecord({
    this.evidenceLevel = VerificationLevel.needsReview,
    this.verificationMethod,
    this.verifiedAt,
    this.pageVerified = false,
    this.evidenceHash,
    this.rejectionReason,
  });

  bool get isFullyVerified =>
      evidenceLevel == VerificationLevel.editoriallyApproved;

  factory VerificationRecord.fromJson(Map<String, dynamic> json) {
    return VerificationRecord(
      evidenceLevel: VerificationLevel.fromString(
        json['evidenceLevel'] ?? json['finalStatus'] ?? json['status'],
      ),
      verificationMethod: json['verificationMethod'],
      verifiedAt: json['verifiedAt'] ?? json['verifiedDate'],
      pageVerified: _parseBool(json['pageVerified']),
      evidenceHash: json['evidenceHash'],
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evidenceLevel': evidenceLevel.name,
      'verificationMethod': verificationMethod,
      'verifiedAt': verifiedAt,
      'pageVerified': pageVerified,
      'evidenceHash': evidenceHash,
      'rejectionReason': rejectionReason,
    };
  }

  VerificationRecord copyWith({
    VerificationLevel? evidenceLevel,
    String? verificationMethod,
    String? verifiedAt,
    bool? pageVerified,
    String? evidenceHash,
    String? rejectionReason,
  }) {
    return VerificationRecord(
      evidenceLevel: evidenceLevel ?? this.evidenceLevel,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      pageVerified: pageVerified ?? this.pageVerified,
      evidenceHash: evidenceHash ?? this.evidenceHash,
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
          evidenceLevel == other.evidenceLevel &&
          verificationMethod == other.verificationMethod &&
          verifiedAt == other.verifiedAt &&
          pageVerified == other.pageVerified &&
          evidenceHash == other.evidenceHash &&
          rejectionReason == other.rejectionReason;

  @override
  int get hashCode => Object.hash(
    evidenceLevel,
    verificationMethod,
    verifiedAt,
    pageVerified,
    evidenceHash,
    rejectionReason,
  );

  @override
  String toString() {
    return 'VerificationRecord(level: ${evidenceLevel.name}, method: $verificationMethod)';
  }
}
