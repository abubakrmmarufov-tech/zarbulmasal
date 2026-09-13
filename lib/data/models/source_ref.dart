import 'package:flutter/foundation.dart';

@immutable
class SourceRef {
  final String bookTitle;
  final String? authorEditor;
  final int? year;
  final int pdfPage;
  final int? printedPage;

  const SourceRef({
    required this.bookTitle,
    this.authorEditor,
    this.year,
    required this.pdfPage,
    this.printedPage,
  });

  factory SourceRef.fromJson(Map<String, dynamic> json) {
    return SourceRef(
      bookTitle: json['bookTitle'] as String,
      authorEditor: json['authorEditor'] as String?,
      year: json['year'] as int?,
      pdfPage: json['pdfPage'] as int,
      printedPage: json['printedPage'] as int?,
    );
  }
}
