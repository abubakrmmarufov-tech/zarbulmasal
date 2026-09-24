import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/providers/learning_providers.dart';
import '../../helpers/test_helper.dart';

/// Persists a level activity into SharedPreferences before the app launches,
/// exactly as a real run would leave it across a restart. [id] is the
/// activity id whose numeric suffix the Continue card must parse (or guard
/// against when malformed).
Future<SharedPreferences> _prefsWithLevelActivity({
  required String id,
  Map<String, Object>? extra,
}) async {
  SharedPreferences.setMockInitialValues({
    'recent_activities': [
      jsonEncode({
        'id': id,
        'type': 'level',
        'title': 'Сатҳи 3',
        'titleTajik': 'Сатҳи 3',
        'subtitle': 'Омӯзиши қадам ба қадам',
        'subtitleTajik': 'Омӯзиши қадам ба қадам',
        'timestamp': DateTime.utc(2026, 9, 22, 8, 0, 0).toIso8601String(),
        'route': '/proverbs',
      }),
    ],
    AppConstants.prefsLanguage: 'tj',
    AppConstants.prefsOnboardingComplete: true,
    ...?extra,
  });
  return SharedPreferences.getInstance();
}

/// Asserts the level tab for [value] is the highlighted (selected) one.
void expectLevelTabSelected(
  WidgetTester tester,
  int value, {
  required bool selected,
}) {
  final tab = find.byKey(ValueKey('level-filter-$value'));
  expect(tab, findsOneWidget);
  final semantics = tester.widget<Semantics>(
    find.descendant(of: tab, matching: find.byType(Semantics)).first,
  );
  expect(semantics.properties.selected, selected);
}

void main() {
  group('Continue learning resumes the persisted level', () {
    testWidgets('restores the level filter after a fresh launch and opens the '
        'filtered proverb list', (tester) async {
      final prefs = await _prefsWithLevelActivity(id: 'level-3');
      final app = await openApp(
        tester,
        route: '/learn',
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      // The persisted activity surfaces the Continue card, but the
      // in-memory level filter is unset on a fresh launch.
      expect(
        find.text(
          AppTranslations.get(
            'learn_continue',
            DisplayLanguage.tajik,
          ).toUpperCase(),
        ),
        findsOneWidget,
      );
      expect(app.container.read(selectedLevelProvider), isNull);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      // The "03" tab is highlighted and the list is filtered to level 3:
      // proverb 21 is level 3, proverb 23 is level 2.
      expectLevelTabSelected(tester, 3, selected: true);
      expect(app.container.read(selectedLevelProvider), 3);
      expect(find.byKey(const ValueKey('21')), findsOneWidget);
      expect(find.byKey(const ValueKey('23')), findsNothing);
    });

    testWidgets('ignores a malformed level id and leaves the list unfiltered', (
      tester,
    ) async {
      final prefs = await _prefsWithLevelActivity(id: 'level-not-a-number');
      final app = await openApp(
        tester,
        route: '/learn',
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      // No level restored: the "all levels" tab stays selected and proverbs
      // from other levels are still listed (proverb 23 is level 2).
      expect(app.container.read(selectedLevelProvider), isNull);
      expectLevelTabSelected(tester, 3, selected: false);
      expect(find.byKey(const ValueKey('23')), findsOneWidget);
    });

    testWidgets('ignores a level that is absent from the catalog', (
      tester,
    ) async {
      final prefs = await _prefsWithLevelActivity(id: 'level-99');
      final app = await openApp(
        tester,
        route: '/learn',
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      expect(app.container.read(selectedLevelProvider), isNull);
      expect(find.byKey(const ValueKey('23')), findsOneWidget);
    });

    testWidgets(
      'clears a stale level filter when the persisted level is malformed '
      'and a different level is already selected',
      (tester) async {
        final prefs = await _prefsWithLevelActivity(id: 'level-not-a-number');
        final app = await openApp(
          tester,
          route: '/learn',
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        // Simulate a level chosen earlier in the session (e.g. on /levels):
        // the in-memory filter must not leak into /proverbs when the persisted
        // record cannot be resolved.
        app.container.read(selectedLevelProvider.notifier).state = 2;
        expect(app.container.read(selectedLevelProvider), 2);

        await tester.tap(find.byIcon(Icons.play_arrow_rounded));
        await tester.pumpAndSettle();

        // The stale filter is cleared, the "all levels" tab is selected, and
        // proverbs from other levels (id 23 is level 2) are listed again.
        expect(app.container.read(selectedLevelProvider), isNull);
        expectLevelTabSelected(tester, 2, selected: false);
        final allTab = find.byKey(const ValueKey('level-filter-all'));
        expect(allTab, findsOneWidget);
        final allSemantics = tester.widget<Semantics>(
          find.descendant(of: allTab, matching: find.byType(Semantics)).first,
        );
        expect(allSemantics.properties.selected, true);
        expect(find.byKey(const ValueKey('23')), findsOneWidget);
      },
    );
  });

  group('Learn Flashcards entry point', () {
    testWidgets('opens the full deck and resets a stale quiz filter', (
      tester,
    ) async {
      final app = await openApp(tester, route: '/learn');

      // Simulate the state a quiz "practice missed" handoff leaves behind:
      // the shared in-memory filter is pinned to "again".
      app.container.read(flashcardsFilterProvider.notifier).state =
          MasteryFilter.again;
      expect(app.container.read(flashcardsFilterProvider), MasteryFilter.again);

      // Learn lists are typographic rows (no decorative icons): find the
      // flashcards row by its title.
      final flashcards = find.text(
        AppTranslations.get('flashcards_title', DisplayLanguage.tajik),
      );
      await tester.ensureVisible(flashcards);
      await tester.tap(flashcards);
      await tester.pumpAndSettle();

      // The general entry point must not inherit the stale filter: the
      // deck opens on "All" with the All chip selected and no empty
      // "again" deck state.
      expect(app.container.read(flashcardsFilterProvider), MasteryFilter.all);
      final lang = DisplayLanguage.tajik;
      final total = app.container.read(proverbsProvider).length;
      final allChip = find.widgetWithText(
        ChoiceChip,
        '${AppTranslations.get('flashcards_filter_all', lang)} ($total)',
      );
      expect(allChip, findsOneWidget);
      expect(tester.widget<ChoiceChip>(allChip).selected, isTrue);
      expect(
        find.text(AppTranslations.get('flashcards_empty_filter', lang)),
        findsNothing,
      );
    });
  });
}
