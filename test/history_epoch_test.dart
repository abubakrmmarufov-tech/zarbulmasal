import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/data/history_repository.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/history/presentation/history_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  group('HistoryEpoch classification', () {
    test('classifies entries into appropriate historical epochs', () {
      const ancientEntry = HistoryEntry(
        id: 'spitamen',
        kind: HistoryEntryKind.person,
        title: 'Спитамен',
        summary: 'Мубориза бар зидди лашкари Искандари Мақдунӣ.',
        period: '558–330 то милод',
        grade: '5',
        sourceBookId: 'history-5',
        sourceSection: 'Муборизаи Спитамен',
      );
      expect(ancientEntry.epoch, HistoryEpoch.ancient);

      const samanidEntry = HistoryEntry(
        id: 'somoni-state',
        kind: HistoryEntryKind.empire,
        title: 'Давлати Сомониён',
        summary: 'Нахустин давлати мутамаркази тоҷикон.',
        period: 'Асрҳои IX–X милодӣ',
        grade: '7',
        sourceBookId: 'history-7',
        sourceSection: 'Ташкилёбии давлати Сомониён',
      );
      expect(samanidEntry.epoch, HistoryEpoch.samanid);

      const medievalEntry = HistoryEntry(
        id: 'temur-state',
        kind: HistoryEntryKind.empire,
        title: 'Давлати Темуриён',
        summary: 'Давлати бузурги асрҳои миёна.',
        period: 'Асрҳои XIV–XV милодӣ',
        grade: '7',
        sourceBookId: 'history-7',
        sourceSection: 'Давлати Темуриён',
      );
      expect(medievalEntry.epoch, HistoryEpoch.medieval);

      const enlightenmentEntry = HistoryEntry(
        id: 'ahmad-donish',
        kind: HistoryEntryKind.person,
        title: 'Аҳмади Дониш',
        summary: 'Сарвари ҳаракати маорифпарварӣ дар Аморати Бухоро.',
        period: 'Асри XIX милодӣ',
        grade: '9',
        sourceBookId: 'history-9',
        sourceSection: 'Маорифпарварӣ',
        keywords: ['маорифпарварӣ', 'ҷадид'],
      );
      expect(enlightenmentEntry.epoch, HistoryEpoch.enlightenment);

      const sovietEntry = HistoryEntry(
        id: 'tajik-assr',
        kind: HistoryEntryKind.event,
        title: 'Таъсиси ҶМШС Тоҷикистон',
        summary: 'Таъсиси ҷумҳурии автономии Тоҷикистон дар ҳайати Ӯзбекистон.',
        period: '1917–1929',
        grade: '10',
        sourceBookId: 'history-10',
        sourceSection: 'Таъсиси ҶМШС',
        keywords: ['шӯравӣ'],
      );
      expect(sovietEntry.epoch, HistoryEpoch.soviet);

      const independenceEntry = HistoryEntry(
        id: 'independence-tajikistan',
        kind: HistoryEntryKind.event,
        title: 'Истиқлолияти давлатии Тоҷикистон',
        summary: 'Эъломияи истиқлолияти давлатӣ.',
        period: '1991 то давраи муосир',
        grade: '11',
        sourceBookId: 'history-11',
        sourceSection: 'Истиқлолият',
      );
      expect(independenceEntry.epoch, HistoryEpoch.independence);
    });
  });

  group('HistoryRepository search with epoch', () {
    test('filters by epoch and search diacritics', () {
      final repo = HistoryRepository();
      const entries = [
        HistoryEntry(
          id: '1',
          kind: HistoryEntryKind.person,
          title: 'Исмоили Сомонӣ',
          summary: 'Амири одил ва бунёдгузори давлати мутамарказ.',
          period: 'Асрҳои IX–X милодӣ',
          grade: '7',
          sourceBookId: 'b1',
          sourceSection: 'Сомониён',
        ),
        HistoryEntry(
          id: '2',
          kind: HistoryEntryKind.person,
          title: 'Спитамен',
          summary: 'Қаҳрамони озодихоҳ.',
          period: 'Замони бостон',
          grade: '5',
          sourceBookId: 'b2',
          sourceSection: 'Спитамен',
        ),
      ];

      // Epoch filter
      final samanids = repo.search(entries, '', epoch: HistoryEpoch.samanid);
      expect(samanids.length, 1);
      expect(samanids.first.title, 'Исмоили Сомонӣ');

      final ancient = repo.search(entries, '', epoch: HistoryEpoch.ancient);
      expect(ancient.length, 1);
      expect(ancient.first.title, 'Спитамен');

      // Diacritic folding search in Cyrillic
      final diacriticSearch = repo.search(
        entries,
        'исмоили сомони',
      ); // without macron
      expect(diacriticSearch.length, 1);
      expect(diacriticSearch.first.id, '1');

      // Search by capital, significance, or dates
      const entriesWithMetadata = [
        HistoryEntry(
          id: 'peshdod',
          kind: HistoryEntryKind.empire,
          title: 'Пешдодиён',
          summary: 'Сулолаи шоҳони асотирӣ.',
          period: 'Асотирӣ',
          grade: '5',
          sourceBookId: 'b1',
          sourceSection: 'Пешдодиён',
          capital: 'Балх',
          significance: 'Сарчашмаи давлатдории ориёӣ',
          dates: 'Давраи бостон',
        ),
      ];
      final capitalSearch = repo.search(entriesWithMetadata, 'балх');
      expect(capitalSearch.length, 1);
      expect(capitalSearch.first.id, 'peshdod');

      final significanceSearch = repo.search(
        entriesWithMetadata,
        'давлатдории ориёи',
      );
      expect(significanceSearch.length, 1);
      expect(significanceSearch.first.id, 'peshdod');
    });
  });

  group('HistoryScreen ViewMode interaction', () {
    testWidgets('allows switching between timeline, canon, and topics', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({
        AppConstants.prefsLanguage: 'tj',
      });

      const testBooks = [
        HistoryBook(
          id: 'history-5',
          grade: '5',
          title: 'Таърихи халқи тоҷик: Замони ориёиҳо',
          author: 'Юсуфшоҳ Яъқубов',
          year: '2015',
          description: 'Китоби дарсии синфи 5.',
          sourceUrl: 'https://maorif.tj/libraries?category=27',
        ),
      ];

      const testEntries = [
        HistoryEntry(
          id: 'spitamen',
          kind: HistoryEntryKind.person,
          title: 'Спитамен',
          summary: 'Сарлашкар ва қаҳрамони муборизаи халқҳои Суғду Бохтар.',
          period: '558–330 то милод',
          grade: '5',
          sourceBookId: 'history-5',
          sourceSection: 'Муборизаи Спитамен',
        ),
        HistoryEntry(
          id: 'somoni',
          kind: HistoryEntryKind.person,
          title: 'Исмоили Сомонӣ',
          summary: 'Амири Сомониён.',
          period: 'Асрҳои IX–X милодӣ',
          grade: '7',
          sourceBookId: 'history-7',
          sourceSection: 'Сомониён',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          displayLanguageProvider.overrideWith(
            (ref) => DisplayLanguageNotifier(),
          ),
          historyBooksProvider.overrideWith((ref) => Future.value(testBooks)),
          historyEntriesProvider.overrideWith(
            (ref) => Future.value(testEntries),
          ),
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

      // Verify mode chips exist
      expect(find.text('Хатти замон'), findsOneWidget);
      expect(find.text('Китобҳои дарсӣ'), findsOneWidget);
      expect(find.text('Мавзӯъҳо'), findsOneWidget);

      // Initially on timeline view: epochs are shown
      expect(find.text('Бостон ва ориёӣ'), findsOneWidget);
      expect(find.text('Сомониён ва эҳё'), findsOneWidget);

      // Filter by Samanids epoch
      await tester.tap(find.text('Сомониён ва эҳё'));
      await tester.pumpAndSettle();

      expect(find.text('Исмоили Сомонӣ'), findsOneWidget);
      expect(find.text('Спитамен'), findsNothing);

      // Switch to Canon mode
      await tester.tap(find.text('Китобҳои дарсӣ'));
      await tester.pumpAndSettle();

      expect(find.text('Синфи 5'), findsWidgets);
      expect(find.text('Синфи 7'), findsWidgets);

      // Filter by Grade 5 (the chip; the textbook shelf above it also
      // names grades).
      await tester.tap(find.widgetWithText(ChoiceChip, 'Синфи 5'));
      await tester.pumpAndSettle();

      expect(find.text('Спитамен'), findsOneWidget);
      expect(find.text('Исмоили Сомонӣ'), findsNothing);
    });
  });
}
