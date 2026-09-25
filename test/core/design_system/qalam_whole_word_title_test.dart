import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';

final _style = QalamTypography.pageTitle(color: Colors.black, fontSize: 34);

Future<RenderParagraph> _pump(
  WidgetTester tester,
  String title, {
  double width = 216,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: QalamWholeWordTitle(title, style: _style),
            ),
          ),
        ),
      ),
    ),
  );
  return tester.renderObject<RenderParagraph>(find.byType(RichText));
}

/// The character offsets where each wrapped line starts.
List<int> _lineStarts(RenderParagraph paragraph, String text) {
  final starts = <int>[0];
  double? top;
  for (var i = 0; i < text.length; i++) {
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: i, extentOffset: i + 1),
    );
    if (boxes.isEmpty || text[i] == ' ') continue;
    final y = boxes.first.top;
    if (top != null && y > top + 1) starts.add(i);
    top = y;
  }
  return starts;
}

void main() {
  testWidgets('a long name beside the portrait wraps only between words', (
    tester,
  ) async {
    const name = 'Абӯабдуллоҳи Рӯдакӣ';
    final paragraph = await _pump(tester, name);
    for (final start in _lineStarts(paragraph, name).skip(1)) {
      expect(name[start - 1], ' ', reason: 'line starts at $start');
    }
    expect(paragraph.size.width, lessThanOrEqualTo(216));
  });

  testWidgets('a title whose words fit keeps its full size', (tester) async {
    await _pump(tester, 'Ҳофиз');
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style!.fontSize, 34);
  });

  testWidgets('shrinking stops at the floor at 200% text', (tester) async {
    await _pump(tester, 'Абӯабдуллоҳи', width: 120, scale: 2);
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style!.fontSize, closeTo(34 * 0.6, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a Home tile title never breaks inside a word at 200% text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 390,
                child: QalamTileGrid(
                  children: [
                    for (final title in ['Адабиёт', 'Зарбулмасалҳо'])
                      QalamFolioTile(
                        title: title,
                        subtitle: '150 зарбулмасал',
                        onTap: () {},
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Зарбулмасалҳо'),
    );
    expect(_lineStarts(paragraph, 'Зарбулмасалҳо'), [0]);
  });
}
