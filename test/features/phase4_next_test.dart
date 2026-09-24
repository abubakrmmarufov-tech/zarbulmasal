// Behaviour added in Phase 4 (roadmap NEXT): one collection index,
// end-of-text navigation, the desktop reading room, the History redesign
// and search quality.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/core/utils/search_normalizer.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/history/presentation/history_end_of_text.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/reader_end_of_text.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/providers/recent_activity_provider.dart';
import 'package:zarbulmasal/shared/widgets/reading_room.dart';

import '../helpers/test_helper.dart';

const _rudakiId = 'rudaki_buyi_juyi_muliyon_grade5_2017_p54';

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

final _worksOverrides = [
  approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
  literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
];

/// Search reads every catalogue; keep them local and settled.
final _searchOverrides = [
  ..._worksOverrides,
  literaryAuthorsProvider.overrideWith((ref) => Future.value(const [])),
  historyEntriesProvider.overrideWith((ref) => Future.value(const [])),
];

String tj(String key, [List<Object> args = const []]) =>
    AppTranslations.get(key, DisplayLanguage.tajik, args);

HistoryEntry _entry(String id, HistoryEntryKind kind) => HistoryEntry(
  id: id,
  kind: kind,
  title: id,
  summary: '',
  period: '',
  grade: '5',
  sourceBookId: 'history-5',
  sourceSection: '',
);

void main() {
  group('X1 · one collection index', () {
    testWidgets('Learn keeps practice only; school and lexicon live in '
        'Explore', (tester) async {
      await openApp(tester, route: '/learn');
      expect(find.text(tj('learn_school_title')), findsNothing);
      expect(find.text(tj('vocab_title')), findsNothing);
      expect(find.text(tj('quiz_title')), findsOneWidget);
    });
  });

  group('X2 · end-of-text navigation', () {
    testWidgets('a poem ends with its neighbours in the works collection', (
      tester,
    ) async {
      final index = _works.indexWhere((work) => work.id == _rudakiId);
      expect(index, greaterThanOrEqualTo(0));
      final app = await openApp(
        tester,
        route: '/literature/work/$_rudakiId',
        height: 1400,
        overrides: _worksOverrides,
      );
      final end = tester.widget<QalamEndOfText>(find.byType(QalamEndOfText));
      expect(end.previous?.title, index > 0 ? _works[index - 1].title : null);
      expect(
        end.next?.title,
        index + 1 < _works.length ? _works[index + 1].title : null,
      );
      expect(end.next, isNotNull, reason: 'fixture must have a next work');

      await tester.scrollUntilVisible(
        find.textContaining(tj('end_next')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.textContaining(tj('end_next')));
      await tester.pumpAndSettle();
      expect(
        app.router.state.uri.path,
        '/literature/work/${_works[index + 1].id}',
      );
    });

    testWidgets('a proverb steps through its own theme', (tester) async {
      final categoryId = seedProverbs.first.categoryId;
      final theme = seedProverbs
          .where((proverb) => proverb.categoryId == categoryId)
          .toList();
      expect(theme.length, greaterThanOrEqualTo(3));
      final app = await openApp(
        tester,
        route: '/proverb/${theme[1].id}',
        height: 2400,
        catalog: seedProverbs,
      );
      final end = tester.widget<QalamEndOfText>(find.byType(QalamEndOfText));
      expect(end.previous?.title, theme[0].tajikCyrillic);
      expect(end.next?.title, theme[2].tajikCyrillic);

      await tester.ensureVisible(find.textContaining(tj('end_next')));
      await tester.tap(find.textContaining(tj('end_next')));
      await tester.pumpAndSettle();
      expect(app.router.state.uri.path, '/proverb/${theme[2].id}');
    });

    test('history neighbours stay within the entry family, in list order', () {
      final entries = [
        _entry('empire-a', HistoryEntryKind.empire),
        _entry('person-a', HistoryEntryKind.person),
        _entry('dynasty-b', HistoryEntryKind.dynasty),
        _entry('person-b', HistoryEntryKind.person),
        _entry('empire-c', HistoryEntryKind.empire),
      ];
      final state = HistoryEndOfText.neighboursOf(entries[2], entries);
      expect(state.previous?.id, 'empire-a');
      expect(state.next?.id, 'empire-c');
      final person = HistoryEndOfText.neighboursOf(entries[1], entries);
      expect(person.previous, isNull);
      expect(person.next?.id, 'person-b');
    });
  });

  group('X4 · desktop reading room', () {
    testWidgets('the rail replaces the bottom bar from 1200 px', (
      tester,
    ) async {
      final app = await openApp(
        tester,
        width: 1440,
        height: 900,
        readingRoom: true,
      );
      expect(find.byType(DesktopRail), findsOneWidget);
      // Only the rail carries the destination labels.
      expect(find.text(tj('nav_explore')), findsOneWidget);

      await tester.tap(find.text(tj('nav_explore')));
      await tester.pumpAndSettle();
      expect(app.router.state.uri.path, '/explore');
    });

    testWidgets('phones keep the bottom bar and no rail', (tester) async {
      await openApp(tester, readingRoom: true);
      expect(find.byType(DesktopRail), findsNothing);
      expect(find.text(tj('nav_explore')), findsOneWidget);
    });

    testWidgets('the rail stays on pushed reading screens', (tester) async {
      await openApp(
        tester,
        route: '/literature/work/$_rudakiId',
        width: 1440,
        height: 900,
        readingRoom: true,
        overrides: _worksOverrides,
      );
      expect(find.byType(DesktopRail), findsOneWidget);
      // The connections sit in a context pane beside the text.
      final panes = tester.widgetList<ReaderEndOfText>(
        find.byType(ReaderEndOfText),
      );
      expect(panes.where((pane) => !pane.showNeighbours), hasLength(1));
    });

    testWidgets('below the pane breakpoint connections follow the poem', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/literature/work/$_rudakiId',
        readingRoom: true,
        overrides: _worksOverrides,
      );
      final panes = tester.widgetList<ReaderEndOfText>(
        find.byType(ReaderEndOfText, skipOffstage: false),
      );
      expect(panes, hasLength(1));
      expect(panes.single.showConnections, isTrue);
    });

    test('reading routes get the wide column; collections map to Explore', () {
      expect(ReadingRoom.isWideRoute('/literature/work/x'), isTrue);
      expect(ReadingRoom.isWideRoute('/proverbs'), isFalse);
      expect(ReadingRoom.destinationFor('/'), 0);
      expect(ReadingRoom.destinationFor('/history/x'), 1);
      expect(ReadingRoom.destinationFor('/quiz'), 2);
      expect(ReadingRoom.destinationFor('/saved/bayoz/1'), 3);
      expect(ReadingRoom.destinationFor('/settings'), isNull);
    });
  });

  group('X6 · search quality', () {
    test('match ranges map folded matches back to the original letters', () {
      const name = 'Абӯабдуллоҳи Рӯдакӣ';
      final start = name.indexOf('Рӯдакӣ');
      expect(SearchNormalizer.matchRange(name, 'руда'), (
        start: start,
        end: start + 4,
      ));
      expect(SearchNormalizer.matchRange(name, 'rudaki'), (
        start: start,
        end: start + 6,
      ));
      const persian = 'ابوعبدالله رودکی';
      expect(SearchNormalizer.matchRange(persian, 'رودکي'), (
        start: persian.indexOf('رودکی'),
        end: persian.length,
      ));
      expect(SearchNormalizer.matchRange(name, 'хирад'), isNull);
    });

    testWidgets('results highlight the match and fold long groups', (
      tester,
    ) async {
      const query = 'дил';
      final matching = seedProverbs
          .where(
            (proverb) => SearchNormalizer.matchesAny([
              proverb.tajikCyrillic,
              proverb.persianText,
              proverb.meaningTj,
              proverb.simpleExplanationTj,
            ], query),
          )
          .length;
      expect(matching, greaterThan(5), reason: 'needs a long group');
      await openApp(
        tester,
        route: '/search',
        height: 2400,
        catalog: seedProverbs,
        overrides: _searchOverrides,
      );
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();

      final showAll = tj('search_show_all', [matching.toString()]);
      expect(find.text(showAll), findsOneWidget);
      final highlighted = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.textSpan is TextSpan &&
            (widget.textSpan! as TextSpan).children!.any(
              (span) =>
                  span is TextSpan &&
                  span.style?.fontWeight == FontWeight.w700 &&
                  SearchNormalizer.normalize(span.text ?? '') == query,
            ),
      );
      expect(highlighted, findsWidgets);

      await tester.tap(find.text(showAll));
      await tester.pumpAndSettle();
      expect(find.text(showAll), findsNothing);
    });

    testWidgets('an empty query offers what was read recently', (tester) async {
      final app = await openApp(
        tester,
        route: '/search',
        catalog: seedProverbs,
        overrides: _searchOverrides,
      );
      app.container
          .read(recentActivityProvider.notifier)
          .addActivity(
            RecentActivity(
              id: 'rudaki',
              type: RecentActivityType.poet,
              title: 'Абӯабдуллоҳи Рӯдакӣ',
              titleTajik: 'Абӯабдуллоҳи Рӯдакӣ',
              timestamp: DateTime.utc(2026, 9, 24),
              route: '/literature/poet/rudaki',
            ),
          );
      await tester.pumpAndSettle();
      expect(find.text(tj('search_empty_prompt_title')), findsOneWidget);
      expect(
        find.widgetWithText(QalamIndexRow, 'Абӯабдуллоҳи Рӯдакӣ'),
        findsOneWidget,
      );
    });

    testWidgets('no results explain what to try and lead to the index', (
      tester,
    ) async {
      final app = await openApp(
        tester,
        route: '/search',
        catalog: seedProverbs,
        overrides: _searchOverrides,
      );
      await tester.enterText(find.byType(TextField), 'ққққққ');
      await tester.pumpAndSettle();
      expect(find.textContaining(tj('search_no_results_tip')), findsOneWidget);
      await tester.tap(find.text(tj('search_browse_index')));
      await tester.pumpAndSettle();
      expect(app.router.state.uri.path, '/explore');
    });
  });
}
