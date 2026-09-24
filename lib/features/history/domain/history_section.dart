/// One readable long-form subsection of a history entry's detail view.
///
/// Each section carries its own source page data so a reader can trace a
/// heading/body back to the exact printed and PDF page it was distilled from.
/// The body is the source-language (Tajik) witness taken from the official
/// textbook; a Persian rendering, when present, is an editorial translation and
/// is explicitly flagged via [persianIsEditorial] rather than presented as an
/// independent original witness.
class HistoryDetailSection {
  final String heading;
  final String? headingPersian;
  final String body;
  final String? bodyPersian;

  /// Overrides the entry-level source book; null means "inherit the entry's
  /// `sourceBookId`".
  final String? sourceBookId;
  final int? printedPage;
  final int? pdfPage;

  /// Inclusive end of the page range a multi-page summary draws from.
  ///
  /// A section may summarize two or three consecutive source pages; [printedPage]
  /// (and [pdfPage]) record where the topic begins and these end fields record
  /// where the summarized material stops, so a reader can trace the whole span
  /// instead of only the start page. Both end fields must be non-null together
  /// and >= the corresponding start page when present.
  final int? printedPageEnd;
  final int? pdfPageEnd;

  /// True whenever [bodyPersian] (or [headingPersian]) is present, because the
  /// Persian text is a faithful editorial translation of the Tajik source
  /// witness, not a separate original source.
  final bool persianIsEditorial;

  const HistoryDetailSection({
    required this.heading,
    this.headingPersian,
    required this.body,
    this.bodyPersian,
    this.sourceBookId,
    this.printedPage,
    this.pdfPage,
    this.printedPageEnd,
    this.pdfPageEnd,
    this.persianIsEditorial = true,
  });

  factory HistoryDetailSection.fromJson(Map<String, dynamic> json) {
    final heading = json['heading'];
    final headingPersian = json['headingPersian'];
    final body = json['body'];
    final bodyPersian = json['bodyPersian'];
    final sourceBookId = json['sourceBookId'];
    final printedPage = json['printedPage'];
    final pdfPage = json['pdfPage'];
    final printedPageEnd = json['printedPageEnd'];
    final pdfPageEnd = json['pdfPageEnd'];
    final persianIsEditorial = json['persianIsEditorial'];
    return HistoryDetailSection(
      heading: heading is String ? heading : '',
      headingPersian: headingPersian is String ? headingPersian : null,
      body: body is String ? body : '',
      bodyPersian: bodyPersian is String ? bodyPersian : null,
      sourceBookId: sourceBookId is String ? sourceBookId : null,
      printedPage: printedPage is num ? printedPage.toInt() : null,
      pdfPage: pdfPage is num ? pdfPage.toInt() : null,
      printedPageEnd: printedPageEnd is num ? printedPageEnd.toInt() : null,
      pdfPageEnd: pdfPageEnd is num ? pdfPageEnd.toInt() : null,
      // A section carrying Persian text is an editorial rendering of the
      // Tajik source witness by default; absent Persian the flag is moot and
      // stays false so it is not serialized.
      persianIsEditorial: persianIsEditorial is bool
          ? persianIsEditorial
          : bodyPersian is String || headingPersian is String,
    );
  }

  Map<String, dynamic> toJson() => {
    'heading': heading,
    if (headingPersian != null) 'headingPersian': headingPersian,
    'body': body,
    if (bodyPersian != null) 'bodyPersian': bodyPersian,
    if (sourceBookId != null) 'sourceBookId': sourceBookId,
    if (printedPage != null) 'printedPage': printedPage,
    if (pdfPage != null) 'pdfPage': pdfPage,
    if (printedPageEnd != null) 'printedPageEnd': printedPageEnd,
    if (pdfPageEnd != null) 'pdfPageEnd': pdfPageEnd,
    if (persianIsEditorial) 'persianIsEditorial': persianIsEditorial,
  };
}
