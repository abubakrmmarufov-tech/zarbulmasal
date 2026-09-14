/// A Tajik-history textbook record from the permitted marifat.tj library.
class HistoryBook {
  final String id;
  final String grade;
  final String title;
  final String author;
  final String year;
  final String edition;
  final String description;
  final String sourceUrl;

  const HistoryBook({
    required this.id,
    required this.grade,
    required this.title,
    required this.author,
    required this.year,
    this.edition = '',
    required this.description,
    required this.sourceUrl,
  });

  factory HistoryBook.fromJson(Map<String, dynamic> json) {
    return HistoryBook(
      id: json['id'] as String? ?? '',
      grade: json['grade']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      year: json['year']?.toString() ?? '',
      edition: json['edition'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'grade': grade,
    'title': title,
    'author': author,
    'year': year,
    'edition': edition,
    'description': description,
    'sourceUrl': sourceUrl,
  };
}
