import 'history_epoch.dart';

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
  final String? capital;
  final String? capitalPersian;
  final String? territory;
  final String? territoryPersian;
  final List<String> keyFigures;
  final List<String> keyFiguresPersian;
  final String? significance;
  final String? significancePersian;
  final String? dates;
  final String? datesPersian;

  /// Related author IDs in the cultural knowledge graph.
  final List<String> relatedAuthorIds;

  /// Related literary work or poem IDs in the cultural knowledge graph.
  final List<String> relatedWorkIds;

  /// Chronological epoch of the entry.
  HistoryEpoch get epoch => HistoryEpoch.fromEntry(this);

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
    this.capital,
    this.capitalPersian,
    this.territory,
    this.territoryPersian,
    this.keyFigures = const [],
    this.keyFiguresPersian = const [],
    this.significance,
    this.significancePersian,
    this.dates,
    this.datesPersian,
    this.relatedAuthorIds = const [],
    this.relatedWorkIds = const [],
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
      capital: json['capital'] as String?,
      capitalPersian: json['capitalPersian'] as String?,
      territory: json['territory'] as String?,
      territoryPersian: json['territoryPersian'] as String?,
      keyFigures: (json['keyFigures'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      keyFiguresPersian: (json['keyFiguresPersian'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      significance: json['significance'] as String?,
      significancePersian: json['significancePersian'] as String?,
      dates: json['dates'] as String?,
      datesPersian: json['datesPersian'] as String?,
      relatedAuthorIds: (json['relatedAuthorIds'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      relatedWorkIds: (json['relatedWorkIds'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    if (titlePersian != null) 'titlePersian': titlePersian,
    'summary': summary,
    if (summaryPersian != null) 'summaryPersian': summaryPersian,
    'period': period,
    'grade': grade,
    'sourceBookId': sourceBookId,
    'sourceSection': sourceSection,
    'keywords': keywords,
    if (capital != null) 'capital': capital,
    if (capitalPersian != null) 'capitalPersian': capitalPersian,
    if (territory != null) 'territory': territory,
    if (territoryPersian != null) 'territoryPersian': territoryPersian,
    if (keyFigures.isNotEmpty) 'keyFigures': keyFigures,
    if (keyFiguresPersian.isNotEmpty) 'keyFiguresPersian': keyFiguresPersian,
    if (significance != null) 'significance': significance,
    if (significancePersian != null) 'significancePersian': significancePersian,
    if (dates != null) 'dates': dates,
    if (datesPersian != null) 'datesPersian': datesPersian,
    if (relatedAuthorIds.isNotEmpty) 'relatedAuthorIds': relatedAuthorIds,
    if (relatedWorkIds.isNotEmpty) 'relatedWorkIds': relatedWorkIds,
  };

  static HistoryEntryKind _kindFromString(String? value) {
    for (final kind in HistoryEntryKind.values) {
      if (kind.name == value) return kind;
    }
    return HistoryEntryKind.event;
  }
}
