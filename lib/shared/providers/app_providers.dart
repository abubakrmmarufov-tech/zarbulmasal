import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/proverb.dart';
import '../../data/models/category.dart';
import '../../data/seed/seed_categories.dart';
import '../../data/seed/seed_proverbs.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConstants.prefsDarkMode) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state == ThemeMode.light;
    await prefs.setBool(AppConstants.prefsDarkMode, isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) {
    return FavoritesNotifier();
  },
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppConstants.prefsFavorites) ?? [];
    state = list.toSet();
  }

  Future<void> toggle(String proverbId) async {
    final prefs = await SharedPreferences.getInstance();
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
      return DisplayLanguageNotifier();
    });

class DisplayLanguageNotifier extends StateNotifier<DisplayLanguage> {
  DisplayLanguageNotifier() : super(DisplayLanguage.tajik) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.prefsLanguage) ?? 'tj';
    state = lang == 'fa' ? DisplayLanguage.persian : DisplayLanguage.tajik;
  }

  Future<void> setLanguage(DisplayLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
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

final filteredProverbsProvider = Provider<List<Proverb>>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final level = ref.watch(selectedLevelProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return proverbs.where((p) {
    final matchesCategory = category == null || p.categoryId == category;
    final matchesLevel = level == null || p.level == level;
    final matchesQuery =
        query.isEmpty ||
        p.tajikCyrillic.toLowerCase().contains(query) ||
        p.persianText.toLowerCase().contains(query) ||
        p.meaningTj.toLowerCase().contains(query);
    return matchesCategory && matchesLevel && matchesQuery;
  }).toList();
});

final favoritesListProvider = Provider<List<Proverb>>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  final favorites = ref.watch(favoritesProvider);
  return proverbs.where((p) => favorites.contains(p.id)).toList();
});

final dailyProverbProvider = Provider<Proverb?>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  final now = DateTime.now();

  if (proverbs.isEmpty) {
    return null;
  }

  final index = (now.year * 365 + now.month * 31 + now.day) % proverbs.length;
  return proverbs[index];
});

// ── Onboarding ──────────────────────────────────────────────────────────

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool?>((ref) {
      return OnboardingNotifier();
    });

class OnboardingNotifier extends StateNotifier<bool?> {
  OnboardingNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.prefsOnboardingComplete) ?? false;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefsOnboardingComplete, true);
    state = true;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefsOnboardingComplete, false);
    state = false;
  }
}
