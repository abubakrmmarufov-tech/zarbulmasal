/// A single reviewed lexical headword from the Luғатнома word list.
///
/// The list is sourced from the local grade-5 reader PDF; each record is one
/// explicit headword–definition pair. Source provenance ([sourceBook],
/// [pdfPage]) is kept on the model as metadata so it is never lost from the
/// JSON, but it is not rendered on list rows.
class WordEntry {
  final String term;
  final String definition;
  final String sourceBook;
  final int pdfPage;

  const WordEntry({
    required this.term,
    required this.definition,
    required this.sourceBook,
    required this.pdfPage,
  });

  /// Parses one JSON object, e.g.
  /// `{"term": "Тилисм", "definition": "ҷоду.", "sourceBook": "...", "pdfPage": 17}`.
  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      term: (json['term'] as String? ?? '').trim(),
      definition: (json['definition'] as String? ?? '').trim(),
      sourceBook: (json['sourceBook'] as String? ?? '').trim(),
      pdfPage: (json['pdfPage'] as num?)?.toInt() ?? 0,
    );
  }
}
