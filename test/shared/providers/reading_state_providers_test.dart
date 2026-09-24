import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/providers/reading_position_provider.dart';
import 'package:zarbulmasal/shared/providers/reading_script_provider.dart';

Future<ProviderContainer> _container(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

ReadingPosition _poem({DateTime? at}) => ReadingPosition(
  kind: ReadingKind.work,
  id: 'rudaki',
  route: '/literature/work/rudaki',
  titleTajik: 'Бӯйи Ҷӯйи Мулиён',
  titlePersian: 'بوی جوی مولیان',
  timestamp: at ?? DateTime.utc(2026, 9, 24),
);

void main() {
  group('readingScriptProvider', () {
    test('follows the interface language until the reader chooses', () async {
      final container = await _container({AppConstants.prefsLanguage: 'fa'});
      expect(container.read(readingScriptProvider), ReadingScript.persian);
    });

    test('a chosen script never changes the interface language', () async {
      final container = await _container({AppConstants.prefsLanguage: 'tj'});
      await container
          .read(readingScriptPreferenceProvider.notifier)
          .setScript(ReadingScript.persian);

      expect(container.read(readingScriptProvider), ReadingScript.persian);
      expect(container.read(displayLanguageProvider), DisplayLanguage.tajik);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.prefsReadingScript), 'persian');
    });

    test('ignores an unknown stored value', () async {
      final container = await _container({
        AppConstants.prefsLanguage: 'tj',
        AppConstants.prefsReadingScript: 'latin',
      });
      expect(container.read(readingScriptPreferenceProvider), isNull);
      expect(container.read(readingScriptProvider), ReadingScript.cyrillic);
    });
  });

  group('readingPositionProvider', () {
    test('stores the opened text and its bayt anchor', () async {
      final container = await _container({});
      final notifier = container.read(readingPositionProvider.notifier);
      await notifier.open(_poem());
      await notifier.updateAnchor(
        kind: ReadingKind.work,
        id: 'rudaki',
        anchor: 4,
        total: 6,
        isBayt: true,
      );

      final position = container.read(readingPositionProvider)!;
      expect(position.anchor, 4);
      expect(position.anchorTotal, 6);
      expect(position.resumeRoute, '/literature/work/rudaki?at=4');

      // A fresh container reads the same position back from storage.
      final reloaded = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
      );
      addTearDown(reloaded.dispose);
      expect(reloaded.read(readingPositionProvider)!.anchor, 4);
    });

    test('reopening the same text keeps its anchor', () async {
      final container = await _container({});
      final notifier = container.read(readingPositionProvider.notifier);
      await notifier.open(_poem());
      await notifier.updateAnchor(
        kind: ReadingKind.work,
        id: 'rudaki',
        anchor: 3,
        total: 6,
        isBayt: true,
      );
      await notifier.open(_poem(at: DateTime.utc(2026, 9, 25)));
      expect(container.read(readingPositionProvider)!.anchor, 3);
    });

    test('an anchor for another text is ignored', () async {
      final container = await _container({});
      final notifier = container.read(readingPositionProvider.notifier);
      await notifier.open(_poem());
      await notifier.updateAnchor(
        kind: ReadingKind.work,
        id: 'other',
        anchor: 5,
        total: 6,
        isBayt: true,
      );
      expect(container.read(readingPositionProvider)!.anchor, isNull);
    });

    test('rejects external or malformed persisted positions', () {
      final valid = _poem().toJson();
      expect(ReadingPosition.tryFromJson(valid), isNotNull);
      expect(
        ReadingPosition.tryFromJson({...valid, 'route': 'https://evil.test'}),
        isNull,
      );
      expect(
        ReadingPosition.tryFromJson({...valid, 'route': '//evil.test/x'}),
        isNull,
      );
      expect(ReadingPosition.tryFromJson({...valid, 'anchor': 0}), isNull);
      expect(ReadingPosition.tryFromJson({...valid, 'kind': 'poet'}), isNull);
      expect(ReadingPosition.tryFromJson('not a map'), isNull);
    });

    test('clear forgets the position', () async {
      final container = await _container({});
      final notifier = container.read(readingPositionProvider.notifier);
      await notifier.open(_poem());
      await notifier.clear();
      expect(container.read(readingPositionProvider), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ReadingPositionNotifier.storageKey), isNull);
    });
  });
}
