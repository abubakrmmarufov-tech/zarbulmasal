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
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/test_helper.dart';

const _shots = [
  ('explore', '/explore', false),
  ('explore_dark', '/explore', true),
  ('home', '/', false),
  ('poets_classical', '/literature/poets?era=classical', false),
  ('history_sasanid', '/history/empire-sasanid', false),
  ('lexicon', '/vocabulary', false),
  (
    'poet_ahmadi_jomi',
    '/literature/poet/9ab32712-ce1d-4054-a7cc-163ca4a8f11f',
    false,
  ),
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

void main() {
  final out = Platform.environment['SCREENS_OUT'];

  setUpAll(_loadFonts);

  for (final (name, route, dark) in _shots) {
    testWidgets('screenshot $name', (tester) async {
      if (out == null) return;
      await openApp(
        tester,
        route: route,
        dark: dark,
        height: 844,
        settle: false,
      );
      // Let the background-isolate loads (works, words, history) finish.
      for (var i = 0; i < 12; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 700)),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first,
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
      });
    });
  }
}
