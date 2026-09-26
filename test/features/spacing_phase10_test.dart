import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/script_direction.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../helpers/test_helper.dart';
import 'literature/presentation/literature_presentation_helpers.dart';

void main() {
  group('scriptDirection', () {
    test('Tajik Cyrillic reads left to right, even after punctuation', () {
      expect(scriptDirection('навъе аз хушбӯйҳо.'), TextDirection.ltr);
      expect(scriptDirection('1. Одамизод ҳар кореро'), TextDirection.ltr);
      expect(scriptDirection('«Ҷӯянда — ёбанда»'), TextDirection.ltr);
    });

    test('Persian script reads right to left', () {
      expect(scriptDirection('دست آدمیزاد — گل.'), TextDirection.rtl);
      expect(scriptDirection('۱. کار و کوشش'), TextDirection.rtl);
    });

    test('text without letters defaults to left to right', () {
      expect(scriptDirection(''), TextDirection.ltr);
      expect(scriptDirection('1867'), TextDirection.ltr);
    });
  });

  testWidgets('the Persian Lexicon keeps a Tajik definition left to right', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/vocabulary',
      language: DisplayLanguage.persian,
      overrides: [
        wordsProvider.overrideWith(
          (ref) async => const [
            WordEntry(
              term: 'Абир',
              definition: 'навъе аз хушбӯйҳо.',
              sourceBook: 'adabiet sinfi 5.pdf',
              pdfPage: 11,
            ),
          ],
        ),
      ],
    );
    final definition = tester.widget<Text>(find.text('навъе аз хушбӯйҳо.'));
    expect(definition.textDirection, TextDirection.ltr);
    expect(
      tester.widget<Text>(find.text('Абир')).textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('the Literature hub fits 320 px at text scale 1.3', (
    tester,
  ) async {
    final second = testWorkRudaki.copyWith(
      id: 'rudaki-second',
      title: 'Шеъри дуюм',
    );
    await pumpTestApp(
      tester,
      route: '/literature',
      works: [testWorkRudaki, second],
      size: const Size(320, 1600),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
