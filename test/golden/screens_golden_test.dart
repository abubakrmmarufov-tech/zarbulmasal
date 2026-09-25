// Golden images of the main screens in light and dark, with the date frozen
// so the daily picks never change. Regenerate after an intended visual
// change with: flutter test --update-goldens test/golden
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/data/history_repository.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../helpers/file_asset_bundle.dart';
import '../helpers/test_helper.dart';

/// 25 September 2026, morning in Dushanbe (UTC+5).
final _frozenNow = DateTime.utc(2026, 9, 25, 6);

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

final _bundle = FileAssetBundle();

final _overrides = [
  nowProvider.overrideWithValue(() => _frozenNow),
  literatureRepositoryProvider.overrideWithValue(
    LiteratureRepository(bundle: _bundle),
  ),
  historyRepositoryProvider.overrideWithValue(
    HistoryRepository(bundle: _bundle),
  ),
  approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
  literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
];

const _screens = <String, String>{
  'home': '/',
  'explore': '/explore',
  'reader': '/literature/work/rudaki_buyi_juyi_muliyon_grade5_2017_p54',
  'poet': '/literature/poet/rudaki',
};

void main() {
  test('the frozen clock is the Tajikistan day of 25 September 2026', () {
    expect(tajikistanDate(_frozenNow), DateTime.utc(2026, 9, 25));
  });

  for (final MapEntry(key: name, value: route) in _screens.entries) {
    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      testWidgets('$name · $theme', (tester) async {
        await openApp(tester, route: route, dark: dark, overrides: _overrides);
        await _precacheImages(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${name}_$theme.png'),
        );
      });
    }
  }
}

/// Decodes every visible image for real, so portraits appear in every run
/// instead of depending on how fast the decoder happened to be.
Future<void> _precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
  });
  await tester.pumpAndSettle();
}
