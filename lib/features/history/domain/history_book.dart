import '../../../core/utils/trusted_url_policy.dart';

/// A Tajik-history textbook record from the official curriculum or uploaded textbook.
class HistoryBook {
  final String id;
  final String grade;
  final String title;
  final String? titlePersian;
  final String author;
  final String? authorPersian;
  final String year;
  final String edition;
  final String description;
  final String? descriptionPersian;
  final String sourceUrl;
  final bool isUploadedBook;
  final String? localPath;
  final int? pages;
  final String? publisher;

  /// A source link that is safe to hand to the platform's external launcher.
  ///
  /// History records are bundled editorial data, but keeping this check at the
  /// model boundary prevents a malformed future record from invoking a local
  /// file, application scheme, or insecure web URL.
  Uri? get externalSourceUri {
    return TrustedUrlPolicy.parseExternal(sourceUrl);
  }

  const HistoryBook({
    required this.id,
    required this.grade,
    required this.title,
    this.titlePersian,
    required this.author,
    this.authorPersian,
    required this.year,
    this.edition = '',
    required this.description,
    this.descriptionPersian,
    required this.sourceUrl,
    this.isUploadedBook = false,
    this.localPath,
    this.pages,
    this.publisher,
  });

  factory HistoryBook.fromJson(Map<String, dynamic> json) {
    return HistoryBook(
      id: json['id'] as String? ?? '',
      grade: json['grade']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      titlePersian: json['titlePersian'] as String?,
      author: json['author'] as String? ?? '',
      authorPersian: json['authorPersian'] as String?,
      year: json['year']?.toString() ?? '',
      edition: json['edition'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionPersian: json['descriptionPersian'] as String?,
      sourceUrl: json['sourceUrl'] as String? ?? '',
      isUploadedBook: json['isUploadedBook'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      pages: (json['pages'] as num?)?.toInt(),
      publisher: json['publisher'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'grade': grade,
    'title': title,
    if (titlePersian != null) 'titlePersian': titlePersian,
    'author': author,
    if (authorPersian != null) 'authorPersian': authorPersian,
    'year': year,
    'edition': edition,
    'description': description,
    if (descriptionPersian != null) 'descriptionPersian': descriptionPersian,
    'sourceUrl': sourceUrl,
    'isUploadedBook': isUploadedBook,
    if (localPath != null) 'localPath': localPath,
    if (pages != null) 'pages': pages,
    if (publisher != null) 'publisher': publisher,
  };
}
