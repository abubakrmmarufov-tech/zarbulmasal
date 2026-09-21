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
}
