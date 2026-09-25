import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/lookup_text.dart';

Future<String?> tapOn(
  WidgetTester tester,
  Widget Function(Widget) wrap,
  String line,
  String word,
) async {
  String? tapped;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: wrap(
          LookupText(
            line,
            style: const TextStyle(fontSize: 20),
            textDirection: TextDirection.ltr,
            onWord: (w) => tapped = w,
          ),
        ),
      ),
    ),
  );
  final paragraph = tester.renderObject<RenderParagraph>(find.byType(RichText));
  final start = line.indexOf(word);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + word.length),
      )
      .first
      .toRect();
  await tester.tapAt(paragraph.localToGlobal(box.center));
  await tester.pumpAndSettle();
  return tapped;
}

void main() {
  const line = 'Зери поям парниён ояд ҳаме.';

  testWidgets('a tap hands over the word under it', (tester) async {
    expect(await tapOn(tester, (c) => c, line, 'парниён'), 'парниён');
  });

  testWidgets('a tap works inside a selection area', (tester) async {
    expect(
      await tapOn(tester, (c) => SelectionArea(child: c), line, 'поям'),
      'поям',
    );
  });

  testWidgets('a tap on a space hands over nothing', (tester) async {
    expect(await tapOn(tester, (c) => c, line, ' '), isNull);
  });
}
