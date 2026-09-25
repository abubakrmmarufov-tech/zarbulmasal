import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/atlas_cover.dart';

void main() {
  testWidgets('bands render at tile size, at zero size and for many seeds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            for (var i = 0; i < 30; i++)
              SizedBox(
                width: 180,
                height: 20,
                child: AtlasCover(seed: 'collection-$i'),
              ),
            const SizedBox(width: 0, height: 0, child: AtlasCover(seed: 'x')),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(AtlasCover), findsNWidgets(31));
  });

  test('a seed always maps to the same palette', () {
    final a = AtlasPainter.stableHash('literature');
    expect(AtlasPainter.stableHash('literature'), a);
    expect(AtlasPainter.stableHash('history'), isNot(a));
  });
}
