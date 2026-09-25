import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_providers.dart';

/// What a «Баёз» can hold.
enum BayozItemKind { work, proverb }

/// A reference to one text in a Баёз (the text itself stays in the catalog).
class BayozItem {
  const BayozItem(this.kind, this.id);

  final BayozItemKind kind;
  final String id;

  Map<String, dynamic> toJson() => {'kind': kind.name, 'id': id};

  static BayozItem? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final kind = BayozItemKind.values
        .where((value) => value.name == json['kind'])
        .firstOrNull;
    final id = json['id'];
    if (kind == null || id is! String || id.trim().isEmpty) return null;
    return BayozItem(kind, id);
  }

  @override
  bool operator ==(Object other) =>
      other is BayozItem && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// «Баёз» — a personal anthology: a titled, ordered collection of texts.
/// Stored only on this device (no accounts, no sync).
class Bayoz {
  const Bayoz({
    required this.id,
    required this.title,
    required this.items,
    required this.createdAt,
  });

  final String id;
  final String title;
  final List<BayozItem> items;
  final DateTime createdAt;

  static const int maxTitleLength = 60;

  bool contains(BayozItem item) => items.contains(item);

  Bayoz copyWith({String? title, List<BayozItem>? items}) => Bayoz(
    id: id,
    title: title ?? this.title,
    items: List.unmodifiable(items ?? this.items),
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'items': items.map((item) => item.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  /// Parses untrusted stored data; malformed items are dropped, a malformed
  /// Баёз is skipped entirely.
  static Bayoz? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final title = json['title'];
    final created = json['createdAt'] is String
        ? DateTime.tryParse(json['createdAt'] as String)
        : null;
    final rawItems = json['items'];
    if (id is! String ||
        id.isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        created == null ||
        rawItems is! List) {
      return null;
    }
    final items = <BayozItem>[];
    for (final raw in rawItems) {
      final item = BayozItem.tryFromJson(raw);
      if (item != null && !items.contains(item)) items.add(item);
    }
    return Bayoz(
      id: id,
      title: _cleanTitle(title),
      items: List.unmodifiable(items),
      createdAt: created,
    );
  }

  static String _cleanTitle(String value) {
    final trimmed = value.trim();
    return trimmed.length <= maxTitleLength
        ? trimmed
        : trimmed.substring(0, maxTitleLength);
  }
}

class BayozNotifier extends StateNotifier<List<Bayoz>> {
  BayozNotifier(this._prefs, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(_load(_prefs));

  static const storageKey = 'bayoz_collections';

  /// Caps that keep the stored list, and the time to load it, bounded.
  static const int maxCollections = 100;
  static const int maxItems = 500;
  final SharedPreferences? _prefs;
  final DateTime Function() _clock;
  final _random = math.Random();
  var _sequence = 0;

  static List<Bayoz> _load(SharedPreferences? prefs) {
    final raw = prefs?.getString(storageKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return List.unmodifiable(
        decoded
            .map(Bayoz.tryFromJson)
            .whereType<Bayoz>()
            .take(maxCollections)
            .map(
              (bayoz) => bayoz.items.length <= maxItems
                  ? bayoz
                  : bayoz.copyWith(items: bayoz.items.take(maxItems).toList()),
            ),
      );
    } on FormatException {
      return const [];
    }
  }

  /// Whether another Баёз may be created ([maxCollections]).
  bool get canCreate => state.length < maxCollections;

  /// Creates a Баёз and returns its id, or `null` for an empty title or
  /// when [maxCollections] are kept already.
  Future<String?> create(String title) async {
    final clean = Bayoz._cleanTitle(title);
    if (clean.isEmpty || !canCreate) return null;
    final now = _clock();
    // Web clocks tick in milliseconds: a sequence number and a random suffix
    // keep ids unique even for two creations within the same tick.
    var id =
        'bayoz-${now.microsecondsSinceEpoch}-${_sequence++}-'
        '${_random.nextInt(1 << 32).toRadixString(36)}';
    while (state.any((bayoz) => bayoz.id == id)) {
      id = '$id-${_random.nextInt(1 << 16).toRadixString(36)}';
    }
    state = List.unmodifiable([
      ...state,
      Bayoz(id: id, title: clean, items: const [], createdAt: now),
    ]);
    await _save();
    return id;
  }

  Future<void> rename(String id, String title) async {
    final clean = Bayoz._cleanTitle(title);
    if (clean.isEmpty) return;
    await _update(id, (bayoz) => bayoz.copyWith(title: clean));
  }

  Future<void> delete(String id) async {
    state = List.unmodifiable(state.where((bayoz) => bayoz.id != id));
    await _save();
  }

  /// Adds [item] to the Баёз, or removes it when it is already there. A
  /// Баёз holding [maxItems] takes no more.
  Future<void> toggle(String id, BayozItem item) => _update(
    id,
    (bayoz) => bayoz.contains(item)
        ? bayoz.copyWith(
            items: bayoz.items.where((existing) => existing != item).toList(),
          )
        : bayoz.items.length >= maxItems
        ? bayoz
        : bayoz.copyWith(items: [...bayoz.items, item]),
  );

  Future<void> _update(String id, Bayoz Function(Bayoz) change) async {
    state = List.unmodifiable([
      for (final bayoz in state) bayoz.id == id ? change(bayoz) : bayoz,
    ]);
    await _save();
  }

  Future<void> _save() async {
    await _prefs?.setString(
      storageKey,
      jsonEncode(state.map((bayoz) => bayoz.toJson()).toList()),
    );
  }
}

final bayozProvider = StateNotifierProvider<BayozNotifier, List<Bayoz>>(
  (ref) => BayozNotifier(ref.watch(sharedPreferencesProvider)),
);
