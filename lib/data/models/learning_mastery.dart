enum MasteryLevel {
  unseen,
  again,
  learning,
  mastered,
}

class ProverbMastery {
  final String proverbId;
  final MasteryLevel level;
  final int reviewCount;
  final int correctCount;
  final DateTime lastReviewedAt;

  const ProverbMastery({
    required this.proverbId,
    required this.level,
    this.reviewCount = 0,
    this.correctCount = 0,
    required this.lastReviewedAt,
  });

  Map<String, dynamic> toJson() => {
    'proverbId': proverbId,
    'level': level.name,
    'reviewCount': reviewCount,
    'correctCount': correctCount,
    'lastReviewedAt': lastReviewedAt.toIso8601String(),
  };

  factory ProverbMastery.fromJson(Map<String, dynamic> json) {
    return ProverbMastery(
      proverbId: json['proverbId'] as String? ?? '',
      level: MasteryLevel.values.firstWhere(
        (l) => l.name == (json['level'] as String?),
        orElse: () => MasteryLevel.unseen,
      ),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      lastReviewedAt:
          DateTime.tryParse(json['lastReviewedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  ProverbMastery copyWith({
    String? proverbId,
    MasteryLevel? level,
    int? reviewCount,
    int? correctCount,
    DateTime? lastReviewedAt,
  }) {
    return ProverbMastery(
      proverbId: proverbId ?? this.proverbId,
      level: level ?? this.level,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProverbMastery &&
          runtimeType == other.runtimeType &&
          proverbId == other.proverbId &&
          level == other.level &&
          reviewCount == other.reviewCount &&
          correctCount == other.correctCount &&
          lastReviewedAt == other.lastReviewedAt;

  @override
  int get hashCode =>
      proverbId.hashCode ^
      level.hashCode ^
      reviewCount.hashCode ^
      correctCount.hashCode ^
      lastReviewedAt.hashCode;
}
