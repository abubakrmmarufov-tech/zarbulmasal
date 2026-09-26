import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/text_style_contrast.dart';

const _paper = Color(0xFFFAF6EC);

Future<Evaluation> _evaluate(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: _paper,
        body: Center(child: child),
      ),
    ),
  );
  return textStyleContrastGuideline.evaluate(tester);
}

void main() {
  testWidgets('ink on paper passes', (tester) async {
    final result = await _evaluate(
      tester,
      const Text('Ранг', style: TextStyle(color: Color(0xFF1A1714))),
    );
    expect(result.passed, isTrue, reason: result.reason);
  });

  testWidgets('pale grey on paper fails for body text', (tester) async {
    final result = await _evaluate(
      tester,
      const Text(
        'Ранг',
        style: TextStyle(color: Color(0xFFB0AAA0), fontSize: 14),
      ),
    );
    expect(result.passed, isFalse);
    expect(result.reason, contains('«Ранг» at 14.0 px'));
  });

  testWidgets('large text needs only 3:1', (tester) async {
    // #8A847B on paper is about 3.5:1.
    const grey = Color(0xFF8A847B);
    final small = await _evaluate(
      tester,
      const Text('Ранг', style: TextStyle(color: grey, fontSize: 14)),
    );
    expect(small.passed, isFalse);
    final large = await _evaluate(
      tester,
      const Text('Ранг', style: TextStyle(color: grey, fontSize: 24)),
    );
    expect(large.passed, isTrue, reason: large.reason);
  });

  testWidgets('a faded ancestor counts', (tester) async {
    final result = await _evaluate(
      tester,
      const Opacity(
        opacity: 0.3,
        child: Text('Ранг', style: TextStyle(color: Color(0xFF1A1714))),
      ),
    );
    expect(result.passed, isFalse);
  });

  testWidgets('text is measured against what is really behind it', (
    tester,
  ) async {
    final result = await _evaluate(
      tester,
      Container(
        color: const Color(0xFF1A1714),
        padding: const EdgeInsets.all(8),
        child: const Text(
          'Ранг',
          style: TextStyle(color: Color(0xFF2A2520), fontSize: 14),
        ),
      ),
    );
    expect(result.passed, isFalse);
  });

  testWidgets('icon glyphs are not text', (tester) async {
    final result = await _evaluate(
      tester,
      const Icon(Icons.search, color: _paper),
    );
    expect(result.passed, isTrue, reason: result.reason);
  });
}
