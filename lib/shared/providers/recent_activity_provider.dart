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

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    final activity = tryFromJson(json);
    if (activity == null) {
      throw const FormatException('Invalid recent activity record');
    }
    return activity;
  }

  /// Parses untrusted persisted data without allowing one bad record to
  /// invalidate the rest of the recent-activity history.
  static RecentActivity? tryFromJson(Map<String, dynamic> json) {
    final id = _nonEmptyString(json['id']);
    final title = _nonEmptyString(json['title']);
    final route = _nonEmptyString(json['route']);
    final timestampValue = _nonEmptyString(json['timestamp']);
    final typeValue = _nonEmptyString(json['type']);
    final type = typeValue == null ? null : _typeFromName(typeValue);
    final timestamp = timestampValue == null
        ? null
        : DateTime.tryParse(timestampValue);
    final subtitle = json['subtitle'];

    if (id == null ||
        title == null ||
        route == null ||
        timestamp == null ||
        type == null ||
        (subtitle != null && subtitle is! String) ||
        !_isInternalRoute(route)) {
      return null;
    }

    return RecentActivity(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle as String?,
      timestamp: timestamp,
      route: route,
    );
  }

  static RecentActivityType? _typeFromName(String value) {
    for (final type in RecentActivityType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  static String? _nonEmptyString(dynamic value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static bool _isInternalRoute(String route) {
    if (!route.startsWith('/') || route.startsWith('//')) return false;
    final uri = Uri.tryParse(route);
    return uri != null && uri.scheme.isEmpty && uri.host.isEmpty;
  }
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
          .map((encoded) {
            try {
              final decoded = jsonDecode(encoded);
              if (decoded is! Map) return null;
              return RecentActivity.tryFromJson(
                Map<String, dynamic>.from(decoded),
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<RecentActivity>()
          .take(_maxItems)
          .toList(growable: false);
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

  Future<void> clearAll() async {
    state = const [];
    if (_prefs == null) return;
    await _prefs.remove(_key);
  }

  Future<void> _save(List<RecentActivity> activities) async {
    if (_prefs == null) return;
    final encoded = activities.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_key, encoded);
  }
}
