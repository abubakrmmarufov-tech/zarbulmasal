import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_book.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';
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
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HistoryScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('history cards and book cards expose in-app details', (
    tester,
  ) async {
    await pumpHistoryScreen(tester);

    // 1. Verify textbook card tap opens in-app book detail sheet
    final bookCard = find.text('Таърихи халқи тоҷик: Замони ориёиҳо');
    expect(bookCard, findsOneWidget);
    await tester.tap(bookCard);
    await tester.pumpAndSettle();

    expect(find.text('Китоби дарсии синфи 5'), findsOneWidget);
    expect(find.text('Дидани мавзӯъҳои синфи 5'), findsOneWidget);

    // Tap "Дидани мавзӯъҳои синфи 5" to close sheet and filter by Grade 5
    await tester.tap(find.text('Дидани мавзӯъҳои синфи 5'));
    await tester.pumpAndSettle();

    // 2. Scroll down to see filtered Grade 5 history cards
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();

    expect(find.text('Тафсилот →'), findsOneWidget);

    // Tap the card to open in-app history entry detail sheet
    await tester.tap(find.text('Тафсилот →'));
    await tester.pumpAndSettle();

    expect(find.text('Хулосаи таърихӣ'), findsOneWidget);
    expect(find.text('Аҳамияти таърихӣ'), findsOneWidget);
    expect(
      find.text('Сарчашмаи таълимӣ: Китоби дарсии «Таърихи халқи тоҷик»'),
      findsOneWidget,
    );
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
    },
  );

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
