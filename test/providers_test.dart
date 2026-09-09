import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/data/seed/seed_categories.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

Future<void> preferencesLoaded() async {
  await SharedPreferences.getInstance();
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'catalog keeps unique identifiers, valid categories and both scripts',
    () {
      final ids = seedProverbs.map((p) => p.id).toSet();
      final categories = seedCategories.map((c) => c.id).toSet();
      expect(ids.length, seedProverbs.length);
      expect(seedProverbs, isNotEmpty);
      for (final proverb in seedProverbs) {
        expect(categories, contains(proverb.categoryId));
        expect(proverb.level, inInclusiveRange(1, 6));
        expect(proverb.tajikCyrillic, matches(RegExp(r'[А-Яа-яӢӣҚқҒғҲҳҶҷӮӯ]')));
        expect(proverb.persianText, matches(RegExp(r'[\u0600-\u06ff]')));
        expect(proverb.meaningTj, isNotEmpty);
        expect(proverb.simpleExplanationTj, isNotEmpty);
        expect(proverb.exampleSentenceTj, isNotEmpty);
        expect(proverb.sourceStatus, SourceStatus.verified);
        expect(proverb.sourceNote, isNot(equals('Сарчашма номаълум.')));
      }
    },
  );

  test('available levels are derived from real catalog content', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final availableLevels = container.read(availableLevelsProvider);

    expect(availableLevels, [1, 2, 3, 4, 5, 6]);
    for (final level in availableLevels) {
      expect(seedProverbs.any((proverb) => proverb.level == level), isTrue);
    }
    expect(availableLevels, isNot(contains(anyOf(7, 8, 9, 10))));
  });

  test('available levels are sorted, unique, bounded, and immutable', () {
    final sparseCatalog = [
      seedProverbs[0].copyWith(id: 'level-6-a', level: 6),
      seedProverbs[1].copyWith(id: 'level-2', level: 2),
      seedProverbs[2].copyWith(id: 'level-6-b', level: 6),
      seedProverbs[3].copyWith(id: 'invalid-low', level: 0),
      seedProverbs[4].copyWith(id: 'invalid-high', level: 11),
    ];
    final sparse = ProviderContainer(
      overrides: [proverbsProvider.overrideWithValue(sparseCatalog)],
    );
    addTearDown(sparse.dispose);

    final available = sparse.read(availableLevelsProvider);
    expect(available, [2, 6]);
    expect(() => available.add(4), throwsUnsupportedError);

    final empty = ProviderContainer(
      overrides: [proverbsProvider.overrideWithValue(const [])],
    );
    addTearDown(empty.dispose);
    expect(empty.read(availableLevelsProvider), isEmpty);
  });

  test('copyWith preserves original content and provenance', () {
    final original = seedProverbs.first;
    final updated = original.copyWith(level: 10, id: 'copy');
    expect(original.level, isNot(10));
    expect(updated.id, 'copy');
    expect(updated.tajikCyrillic, original.tajikCyrillic);
    expect(updated.persianText, original.persianText);
    expect(updated.sourceNote, original.sourceNote);
    expect(updated.sourceStatus, original.sourceStatus);
  });

  test('search finds Cyrillic, Persian and meanings and combines filters', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final target = seedProverbs.first;
    expect(container.read(filteredProverbsProvider), seedProverbs);
    for (final query in [
      target.tajikCyrillic.toUpperCase(),
      target.persianText,
      target.meaningTj,
    ]) {
      container.read(searchQueryProvider.notifier).state = query;
      expect(container.read(filteredProverbsProvider), contains(target));
    }
    container.read(searchQueryProvider.notifier).state = '';
    container.read(selectedCategoryProvider.notifier).state = target.categoryId;
    container.read(selectedLevelProvider.notifier).state = target.level;
    final combined = container.read(filteredProverbsProvider);
    expect(combined, contains(target));
    expect(
      combined.every(
        (p) => p.categoryId == target.categoryId && p.level == target.level,
      ),
      isTrue,
    );
    container.read(searchQueryProvider.notifier).state =
        'no-such-proverb-83971';
    expect(container.read(filteredProverbsProvider), isEmpty);
    container.read(searchQueryProvider.notifier).state = '';
    container.read(selectedCategoryProvider.notifier).state = null;
    container.read(selectedLevelProvider.notifier).state = null;
    expect(
      container.read(filteredProverbsProvider).length,
      seedProverbs.length,
    );
  });

  test(
    'favorites add/remove immutably and survive provider recreation',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(favoritesProvider);
      await preferencesLoaded();
      final before = container.read(favoritesProvider);
      await container
          .read(favoritesProvider.notifier)
          .toggle(seedProverbs.first.id);
      expect(before, isEmpty);
      expect(
        container.read(favoritesProvider),
        contains(seedProverbs.first.id),
      );
      expect(container.read(favoritesListProvider), [seedProverbs.first]);
      final recreated = ProviderContainer();
      addTearDown(recreated.dispose);
      recreated.read(favoritesProvider);
      await preferencesLoaded();
      expect(recreated.read(favoritesListProvider), [seedProverbs.first]);
      expect(
        recreated
            .read(favoritesProvider.notifier)
            .isFavorite(seedProverbs.first.id),
        isTrue,
      );
      await recreated
          .read(favoritesProvider.notifier)
          .toggle(seedProverbs.first.id);
      expect(recreated.read(favoritesProvider), isEmpty);
      expect(
        (await SharedPreferences.getInstance()).getStringList(
          AppConstants.prefsFavorites,
        ),
        isEmpty,
      );
    },
  );

  test('stale saved identifiers do not fabricate proverb content', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefsFavorites: ['deleted-id', seedProverbs.last.id],
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(favoritesProvider);
    await preferencesLoaded();
    expect(container.read(favoritesListProvider), [seedProverbs.last]);
  });

  test('language selection survives restart in both directions', () async {
    final notifier = DisplayLanguageNotifier();
    addTearDown(notifier.dispose);
    await preferencesLoaded();
    expect(notifier.state, DisplayLanguage.tajik);
    await notifier.setLanguage(DisplayLanguage.persian);
    expect(
      (await SharedPreferences.getInstance()).getString(
        AppConstants.prefsLanguage,
      ),
      'fa',
    );
    final recreated = DisplayLanguageNotifier();
    addTearDown(recreated.dispose);
    await preferencesLoaded();
    expect(recreated.state, DisplayLanguage.persian);
    await recreated.setLanguage(DisplayLanguage.tajik);
    expect(recreated.state, DisplayLanguage.tajik);
    expect(
      (await SharedPreferences.getInstance()).getString(
        AppConstants.prefsLanguage,
      ),
      'tj',
    );
  });

  test('light/dark theme survives restart and toggles back', () async {
    final notifier = ThemeModeNotifier();
    addTearDown(notifier.dispose);
    await preferencesLoaded();
    expect(notifier.state, ThemeMode.light);
    await notifier.toggleTheme();
    expect(notifier.state, ThemeMode.dark);
    final recreated = ThemeModeNotifier();
    addTearDown(recreated.dispose);
    await preferencesLoaded();
    expect(recreated.state, ThemeMode.dark);
    await recreated.toggleTheme();
    expect(recreated.state, ThemeMode.light);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppConstants.prefsDarkMode,
      ),
      isFalse,
    );
  });

  test('onboarding completion survives provider recreation', () async {
    final first = ProviderContainer();
    first.read(onboardingCompleteProvider);
    await preferencesLoaded();
    await first.read(onboardingCompleteProvider.notifier).complete();
    first.dispose();

    final recreated = ProviderContainer();
    addTearDown(recreated.dispose);
    recreated.read(onboardingCompleteProvider);
    await preferencesLoaded();
    expect(recreated.read(onboardingCompleteProvider), isTrue);
  });

  test(
    'daily content is real, consistent today and handles an empty catalog',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final daily = container.read(dailyProverbProvider);
      expect(seedProverbs, contains(daily));
      container.invalidate(dailyProverbProvider);
      expect(container.read(dailyProverbProvider), daily);
      final empty = ProviderContainer(
        overrides: [proverbsProvider.overrideWithValue([])],
      );
      addTearDown(empty.dispose);
      expect(empty.read(dailyProverbProvider), isNull);
      expect(empty.read(filteredProverbsProvider), isEmpty);
    },
  );

  test(
    'both translation catalogs contain all interface keys and interpolate',
    () {
      expect(AppTranslations.fa.keys.toSet(), AppTranslations.tj.keys.toSet());
      expect(
        AppTranslations.get('app_name', DisplayLanguage.tajik),
        'Зарбулмасал',
      );
      expect(
        AppTranslations.get('app_name', DisplayLanguage.persian),
        'ضرب‌المثل',
      );
      for (final language in DisplayLanguage.values) {
        final result = AppTranslations.get('quiz_correct_of', language, [3, 5]);
        final expectedThree = language == DisplayLanguage.persian ? '۳' : '3';
        final expectedFive = language == DisplayLanguage.persian ? '۵' : '5';
        expect(result, contains(expectedThree));
        expect(result, contains(expectedFive));
        expect(result, isNot(contains(r'${')));
        for (final key in AppTranslations.tj.keys) {
          expect(
            AppTranslations.get(key, language),
            isNotEmpty,
            reason: '$language / $key',
          );
        }
      }
      expect(
        AppTranslations.get('levels_subtitle', DisplayLanguage.persian, [6]),
        '۶ سطح موجود',
      );
    },
  );

  test(
    'translations preserve authentic Tajik terminology and diacritic integrity',
    () {
      expect(
        AppTranslations.get('progression_advanced', DisplayLanguage.tajik),
        'Пешрафта',
      );
      expect(
        AppTranslations.get('progression_advanced', DisplayLanguage.persian),
        'پیشرفته',
      );
      expect(
        AppTranslations.get('quiz_loading', DisplayLanguage.tajik),
        'Боргирӣ...',
      );
      expect(
        AppTranslations.get('flashcards_loading', DisplayLanguage.tajik),
        'Боргирӣ...',
      );
      expect(
        AppTranslations.get('settings_inactive', DisplayLanguage.tajik),
        'Ғайрифаъол',
      );

      // Verify no Russian loanword relics remain in Tajik translations
      for (final entry in AppTranslations.tj.entries) {
        expect(
          entry.value,
          isNot(contains('Загрузка')),
          reason: 'Key ${entry.key} contains Russian loanword Загрузка',
        );
        expect(
          entry.value,
          isNot(contains('Продвинута')),
          reason: 'Key ${entry.key} contains Russian loanword Продвинута',
        );
        expect(
          entry.value,
          isNot(contains('Гайрифаъол')),
          reason: 'Key ${entry.key} contains missing diacritic Гайрифаъол',
        );
      }
    },
  );
}
