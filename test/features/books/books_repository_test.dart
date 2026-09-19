import 'package:flutter_riverpod/flutter_riverpod.dart';
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
