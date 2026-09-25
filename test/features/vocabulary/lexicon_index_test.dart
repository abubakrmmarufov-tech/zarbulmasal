import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/vocabulary/domain/lexicon_index.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';

WordEntry entry(String term, String definition, {int page = 11}) => WordEntry(
  term: term,
  definition: definition,
  sourceBook: 'adabiet sinfi 5.pdf',
  pdfPage: page,
);

void main() {
  final index = LexiconIndex([
    entry('Хирадманд', 'шахси боақл.'),
    entry('Гул', 'шукуфа.'),
    entry('Ёр', 'дӯст.'),
    entry('Чашм ниҳодан', 'умедвор будан.'),
    entry('Хирадманд', 'доно.', page: 40),
  ]);

  group('lookup', () {
    test('finds a headword whatever its case', () {
      final found = index.lookup('хирадманд');
      expect(found.map((e) => e.definition), ['шахси боақл.', 'доно.']);
    });

    test('finds the headword under common endings', () {
      expect(index.lookup('Гули').single.term, 'Гул'); // izofat
      expect(index.lookup('гулҳо').single.term, 'Гул'); // plural
      expect(index.lookup('гулҳоро').single.term, 'Гул'); // plural + object
      expect(index.lookup('ёрам').single.term, 'Ёр'); // possessive
    });

    test('does not strip a word down to a stub', () {
      expect(index.lookup('Ри'), isEmpty);
      expect(index.lookup('ҳо'), isEmpty);
    });

    test('an unknown word finds nothing', () {
      expect(index.lookup('Бухоро'), isEmpty);
    });
  });

  group('wordAt', () {
    const line = 'Ба сони чеҳраи Лайло, к-аз ишқ!';

    test('the word around a character offset', () {
      expect(LexiconIndex.wordAt(line, 10), 'чеҳраи');
      expect(LexiconIndex.wordAt(line, 8), 'чеҳраи');
    });

    test('keeps hyphenated forms and drops punctuation', () {
      expect(LexiconIndex.wordAt(line, 22), 'к-аз');
      expect(LexiconIndex.wordAt(line, 19), 'Лайло');
    });

    test('a space or punctuation mark is no word', () {
      expect(LexiconIndex.wordAt(line, 2), isNull);
      expect(LexiconIndex.wordAt(line, 20), isNull);
      expect(LexiconIndex.wordAt(line, 99), isNull);
    });
  });

  test('the grade is read from the source book', () {
    expect(LexiconIndex.gradeOf(entry('Гул', 'x')), '5');
  });
}
