import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/proverb.dart';
import '../../data/models/category.dart';
import '../../data/seed/seed_categories.dart';
import '../../data/seed/seed_proverbs.dart';

void _debugLog({
  required String runId,
  required String hypothesisId,
  required String location,
  required String message,
  required Map<String, Object?> data,
}) {
  if (!kDebugMode) {
    return;
  }

  debugPrint(
    '[zarbulmasal][$runId][$hypothesisId] $location: $message ${data.isEmpty ? '' : data}',
  );
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // #region agent log
    _debugLog(runId: 'run2', hypothesisId: 'H4', location: 'app_providers.dart:20', message: 'theme load start', data: {'initialState': state.name});
    // #endregion
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConstants.prefsDarkMode) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    // #region agent log
    _debugLog(runId: 'run2', hypothesisId: 'H4', location: 'app_providers.dart:25', message: 'theme load complete', data: {'storedIsDark': isDark, 'finalState': state.name});
    // #endregion
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state == ThemeMode.light;
    await prefs.setBool(AppConstants.prefsDarkMode, isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

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
    final matchesQuery = query.isEmpty ||
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
  _debugLog(runId: 'run2', hypothesisId: 'H1', location: 'app_providers.dart:104', message: 'daily proverb evaluate', data: {'count': proverbs.length, 'year': now.year, 'month': now.month, 'day': now.day});

  if (proverbs.isEmpty) {
    return null;
  }

  final index = (now.year * 365 + now.month * 31 + now.day) % proverbs.length;
  return proverbs[index];
});
