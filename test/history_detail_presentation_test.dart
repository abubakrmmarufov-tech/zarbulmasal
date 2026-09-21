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
      historyBooksProvider.overrideWith((ref) => Future.value([_book])),
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
