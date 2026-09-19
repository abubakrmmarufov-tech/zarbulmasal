import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/book_domain.dart';

class BooksRepository {
  Future<List<BookProvider>> loadProviders() async {
    final decoded = jsonDecode(
      await rootBundle.loadString('assets/data/books/providers.json'),
    );
    return (decoded as List)
        .whereType<Map<String, dynamic>>()
        .map(BookProvider.fromJson)
        .toList(growable: false);
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
        final sourceUri = Uri.tryParse(edition.sourceUrl);
        if (sourceUri == null ||
            sourceUri.scheme != 'https' ||
            sourceUri.host.trim().isEmpty) {
          throw FormatException(
            'Edition has invalid source URL: ${edition.id}',
          );
        }
        if (edition.readUrl != null && edition.readUrl!.trim().isNotEmpty) {
          final readUri = Uri.tryParse(edition.readUrl!);
          if (readUri == null ||
              readUri.scheme != 'https' ||
              readUri.host.trim().isEmpty) {
            throw FormatException(
              'Edition has invalid read URL: ${edition.id}',
            );
          }
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
}
