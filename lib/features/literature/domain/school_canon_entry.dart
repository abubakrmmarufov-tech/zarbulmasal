/// An entry in the official Tajik school literary canon.
///
/// Maps a literary work or author to approved national curriculum textbooks
/// (*Хониши адабӣ*, *Адабиёти тоҷик*) approved by the Ministry of Education.
class SchoolCanonEntry {
  /// Unique entry identifier (e.g. "canon-rudaki-grade5").
  final String id;

  /// ID of the referenced literary work.
  final String workId;

  /// ID of the author.
  final String authorId;

  /// School grade level (e.g. "4", "5", "8", "10", "11").
  final String grade;

  /// Subject name (e.g. "Адабиёти тоҷик", "Хониши адабӣ").
  final String subject;

  /// Title of the official textbook where this work appears.
  final String textbookTitle;

  /// Authors/compilers of the approved textbook.
  final String textbookAuthors;

  /// Publishing house (e.g. "Маориф").
  final String textbookPublisher;

  /// Publication year of the textbook edition (e.g. "2018").
  final String textbookYear;

  /// Curriculum requirement type: "mandatory" (*ҳатмӣ*) or "recommended" (*барои мутолиаи беруназсинфӣ*).
  final String curriculumType;

  /// Bibliographical page citation or curriculum evidence.
  final String sourceEvidence;

  const SchoolCanonEntry({
    required this.id,
    required this.workId,
    required this.authorId,
    required this.grade,
    required this.subject,
    required this.textbookTitle,
    required this.textbookAuthors,
    required this.textbookPublisher,
    required this.textbookYear,
    this.curriculumType = 'mandatory',
    required this.sourceEvidence,
  });

  /// Whether this canon entry is part of the mandatory school syllabus.
  bool get isMandatory => curriculumType.trim().toLowerCase() == 'mandatory';

  /// Creates a [SchoolCanonEntry] from a JSON map.
  factory SchoolCanonEntry.fromJson(Map<String, dynamic> json) {
    return SchoolCanonEntry(
      id: (json['id'] ?? '') as String,
      workId: (json['workId'] ?? json['work_id'] ?? '') as String,
      authorId: (json['authorId'] ?? json['author_id'] ?? '') as String,
      grade: (json['grade'] ?? '').toString(),
      subject: (json['subject'] ?? '') as String,
      textbookTitle:
          (json['textbookTitle'] ?? json['textbook_title'] ?? '') as String,
      textbookAuthors:
          (json['textbookAuthors'] ?? json['textbook_authors'] ?? '') as String,
      textbookPublisher:
          (json['textbookPublisher'] ?? json['textbook_publisher'] ?? '')
              as String,
      textbookYear: (json['textbookYear'] ?? json['textbook_year'] ?? '')
          .toString(),
      curriculumType:
          (json['curriculumType'] ?? json['curriculum_type'] ?? 'mandatory')
              as String,
      sourceEvidence:
          (json['sourceEvidence'] ?? json['source_evidence'] ?? '') as String,
    );
  }

  /// Converts this [SchoolCanonEntry] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workId': workId,
      'authorId': authorId,
      'grade': grade,
      'subject': subject,
      'textbookTitle': textbookTitle,
      'textbookAuthors': textbookAuthors,
      'textbookPublisher': textbookPublisher,
      'textbookYear': textbookYear,
      'curriculumType': curriculumType,
      'sourceEvidence': sourceEvidence,
    };
  }

  /// Creates a copy of this [SchoolCanonEntry] with given fields replaced.
  SchoolCanonEntry copyWith({
    String? id,
    String? workId,
    String? authorId,
    String? grade,
    String? subject,
    String? textbookTitle,
    String? textbookAuthors,
    String? textbookPublisher,
    String? textbookYear,
    String? curriculumType,
    String? sourceEvidence,
  }) {
    return SchoolCanonEntry(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      authorId: authorId ?? this.authorId,
      grade: grade ?? this.grade,
      subject: subject ?? this.subject,
      textbookTitle: textbookTitle ?? this.textbookTitle,
      textbookAuthors: textbookAuthors ?? this.textbookAuthors,
      textbookPublisher: textbookPublisher ?? this.textbookPublisher,
      textbookYear: textbookYear ?? this.textbookYear,
      curriculumType: curriculumType ?? this.curriculumType,
      sourceEvidence: sourceEvidence ?? this.sourceEvidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolCanonEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SchoolCanonEntry(id: $id, workId: $workId, grade: $grade, subject: $subject)';
  }
}
