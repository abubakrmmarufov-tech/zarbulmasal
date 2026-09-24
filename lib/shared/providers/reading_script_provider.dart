import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'app_providers.dart';

/// The script a reader wants texts (poems, proverbs) shown in.
///
/// Deliberately separate from [DisplayLanguage]: changing the reading script
/// never changes the interface language, navigation, or layout direction.
enum ReadingScript {
  cyrillic,
  persian;

  static ReadingScript? fromStorage(String? value) => switch (value) {
    'cyrillic' => ReadingScript.cyrillic,
    'persian' => ReadingScript.persian,
    _ => null,
  };
}

/// The reader's explicit choice, or `null` while they have not chosen one.
class ReadingScriptPreferenceNotifier extends StateNotifier<ReadingScript?> {
  ReadingScriptPreferenceNotifier([SharedPreferences? prefs])
    : _prefs = prefs,
      super(
        ReadingScript.fromStorage(
          prefs?.getString(AppConstants.prefsReadingScript),
        ),
      ) {
    if (prefs == null) _load();
  }

  final SharedPreferences? _prefs;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = ReadingScript.fromStorage(
        prefs.getString(AppConstants.prefsReadingScript),
      );
    } on Exception {
      // Storage unavailable: keep following the interface language.
    }
  }

  Future<void> setScript(ReadingScript script) async {
    state = script;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefsReadingScript, script.name);
    } on Exception {
      // The in-memory choice still applies for this session.
    }
  }
}

final readingScriptPreferenceProvider =
    StateNotifierProvider<ReadingScriptPreferenceNotifier, ReadingScript?>(
      (ref) =>
          ReadingScriptPreferenceNotifier(ref.watch(sharedPreferencesProvider)),
    );

/// The effective reading script: the reader's choice, or — until they make
/// one — the script of the interface language.
final readingScriptProvider = Provider<ReadingScript>((ref) {
  final chosen = ref.watch(readingScriptPreferenceProvider);
  if (chosen != null) return chosen;
  return ref.watch(displayLanguageProvider) == DisplayLanguage.persian
      ? ReadingScript.persian
      : ReadingScript.cyrillic;
});
