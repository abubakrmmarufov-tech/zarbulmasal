import '../../../core/utils/search_normalizer.dart';
import '../../../core/utils/trusted_url_policy.dart';
import '../../../shared/providers/app_providers.dart';

/// The source role for a book record. Provider metadata must never become
/// factual provenance for biographies, poems, or history claims.
enum BookSourcePurpose { bookAvailability, coverAsset, externalReading }

enum BookAvailability {
  readableExternal,
  pdfAvailable,
  downloadAvailable,
  catalogueOnly,
  unavailable,
  accessRestricted,
  rightsUnclear,
}

enum BookRightsStatus { rightsUnclear, providerStated, licensed, publicDomain }

enum BookFormat { pdf, epub, html, externalReader, catalogue }

class BookProvider {
  final String id;
  final String name;
  final String domain;
  final String catalogueUrl;
  final String descriptionTj;
  final String descriptionFa;
  final int? catalogueSize;
  final int? authorCount;
  final int? categoryCount;
  final bool supportsReader;
  final bool supportsDownload;
  final BookSourcePurpose sourcePurpose;

  const BookProvider({
    required this.id,
    required this.name,
    required this.domain,
    required this.catalogueUrl,
    required this.descriptionTj,
    required this.descriptionFa,
    this.catalogueSize,
    this.authorCount,
    this.categoryCount,
    required this.supportsReader,
    required this.supportsDownload,
    required this.sourcePurpose,
  });

  /// Provider catalogue links are untrusted metadata until they pass the
  /// central external-link policy.
  Uri? get catalogueUri => TrustedUrlPolicy.parseExternal(catalogueUrl);

  factory BookProvider.fromJson(Map<String, dynamic> json) {
    return BookProvider(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      catalogueUrl: json['catalogueUrl'] as String? ?? '',
      descriptionTj: json['descriptionTj'] as String? ?? '',
      descriptionFa: json['descriptionFa'] as String? ?? '',
      catalogueSize: (json['catalogueSize'] as num?)?.toInt(),
      authorCount: (json['authorCount'] as num?)?.toInt(),
      categoryCount: (json['categoryCount'] as num?)?.toInt(),
      supportsReader: json['supportsReader'] as bool? ?? false,
      supportsDownload: json['supportsDownload'] as bool? ?? false,
      sourcePurpose: _sourcePurpose(json['sourcePurpose'] as String?),
    );
  }

  static BookSourcePurpose _sourcePurpose(String? value) {
    return BookSourcePurpose.values.firstWhere(
      (item) => item.name == value,
      orElse: () => BookSourcePurpose.bookAvailability,
    );
  }
}

class BookEdition {
  final String id;
  final String bookId;
  final String providerId;
  final String sourceUrl;
  final String? readUrl;
  final String? downloadUrl;
  final String? coverUrl;

  /// Checked-in copy of the provider cover; the only cover the app draws.
  /// [coverUrl] remains the source/provenance link.
  final String? coverAssetPath;
  final String? publisher;
  final String? city;
  final String? publicationYear;
  final String? editionLabel;
  final int? pageCount;
  final String language;
  final List<String> scripts;
  final List<String> categories;
  final String? grade;
  final BookFormat format;
  final BookAvailability availability;
  final BookRightsStatus rightsStatus;
  final String metadataNote;

  const BookEdition({
    required this.id,
    required this.bookId,
    required this.providerId,
    required this.sourceUrl,
    this.readUrl,
    this.downloadUrl,
    this.coverUrl,
    this.coverAssetPath,
    this.publisher,
    this.city,
    this.publicationYear,
    this.editionLabel,
    this.pageCount,
    required this.language,
    this.scripts = const [],
    this.categories = const [],
    this.grade,
    required this.format,
    required this.availability,
    required this.rightsStatus,
    required this.metadataNote,
  });

  /// URLs supplied by catalog metadata must remain safe even when a caller
  /// constructs a [BookEdition] outside the repository validation boundary.
  Uri? get sourceUri => _secureExternalUri(sourceUrl);
  Uri? get readUri => _secureExternalUri(readUrl);
  Uri? get downloadUri => _secureExternalUri(downloadUrl);
  Uri? get coverUri => _secureExternalUri(coverUrl);

  /// Whether a cover is bundled with the app. The app is offline: a cover
  /// that exists only at [coverUrl] is never fetched.
  bool get hasCover => coverAssetPath?.trim().isNotEmpty ?? false;
  bool get canRead => readUri != null;

  static Uri? _secureExternalUri(String? value) {
    return TrustedUrlPolicy.parseExternal(value);
  }

  factory BookEdition.fromJson(Map<String, dynamic> json) {
    return BookEdition(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      readUrl: json['readUrl'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      coverAssetPath: json['coverAssetPath'] as String?,
      publisher: json['publisher'] as String?,
      city: json['city'] as String?,
      publicationYear: json['publicationYear']?.toString(),
      editionLabel: json['editionLabel'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      language: json['language'] as String? ?? '',
      scripts: _stringList(json['scripts']),
      categories: _stringList(json['categories']),
      grade: json['grade'] as String?,
      format: _format(json['format'] as String?),
      availability: _availability(json['availability'] as String?),
      rightsStatus: _rightsStatus(json['rightsStatus'] as String?),
      metadataNote: json['metadataNote'] as String? ?? '',
    );
  }

  static List<String> _stringList(Object? value) {
    return value is List ? value.whereType<String>().toList() : const [];
  }

  static BookFormat _format(String? value) => BookFormat.values.firstWhere(
    (item) => item.name == value,
    orElse: () => BookFormat.catalogue,
  );

  static BookAvailability _availability(String? value) =>
      BookAvailability.values.firstWhere(
        (item) => item.name == value,
        orElse: () => BookAvailability.catalogueOnly,
      );

  static BookRightsStatus _rightsStatus(String? value) =>
      BookRightsStatus.values.firstWhere(
        (item) => item.name == value,
        orElse: () => BookRightsStatus.rightsUnclear,
      );
}

class Book {
  final String id;
  final String canonicalTitle;
  final String titleTj;
  final String? titleFa;
  final List<String> alternateTitles;
  final String? authorNameTj;
  final String? authorNameFa;
  final String? authorId;
  final String descriptionTj;
  final String? descriptionFa;
  final String language;
  final List<String> genres;
  final List<String> categoryIds;
  final List<String> relatedPoetIds;
  final List<String> relatedWorkIds;
  final List<String> relatedHistoryIds;
  final List<BookEdition> editions;

  const Book({
    required this.id,
    required this.canonicalTitle,
    required this.titleTj,
    this.titleFa,
    this.alternateTitles = const [],
    this.authorNameTj,
    this.authorNameFa,
    this.authorId,
    required this.descriptionTj,
    this.descriptionFa,
    required this.language,
    this.genres = const [],
    this.categoryIds = const [],
    this.relatedPoetIds = const [],
    this.relatedWorkIds = const [],
    this.relatedHistoryIds = const [],
    this.editions = const [],
  });

  String titleFor(DisplayLanguage language) {
    if (language == DisplayLanguage.persian) {
      return titleFa?.trim() ?? '';
    }
    return titleTj;
  }

  String? authorFor(DisplayLanguage language) {
    if (language == DisplayLanguage.persian) {
      final translated = authorNameFa?.trim() ?? '';
      return translated.isEmpty ? null : translated;
    }
    return authorNameTj;
  }

  String descriptionFor(DisplayLanguage language) {
    if (language == DisplayLanguage.persian) {
      return descriptionFa?.trim() ?? '';
    }
    return descriptionTj;
  }

  BookEdition? get primaryEdition => editions.firstOrNull;

  bool matches(String query) {
    return SearchNormalizer.matchesAny([
      canonicalTitle,
      titleTj,
      titleFa ?? '',
      authorNameTj ?? '',
      authorNameFa ?? '',
      ...alternateTitles,
      ...genres,
      ...categoryIds,
      language,
      ...editions.expand((edition) => edition.categories),
      ...editions.map((edition) => edition.publisher ?? ''),
    ], query);
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final rawEditions = json['editions'];
    return Book(
      id: json['id'] as String? ?? '',
      canonicalTitle: json['canonicalTitle'] as String? ?? '',
      titleTj: json['titleTj'] as String? ?? '',
      titleFa: json['titleFa'] as String?,
      alternateTitles: _stringList(json['alternateTitles']),
      authorNameTj: json['authorNameTj'] as String?,
      authorNameFa: json['authorNameFa'] as String?,
      authorId: json['authorId'] as String?,
      descriptionTj: json['descriptionTj'] as String? ?? '',
      descriptionFa: json['descriptionFa'] as String?,
      language: json['language'] as String? ?? '',
      genres: _stringList(json['genres']),
      categoryIds: _stringList(json['categoryIds']),
      relatedPoetIds: _stringList(json['relatedPoetIds']),
      relatedWorkIds: _stringList(json['relatedWorkIds']),
      relatedHistoryIds: _stringList(json['relatedHistoryIds']),
      editions: rawEditions is List
          ? rawEditions
                .whereType<Map<String, dynamic>>()
                .map(BookEdition.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  static List<String> _stringList(Object? value) {
    return value is List ? value.whereType<String>().toList() : const [];
  }
}
