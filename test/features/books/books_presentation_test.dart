import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/books/presentation/presentation.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import '../../helpers/test_helper.dart';

const testBook = Book(
  id: 'books-fixture',
  canonicalTitle: 'Китоби санҷишӣ',
  titleTj: 'Китоби санҷишӣ',
  titleFa: 'کتاب آزمایشی',
  authorNameTj: 'Муаллифи санҷишӣ',
  authorNameFa: 'نویسندهٔ آزمایشی',
  descriptionTj: 'Маълумоти метамаълумотӣ.',
  descriptionFa: 'اطلاعات کتاب.',
  language: 'Тоҷикӣ',
  categoryIds: ['nazm'],
  genres: ['poetry'],
  editions: [
    BookEdition(
      id: 'books-fixture-edition',
      bookId: 'books-fixture',
      providerId: 'kitobkhon',
      sourceUrl: 'https://kitobkhon.net/book/books-fixture',
      readUrl: 'https://kitobkhon.net/storage/books/books-fixture.pdf',
      publicationYear: '2026',
      pageCount: 12,
      language: 'Тоҷикӣ',
      scripts: ['cyrillic'],
      categories: ['Назм'],
      format: BookFormat.pdf,
      availability: BookAvailability.readableExternal,
      rightsStatus: BookRightsStatus.rightsUnclear,
      metadataNote: 'Манбаи санҷишӣ',
    ),
  ],
);

const testProvider = BookProvider(
  id: 'kitobkhon',
  name: 'Китобхон',
  domain: 'kitobkhon.net',
  catalogueUrl: 'https://kitobkhon.net/books',
  descriptionTj: 'Каталог',
  descriptionFa: 'فهرست',
  catalogueSize: 1,
  authorCount: 1,
  categoryCount: 1,
  supportsReader: false,
  supportsDownload: true,
  sourcePurpose: BookSourcePurpose.bookAvailability,
);

void main() {
  List<Override> overrides() => [
    booksProvider.overrideWith((ref) => Future.value([testBook])),
    bookProvidersProvider.overrideWith((ref) => Future.value([testProvider])),
  ];

  testWidgets('Books route renders metadata, filters, and read affordance', (
    tester,
  ) async {
    await openApp(tester, route: '/books', overrides: overrides());

    expect(find.byType(BooksScreen), findsOneWidget);
    expect(find.text('Китобхона'), findsWidgets);
    expect(find.text('Китоби санҷишӣ'), findsWidgets);
    expect(find.byType(FilterChip), findsWidgets);

    await tester.tap(find.text('Китоби санҷишӣ').last);
    await tester.pumpAndSettle();
    expect(find.byType(BookDetailScreen), findsOneWidget);
    expect(find.text('Хондан дар Китобхон'), findsOneWidget);
    expect(find.text('Ҳуқуқи бознашр норӯшан аст'), findsOneWidget);
  });

  testWidgets('Books route localizes title, author, and direction in Persian', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/books',
      language: DisplayLanguage.persian,
      overrides: overrides(),
    );

    expect(find.text('کتابخانه'), findsWidgets);
    expect(find.text('کتاب آزمایشی'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(BooksScreen))),
      TextDirection.rtl,
    );
  });

  testWidgets('invalid book id shows a truthful unavailable state', (
    tester,
  ) async {
    await openApp(tester, route: '/books/missing', overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.text('Китобе ёфт нашуд'), findsOneWidget);
    expect(find.text('Хондан дар Китобхон'), findsNothing);
  });

  testWidgets('global search includes books and routes to the detail page', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/search',
      overrides: [
        booksProvider.overrideWith((ref) => Future.value([testBook])),
        literaryAuthorsProvider.overrideWith((ref) => Future.value([])),
        approvedWorksProvider.overrideWith((ref) => Future.value([])),
        historyEntriesProvider.overrideWith((ref) => Future.value([])),
      ],
    );

    final field = find.byType(TextField);
    await tester.enterText(field, 'санҷишӣ');
    await tester.pumpAndSettle();

    expect(find.text('Китоби санҷишӣ'), findsOneWidget);
    await tester.tap(find.text('Китоби санҷишӣ'));
    await tester.pumpAndSettle();
    expect(find.byType(BookDetailScreen), findsOneWidget);
  });
}
