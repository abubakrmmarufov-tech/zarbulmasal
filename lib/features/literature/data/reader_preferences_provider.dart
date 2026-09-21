import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/providers/app_providers.dart';

class ReaderPreferencesState {
  final double fontSizeDelta;
  final double lineHeightMultiplier;
  final String defaultReaderMode; // 'standard' or 'parallel'

  const ReaderPreferencesState({
    this.fontSizeDelta = 0.0,
    this.lineHeightMultiplier = 1.6,
    this.defaultReaderMode = 'standard',
  });

  ReaderPreferencesState copyWith({
    double? fontSizeDelta,
    double? lineHeightMultiplier,
    String? defaultReaderMode,
  }) {
    return ReaderPreferencesState(
      fontSizeDelta: fontSizeDelta ?? this.fontSizeDelta,
      lineHeightMultiplier: lineHeightMultiplier ?? this.lineHeightMultiplier,
      defaultReaderMode: defaultReaderMode ?? this.defaultReaderMode,
    );
  }
}

class ReaderPreferencesNotifier extends StateNotifier<ReaderPreferencesState> {
  static const String _keyFontSizeDelta = 'reader_font_size_delta';
  static const String _keyLineHeight = 'reader_line_height_multiplier';
  static const String _keyReaderMode = 'reader_default_mode';

  static const double minDelta = -4.0;
  static const double maxDelta = 10.0;
  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 2.5;
  static const Set<String> validReaderModes = {'standard', 'parallel'};

  final SharedPreferences? _prefs;

  static ReaderPreferencesState _resolveInitial(SharedPreferences? prefs) {
    if (prefs == null) return const ReaderPreferencesState();
    final storedDelta = prefs.getDouble(_keyFontSizeDelta);
    final delta = storedDelta != null && storedDelta.isFinite
        ? storedDelta
        : 0.0;
    final storedLineHeight = prefs.getDouble(_keyLineHeight);
    final lineHeight =
        storedLineHeight != null &&
            storedLineHeight.isFinite &&
            storedLineHeight >= minLineHeight &&
            storedLineHeight <= maxLineHeight
        ? storedLineHeight
        : 1.6;
    final storedMode = prefs.getString(_keyReaderMode);
    final mode = validReaderModes.contains(storedMode)
        ? storedMode!
        : 'standard';
    return ReaderPreferencesState(
      fontSizeDelta: delta.clamp(minDelta, maxDelta),
      lineHeightMultiplier: lineHeight,
      defaultReaderMode: mode,
    );
  }

  ReaderPreferencesNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(_resolveInitial(prefs)) {
    if (prefs == null) {
      _loadPreferences();
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      state = _resolveInitial(prefs);
    } catch (_) {
      // Fallback to default state if SharedPreferences is unavailable
    }
  }

  Future<void> setFontSizeDelta(double delta) async {
    final clamped = delta.clamp(minDelta, maxDelta);
    state = state.copyWith(fontSizeDelta: clamped);
    await _saveDouble(_keyFontSizeDelta, clamped);
  }

  Future<void> increaseFontSize() async {
    await setFontSizeDelta(state.fontSizeDelta + 2.0);
  }

  Future<void> decreaseFontSize() async {
    await setFontSizeDelta(state.fontSizeDelta - 2.0);
  }

  Future<void> resetFontSize() async {
    await setFontSizeDelta(0.0);
  }

  Future<void> setLineHeightMultiplier(double multiplier) async {
    final safeMultiplier = multiplier.isFinite
        ? multiplier.clamp(minLineHeight, maxLineHeight)
        : 1.6;
    state = state.copyWith(lineHeightMultiplier: safeMultiplier);
    await _saveDouble(_keyLineHeight, safeMultiplier);
  }

  Future<void> setDefaultReaderMode(String mode) async {
    final safeMode = validReaderModes.contains(mode) ? mode : 'standard';
    state = state.copyWith(defaultReaderMode: safeMode);
    await _saveString(_keyReaderMode, safeMode);
  }

  Future<void> _saveDouble(String key, double value) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (_) {}
  }

  Future<void> _saveString(String key, String value) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }
}

final readerPreferencesProvider =
    StateNotifierProvider<ReaderPreferencesNotifier, ReaderPreferencesState>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ReaderPreferencesNotifier(prefs);
    });
