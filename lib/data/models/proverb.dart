enum ProverbType { traditional, modernCustom }

enum SourceStatus { verified, unverified }

class Proverb {
  final String id;
  final String tajikCyrillic;
  final String persianText;
  final String simpleExplanationTj;
  final String meaningTj;
  final String exampleSentenceTj;
  final String categoryId;
  final int level;
  final ProverbType type;
  final SourceStatus sourceStatus;
  final String sourceNote;

  const Proverb({
    required this.id,
    required this.tajikCyrillic,
    required this.persianText,
    required this.simpleExplanationTj,
    required this.meaningTj,
    required this.exampleSentenceTj,
    required this.categoryId,
    required this.level,
    required this.type,
    required this.sourceStatus,
    required this.sourceNote,
  });

  Proverb copyWith({
    String? id,
    String? tajikCyrillic,
    String? persianText,
    String? simpleExplanationTj,
    String? meaningTj,
    String? exampleSentenceTj,
    String? categoryId,
    int? level,
    ProverbType? type,
    SourceStatus? sourceStatus,
    String? sourceNote,
  }) {
    return Proverb(
      id: id ?? this.id,
      tajikCyrillic: tajikCyrillic ?? this.tajikCyrillic,
      persianText: persianText ?? this.persianText,
      simpleExplanationTj: simpleExplanationTj ?? this.simpleExplanationTj,
      meaningTj: meaningTj ?? this.meaningTj,
      exampleSentenceTj: exampleSentenceTj ?? this.exampleSentenceTj,
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
      type: type ?? this.type,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      sourceNote: sourceNote ?? this.sourceNote,
    );
  }
}
