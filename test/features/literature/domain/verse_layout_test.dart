import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

void main() {
  group('VerseLayout.of', () {
    test('pairs an even-length qasida into bayts in order', () {
      final layout = VerseLayout.of('a,\nb.\nc,\nd.', WorkType.qasida);
      expect(layout.stanzas, hasLength(1));
      expect(layout.stanzas.single.unitsAreBayts, isTrue);
      expect(layout.stanzas.single.units, [
        ['a,', 'b.'],
        ['c,', 'd.'],
      ]);
      expect(layout.unitCount, 2);
      expect(layout.isBaytText, isTrue);
    });

    test('keeps a "poem" typed text as single lines (no guessed couplets)', () {
      final layout = VerseLayout.of('a\nb\nc\nd', WorkType.poem);
      expect(layout.stanzas.single.unitsAreBayts, isFalse);
      expect(layout.unitCount, 4);
      expect(layout.isBaytText, isFalse);
    });

    test('keeps an odd-length ghazal as lines', () {
      final layout = VerseLayout.of('a\nb\nc', WorkType.ghazal);
      expect(layout.stanzas.single.unitsAreBayts, isFalse);
    });

    test('blank lines split stanzas exactly as recorded', () {
      final layout = VerseLayout.of('a\nb\nc\nd\n\ne\nf\ng\nh', WorkType.rubai);
      expect(layout.stanzas, hasLength(2));
      expect(layout.unitCount, 4);
    });

    test('never alters characters or order', () {
      const text = 'Эй Бухоро, шод бошу дер зӣ,\nМир наздат шодмон ояд ҳаме.';
      final layout = VerseLayout.of(text, WorkType.qasida);
      final rebuilt = layout.stanzas
          .expand((stanza) => stanza.units)
          .expand((unit) => unit)
          .join('\n');
      expect(rebuilt, text);
    });
  });

  test('every displayable work keeps all of its text through the layout', () {
    final raw = jsonDecode(
      File('assets/data/literature/runtime_works.json').readAsStringSync(),
    );
    final works = expandRuntimeWorks(raw)
        .map(LiteraryWork.fromJson)
        .where((work) => work.isDisplayable && work.hasTajikText);
    expect(works, isNotEmpty);
    for (final work in works) {
      final source = work.textTajik!
          .split('\n')
          .map((line) => line.trimRight())
          .where((line) => line.trim().isNotEmpty)
          .toList();
      final laidOut = VerseLayout.of(work.textTajik!, work.type).stanzas
          .expand((stanza) => stanza.units)
          .expand((unit) => unit)
          .toList();
      expect(laidOut, source, reason: work.id);
    }
  });
}
