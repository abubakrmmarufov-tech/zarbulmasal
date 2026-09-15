import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderPreferencesState {
  final double fontSizeDelta;
  final double lineHeightMultiplier;

  const ReaderPreferencesState({
    this.fontSizeDelta = 0.0,
    this.lineHeightMultiplier = 1.6,
  });

  ReaderPreferencesState copyWith({
    double? fontSizeDelta,
    double? lineHeightMultiplier,
  }) {
    return ReaderPreferencesState(
      fontSizeDelta: fontSizeDelta ?? this.fontSizeDelta,
      lineHeightMultiplier: lineHeightMultiplier ?? this.lineHeightMultiplier,
    );
  }
}

class ReaderPreferencesNotifier extends StateNotifier<ReaderPreferencesState> {
  static const String _keyFontSizeDelta = 'reader_font_size_delta';
  static const double minDelta = -4.0;
  static const double maxDelta = 10.0;

  ReaderPreferencesNotifier() : super(const ReaderPreferencesState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final delta = prefs.getDouble(_keyFontSizeDelta) ?? 0.0;
      state = state.copyWith(fontSizeDelta: delta.clamp(minDelta, maxDelta));
    } catch (_) {
      // Fallback to default state if SharedPreferences is unavailable
    }
  }

  Future<void> increaseFontSize() async {
    final newDelta = (state.fontSizeDelta + 2.0).clamp(minDelta, maxDelta);
    state = state.copyWith(fontSizeDelta: newDelta);
    await _saveFontSizeDelta(newDelta);
  }

  Future<void> decreaseFontSize() async {
    final newDelta = (state.fontSizeDelta - 2.0).clamp(minDelta, maxDelta);
    state = state.copyWith(fontSizeDelta: newDelta);
    await _saveFontSizeDelta(newDelta);
  }

  Future<void> resetFontSize() async {
    state = state.copyWith(fontSizeDelta: 0.0);
    await _saveFontSizeDelta(0.0);
  }

  Future<void> _saveFontSizeDelta(double delta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSizeDelta, delta);
    } catch (_) {}
  }
}

final readerPreferencesProvider =
    StateNotifierProvider<ReaderPreferencesNotifier, ReaderPreferencesState>((
      ref,
    ) {
      return ReaderPreferencesNotifier();
    });
