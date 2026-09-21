import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/books/presentation/presentation.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';
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

const bookWithoutAuthor = Book(
  id: 'book-without-author',
  canonicalTitle: 'Китоби бе муаллиф',
  titleTj: 'Китоби бе муаллиф',
  titleFa: 'کتاب بدون نویسنده',
  descriptionTj: 'Маълумоти манбаъ.',
  descriptionFa: 'اطلاعات منبع.',
  language: 'Тоҷикӣ',
  editions: [
    BookEdition(
      id: 'book-without-author-edition',
      bookId: 'book-without-author',
      providerId: 'kitobkhon',
      sourceUrl: 'https://kitobkhon.net/book/book-without-author',
      readUrl: 'https://kitobkhon.net/storage/books/book-without-author.pdf',
      language: 'Тоҷикӣ',
      format: BookFormat.pdf,
      availability: BookAvailability.readableExternal,
      rightsStatus: BookRightsStatus.rightsUnclear,
      metadataNote: 'Манбаи санҷишӣ',
    ),
  ],
);

const bookWithRelatedPoet = Book(
  id: 'book-with-related-poet',
  canonicalTitle: 'Китоби вобаста',
  titleTj: 'Китоби вобаста',
  titleFa: 'کتاب مرتبط',
  authorNameTj: 'Муаллифи санҷишӣ',
  authorNameFa: 'نویسندهٔ آزمایشی',
  descriptionTj: 'Китоби дорои робитаи санҷишӣ.',
  descriptionFa: 'کتابی با پیوند آزمایشی.',
  language: 'Тоҷикӣ',
  relatedPoetIds: ['rudaki'],
  editions: [
    BookEdition(
      id: 'book-with-related-poet-edition',
      bookId: 'book-with-related-poet',
      providerId: 'kitobkhon',
      sourceUrl: 'https://kitobkhon.net/book/book-with-related-poet',
      readUrl: 'https://kitobkhon.net/storage/books/book-with-related-poet.pdf',
      language: 'Тоҷикӣ',
      format: BookFormat.pdf,
      availability: BookAvailability.readableExternal,
      rightsStatus: BookRightsStatus.rightsUnclear,
      metadataNote: 'Манбаи санҷишӣ',
    ),
  ],
);

const testRelatedPoet = LiteraryAuthor(
  id: 'rudaki',
  canonicalName: 'Абӯабдуллоҳи Рӯдакӣ',
  canonicalNamePersian: 'ابوعبدالله رودکی',
  literaryPeriod: 'Асри IX-X',
  biographyTj: 'Сардафтари адабиёти классикии тоҷик.',
  biographySource: 'Адабиёти тоҷик, синфи 5, с. 49',
  biographyTjProvenance: 'SOURCE_BACKED',
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Public domain author.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
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
    for (
      var index = 0;
      index < find.byType(FilterChip).evaluate().length;
      index++
    ) {
      expect(
        tester.getSize(find.byType(FilterChip).at(index)).height,
        greaterThanOrEqualTo(48),
        reason: 'Book filters must retain a 48dp touch target.',
      );
    }

    await tester.tap(find.text('Китоби санҷишӣ').last);
    await tester.pumpAndSettle();
    expect(find.byType(BookDetailScreen), findsOneWidget);
    expect(find.text('Хондан дар Китобхон'), findsOneWidget);
    expect(find.text('Ҳуқуқи бознашр норӯшан аст'), findsOneWidget);
    expect(find.text('Муаллиф дар феҳристи манбаъ'), findsOneWidget);
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
    expect(find.text('کتاب آزمایشی'), findsWidgets);
    expect(
      find.text('Китоби санҷишӣ'),
      findsNothing,
      reason: 'Cover placeholders must use the active Persian title.',
    );
    expect(
      Directionality.of(tester.element(find.byType(BooksScreen))),
      TextDirection.rtl,
    );
    await tester.tap(find.text('کتاب آزمایشی').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Kitobkhon · kitobkhon.net'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kitobkhon · kitobkhon.net'), findsOneWidget);
    expect(find.text('زبان تاجیکی'), findsOneWidget);
    expect(find.text('خط سیریلیک'), findsOneWidget);
    expect(find.text('cyrillic'), findsNothing);
  });

  testWidgets('invalid book id shows a truthful unavailable state', (
    tester,
  ) async {
    await openApp(tester, route: '/books/missing', overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.text('Китобе ёфт нашуд'), findsOneWidget);
    expect(find.text('Хондан дар Китобхон'), findsNothing);
  });

  testWidgets(
    'missing source author is disclosed instead of silently omitted',
    (tester) async {
      await openApp(
        tester,
        route: '/books',
        overrides: [
          booksProvider.overrideWith(
            (ref) => Future.value([bookWithoutAuthor]),
          ),
          bookProvidersProvider.overrideWith(
            (ref) => Future.value([testProvider]),
          ),
        ],
      );

      expect(
        find.text('Муаллиф дар маълумоти манбаъ нишон дода нашудааст'),
        findsOneWidget,
      );
      await tester.tap(find.text('Китоби бе муаллиф').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Муаллиф дар маълумоти манбаъ нишон дода нашудааст'),
        findsOneWidget,
      );
    },
  );

  testWidgets('missing source author is disclosed in Persian', (tester) async {
    await openApp(
      tester,
      route: '/books',
      language: DisplayLanguage.persian,
      overrides: [
        booksProvider.overrideWith((ref) => Future.value([bookWithoutAuthor])),
        bookProvidersProvider.overrideWith(
          (ref) => Future.value([testProvider]),
        ),
      ],
    );

    expect(
      find.text('نام نویسنده در اطلاعات منبع ذکر نشده است'),
      findsOneWidget,
    );
    await tester.tap(find.text('کتاب بدون نویسنده').last);
    await tester.pumpAndSettle();
    expect(
      find.text('نام نویسنده در اطلاعات منبع ذکر نشده است'),
      findsOneWidget,
    );
  });

  testWidgets('book detail renders related poets and routes to their dossier', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/books/${bookWithRelatedPoet.id}',
      overrides: [
        booksProvider.overrideWith(
          (ref) => Future.value([bookWithRelatedPoet]),
        ),
        literaryAuthorsProvider.overrideWith(
          (ref) => Future.value([testRelatedPoet]),
        ),
        literaryWorksProvider.overrideWith((ref) => Future.value([])),
        schoolCanonProvider.overrideWith((ref) => Future.value([])),
      ],
    );

    expect(find.text('Шоирони вобаста дар Мероси адабӣ'), findsOneWidget);
    expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);

    await tester.tap(find.text('Абӯабдуллоҳи Рӯдакӣ'));
    await tester.pumpAndSettle();
    expect(find.byType(PoetDetailScreen), findsOneWidget);
  });

  testWidgets('book-detail load failure retries the failed catalog request', (
    tester,
  ) async {
    var loadAttempts = 0;
    await openApp(
      tester,
      route: '/books/${testBook.id}',
      overrides: [
        booksProvider.overrideWith((ref) async {
          loadAttempts += 1;
          if (loadAttempts == 1) {
            throw StateError('Simulated catalog failure');
          }
          return [testBook];
        }),
      ],
    );

    final retry = find.byType(OutlinedButton);
    expect(retry, findsOneWidget);
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(loadAttempts, 2);
    expect(find.text('Хондан дар Китобхон'), findsOneWidget);
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
