import 'package:flutter/foundation.dart';

/// Where a printed text was found: the book's edition and the page.
///
/// [pdfPage] is the page of the local scan; [printedPage] is the number
/// printed on that page. Scans have unnumbered leaves, so the two differ and
/// both are kept. [printedText] is the text exactly as that page prints it.
@immutable
class SourceRef {
  final String bookTitle;
  final String? authorEditor;
  final int? year;
  final int pdfPage;
  final int? printedPage;
  final String? publisher;
  final String? city;
  final String? printedText;
  final String? note;

  const SourceRef({
    required this.bookTitle,
    this.authorEditor,
    this.year,
    required this.pdfPage,
    this.printedPage,
    this.publisher,
    this.city,
    this.printedText,
    this.note,
  });

  factory SourceRef.fromJson(Map<String, dynamic> json) {
    return SourceRef(
      bookTitle: json['bookTitle'] as String,
      authorEditor: json['authorEditor'] as String?,
      year: json['year'] as int?,
      pdfPage: json['pdfPage'] as int,
      printedPage: json['printedPage'] as int?,
      publisher: json['publisher'] as String?,
      city: json['city'] as String?,
      printedText: json['printedText'] as String?,
      note: json['note'] as String?,
    );
  }
}
