import 'history_epoch.dart';
import 'history_section.dart';

const _verifiedClaimStatus = 'VERIFIED_UPLOADED_BOOK_PAGE';
const _sourceLocatedClaimStatus = 'SOURCE_LOCATED';
const _needsReviewClaimStatus = 'NEEDS_REVIEW';

enum HistoryEntryKind {
  empire,
  dynasty,
  ruler,
  person,
  event,
  battle,
  place,
  cultural,
  poem,
  oral,
}

/// A historical claim with explicit evidence state.
class HistoryClaimProvenance {
  final String claim;
  final String? claimPersian;
  final String sourceBookId;
  final int? printedPage;
  final int? pdfPage;
  final String _rawStatus;
  final String? statusNote;

  /// Returns only a status the renderer and validators understand.
  String get status => _normalizedStatus(_rawStatus);

  const HistoryClaimProvenance({
    required this.claim,
    this.claimPersian,
    required this.sourceBookId,
    this.printedPage,
    this.pdfPage,
    String status = _needsReviewClaimStatus,
    this.statusNote,
  }) : _rawStatus = status;

  factory HistoryClaimProvenance.fromJson(Map<String, dynamic> json) {
    return HistoryClaimProvenance(
      claim: json['claim'] as String? ?? '',
      claimPersian: json['claimPersian'] as String?,
      sourceBookId: json['sourceBookId'] as String? ?? '',
      printedPage: (json['printedPage'] as num?)?.toInt(),
      pdfPage: (json['pdfPage'] as num?)?.toInt(),
      status: _normalizedStatus(json['status']),
      statusNote: json['statusNote'] as String?,
    );
  }

  static String _normalizedStatus(Object? value) {
    if (value is! String) return _needsReviewClaimStatus;
    return switch (value.trim()) {
      _verifiedClaimStatus => _verifiedClaimStatus,
      _sourceLocatedClaimStatus => _sourceLocatedClaimStatus,
      _needsReviewClaimStatus => _needsReviewClaimStatus,
      _ => _needsReviewClaimStatus,
    };
  }

  Map<String, dynamic> toJson() => {
    'claim': claim,
    if (claimPersian != null) 'claimPersian': claimPersian,
    'sourceBookId': sourceBookId,
    if (printedPage != null) 'printedPage': printedPage,
    if (pdfPage != null) 'pdfPage': pdfPage,
    'status': status,
    if (statusNote != null) 'statusNote': statusNote,
  };
}

/// A structured, source-bound historical research entity distilled from
/// official school textbooks and curriculum records.
class HistoryEntry {
  final String id;
  final HistoryEntryKind kind;
  final String title;
  final String? titlePersian;
  final String summary;
  final String? summaryPersian;
  final String period;
  final String? periodPersian;
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

  // Enriched historical depth fields
  final String? founder;
  final String? founderPersian;
  final List<String> rulers;
  final List<String> rulersPersian;
  final String? predecessor;
  final String? successor;
  final String? religion;
  final String? religionPersian;
  final String? origins;
  final String? originsPersian;
  final String? culture;
  final String? culturePersian;
  final String? decline;
  final String? declinePersian;

  /// Related author IDs in the cultural knowledge graph.
  final List<String> relatedAuthorIds;

  /// Related literary work or poem IDs in the cultural knowledge graph.
  final List<String> relatedWorkIds;

  /// Related history entry IDs forming the interconnected graph.
  final List<String> relatedEntryIds;

  /// Claim-level provenance citations verifying facts against exact pages.
  final List<HistoryClaimProvenance> claimProvenance;

  /// Long-form, source-bound detail sections rendered on the full detail page.
  /// The concise [summary] remains the card-facing text; these sections carry
  /// the readable multi-paragraph explanation.
  final List<HistoryDetailSection> sections;

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
    this.periodPersian,
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
    this.founder,
    this.founderPersian,
    this.rulers = const [],
    this.rulersPersian = const [],
    this.predecessor,
    this.successor,
    this.religion,
    this.religionPersian,
    this.origins,
    this.originsPersian,
    this.culture,
    this.culturePersian,
    this.decline,
    this.declinePersian,
    this.relatedAuthorIds = const [],
    this.relatedWorkIds = const [],
    this.relatedEntryIds = const [],
    this.claimProvenance = const [],
    this.sections = const [],
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
      periodPersian: json['periodPersian'] as String?,
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
      founder: json['founder'] as String?,
      founderPersian: json['founderPersian'] as String?,
      rulers: (json['rulers'] as List? ?? const []).whereType<String>().toList(
        growable: false,
      ),
      rulersPersian: (json['rulersPersian'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      predecessor: json['predecessor'] as String?,
      successor: json['successor'] as String?,
      religion: json['religion'] as String?,
      religionPersian: json['religionPersian'] as String?,
      origins: json['origins'] as String?,
      originsPersian: json['originsPersian'] as String?,
      culture: json['culture'] as String?,
      culturePersian: json['culturePersian'] as String?,
      decline: json['decline'] as String?,
      declinePersian: json['declinePersian'] as String?,
      relatedAuthorIds: (json['relatedAuthorIds'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      relatedWorkIds: (json['relatedWorkIds'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      relatedEntryIds: (json['relatedEntryIds'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      claimProvenance: (json['claimProvenance'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((m) => HistoryClaimProvenance.fromJson(m))
          .toList(growable: false),
      sections: (json['sections'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((m) => HistoryDetailSection.fromJson(m))
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
    if (periodPersian != null) 'periodPersian': periodPersian,
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
    if (founder != null) 'founder': founder,
    if (founderPersian != null) 'founderPersian': founderPersian,
    if (rulers.isNotEmpty) 'rulers': rulers,
    if (rulersPersian.isNotEmpty) 'rulersPersian': rulersPersian,
    if (predecessor != null) 'predecessor': predecessor,
    if (successor != null) 'successor': successor,
    if (religion != null) 'religion': religion,
    if (religionPersian != null) 'religionPersian': religionPersian,
    if (origins != null) 'origins': origins,
    if (originsPersian != null) 'originsPersian': originsPersian,
    if (culture != null) 'culture': culture,
    if (culturePersian != null) 'culturePersian': culturePersian,
    if (decline != null) 'decline': decline,
    if (declinePersian != null) 'declinePersian': declinePersian,
    if (relatedAuthorIds.isNotEmpty) 'relatedAuthorIds': relatedAuthorIds,
    if (relatedWorkIds.isNotEmpty) 'relatedWorkIds': relatedWorkIds,
    if (relatedEntryIds.isNotEmpty) 'relatedEntryIds': relatedEntryIds,
    if (claimProvenance.isNotEmpty)
      'claimProvenance': claimProvenance.map((c) => c.toJson()).toList(),
    if (sections.isNotEmpty)
      'sections': sections.map((s) => s.toJson()).toList(),
  };

  static HistoryEntryKind _kindFromString(String? value) {
    for (final kind in HistoryEntryKind.values) {
      if (kind.name == value) return kind;
    }
    return HistoryEntryKind.event;
  }
}
