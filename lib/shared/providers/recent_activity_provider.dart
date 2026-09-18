import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_providers.dart';

enum RecentActivityType { proverb, poet, work, history, level }

class RecentActivity {
  final String id;
  final RecentActivityType type;
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final String route;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.timestamp,
    required this.route,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'timestamp': timestamp.toIso8601String(),
    'route': route,
  };

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
    id: json['id'] as String,
    type: RecentActivityType.values.byName(json['type'] as String),
    title: json['title'] as String,
    subtitle: json['subtitle'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
    route: json['route'] as String,
  );
}

final recentActivityProvider =
    StateNotifierProvider<RecentActivityNotifier, List<RecentActivity>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return RecentActivityNotifier(prefs);
    });

class RecentActivityNotifier extends StateNotifier<List<RecentActivity>> {
  static const _key = 'recent_activities';
  static const _maxItems = 20;
  final SharedPreferences? _prefs;

  RecentActivityNotifier(this._prefs) : super(_loadInitial(_prefs));

  static List<RecentActivity> _loadInitial(SharedPreferences? prefs) {
    if (prefs == null) return [];
    final list = prefs.getStringList(_key);
    if (list == null) return [];
    try {
      return list
          .map(
            (e) =>
                RecentActivity.fromJson(jsonDecode(e) as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addActivity(RecentActivity activity) async {
    final List<RecentActivity> current = List.from(state);

    // Remove if already exists to move it to the top
    current.removeWhere(
      (item) => item.id == activity.id && item.type == activity.type,
    );

    // Insert at beginning
    current.insert(0, activity);

    // Enforce bound
    if (current.length > _maxItems) {
      current.removeRange(_maxItems, current.length);
    }

    state = current;
    await _save(current);
  }

  Future<void> _save(List<RecentActivity> activities) async {
    if (_prefs == null) return;
    final encoded = activities.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_key, encoded);
  }
}
