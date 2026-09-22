import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_book.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';
import 'package:zarbulmasal/features/history/presentation/history_detail_screen.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

const _entry = HistoryEntry(
  id: 'samanids',
  kind: HistoryEntryKind.dynasty,
  title: 'Сомониён',
  titlePersian: 'سامانیان',
  summary: 'Сулолаи маъруфи таърихи тоҷикон.',
  summaryPersian: 'دودمان نامدار تاریخ تاجیکان.',
  period: 'Асрҳои IX–X',
  periodPersian: 'قرن‌های ۹–۱۰',
  grade: '6',
  sourceBookId: 'history-6',
  sourceSection: 'Давлати Сомониён',
  capital: 'Бухоро',
  capitalPersian: 'بخارا',
  territory: 'Мовароуннаҳр',
  territoryPersian: 'ماوراءالنهر',
  keyFigures: ['Исмоили Сомонӣ'],
  keyFiguresPersian: ['اسماعیل سامانی'],
  significance: 'Маркази муҳими фарҳангӣ.',
  significancePersian: 'مرکز مهم فرهنگی.',
  dates: '819–999',
  datesPersian: '۸۱۹–۹۹۹',
  relatedAuthorIds: ['missing-author'],
  relatedWorkIds: ['missing-work'],
);

const _book = HistoryBook(
  id: 'history-6',
  grade: '6',
  title: 'Таърихи халқи тоҷик',
  titlePersian: 'تاریخ مردم تاجیک',
  author: 'Муаллиф',
  authorPersian: 'نویسنده',
  year: '2018',
  description: 'Китоби дарсӣ.',
  sourceUrl: 'https://maorif.tj/history',
);

Future<void> _pumpDetail(
  WidgetTester tester, {
  required String entryId,
  required Future<HistoryEntry?> Function() loadEntry,
  HistoryBook book = _book,
  DisplayLanguage language = DisplayLanguage.tajik,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({
    AppConstants.prefsLanguage: language == DisplayLanguage.persian
        ? 'fa'
        : 'tj',
  });
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      historyEntryByIdProvider(entryId).overrideWith((ref) => loadEntry()),
      historyBooksProvider.overrideWith((ref) => Future.value([book])),
      authorByIdProvider('missing-author').overrideWith((ref) async => null),
      approvedWorksProvider.overrideWith((ref) async => const []),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: HistoryDetailScreen(entryId: entryId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('history detail renders structured Tajik content and sources', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      entryId: _entry.id,
      loadEntry: () async => _entry,
    );

    expect(find.text('Сомониён'), findsOneWidget);
    expect(find.text('Сулолаи маъруфи таърихи тоҷикон.'), findsOneWidget);
    expect(find.text('Бухоро'), findsOneWidget);
    expect(find.text('Исмоили Сомонӣ'), findsOneWidget);
    expect(find.text('Аҳамияти таърихӣ'), findsOneWidget);
    expect(
      find.text('Сарчашмаи таълимӣ: Китоби дарсии «Таърихи халқи тоҷик»'),
      findsOneWidget,
    );
    expect(find.text('Мутолиа дар сомонаи расмӣ (maorif.tj)'), findsOneWidget);
    expect(find.text('missing-author'), findsOneWidget);
    expect(find.text('missing-work'), findsOneWidget);
  });

  testWidgets('history detail switches to Persian fields and direction', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      entryId: _entry.id,
      loadEntry: () async => _entry,
      language: DisplayLanguage.persian,
    );

    expect(find.text('سامانیان'), findsOneWidget);
    expect(find.text('دودمان نامدار تاریخ تاجیکان.'), findsOneWidget);
    expect(find.text('بخارا'), findsOneWidget);
    expect(find.text('اسماعیل سامانی'), findsOneWidget);
    expect(find.text('تاریخ مردم تاجیک (نویسنده)'), findsOneWidget);
    expect(find.byType(Directionality), findsWidgets);
  });

  testWidgets('Persian history detail hides untranslated fields and IDs', (
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
      relatedWorkIds: ['UNTRANSLATED_WORK_ID_SENTINEL'],
    );
    const book = HistoryBook(
      id: 'history-5',
      grade: '5',
      title: 'TAJIK_BOOK_TITLE_SENTINEL',
      author: 'TAJIK_BOOK_AUTHOR_SENTINEL',
      year: '2015',
      description: 'TAJIK_BOOK_DESCRIPTION_SENTINEL',
      sourceUrl: 'https://maorif.tj/libraries?category=27',
    );

    await _pumpDetail(
      tester,
      entryId: entry.id,
      loadEntry: () async => entry,
      book: book,
      language: DisplayLanguage.persian,
    );

    expect(find.text('ترجمهٔ فارسی عنوان در دسترس نیست'), findsWidgets);
    for (final sourceOnly in [
      'TAJIK_ENTRY_TITLE_SENTINEL',
      'TAJIK_SUMMARY_SENTINEL',
      'TAJIK_PERIOD_SENTINEL',
      'TAJIK_DATES_SENTINEL',
      'TAJIK_CAPITAL_SENTINEL',
      'TAJIK_TERRITORY_SENTINEL',
      'TAJIK_FIGURE_SENTINEL',
      'TAJIK_SIGNIFICANCE_SENTINEL',
      'TAJIK_SECTION_SENTINEL',
      'TAJIK_BOOK_TITLE_SENTINEL',
      'TAJIK_BOOK_AUTHOR_SENTINEL',
      'TAJIK_BOOK_DESCRIPTION_SENTINEL',
      'UNTRANSLATED_WORK_ID_SENTINEL',
    ]) {
      expect(find.text(sourceOnly), findsNothing, reason: sourceOnly);
    }
    expect(find.text('خلاصهٔ تاریخی'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history detail distinguishes missing and failed entries', (
    tester,
  ) async {
    await _pumpDetail(tester, entryId: 'missing', loadEntry: () async => null);
    expect(find.text('Сабти таърихӣ ёфт нашуд'), findsOneWidget);
    expect(find.text('Бозгашт ба таърих'), findsOneWidget);

    await _pumpDetail(
      tester,
      entryId: 'failed',
      loadEntry: () async => throw StateError('load failed'),
    );
    expect(find.text('Хато дар боргирии маълумот'), findsOneWidget);
  });
}
