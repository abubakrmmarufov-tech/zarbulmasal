// Phone-size screenshots of app routes with the real fonts, for design
// review when no device is attached.
//
//   SCREENS_OUT=/path/to/out flutter test tool/design/screens_test.dart
//
// Routes and themes are listed below; each becomes <name>.png at 3x.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/data/history_repository.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/lookup_text.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../../test/helpers/file_asset_bundle.dart';
import '../../test/helpers/test_helper.dart';

const _tj = DisplayLanguage.tajik;
const _fa = DisplayLanguage.persian;
const _poem = '/literature/work/rudaki_buyi_juyi_muliyon_grade5_2017_p54';

/// (file name, route, dark, language, word to tap in the poem or null).
const _shots = [
  ('home', '/', false, _tj, null),
  ('home_dark', '/', true, _tj, null),
  ('explore', '/explore', false, _tj, null),
  ('poems_by_form_ghazal', '/literature/works?form=ghazal', false, _tj, null),
  ('reader', _poem, false, _tj, null),
  ('reader_word_sheet', _poem, false, _tj, 'парниён'),
  ('reader_dark', _poem, true, _tj, null),
  ('poet_rudaki', '/literature/poet/rudaki', false, _tj, null),
  ('history_ayni', '/history/person-ayni', false, _tj, null),
  ('lexicon', '/vocabulary', false, _tj, null),
  ('settings', '/settings', false, _tj, null),
  ('home_persian', '/', false, _fa, null),
  ('reader_persian', _poem, false, _fa, null),
];

Future<void> _loadFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final icons = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

List<dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as List<dynamic>;

/// The catalogues read straight from the repository files: the app decodes
/// them on background isolates, which never finish inside a widget test.
List<Override> _catalogues() {
  final works = expandRuntimeWorks(
    jsonDecode(
      File('assets/data/literature/runtime_works.json').readAsStringSync(),
    ),
  ).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();
  final words = _json('assets/data/vocabulary/words.json')
      .whereType<Map<String, dynamic>>()
      .map(WordEntry.fromJson)
      .where((w) => w.term.isNotEmpty && w.definition.isNotEmpty)
      .toList();
  final entries = _json('assets/data/history/entries.json')
      .whereType<Map>()
      .map((m) => HistoryEntry.fromJson(Map<String, dynamic>.from(m)))
      .toList();
  final bundle = FileAssetBundle();
  return [
    literatureRepositoryProvider.overrideWithValue(
      LiteratureRepository(bundle: bundle),
    ),
    historyRepositoryProvider.overrideWithValue(
      HistoryRepository(bundle: bundle),
    ),
    approvedWorksProvider.overrideWith((ref) => Future.value(works)),
    literaryWorksProvider.overrideWith((ref) => Future.value(works)),
    historyEntriesProvider.overrideWith((ref) async => entries),
    wordsProvider.overrideWith((ref) async => words),
  ];
}

/// Opens the Lexicon sheet by tapping [word] where the poem prints it.
Future<void> _tapWord(WidgetTester tester, String word) async {
  final line = find.byWidgetPredicate(
    (w) => w is LookupText && w.text.contains(word),
  );
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: line.first, matching: find.byType(RichText)),
  );
  final start = tester.widget<LookupText>(line.first).text.indexOf(word);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + word.length),
      )
      .first
      .toRect();
  await tester.tapAt(paragraph.localToGlobal(box.center));
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  final out = Platform.environment['SCREENS_OUT'];

  setUpAll(() async {
    // Screens are shown as the release build draws them: no debug banner.
    WidgetsApp.debugAllowBannerOverride = false;
    await _loadFonts();
  });

  for (final (name, route, dark, language, word) in _shots) {
    testWidgets('screenshot $name', (tester) async {
      if (out == null) return;
      await openApp(
        tester,
        route: route,
        dark: dark,
        language: language,
        height: 844,
        settle: false,
        overrides: _catalogues(),
      );
      // Let the background-isolate loads (works, words, history) finish.
      for (var i = 0; i < 12; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 700)),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
      if (word != null) await _tapWord(tester, word);
      // The whole view, so sheets and dialogs above the page are included.
      final view = tester.binding.renderViews.first;
      final layer = view.debugLayer! as OffsetLayer;
      await tester.runAsync(() async {
        final image = await layer.toImage(
          Offset.zero & view.size,
          pixelRatio: 2,
        );
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
      });
    });
  }
}
