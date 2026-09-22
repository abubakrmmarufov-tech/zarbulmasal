import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/utils/trusted_url_policy.dart';
import '../domain/book_domain.dart';

class BooksRepository {
  Future<List<BookProvider>> loadProviders() async {
    final decoded = jsonDecode(
      await rootBundle.loadString('assets/data/books/providers.json'),
    );
    final providers = (decoded as List)
        .whereType<Map<String, dynamic>>()
        .map(BookProvider.fromJson)
        .toList(growable: false);
    validateProviders(providers);
    return providers;
  }

  void validateProviders(List<BookProvider> providers) {
    final ids = <String>{};
    for (final provider in providers) {
      if (provider.id.trim().isEmpty || !ids.add(provider.id)) {
        throw FormatException('Duplicate or empty provider id: ${provider.id}');
      }
      if (provider.catalogueUrl.trim().isEmpty ||
          provider.catalogueUri == null) {
        throw FormatException(
          'Provider has invalid catalogue URL: ${provider.id}',
        );
      }
    }
  }

  Future<List<Book>> loadBooks() async {
    final decoded = jsonDecode(
      await rootBundle.loadString('assets/data/books/books.json'),
    );
    final books = (decoded as List)
        .whereType<Map<String, dynamic>>()
        .map(Book.fromJson)
        .toList(growable: false);
    validateBooks(books);
    return books;
  }

  void validateBooks(List<Book> books) {
    final ids = <String>{};
    final editionIds = <String>{};
    for (final book in books) {
      if (book.id.trim().isEmpty || !ids.add(book.id)) {
        throw FormatException('Duplicate or empty book id: ${book.id}');
      }
      for (final edition in book.editions) {
        if (edition.bookId != book.id || !editionIds.add(edition.id)) {
          throw FormatException('Invalid edition relationship: ${edition.id}');
        }
        if (edition.sourceUrl.trim().isEmpty) {
          throw FormatException('Edition has no source URL: ${edition.id}');
        }
        if (!_isSecureExternalUrl(edition.sourceUrl)) {
          throw FormatException(
            'Edition has invalid source URL: ${edition.id}',
          );
        }
        if (!_isEmpty(edition.readUrl) &&
            !_isSecureExternalUrl(edition.readUrl)) {
          throw FormatException('Edition has invalid read URL: ${edition.id}');
        }
        if (!_isEmpty(edition.coverUrl) &&
            !_isSecureExternalUrl(edition.coverUrl)) {
          throw FormatException('Edition has invalid cover URL: ${edition.id}');
        }
        if (!_isEmpty(edition.coverAssetPath) &&
            !_isSafeCoverAssetPath(edition.coverAssetPath)) {
          throw FormatException(
            'Edition has invalid local cover asset path: ${edition.id}',
          );
        }
        if (!_isEmpty(edition.downloadUrl) &&
            !_isSecureExternalUrl(edition.downloadUrl)) {
          throw FormatException(
            'Edition has invalid download URL: ${edition.id}',
          );
        }
        if (edition.availability == BookAvailability.readableExternal &&
            !edition.canRead) {
          throw FormatException(
            'Readable edition has no read URL: ${edition.id}',
          );
        }
      }
    }
  }

  static bool _isEmpty(String? value) => value == null || value.trim().isEmpty;

  static bool _isSecureExternalUrl(String? value) {
    if (_isEmpty(value)) return false;
    return TrustedUrlPolicy.parseExternal(value) != null;
  }

  static bool _isSafeCoverAssetPath(String? value) {
    if (_isEmpty(value)) return false;
    final path = value!.trim();
    return path.startsWith('assets/data/books/covers/') &&
        !path.contains('..') &&
        !path.contains('\\') &&
        (path.endsWith('.jpg') ||
            path.endsWith('.jpeg') ||
            path.endsWith('.png') ||
            path.endsWith('.webp'));
  }
}
