import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/books/presentation/book_display_text.dart';
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
      publisher: 'Маориф',
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

const untranslatedBook = Book(
  id: 'untranslated-book',
  canonicalTitle: 'Китоби тарҷуманашуда',
  titleTj: 'Китоби тарҷуманашуда',
  authorNameTj: 'Муаллифи тарҷуманашуда',
  descriptionTj: 'Тавсифи тарҷуманашуда.',
  language: 'Тоҷикӣ',
);

const longOriginalMetadataBook = Book(
  id: 'long-original-metadata-book',
  canonicalTitle: 'Китоби дорои унвони дароз',
  titleTj:
      'Унвони тоҷикӣ бо шарҳи пурраи таърихӣ ва библиографии нашри аслӣ барои намоиши комил дар саҳифаи китоб',
  authorNameTj:
      'Муаллифи асосӣ бо номи пурра ва номи иловагӣ, ки дар сабти аслии библиографӣ оварда шудааст',
  descriptionTj: 'Китоби санҷишӣ.',
  language: 'Тоҷикӣ',
);

const khiradBook = Book(
  id: 'khirad-fixture',
  canonicalTitle: 'Маснавии Маънавӣ (ҷилди 1)',
  titleTj: 'Маснавии Маънавӣ (ҷилди 1)',
  titleFa: 'مثنوی معنوی (جلد ۱)',
  authorNameTj: 'Мавлоно Ҷалолуддини Балхӣ',
  authorNameFa: 'مولانا جلال‌الدین بلخی',
  descriptionTj: 'Рисолаи манзуми фалсафӣ-ирфонӣ.',
  descriptionFa: 'رسالهٔ منظوم فلسفی-عرفانی.',
  language: 'Тоҷикӣ',
  categoryIds: ['nazm'],
  genres: ['poetry'],
  editions: [
    BookEdition(
      id: 'khirad-fixture-edition',
      bookId: 'khirad-fixture',
      providerId: 'khirad',
      sourceUrl: 'https://khirad.tj/books/fixture',
      readUrl: 'https://khirad.tj/books/read/fixture',
      publisher: 'Адиб',
      publicationYear: '2013',
      pageCount: 480,
      language: 'Тоҷикӣ',
      scripts: ['cyrillic'],
      categories: ['Адабиёт'],
      format: BookFormat.html,
      availability: BookAvailability.readableExternal,
      rightsStatus: BookRightsStatus.rightsUnclear,
      metadataNote: 'Метамаълумот аз саҳифаи провайдер.',
    ),
  ],
);

const khiradProvider = BookProvider(
  id: 'khirad',
  name: 'Хирад',
  domain: 'khirad.tj',
  catalogueUrl: 'https://khirad.tj/all-books',
  descriptionTj: 'Китобхонаи электронии «Хирад».',
  descriptionFa: 'کتابخانهٔ الکترونیکی «خرد».',
  supportsReader: true,
  supportsDownload: false,
  sourcePurpose: BookSourcePurpose.bookAvailability,
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

  test('Persian book metadata never falls back to Tajik text', () {
    const persian = DisplayLanguage.persian;

    expect(
      BookDisplayText.title(untranslatedBook, persian),
      isNot(contains('Китоби')),
    );
    expect(
      BookDisplayText.author(untranslatedBook, persian),
      isNot(contains('Муаллифи')),
    );
    expect(
      BookDisplayText.description(untranslatedBook, persian),
      isNot(contains('Тавсифи')),
    );
    expect(
      BookDisplayText.originalTitle(untranslatedBook, persian),
      'Китоби тарҷуманашуда',
    );
    expect(
      BookDisplayText.originalAuthor(untranslatedBook, persian),
      'Муаллифи тарҷуманашуда',
    );
    expect(
      BookDisplayText.originalTitle(untranslatedBook, DisplayLanguage.tajik),
      isNull,
    );
  });

  testWidgets(
    'Persian Books clearly labels original Tajik metadata on list and detail',
    (tester) async {
      await openApp(
        tester,
        route: '/books',
        language: DisplayLanguage.persian,
        overrides: [
          booksProvider.overrideWith((ref) => Future.value([untranslatedBook])),
          bookProvidersProvider.overrideWith((ref) => Future.value([])),
        ],
      );

      expect(find.text('عنوان اصلی تاجیکی'), findsOneWidget);
      expect(find.text('Китоби тарҷуманашуда'), findsOneWidget);
      expect(find.text('نام نویسندهٔ اصلی تاجیکی'), findsOneWidget);
      expect(find.text('Муаллифи тарҷуманашуда'), findsOneWidget);

      await tester.tap(find.text('عنوان فارسی کتاب در دسترس نیست').first);
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailScreen), findsOneWidget);
      expect(find.text('عنوان اصلی تاجیکی'), findsOneWidget);
      expect(find.text('Китоби тарҷуманашуда'), findsOneWidget);
      expect(find.text('نام نویسندهٔ اصلی تاجیکی'), findsOneWidget);
      expect(find.text('Муаллифи тарҷуманашуда'), findsOneWidget);
    },
  );

  testWidgets('Books route renders metadata, filters, and read affordance', (
    tester,
  ) async {
    await openApp(tester, route: '/books', overrides: overrides());

    expect(find.byType(BooksScreen), findsOneWidget);
    expect(find.text('Китобхона'), findsWidgets);
    expect(find.text('Китоби санҷишӣ'), findsWidgets);
    // The meta line carries the page count, not a bare label.
    expect(find.text('PDF · 2026 · 12 саҳифа'), findsOneWidget);
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

  testWidgets(
    'khirad books show Khirad provider labels and an HTML badge, never Kitobkhon or PDF',
    (tester) async {
      await openApp(
        tester,
        route: '/books',
        overrides: [
          booksProvider.overrideWith((ref) => Future.value([khiradBook])),
          bookProvidersProvider.overrideWith(
            (ref) => Future.value([khiradProvider]),
          ),
        ],
      );

      expect(find.byType(BooksScreen), findsOneWidget);
      // HTML reader record must not be labeled PDF on the list tile.
      // Format, year and pages now share one meta line ("HTML · …").
      expect(find.textContaining(RegExp(r'^HTML( ·|$)')), findsOneWidget);
      expect(find.textContaining(RegExp(r'^PDF( ·|$)')), findsNothing);

      await tester.tap(find.text('Маснавии Маънавӣ (ҷилди 1)').last);
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailScreen), findsOneWidget);
      expect(find.text('Хондан дар Хирад'), findsOneWidget);
      expect(find.text('Хондан дар Китобхон'), findsNothing);
      expect(find.textContaining('khirad.tj'), findsNothing);
      expect(find.text('Китобхон · kitobkhon.net'), findsNothing);
    },
  );

  testWidgets(
    'khirad provider labels localize in Persian without Kitobkhon attribution',
    (tester) async {
      await openApp(
        tester,
        route: '/books',
        language: DisplayLanguage.persian,
        overrides: [
          booksProvider.overrideWith((ref) => Future.value([khiradBook])),
          bookProvidersProvider.overrideWith(
            (ref) => Future.value([khiradProvider]),
          ),
        ],
      );

      await tester.tap(find.text('مثنوی معنوی (جلد ۱)').last);
      await tester.pumpAndSettle();

      expect(find.text('خواندن در خرد'), findsOneWidget);
      expect(find.text('خواندن در کتاب‌خوان'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('خرد · khirad.tj'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('خرد · khirad.tj'), findsOneWidget);
    },
  );

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
    expect(find.text('عنوان اصلی تاجیکی'), findsNothing);
    expect(find.text('نام نویسندهٔ اصلی تاجیکی'), findsNothing);
    expect(find.text('Муаллифи санҷишӣ'), findsNothing);
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
    expect(find.text('Манбаи санҷишӣ'), findsNothing);
    expect(find.text('ناشر اصلی تاجیکی'), findsOneWidget);
    expect(find.text('Маориф'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Маориф')).textDirection,
      TextDirection.ltr,
    );
    expect(find.text('۲۰۲۶'), findsOneWidget);
    expect(find.text('۱۲'), findsOneWidget);
    expect(
      find.text(
        'یادداشت فهرست منبع فقط به تاجیکی ثبت شده و برای حفظ دقت پنهان شده است.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Persian original metadata stays readable on a compact phone', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/books',
      width: 320,
      height: 568,
      language: DisplayLanguage.persian,
      overrides: [
        booksProvider.overrideWith((ref) => Future.value([untranslatedBook])),
        bookProvidersProvider.overrideWith((ref) => Future.value([])),
      ],
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('عنوان فارسی کتاب در دسترس نیست').first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('عنوان اصلی تاجیکی'), findsOneWidget);
    expect(find.text('Китоби тарҷуманашуда'), findsOneWidget);
  });

  testWidgets('Persian book detail shows full original source metadata', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/books/${longOriginalMetadataBook.id}',
      language: DisplayLanguage.persian,
      overrides: [
        booksProvider.overrideWith(
          (ref) => Future.value([longOriginalMetadataBook]),
        ),
        bookProvidersProvider.overrideWith((ref) => Future.value([])),
      ],
    );

    final title = find.text(longOriginalMetadataBook.titleTj);
    final author = find.text(longOriginalMetadataBook.authorNameTj!);
    expect(tester.widget<Text>(title).maxLines, isNull);
    expect(tester.widget<Text>(author).maxLines, isNull);
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
