import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_providers.dart';

/// Kinds of screens that count as "reading" for Continue reading.
///
/// Hubs, poet dossiers, lists, levels and search are deliberately absent:
/// visiting them (including via Back) must never become the resume target.
enum ReadingKind { work, proverb, history }

/// Where the reader stopped: one text plus an optional unit anchor
/// (a bayt or a line, 1-based) so Continue can reopen at the right place.
class ReadingPosition {
  const ReadingPosition({
    required this.kind,
    required this.id,
    required this.route,
    required this.titleTajik,
    this.titlePersian,
    this.titlePersianGenerated = false,
    this.anchor,
    this.anchorTotal,
    this.anchorIsBayt = false,
    required this.timestamp,
  });

  final ReadingKind kind;
  final String id;

  /// Internal route of the text, without the anchor.
  final String route;
  final String titleTajik;
  final String? titlePersian;

  /// Whether [titlePersian] is a mechanical transliteration (data:
  /// `titlePersianSource: "generated"`), which must be labelled when shown.
  final bool titlePersianGenerated;
  final int? anchor;
  final int? anchorTotal;
  final bool anchorIsBayt;
  final DateTime timestamp;

  /// Route that reopens the text at its anchor.
  String get resumeRoute =>
      anchor == null || anchor! <= 1 ? route : '$route?at=$anchor';

  ReadingPosition withAnchor(int anchor, int total, {required bool isBayt}) =>
      ReadingPosition(
        kind: kind,
        id: id,
        route: route,
        titleTajik: titleTajik,
        titlePersian: titlePersian,
        titlePersianGenerated: titlePersianGenerated,
        anchor: anchor,
        anchorTotal: total,
        anchorIsBayt: isBayt,
        timestamp: timestamp,
      );

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'id': id,
    'route': route,
    'titleTajik': titleTajik,
    if (titlePersian != null) 'titlePersian': titlePersian,
    'titlePersianGenerated': titlePersianGenerated,
    if (anchor != null) 'anchor': anchor,
    if (anchorTotal != null) 'anchorTotal': anchorTotal,
    'anchorIsBayt': anchorIsBayt,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Parses untrusted persisted data; returns `null` for anything malformed
  /// or pointing outside the app.
  static ReadingPosition? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final kind = ReadingKind.values
        .where((value) => value.name == json['kind'])
        .firstOrNull;
    final id = json['id'];
    final route = json['route'];
    final title = json['titleTajik'];
    final titlePersian = json['titlePersian'];
    final anchor = json['anchor'];
    final total = json['anchorTotal'];
    final timestamp = json['timestamp'] is String
        ? DateTime.tryParse(json['timestamp'] as String)
        : null;
    if (kind == null ||
        id is! String ||
        id.isEmpty ||
        route is! String ||
        !_isInternalRoute(route) ||
        title is! String ||
        title.trim().isEmpty ||
        (titlePersian != null && titlePersian is! String) ||
        (anchor != null && (anchor is! int || anchor < 1)) ||
        (total != null && (total is! int || total < 1)) ||
        timestamp == null) {
      return null;
    }
    return ReadingPosition(
      kind: kind,
      id: id,
      route: route,
      titleTajik: title,
      titlePersian: titlePersian as String?,
      titlePersianGenerated: json['titlePersianGenerated'] == true,
      anchor: anchor as int?,
      anchorTotal: total as int?,
      anchorIsBayt: json['anchorIsBayt'] == true,
      timestamp: timestamp,
    );
  }

  static bool _isInternalRoute(String route) {
    if (!route.startsWith('/') || route.startsWith('//')) return false;
    final uri = Uri.tryParse(route);
    return uri != null &&
        uri.scheme.isEmpty &&
        uri.host.isEmpty &&
        uri.query.isEmpty;
  }
}

class ReadingPositionNotifier extends StateNotifier<ReadingPosition?> {
  ReadingPositionNotifier(this._prefs) : super(_load(_prefs));

  static const storageKey = 'reading_position';
  final SharedPreferences? _prefs;

  static ReadingPosition? _load(SharedPreferences? prefs) {
    final raw = prefs?.getString(storageKey);
    if (raw == null) return null;
    try {
      return ReadingPosition.tryFromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  /// Records that [position]'s text is being read. Reopening the text that
  /// is already current is a no-op, so its anchor survives and listeners are
  /// not notified on every rebuild of a reading screen.
  Future<void> open(ReadingPosition position) async {
    final current = state;
    if (current != null &&
        current.kind == position.kind &&
        current.id == position.id) {
      return;
    }
    state = position;
    await _save();
  }

  /// Moves the anchor for the text currently being read.
  Future<void> updateAnchor({
    required ReadingKind kind,
    required String id,
    required int anchor,
    required int total,
    required bool isBayt,
  }) async {
    final current = state;
    if (current == null || current.kind != kind || current.id != id) return;
    if (current.anchor == anchor && current.anchorTotal == total) return;
    state = current.withAnchor(anchor, total, isBayt: isBayt);
    await _save();
  }

  Future<void> clear() async {
    state = null;
    await _prefs?.remove(storageKey);
  }

  Future<void> _save() async {
    final value = state;
    if (_prefs == null || value == null) return;
    await _prefs.setString(storageKey, jsonEncode(value.toJson()));
  }
}

final readingPositionProvider =
    StateNotifierProvider<ReadingPositionNotifier, ReadingPosition?>(
      (ref) => ReadingPositionNotifier(ref.watch(sharedPreferencesProvider)),
    );
