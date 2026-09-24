import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/features/literature/data/reader_preferences_provider.dart';

void main() {
  test(
    'malformed persisted reader preferences fall back to safe defaults',
    () async {
      SharedPreferences.setMockInitialValues({
        'reader_font_size_delta': double.nan,
        'reader_line_height_multiplier': 99.0,
        'reader_default_mode': 'unknown',
      });
      final prefs = await SharedPreferences.getInstance();

      final notifier = ReaderPreferencesNotifier(prefs);

      expect(notifier.state.fontSizeDelta, 0.0);
      expect(notifier.state.lineHeightMultiplier, 1.6);
      expect(notifier.state.defaultReaderMode, 'standard');
    },
  );

  test(
    'reader preference setters reject non-finite and unknown values',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ReaderPreferencesNotifier(prefs);

      await notifier.setLineHeightMultiplier(double.infinity);
      await notifier.setDefaultReaderMode('invalid');

      expect(notifier.state.lineHeightMultiplier, 1.6);
      expect(notifier.state.defaultReaderMode, 'standard');
    },
  );

  test(
    'reader font size may shrink to 70% (delta -6) with a safe clamp',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ReaderPreferencesNotifier(prefs);

      // Three A- steps from 0 land exactly on the new 70% floor.
      await notifier.decreaseFontSize();
      await notifier.decreaseFontSize();
      await notifier.decreaseFontSize();
      expect(notifier.state.fontSizeDelta, -6.0);

      // Values below the floor clamp to the floor instead of escaping it.
      await notifier.setFontSizeDelta(-9);
      expect(notifier.state.fontSizeDelta, -6.0);

      // The 70% floor is persisted and survives notifier recreation.
      final restarted = ReaderPreferencesNotifier(prefs);
      expect(restarted.state.fontSizeDelta, -6.0);
    },
  );

  test('reader preferences survive notifier recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final first = ReaderPreferencesNotifier(prefs);

    await first.setFontSizeDelta(6);
    await first.setLineHeightMultiplier(1.8);
    await first.setDefaultReaderMode('parallel');

    final restarted = ReaderPreferencesNotifier(prefs);
    expect(restarted.state.fontSizeDelta, 6);
    expect(restarted.state.lineHeightMultiplier, 1.8);
    expect(restarted.state.defaultReaderMode, 'parallel');
  });
}
