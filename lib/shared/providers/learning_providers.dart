import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/learning_mastery.dart';
import '../../data/models/proverb.dart';
import 'app_providers.dart';

enum MasteryFilter {
  all,
  again,
  learning,
  mastered,
}

final proverbMasteryProvider =
    StateNotifierProvider<ProverbMasteryNotifier, Map<String, ProverbMastery>>(
      (ref) {
        final prefs = ref.watch(sharedPreferencesProvider);
        return ProverbMasteryNotifier(prefs);
      },
    );

class ProverbMasteryNotifier
    extends StateNotifier<Map<String, ProverbMastery>> {
  final SharedPreferences? _prefs;
  late Future<void> _initFuture;

  static Map<String, ProverbMastery> _resolveInitial(SharedPreferences? prefs) {
    if (prefs == null) return const {};
    final raw = prefs.getString(AppConstants.prefsMastery);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map(
          (k, v) => MapEntry(
            k,
            ProverbMastery.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
        );
      }
    } catch (_) {}
    return const {};
  }

  ProverbMasteryNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(_resolveInitial(prefs)) {
    if (prefs == null) {
      _initFuture = _loadFromStorage();
    } else {
      _initFuture = Future.value();
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.prefsMastery);
      if (raw == null || raw.isEmpty) {
        if (mounted) state = const {};
        return;
      }
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic> && mounted) {
        state = decoded.map(
          (k, v) => MapEntry(
            k,
            ProverbMastery.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
        );
      }
    } catch (_) {
      if (mounted) state = const {};
    }
  }

  Future<void> recordReview(
    String proverbId,
    MasteryLevel newLevel, {
    bool isCorrect = true,
  }) async {
    await _initFuture;
    final current = state[proverbId];
    final updated = ProverbMastery(
      proverbId: proverbId,
      level: newLevel,
      reviewCount: (current?.reviewCount ?? 0) + 1,
      correctCount: (current?.correctCount ?? 0) + (isCorrect ? 1 : 0),
      lastReviewedAt: DateTime.now(),
    );

    final next = Map<String, ProverbMastery>.from(state);
    next[proverbId] = updated;
    state = next;

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final serialized = json.encode(
      next.map((k, v) => MapEntry(k, v.toJson())),
    );
    await prefs.setString(AppConstants.prefsMastery, serialized);
  }

  MasteryLevel getLevel(String proverbId) {
    return state[proverbId]?.level ?? MasteryLevel.unseen;
  }

  Future<void> resetAll() async {
    await _initFuture;
    state = const {};
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefsMastery);
  }
}

class MasteryStats {
  final int totalProverbs;
  final int masteredCount;
  final int learningCount;
  final int againCount;
  final int unseenCount;

  const MasteryStats({
    required this.totalProverbs,
    required this.masteredCount,
    required this.learningCount,
    required this.againCount,
    required this.unseenCount,
  });

  int get percentMastered =>
      totalProverbs > 0 ? ((masteredCount / totalProverbs) * 100).round() : 0;
}

final masteryStatsProvider = Provider<MasteryStats>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  final masteryMap = ref.watch(proverbMasteryProvider);

  int mastered = 0;
  int learning = 0;
  int again = 0;

  for (final p in proverbs) {
    final entry = masteryMap[p.id];
    if (entry == null || entry.level == MasteryLevel.unseen) {
      continue;
    }
    switch (entry.level) {
      case MasteryLevel.mastered:
        mastered++;
        break;
      case MasteryLevel.learning:
        learning++;
        break;
      case MasteryLevel.again:
        again++;
        break;
      case MasteryLevel.unseen:
        break;
    }
  }

  final unseen = proverbs.length - (mastered + learning + again);

  return MasteryStats(
    totalProverbs: proverbs.length,
    masteredCount: mastered,
    learningCount: learning,
    againCount: again,
    unseenCount: unseen < 0 ? 0 : unseen,
  );
});

final flashcardsFilterProvider = StateProvider<MasteryFilter>(
  (ref) => MasteryFilter.all,
);

final activeFlashcardsProvider = Provider<List<Proverb>>((ref) {
  final proverbs = ref.watch(proverbsProvider);
  final filter = ref.watch(flashcardsFilterProvider);
  final masteryMap = ref.watch(proverbMasteryProvider);

  switch (filter) {
    case MasteryFilter.all:
      return proverbs;
    case MasteryFilter.again:
      return proverbs
          .where((p) => masteryMap[p.id]?.level == MasteryLevel.again)
          .toList();
    case MasteryFilter.learning:
      return proverbs
          .where((p) => masteryMap[p.id]?.level == MasteryLevel.learning)
          .toList();
    case MasteryFilter.mastered:
      return proverbs
          .where((p) => masteryMap[p.id]?.level == MasteryLevel.mastered)
          .toList();
  }
});
