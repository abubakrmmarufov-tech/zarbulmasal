import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/search_normalizer.dart';
import '../../data/models/proverb.dart';
import '../../data/models/category.dart';
import '../../data/seed/seed_categories.dart';
import '../../data/seed/seed_proverbs.dart';

/// Injected pre-loaded SharedPreferences instance.
/// In production, this is initialized before runApp and overridden in ProviderScope
/// so that theme, language, and onboarding states are instant and non-flashing.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;

  /// Tri-state storage key. The legacy binary `dark_mode` flag is only read
  /// for migration and is never written again.
  static const String prefsThemeMode = 'theme_mode';

  static ThemeMode _resolveInitial(SharedPreferences? prefs) {
    if (prefs == null) return ThemeMode.system;
    final stored = prefs.getString(prefsThemeMode);
    if (stored != null) return _fromStorage(stored);
    // Migration path: preserve any previously stored binary choice so
    // existing users never lose their appearance preference.
    final isDark = prefs.getBool(AppConstants.prefsDarkMode);
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static ThemeMode _fromStorage(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static String _toStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeModeNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(_resolveInitial(prefs)) {
    if (prefs == null) {
      _loadTheme();
    }
  }

  Future<void> _loadTheme() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    state = _resolveInitial(prefs);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(prefsThemeMode, _toStorage(mode));
    state = mode;
  }

  /// Convenience shim for the light/dark flip used by tests and legacy UI.
  Future<void> toggleTheme() async {
    await setThemeMode(
      state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return FavoritesNotifier(prefs);
  },
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences? _prefs;
  late Future<void> _initFuture;

  static Set<String> _resolveInitial(SharedPreferences? prefs) {
    if (prefs == null) return const {};
    final list = prefs.getStringList(AppConstants.prefsFavorites) ?? [];
    return list.toSet();
  }

  FavoritesNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(_resolveInitial(prefs)) {
    if (prefs == null) {
      _initFuture = _loadFavorites();
    } else {
      _initFuture = Future.value();
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppConstants.prefsFavorites) ?? [];
    state = list.toSet();
  }

  Future<void> toggle(String proverbId) async {
    await _initFuture;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state);
    if (newSet.contains(proverbId)) {
      newSet.remove(proverbId);
    } else {
      newSet.add(proverbId);
    }
    await prefs.setStringList(AppConstants.prefsFavorites, newSet.toList());
    state = newSet;
  }

  bool isFavorite(String proverbId) => state.contains(proverbId);
}

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final selectedLevelProvider = StateProvider<int?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

enum DisplayLanguage { tajik, persian }

final displayLanguageProvider =
    StateNotifierProvider<DisplayLanguageNotifier, DisplayLanguage>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return DisplayLanguageNotifier(prefs);
    });

/// User-selected interface text multiplier, separate from poem typography.
final appTextScaleProvider =
    StateNotifierProvider<AppTextScaleNotifier, double>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AppTextScaleNotifier(prefs);
    });

class AppTextScaleNotifier extends StateNotifier<double> {
  static const double minimum = 0.9;
  static const double defaultScale = 1.0;
  static const double maximum = 1.2;

  final SharedPreferences? _prefs;

  static double _resolveInitial(SharedPreferences? prefs) {
    final stored = prefs?.getDouble(AppConstants.prefsAppTextScale);
    if (stored == null || !stored.isFinite) return defaultScale;
    return stored.clamp(minimum, maximum);
  }

  AppTextScaleNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(_resolveInitial(prefs)) {
    if (prefs == null) _load();
  }

  Future<void> _load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    state = _resolveInitial(prefs);
  }

  Future<void> setScale(double value) async {
    final safeValue = value.isFinite
        ? value.clamp(minimum, maximum)
        : defaultScale;
    state = safeValue;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefsAppTextScale, safeValue);
  }
}

class DisplayLanguageNotifier extends StateNotifier<DisplayLanguage> {
  final SharedPreferences? _prefs;

  static DisplayLanguage _resolveInitial(SharedPreferences? prefs) {
    if (prefs == null) return DisplayLanguage.tajik;
    final lang = prefs.getString(AppConstants.prefsLanguage) ?? 'tj';
    return lang == 'fa' ? DisplayLanguage.persian : DisplayLanguage.tajik;
  }

  DisplayLanguageNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(_resolveInitial(prefs)) {
    if (prefs == null) {
      _loadLanguage();
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.prefsLanguage) ?? 'tj';
    state = lang == 'fa' ? DisplayLanguage.persian : DisplayLanguage.tajik;
  }

  Future<void> setLanguage(DisplayLanguage lang) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefsLanguage,
      lang == DisplayLanguage.persian ? 'fa' : 'tj',
    );
    state = lang;
  }
}

final categoriesProvider = Provider<List<Category>>((ref) {
  return seedCategories;
});

final proverbsProvider = Provider<List<Proverb>>((ref) {
  return seedProverbs;
});

final availableLevelsProvider = Provider<List<int>>((ref) {
  final levels =
      ref
          .watch(proverbsProvider)
          .map((proverb) => proverb.level)
          .where(
            (level) => level > 0 && level <= AppConstants.levelNames.length,
          )
          .toSet()
          .toList()
        ..sort();
  return List<int>.unmodifiable(levels);
});

final filteredProverbsProvider = Provider<List<Proverb>>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final level = ref.watch(selectedLevelProvider);
  final query = ref.watch(searchQueryProvider);

  return proverbs.where((p) {
    final matchesCategory = category == null || p.categoryId == category;
    final matchesLevel = level == null || p.level == level;
    final matchesQuery =
        query.isEmpty ||
        SearchNormalizer.matchesAny([
          p.tajikCyrillic,
          p.persianText,
          p.meaningTj,
          p.simpleExplanationTj,
          p.exampleSentenceTj,
        ], query);
    return matchesCategory && matchesLevel && matchesQuery;
  }).toList();
});

final favoritesListProvider = Provider<List<Proverb>>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  final favorites = ref.watch(favoritesProvider);
  return proverbs.where((p) => favorites.contains(p.id)).toList();
});

/// Deterministic, gapless calendar day index calculation based on UTC days difference.
/// Guaranteed to advance by exactly 1 day per calendar day regardless of month length (28, 29, 30, 31)
/// and across leap years and year-end transitions.
int calendarDayIndex(DateTime now, int catalogLength) {
  if (catalogLength <= 0) return 0;
  final epoch = DateTime.utc(2020, 1, 1);
  final target = DateTime.utc(now.year, now.month, now.day);
  final days = target.difference(epoch).inDays;
  return ((days % catalogLength) + catalogLength) % catalogLength;
}

final dailyProverbProvider = Provider<Proverb?>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  if (proverbs.isEmpty) {
    return null;
  }
  final index = calendarDayIndex(DateTime.now(), proverbs.length);
  return proverbs[index];
});

// ── Onboarding ──────────────────────────────────────────────────────────

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool?>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return OnboardingNotifier(prefs);
    });

class OnboardingNotifier extends StateNotifier<bool?> {
  final SharedPreferences? _prefs;

  static bool? _resolveInitial(SharedPreferences? prefs) {
    if (prefs == null) return null;
    return prefs.getBool(AppConstants.prefsOnboardingComplete) ?? false;
  }

  OnboardingNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(_resolveInitial(prefs)) {
    if (prefs == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.prefsOnboardingComplete) ?? false;
  }

  Future<void> complete() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefsOnboardingComplete, true);
    state = true;
  }

  Future<void> reset() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefsOnboardingComplete, false);
    state = false;
  }
}
