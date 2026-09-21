import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/features/books/data/books_repository.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  group('BooksRepository', () {
    final repository = BooksRepository();

    test(
      'loads provider catalogue metadata with availability-only purpose',
      () async {
        final providers = await repository.loadProviders();
        expect(providers, hasLength(1));
        expect(providers.single.id, 'kitobkhon');
        expect(providers.single.catalogueSize, 1092);
        expect(
          providers.single.sourcePurpose,
          BookSourcePurpose.bookAvailability,
        );
      },
    );

    test(
      'rejects unsafe provider catalogue URLs at the repository boundary',
      () {
        final unsafeProvider = BookProvider.fromJson({
          'id': 'unsafe-provider',
          'name': 'Unsafe provider',
          'domain': 'kitobkhon.net',
          'catalogueUrl': 'javascript:alert(1)',
          'descriptionTj': 'Fixture',
          'descriptionFa': 'Fixture',
          'sourcePurpose': 'bookAvailability',
        });

        expect(
          () => repository.validateProviders([unsafeProvider]),
          throwsFormatException,
        );
      },
    );

    test('provider catalogue getter exposes only trusted HTTPS URLs', () {
      final unsafeProvider = BookProvider.fromJson({
        'id': 'unsafe-provider',
        'name': 'Unsafe provider',
        'domain': 'kitobkhon.net',
        'catalogueUrl': 'http://kitobkhon.net/books',
        'descriptionTj': 'Fixture',
        'descriptionFa': 'Fixture',
        'sourcePurpose': 'bookAvailability',
      });
      final secureProvider = BookProvider.fromJson({
        'id': 'secure-provider',
        'name': 'Secure provider',
        'domain': 'kitobkhon.net',
        'catalogueUrl': 'https://kitobkhon.net/books',
        'descriptionTj': 'Fixture',
        'descriptionFa': 'Fixture',
        'sourcePurpose': 'bookAvailability',
      });

      expect(unsafeProvider.catalogueUri, isNull);
      expect(secureProvider.catalogueUri, isNotNull);
    });

    test(
      'loads unique canonical books and valid edition relationships',
      () async {
        final books = await repository.loadBooks();
        final bookIds = books.map((book) => book.id).toSet();
        final editionIds = books
            .expand((book) => book.editions)
            .map((e) => e.id)
            .toSet();

        expect(books.length, 18);
        expect(bookIds.length, books.length);
        expect(editionIds.length, books.expand((book) => book.editions).length);
        expect(books.every((book) => book.editions.isNotEmpty), isTrue);
        expect(
          books
              .expand((book) => book.editions)
              .every(
                (edition) =>
                    edition.providerId == 'kitobkhon' &&
                    edition.availability == BookAvailability.readableExternal &&
                    edition.rightsStatus == BookRightsStatus.rightsUnclear &&
                    edition.downloadUrl == null &&
                    edition.readUrl != null,
              ),
          isTrue,
        );
      },
    );

    test('retains verified author and related-poet relationships', () async {
      final books = await repository.loadBooks();
      final badiBoron = books.firstWhere((book) => book.id == 'badi-boron');
      final ahmadiDonish = books.firstWhere(
        (book) => book.id == 'ahmadi-donish',
      );
      final farzona = books.firstWhere((book) => book.id == 'devoni-farzona-1');

      expect(badiBoron.authorId, 'ef5a57a2-8949-43dd-85eb-8ceaf78335f3');
      expect(badiBoron.relatedPoetIds, contains(badiBoron.authorId));
      expect(ahmadiDonish.authorId, 'e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b');
      expect(ahmadiDonish.relatedPoetIds, ['ahmad_donish']);
      expect(farzona.authorId, 'farzona');
      expect(farzona.relatedPoetIds, ['farzona']);
    });

    test(
      'all related-poet links are unique and resolve to the poet catalog',
      () async {
        final books = await repository.loadBooks();
        final poets =
            jsonDecode(
                  await rootBundle.loadString(
                    'assets/data/literature/poets.json',
                  ),
                )
                as List<dynamic>;
        final poetIds = poets
            .whereType<Map<String, dynamic>>()
            .map((poet) => poet['id'])
            .whereType<String>()
            .toSet();

        for (final book in books) {
          expect(
            book.relatedPoetIds.toSet(),
            hasLength(book.relatedPoetIds.length),
            reason: 'Duplicate related poet on ${book.id}',
          );
          expect(
            book.relatedPoetIds.every(poetIds.contains),
            isTrue,
            reason: 'Dangling related poet on ${book.id}',
          );
        }
      },
    );

    test(
      'retains the provider cover for Qobusnoma when it matches the book page',
      () async {
        final books = await repository.loadBooks();
        final qobusnoma = books.firstWhere((book) => book.id == 'qobusnoma');
        final edition = qobusnoma.editions.single;

        expect(
          edition.coverUrl,
          'https://kitobkhon.net/storage/covers/kitobkhon-net-kobusnoma.jpg',
        );
        expect(edition.coverUri, isNotNull);
      },
    );

    test(
      'bundles exact provider covers for web rendering with provenance URLs',
      () async {
        final books = await repository.loadBooks();
        final covered = books
            .expand((book) => book.editions)
            .where((edition) => edition.coverAssetPath != null)
            .toList(growable: false);

        expect(covered, hasLength(8));
        for (final edition in covered) {
          expect(edition.coverUrl, startsWith('https://kitobkhon.net/'));
          expect(
            edition.coverAssetPath,
            startsWith('assets/data/books/covers/'),
          );
          final bytes = await rootBundle.load(edition.coverAssetPath!);
          expect(bytes.lengthInBytes, greaterThan(1000));
        }
      },
    );

    test('keeps editions separate under one canonical book', () {
      final book = Book.fromJson({
        'id': 'canonical-example',
        'canonicalTitle': 'Example',
        'titleTj': 'Example',
        'descriptionTj': 'Metadata fixture',
        'language': 'Тоҷикӣ',
        'editions': [
          {
            'id': 'edition-a',
            'bookId': 'canonical-example',
            'providerId': 'kitobkhon',
            'sourceUrl': 'https://kitobkhon.net/book/example-a',
            'readUrl': 'https://kitobkhon.net/storage/books/example-a.pdf',
            'language': 'Тоҷикӣ',
            'format': 'pdf',
            'availability': 'readableExternal',
            'rightsStatus': 'rightsUnclear',
            'metadataNote': 'fixture',
          },
          {
            'id': 'edition-b',
            'bookId': 'canonical-example',
            'providerId': 'kitobkhon',
            'sourceUrl': 'https://kitobkhon.net/book/example-b',
            'readUrl': 'https://kitobkhon.net/storage/books/example-b.pdf',
            'language': 'Тоҷикӣ',
            'format': 'pdf',
            'availability': 'readableExternal',
            'rightsStatus': 'rightsUnclear',
            'metadataNote': 'fixture',
          },
        ],
      });

      expect(book.id, 'canonical-example');
      expect(book.editions.map((edition) => edition.id), [
        'edition-a',
        'edition-b',
      ]);
    });

    test('persists saved books without mutating the previous set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final first = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(first.dispose);

      final before = first.read(bookFavoritesProvider);
      await first.read(bookFavoritesProvider.notifier).toggle('badi-boron');
      expect(before, isEmpty);
      expect(first.read(bookFavoritesProvider), {'badi-boron'});

      final second = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(second.dispose);
      expect(second.read(bookFavoritesProvider), {'badi-boron'});
      expect(prefs.getStringList(AppConstants.prefsBookFavorites), [
        'badi-boron',
      ]);
    });

    test('rejects malformed external URLs at the repository boundary', () {
      final malformed = Book.fromJson({
        'id': 'malformed-url',
        'canonicalTitle': 'Malformed',
        'titleTj': 'Malformed',
        'descriptionTj': 'Fixture',
        'language': 'Тоҷикӣ',
        'editions': [
          {
            'id': 'malformed-edition',
            'bookId': 'malformed-url',
            'providerId': 'kitobkhon',
            'sourceUrl': 'javascript:alert(1)',
            'readUrl': 'https://kitobkhon.net/storage/books/a.pdf',
            'language': 'Тоҷикӣ',
            'format': 'pdf',
            'availability': 'readableExternal',
            'rightsStatus': 'rightsUnclear',
            'metadataNote': 'fixture',
          },
        ],
      });

      expect(
        () => repository.validateBooks([malformed]),
        throwsFormatException,
      );
    });

    test(
      'rejects unsafe cover and download URLs at the repository boundary',
      () {
        Book invalidBook({String? coverUrl, String? downloadUrl}) =>
            Book.fromJson({
              'id': 'unsafe-asset-url',
              'canonicalTitle': 'Unsafe asset URL',
              'titleTj': 'Unsafe asset URL',
              'descriptionTj': 'Fixture',
              'language': 'Тоҷикӣ',
              'editions': [
                {
                  'id': 'unsafe-asset-edition',
                  'bookId': 'unsafe-asset-url',
                  'providerId': 'kitobkhon',
                  'sourceUrl': 'https://kitobkhon.net/book/fixture',
                  'readUrl': 'https://kitobkhon.net/storage/books/fixture.pdf',
                  'coverUrl': ?coverUrl,
                  'downloadUrl': ?downloadUrl,
                  'language': 'Тоҷикӣ',
                  'format': 'pdf',
                  'availability': 'readableExternal',
                  'rightsStatus': 'rightsUnclear',
                  'metadataNote': 'fixture',
                },
              ],
            });

        expect(
          () => repository.validateBooks([
            invalidBook(coverUrl: 'file:///private/cover.jpg'),
          ]),
          throwsFormatException,
        );
        expect(
          () => repository.validateBooks([
            invalidBook(downloadUrl: 'javascript:alert(1)'),
          ]),
          throwsFormatException,
        );
      },
    );

    test(
      'rejects unsafe local cover asset paths at the repository boundary',
      () {
        final book = Book.fromJson({
          'id': 'unsafe-local-cover',
          'canonicalTitle': 'Unsafe local cover',
          'titleTj': 'Unsafe local cover',
          'descriptionTj': 'Fixture',
          'language': 'Тоҷикӣ',
          'editions': [
            {
              'id': 'unsafe-local-cover-edition',
              'bookId': 'unsafe-local-cover',
              'providerId': 'kitobkhon',
              'sourceUrl': 'https://kitobkhon.net/book/fixture',
              'readUrl': 'https://kitobkhon.net/storage/books/fixture.pdf',
              'coverAssetPath': 'assets/data/books/covers/../secret.jpg',
              'language': 'Тоҷикӣ',
              'format': 'pdf',
              'availability': 'readableExternal',
              'rightsStatus': 'rightsUnclear',
              'metadataNote': 'fixture',
            },
          ],
        });

        expect(() => repository.validateBooks([book]), throwsFormatException);
      },
    );

    test('edition external-link getters expose only HTTPS URIs', () {
      const unsafeEdition = BookEdition(
        id: 'unsafe-direct-edition',
        bookId: 'unsafe-direct-book',
        providerId: 'fixture',
        sourceUrl: 'javascript:alert(1)',
        readUrl: 'file:///private/book.pdf',
        downloadUrl: 'http://example.test/book.pdf',
        coverUrl: 'zarbulmasal://cover',
        language: 'Тоҷикӣ',
        format: BookFormat.pdf,
        availability: BookAvailability.catalogueOnly,
        rightsStatus: BookRightsStatus.rightsUnclear,
        metadataNote: 'fixture',
      );
      const secureEdition = BookEdition(
        id: 'secure-direct-edition',
        bookId: 'secure-direct-book',
        providerId: 'fixture',
        sourceUrl: 'https://kitobkhon.net/catalogue',
        readUrl: 'https://kitobkhon.net/book.pdf',
        coverUrl: 'https://kitobkhon.net/cover.jpg',
        language: 'Тоҷикӣ',
        format: BookFormat.pdf,
        availability: BookAvailability.readableExternal,
        rightsStatus: BookRightsStatus.rightsUnclear,
        metadataNote: 'fixture',
      );

      expect(unsafeEdition.sourceUri, isNull);
      expect(unsafeEdition.readUri, isNull);
      expect(unsafeEdition.downloadUri, isNull);
      expect(unsafeEdition.coverUri, isNull);
      expect(unsafeEdition.canRead, isFalse);
      expect(unsafeEdition.hasCover, isFalse);
      expect(secureEdition.sourceUri, isNotNull);
      expect(secureEdition.readUri, isNotNull);
      expect(secureEdition.coverUri, isNotNull);
      expect(secureEdition.canRead, isTrue);
      expect(secureEdition.hasCover, isTrue);
    });

    test('rejects duplicate canonical ids and duplicate edition ids', () {
      final duplicate = Book.fromJson({
        'id': 'duplicate',
        'canonicalTitle': 'Duplicate',
        'titleTj': 'Duplicate',
        'descriptionTj': 'Fixture',
        'language': 'Тоҷикӣ',
        'editions': [],
      });
      expect(
        () => repository.validateBooks([duplicate, duplicate]),
        throwsFormatException,
      );
    });

    test(
      'book matching searches title, author, aliases, and categories',
      () async {
        final books = await repository.loadBooks();
        expect(books.any((book) => book.matches('Фирдавсӣ')), isTrue);
        expect(books.any((book) => book.matches('tarikh')), isTrue);
        expect(books.any((book) => book.matches('назм')), isTrue);
      },
    );
  });
}
