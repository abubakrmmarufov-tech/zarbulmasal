import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/design_system/qalam_flash_card.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/data/models/learning_mastery.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/flashcards/flashcards_screen.dart';
import 'package:zarbulmasal/features/quiz/quiz_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/providers/learning_providers.dart';

void main() {
  group('ProverbMastery model', () {
    test('round-trips JSON correctly', () {
      final now = DateTime.utc(2026, 9, 17, 10, 0, 0);
      final original = ProverbMastery(
        proverbId: 'p-1',
        level: MasteryLevel.learning,
        reviewCount: 3,
        correctCount: 2,
        lastReviewedAt: now,
      );

      final jsonMap = original.toJson();
      final parsed = ProverbMastery.fromJson(jsonMap);

      expect(parsed.proverbId, 'p-1');
      expect(parsed.level, MasteryLevel.learning);
      expect(parsed.reviewCount, 3);
      expect(parsed.correctCount, 2);
      expect(parsed.lastReviewedAt, now);
      expect(parsed, equals(original));
    });

    test('handles fallback on empty/corrupted JSON', () {
      final parsed = ProverbMastery.fromJson({});
      expect(parsed.proverbId, '');
      expect(parsed.level, MasteryLevel.unseen);
      expect(parsed.reviewCount, 0);
      expect(parsed.correctCount, 0);
    });

    test('copyWith works correctly', () {
      final original = ProverbMastery(
        proverbId: 'p-1',
        level: MasteryLevel.again,
        lastReviewedAt: DateTime.now(),
      );
      final updated = original.copyWith(level: MasteryLevel.mastered);
      expect(updated.level, MasteryLevel.mastered);
      expect(updated.proverbId, 'p-1');
    });
  });

  group('ProverbMasteryNotifier', () {
    test('initializes empty when no prefs exist', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final map = container.read(proverbMasteryProvider);
      expect(map, isEmpty);
    });

    test('initializes from pre-seeded SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsMastery: json.encode({
          'p-1': {
            'proverbId': 'p-1',
            'level': 'mastered',
            'reviewCount': 5,
            'correctCount': 5,
            'lastReviewedAt': '2026-09-17T00:00:00.000Z',
          },
        }),
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(proverbMasteryProvider.notifier);
      expect(notifier.getLevel('p-1'), MasteryLevel.mastered);
      expect(notifier.getLevel('unseen-id'), MasteryLevel.unseen);
    });

    test('records review and persists to storage', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ProverbMasteryNotifier(prefs);

      await notifier.recordReview(
        'proverb-10',
        MasteryLevel.learning,
        isCorrect: true,
      );
      expect(notifier.getLevel('proverb-10'), MasteryLevel.learning);
      expect(notifier.state['proverb-10']?.reviewCount, 1);
      expect(notifier.state['proverb-10']?.correctCount, 1);

      await notifier.recordReview(
        'proverb-10',
        MasteryLevel.mastered,
        isCorrect: true,
      );
      expect(notifier.getLevel('proverb-10'), MasteryLevel.mastered);
      expect(notifier.state['proverb-10']?.reviewCount, 2);
      expect(notifier.state['proverb-10']?.correctCount, 2);

      // Verify raw storage content
      final raw = prefs.getString(AppConstants.prefsMastery);
      expect(raw, isNotNull);
      final decoded = json.decode(raw!) as Map<String, dynamic>;
      expect(decoded['proverb-10']['level'], 'mastered');
    });
  });

  group('MasteryStatsProvider', () {
    test('calculates counts accurately', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final stats0 = container.read(masteryStatsProvider);
      expect(stats0.masteredCount, 0);
      expect(stats0.learningCount, 0);
      expect(stats0.againCount, 0);
      expect(stats0.unseenCount, seedProverbs.length);
      expect(stats0.percentMastered, 0);

      // Record some items
      final notifier = container.read(proverbMasteryProvider.notifier);
      await notifier.recordReview(seedProverbs[0].id, MasteryLevel.mastered);
      await notifier.recordReview(seedProverbs[1].id, MasteryLevel.learning);
      await notifier.recordReview(seedProverbs[2].id, MasteryLevel.again);

      final stats1 = container.read(masteryStatsProvider);
      expect(stats1.masteredCount, 1);
      expect(stats1.learningCount, 1);
      expect(stats1.againCount, 1);
      expect(stats1.unseenCount, seedProverbs.length - 3);
    });
  });

  group('Flashcards Screen Widgets', () {
    testWidgets('renders filter bar and chips with live counts', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FlashcardsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ChoiceChip), findsNWidgets(4));
      expect(find.textContaining('Ҳама'), findsOneWidget);
      expect(find.textContaining('Бозхонӣ'), findsWidgets);
      expect(find.textContaining('Дар ёдгирӣ'), findsWidgets);
      expect(find.textContaining('Аз худ шуд'), findsWidgets);
    });

    testWidgets('shows empty filter state when no cards match filter', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FlashcardsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'Бозхонӣ' filter chip (0 cards initially)
      final againChip = find.widgetWithText(ChoiceChip, 'Бозхонӣ (0)');
      expect(againChip, findsOneWidget);
      await tester.tap(againChip);
      await tester.pumpAndSettle();

      expect(
        find.text(
          AppTranslations.get('flashcards_empty_filter', DisplayLanguage.tajik),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          AppTranslations.get('flashcards_empty_hint', DisplayLanguage.tajik),
        ),
        findsOneWidget,
      );
    });

    testWidgets('honors a missed-review filter selected before navigation', (
      tester,
    ) async {
      final missed = seedProverbs.first;
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          proverbsProvider.overrideWithValue([missed, seedProverbs[1]]),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(proverbMasteryProvider.notifier)
          .recordReview(missed.id, MasteryLevel.again, isCorrect: false);
      container.read(flashcardsFilterProvider.notifier).state =
          MasteryFilter.again;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FlashcardsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final againChip = find.widgetWithText(ChoiceChip, 'Бозхонӣ (1)');
      expect(againChip, findsOneWidget);
      expect(tester.widget<ChoiceChip>(againChip).selected, isTrue);
      expect(
        tester.widget<QalamFlashCard>(find.byType(QalamFlashCard)).proverb.id,
        missed.id,
      );
    });
  });

  group('Quiz Screen Cyrillic Directionality', () {
    testWidgets(
      'isolates Cyrillic text in LTR direction even in Persian locale',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              displayLanguageProvider.overrideWith(
                (ref) =>
                    DisplayLanguageNotifier(prefs)
                      ..state = DisplayLanguage.persian,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const QuizScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Answer first question
        final choice = find.byType(InkWell).first;
        await tester.tap(choice);
        await tester.pumpAndSettle();

        // Verify Directionality widget around review box is LTR
        final ltrWidgets = find.byWidgetPredicate(
          (w) => w is Directionality && w.textDirection == TextDirection.ltr,
        );
        expect(ltrWidgets, findsWidgets);
      },
    );
  });
}
