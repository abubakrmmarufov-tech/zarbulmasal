import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_book.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';
import 'package:zarbulmasal/features/history/presentation/history_detail_screen.dart';
import 'package:zarbulmasal/features/history/presentation/history_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

Future<void> pumpHistoryScreen(
  WidgetTester tester, {
  List<HistoryBook>? books,
  List<HistoryEntry>? entries,
  DisplayLanguage language = DisplayLanguage.tajik,
  double width = 390,
  double height = 844,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({
    AppConstants.prefsLanguage: language == DisplayLanguage.persian
        ? 'fa'
        : 'tj',
  });

  final testBooks =
      books ??
      [
        const HistoryBook(
          id: 'history-5',
          grade: '5',
          title: 'Таърихи халқи тоҷик: Замони ориёиҳо',
          author: 'Юсуфшоҳ Яъқубов',
          year: '2015',
          description: 'Китоби дарсии синфи 5 оид ба замони қадим ва ориёиҳо.',
          sourceUrl: 'https://maorif.tj/libraries?category=27',
        ),
      ];

  final testEntries =
      entries ??
      [
        const HistoryEntry(
          id: 'spitamen',
          kind: HistoryEntryKind.person,
          title: 'Спитамен',
          summary:
              'Сарлашкар ва қаҳрамони муборизаи халқҳои Суғду Бохтар бар зидди лашкари Искандари Мақдунӣ.',
          period: 'Солҳои 329–327 пеш аз милод',
          grade: '5',
          sourceBookId: 'history-5',
          sourceSection: 'Муборизаи Спитамен',
          significance:
              'Рамзи фидокории миллӣ ва озодихоҳӣ дар таърихи тоҷикон.',
          dates: '329–327 п.м.',
        ),
      ];

  final container = ProviderContainer(
    overrides: [
      displayLanguageProvider.overrideWith((ref) => DisplayLanguageNotifier()),
      historyBooksProvider.overrideWith((ref) => Future.value(testBooks)),
      historyEntriesProvider.overrideWith((ref) => Future.value(testEntries)),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: GoRouter(
          initialLocation: '/history',
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: '/history/:id',
              builder: (context, state) =>
                  HistoryDetailScreen(entryId: state.pathParameters['id']!),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('textbook shelf and entry rows open in-app details', (
    tester,
  ) async {
    await pumpHistoryScreen(tester);

    // Entries come first; the textbook shelf lives under «By textbook».
    expect(find.text('Спитамен'), findsOneWidget);
    expect(find.text('Таърихи халқи тоҷик: Замони ориёиҳо'), findsNothing);
    await tester.tap(find.text('Китобҳои дарсӣ'));
    await tester.pumpAndSettle();

    // 1. The textbook card opens the in-app book sheet.
    final bookCard = find.text('Таърихи халқи тоҷик: Замони ориёиҳо');
    expect(bookCard, findsOneWidget);
    await tester.tap(bookCard);
    await tester.pumpAndSettle();

    expect(find.text('Китоби дарсии синфи 5'), findsOneWidget);
    expect(find.text('Дидани мавзӯъҳои синфи 5'), findsOneWidget);

    // "Дидани мавзӯъҳои синфи 5" closes the sheet and filters by grade 5.
    await tester.tap(find.text('Дидани мавзӯъҳои синфи 5'));
    await tester.pumpAndSettle();

    // 2. An entry row opens the entry page directly (no intermediate sheet).
    await tester.ensureVisible(find.text('Спитамен'));
    await tester.tap(find.text('Спитамен'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryDetailScreen), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Хулосаи таърихӣ'), findsOneWidget);
    expect(find.text('Аҳамияти таърихӣ'), findsOneWidget);
    expect(
      find.text('Сарчашмаи таълимӣ: Китоби дарсии «Таърихи халқи тоҷик»'),
      findsOneWidget,
    );
  });

  testWidgets('search is folded behind an icon until opened', (tester) async {
    await pumpHistoryScreen(tester);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Спитамен');
    await tester.pumpAndSettle();
    expect(find.text('Спитамен'), findsWidgets);
    // An active query keeps the field open.
    await tester.tap(find.byTooltip('Ҷустуҷӯ дар номҳо ва воқеаҳо'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('loaded history cards stay stable on a small large-text phone', (
    tester,
  ) async {
    await pumpHistoryScreen(tester, width: 320, height: 568);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'history filters expose source-backed events and oral narratives',
    (tester) async {
      await pumpHistoryScreen(
        tester,
        entries: const [
          HistoryEntry(
            id: 'event-test',
            kind: HistoryEntryKind.event,
            title: 'Рӯйдоди санҷишӣ',
            summary: 'Хулосаи рӯйдоди санҷишӣ.',
            period: 'Соли 1000',
            grade: '5',
            sourceBookId: 'history-5',
            sourceSection: 'Рӯйдодҳо',
          ),
          HistoryEntry(
            id: 'oral-test',
            kind: HistoryEntryKind.oral,
            title: 'Ривояти санҷишӣ',
            summary: 'Хулосаи ривояти санҷишӣ.',
            period: 'Замони қадим',
            grade: '5',
            sourceBookId: 'history-5',
            sourceSection: 'Ривоятҳо',
          ),
        ],
      );

      final events = find.widgetWithText(ChoiceChip, 'Рӯйдодҳо');
      await tester.ensureVisible(events);
      await tester.tap(events);
      await tester.pumpAndSettle();
      expect(tester.widget<ChoiceChip>(events).selected, isTrue);
      expect(find.text('Рӯйдоди санҷишӣ'), findsOneWidget);
      expect(find.text('Ривояти санҷишӣ'), findsNothing);

      final oralNarratives = find.widgetWithText(ChoiceChip, 'Ривоятҳо');
      await tester.ensureVisible(oralNarratives);
      await tester.tap(oralNarratives);
      await tester.pumpAndSettle();
      expect(tester.widget<ChoiceChip>(oralNarratives).selected, isTrue);
      expect(find.text('Ривояти санҷишӣ'), findsOneWidget);
      expect(find.text('Рӯйдоди санҷишӣ'), findsNothing);
    },
  );

  testWidgets(
    'Persian history filters retain clear event and narrative labels',
    (tester) async {
      await pumpHistoryScreen(tester, language: DisplayLanguage.persian);

      expect(find.widgetWithText(ChoiceChip, 'رویدادها'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'روایت‌ها'), findsOneWidget);
      final chips = find.byType(ChoiceChip);
      for (var index = 0; index < chips.evaluate().length; index++) {
        expect(
          tester.getSize(chips.at(index)).height,
          greaterThanOrEqualTo(48),
          reason: 'History filters must retain a 48dp touch target.',
        );
      }
    },
  );

  testWidgets('Persian history book card hides untranslated metadata', (
    tester,
  ) async {
    await pumpHistoryScreen(
      tester,
      language: DisplayLanguage.persian,
      books: const [
        HistoryBook(
          id: 'history-5',
          grade: '5',
          title: 'TAJIK_BOOK_TITLE_SENTINEL',
          author: 'TAJIK_BOOK_AUTHOR_SENTINEL',
          year: '2015',
          description: 'TAJIK_BOOK_DESCRIPTION_SENTINEL',
          sourceUrl: 'https://maorif.tj/libraries?category=27',
        ),
      ],
      entries: const [],
    );

    await tester.tap(find.text('کتاب‌های درسی'));
    await tester.pumpAndSettle();
    const pending = 'ترجمهٔ فارسی عنوان در دسترس نیست';
    expect(find.text(pending), findsOneWidget);
    expect(find.text('TAJIK_BOOK_TITLE_SENTINEL'), findsNothing);
    expect(find.text('TAJIK_BOOK_AUTHOR_SENTINEL'), findsNothing);

    await tester.tap(find.text(pending));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text(pending),
      ),
      findsOneWidget,
    );
    expect(find.text('TAJIK_BOOK_AUTHOR_SENTINEL'), findsNothing);
    expect(find.text('TAJIK_BOOK_DESCRIPTION_SENTINEL'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Persian history entry page hides untranslated source fields', (
    tester,
  ) async {
    const entry = HistoryEntry(
      id: 'persian-missing-fields',
      kind: HistoryEntryKind.person,
      title: 'TAJIK_ENTRY_TITLE_SENTINEL',
      summary: 'TAJIK_SUMMARY_SENTINEL',
      period: 'TAJIK_PERIOD_SENTINEL',
      dates: 'TAJIK_DATES_SENTINEL',
      grade: '5',
      sourceBookId: 'history-5',
      sourceSection: 'TAJIK_SECTION_SENTINEL',
      capital: 'TAJIK_CAPITAL_SENTINEL',
      territory: 'TAJIK_TERRITORY_SENTINEL',
      keyFigures: ['TAJIK_FIGURE_SENTINEL'],
      significance: 'TAJIK_SIGNIFICANCE_SENTINEL',
    );
    await pumpHistoryScreen(
      tester,
      language: DisplayLanguage.persian,
      entries: const [entry],
      books: const [
        HistoryBook(
          id: 'history-5',
          grade: '5',
          title: 'کتاب تاریخ ترجمه‌شده',
          titlePersian: 'کتاب تاریخ ترجمه‌شده',
          author: 'Нависанда',
          authorPersian: 'نویسنده',
          year: '2015',
          description: 'Тавсиф',
          descriptionPersian: 'توضیح',
          sourceUrl: 'https://maorif.tj/libraries?category=27',
        ),
      ],
    );

    const pending = 'ترجمهٔ فارسی عنوان در دسترس نیست';
    expect(find.text(pending), findsOneWidget);
    for (final sourceOnly in [
      'TAJIK_ENTRY_TITLE_SENTINEL',
      'TAJIK_SUMMARY_SENTINEL',
      'TAJIK_PERIOD_SENTINEL',
      'TAJIK_DATES_SENTINEL',
      'TAJIK_CAPITAL_SENTINEL',
      'TAJIK_TERRITORY_SENTINEL',
      'TAJIK_FIGURE_SENTINEL',
      'TAJIK_SIGNIFICANCE_SENTINEL',
    ]) {
      expect(find.text(sourceOnly), findsNothing, reason: sourceOnly);
    }

    await tester.ensureVisible(find.text(pending));
    await tester.tap(find.text(pending));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryDetailScreen), findsOneWidget);

    expect(find.text('TAJIK_SECTION_SENTINEL'), findsNothing);
    expect(find.text('TAJIK_ENTRY_TITLE_SENTINEL'), findsNothing);
    expect(find.text('TAJIK_SUMMARY_SENTINEL'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'grade 8 explains unavailable detail instead of a failed search',
    (tester) async {
      await pumpHistoryScreen(
        tester,
        books: [
          const HistoryBook(
            id: 'history-8',
            grade: '8',
            title: 'Таърихи халқи тоҷик',
            author: 'А. Мухторов',
            year: '2016',
            description: 'Source record only',
            sourceUrl: 'https://maorif.tj/libraries?category=27',
          ),
        ],
        entries: const [],
        width: 320,
        height: 568,
      );

      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -420));
      await tester.pumpAndSettle();
      final gradeEight = find.widgetWithText(ChoiceChip, 'Синфи 8');
      await tester.ensureVisible(gradeEight);
      await tester.tap(gradeEight);
      await tester.pumpAndSettle();

      expect(tester.widget<ChoiceChip>(gradeEight).selected, isTrue);
      expect(
        find.text('Барои синфи 8 феҳристи муфассал ҳоло дастрас нест'),
        findsOneWidget,
      );
      expect(find.text('Мундариҷа ёфт нашуд'), findsNothing);
    },
  );
}
