import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/portrait_warm_up.dart';

final List<LiteraryAuthor> _authors =
    (jsonDecode(File('assets/data/literature/poets.json').readAsStringSync())
            as List)
        .cast<Map<String, dynamic>>()
        .map(LiteraryAuthor.fromJson)
        .toList();

Future<bool> _cached(PortraitRecord portrait) async {
  final key = await portraitImage(
    portrait,
    height: QalamPortrait.defaultHeight,
    devicePixelRatio: 1,
  ).obtainKey(ImageConfiguration.empty);
  return PaintingBinding.instance.imageCache.statusForKey(key).tracked;
}

void main() {
  void useDevicePixelRatio1(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  setUp(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    resetPortraitWarmUp();
  });

  test('the first screenful is the list order, displayable portraits only', () {
    final first = firstScreenfulOf(_authors).toList();
    expect(first, isNotEmpty);
    expect(first.length, lessThanOrEqualTo(firstScreenfulPortraits));
    expect(first.every((p) => p.isDisplayable), isTrue);
    final named = _authors.where((a) => a.hasCanonicalName).toList();
    expect(
      first.first,
      same(named.firstWhere((a) => a.portrait != null).portrait),
    );
  });

  testWidgets('a portrait draws the provider precaching fills', (tester) async {
    useDevicePixelRatio1(tester);
    final portrait = firstScreenfulOf(_authors).first;
    await tester.pumpWidget(
      MaterialApp(
        home: QalamPortrait(portrait: portrait, label: 'Шоир'),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    await tester.runAsync(() async {
      expect(
        await image.image.obtainKey(ImageConfiguration.empty),
        await portraitImage(
          portrait,
          height: QalamPortrait.defaultHeight,
          devicePixelRatio: 1,
        ).obtainKey(ImageConfiguration.empty),
      );
    });
  });

  testWidgets('Home warms the first screenful of portraits once', (
    tester,
  ) async {
    useDevicePixelRatio1(tester);
    final portraits = firstScreenfulOf(_authors).toList();
    await tester.runAsync(() async {
      expect(await _cached(portraits.first), isFalse);
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          literaryAuthorsProvider.overrideWith((ref) async => _authors),
        ],
        child: const MaterialApp(home: Scaffold(body: PortraitWarmUp())),
      ),
    );
    // Let the authors load, the frame run and each portrait decode.
    var cached = 0;
    for (var i = 0; i < 40 && cached < portraits.length; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      cached = 0;
      await tester.runAsync(() async {
        for (final portrait in portraits) {
          if (await _cached(portrait)) cached++;
        }
      });
    }
    expect(cached, portraits.length);
    expect(find.byType(Image), findsNothing, reason: 'it draws nothing');
  });
}
