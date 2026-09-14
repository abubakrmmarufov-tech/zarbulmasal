enum HistoryEntryKind { empire, person, event, place, poem, oral }

/// A short, source-bound research card distilled from a school history book.
class HistoryEntry {
  final String id;
  final HistoryEntryKind kind;
  final String title;
  final String? titlePersian;
  final String summary;
  final String? summaryPersian;
  final String period;
  final String grade;
  final String sourceBookId;
  final String sourceSection;
  final List<String> keywords;

  const HistoryEntry({
    required this.id,
    required this.kind,
    required this.title,
    this.titlePersian,
    required this.summary,
    this.summaryPersian,
    required this.period,
    required this.grade,
    required this.sourceBookId,
    required this.sourceSection,
    this.keywords = const [],
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String? ?? '',
      kind: _kindFromString(json['kind'] as String?),
      title: json['title'] as String? ?? '',
      titlePersian: json['titlePersian'] as String?,
      summary: json['summary'] as String? ?? '',
      summaryPersian: json['summaryPersian'] as String?,
      period: json['period'] as String? ?? '',
      grade: json['grade']?.toString() ?? '',
      sourceBookId: json['sourceBookId'] as String? ?? '',
      sourceSection: json['sourceSection'] as String? ?? '',
      keywords: (json['keywords'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'titlePersian': titlePersian,
    'summary': summary,
    'summaryPersian': summaryPersian,
    'period': period,
    'grade': grade,
    'sourceBookId': sourceBookId,
    'sourceSection': sourceSection,
    'keywords': keywords,
  };

  static HistoryEntryKind _kindFromString(String? value) {
    for (final kind in HistoryEntryKind.values) {
      if (kind.name == value) return kind;
    }
    return HistoryEntryKind.event;
  }
}
