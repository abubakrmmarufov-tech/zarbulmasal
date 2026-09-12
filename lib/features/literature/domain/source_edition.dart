/// Standard source types recognized by the philological source hierarchy.
abstract class SourceEditionType {
  /// Scan of a physical printed book from an academic or state press.
  static const String printedBookScan = 'printed-book-scan';

  /// Official national curriculum textbook approved by the Ministry of Education.
  static const String officialTextbook = 'official-textbook';

  /// Critical scholarly edition with variant apparatus.
  static const String criticalEdition = 'critical-edition';

  /// Volume from the state presidential series (e.g. «Ахтарони адаб»).
  static const String presidentialSeries = 'presidential-series';

  /// Monograph or academic collection from Donish, Irfon, or Adib.
  static const String academicMonograph = 'academic-monograph';
}

/// A published edition used as a primary or secondary source for literary content.
///
/// Documents the exact physical book witness (Tier A / Tier B) used to collate
/// literary works and verify biographical claims.
class SourceEdition {
  /// Title of the published volume or textbook.
  final String bookTitle;

  /// Author name as printed on the title page.
  final String? authorAsPrinted;

  /// Editor or compiler of the edition (e.g. "Муҳаррир: А. Абдуллоев").
  final String? editor;

  /// Volume number (e.g. "ҷ. 1", "2").
  final String? volume;

  /// Edition designation (e.g. "Нашри дуввум", "2nd ed.").
  final String? edition;

  /// Publishing house (e.g. "Адиб", "Маориф", "Дониш", "Ирфон").
  final String publisher;

  /// City of publication (e.g. "Душанбе", "Хуҷанд", "Москва").
  final String city;

  /// Year of publication (e.g. "1981", "2014").
  final String year;

  /// International Standard Book Number (if issued).
  final String? isbn;

  /// Starting page number of the work within the volume.
  final int? pageStart;

  /// Ending page number of the work within the volume.
  final int? pageEnd;

  /// Holding institution or repository (e.g. "КМТ", "Институти забон ва адабиёт").
  final String? sourceInstitution;

  /// Type of source (e.g. 'printed-book-scan', 'official-textbook', 'critical-edition').
  final String sourceType;

  /// Archive reference, call number, or file identifier.
  final String? sourceReference;

  /// Date when the source was accessed or verified (e.g. "2026-09-10").
  final String? accessDate;

  /// Whether a high-resolution facsimile/image scan was directly inspected.
  final bool sourceImageVerified;

  const SourceEdition({
    required this.bookTitle,
    this.authorAsPrinted,
    this.editor,
    this.volume,
    this.edition,
    required this.publisher,
    required this.city,
    required this.year,
    this.isbn,
    this.pageStart,
    this.pageEnd,
    this.sourceInstitution,
    required this.sourceType,
    this.sourceReference,
    this.accessDate,
    this.sourceImageVerified = false,
  });

  /// Formatted page range, e.g., "с. 45–48" or "с. 45".
  String? get formattedPages {
    if (pageStart == null) return null;
    if (pageEnd == null || pageEnd == pageStart) return 'с. $pageStart';
    return 'с. $pageStart–$pageEnd';
  }

  /// Formatted standard bibliographical citation.
  String get citation {
    final buffer = StringBuffer();
    if (authorAsPrinted != null && authorAsPrinted!.trim().isNotEmpty) {
      buffer.write('${authorAsPrinted!.trim()}. ');
    }
    buffer.write(bookTitle.trim());
    if (volume != null && volume!.trim().isNotEmpty) {
      buffer.write(', ҷ. ${volume!.trim()}');
    }
    if (editor != null && editor!.trim().isNotEmpty) {
      buffer.write(' / Зери таҳрири ${editor!.trim()}');
    }
    buffer.write(' — $city: $publisher, $year.');
    final pages = formattedPages;
    if (pages != null) {
      buffer.write(' — $pages.');
    }
    return buffer.toString();
  }

  /// Creates a [SourceEdition] from a JSON map.
  factory SourceEdition.fromJson(Map<String, dynamic> json) {
    return SourceEdition(
      bookTitle: (json['bookTitle'] ?? json['book_title'] ?? '') as String,
      authorAsPrinted:
          (json['authorAsPrinted'] ?? json['author_as_printed']) as String?,
      editor: (json['editor']) as String?,
      volume: (json['volume'])?.toString(),
      edition: (json['edition'])?.toString(),
      publisher: (json['publisher'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      year: (json['year'] ?? '').toString(),
      isbn: (json['isbn']) as String?,
      pageStart: _parseInt(json['pageStart'] ?? json['page_start']),
      pageEnd: _parseInt(json['pageEnd'] ?? json['page_end']),
      sourceInstitution:
          (json['sourceInstitution'] ?? json['source_institution']) as String?,
      sourceType: (json['sourceType'] ?? json['source_type'] ?? '') as String,
      sourceReference:
          (json['sourceReference'] ?? json['source_reference']) as String?,
      accessDate: (json['accessDate'] ?? json['access_date']) as String?,
      sourceImageVerified: _parseBool(
        json['sourceImageVerified'] ?? json['source_image_verified'],
      ),
    );
  }

  /// Converts this [SourceEdition] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'bookTitle': bookTitle,
      'authorAsPrinted': authorAsPrinted,
      'editor': editor,
      'volume': volume,
      'edition': edition,
      'publisher': publisher,
      'city': city,
      'year': year,
      'isbn': isbn,
      'pageStart': pageStart,
      'pageEnd': pageEnd,
      'sourceInstitution': sourceInstitution,
      'sourceType': sourceType,
      'sourceReference': sourceReference,
      'accessDate': accessDate,
      'sourceImageVerified': sourceImageVerified,
    };
  }

  /// Creates a copy of this [SourceEdition] with given fields replaced.
  SourceEdition copyWith({
    String? bookTitle,
    String? authorAsPrinted,
    String? editor,
    String? volume,
    String? edition,
    String? publisher,
    String? city,
    String? year,
    String? isbn,
    int? pageStart,
    int? pageEnd,
    String? sourceInstitution,
    String? sourceType,
    String? sourceReference,
    String? accessDate,
    bool? sourceImageVerified,
  }) {
    return SourceEdition(
      bookTitle: bookTitle ?? this.bookTitle,
      authorAsPrinted: authorAsPrinted ?? this.authorAsPrinted,
      editor: editor ?? this.editor,
      volume: volume ?? this.volume,
      edition: edition ?? this.edition,
      publisher: publisher ?? this.publisher,
      city: city ?? this.city,
      year: year ?? this.year,
      isbn: isbn ?? this.isbn,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      sourceInstitution: sourceInstitution ?? this.sourceInstitution,
      sourceType: sourceType ?? this.sourceType,
      sourceReference: sourceReference ?? this.sourceReference,
      accessDate: accessDate ?? this.accessDate,
      sourceImageVerified: sourceImageVerified ?? this.sourceImageVerified,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceEdition &&
          runtimeType == other.runtimeType &&
          bookTitle == other.bookTitle &&
          authorAsPrinted == other.authorAsPrinted &&
          editor == other.editor &&
          volume == other.volume &&
          edition == other.edition &&
          publisher == other.publisher &&
          city == other.city &&
          year == other.year &&
          isbn == other.isbn &&
          pageStart == other.pageStart &&
          pageEnd == other.pageEnd &&
          sourceInstitution == other.sourceInstitution &&
          sourceType == other.sourceType &&
          sourceReference == other.sourceReference &&
          accessDate == other.accessDate &&
          sourceImageVerified == other.sourceImageVerified;

  @override
  int get hashCode => Object.hash(
    bookTitle,
    authorAsPrinted,
    editor,
    volume,
    edition,
    publisher,
    city,
    year,
    isbn,
    pageStart,
    pageEnd,
    sourceInstitution,
    sourceType,
    sourceReference,
    accessDate,
    sourceImageVerified,
  );

  @override
  String toString() {
    return 'SourceEdition(bookTitle: $bookTitle, publisher: $publisher, year: $year, pages: $formattedPages)';
  }
}
