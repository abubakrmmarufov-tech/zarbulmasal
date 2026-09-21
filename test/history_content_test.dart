import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List books;
  late List entries;

  setUpAll(() {
    books =
        jsonDecode(File('assets/data/history/books.json').readAsStringSync())
            as List;
    entries =
        jsonDecode(File('assets/data/history/entries.json').readAsStringSync())
            as List;
  });

  test('history catalog covers grades 5 through 11 exactly once', () {
    expect(books.map((book) => book['grade']).toSet(), {
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
    });
    expect(books.map((book) => book['id']).toSet().length, books.length);
  });

  test(
    'every history item points to a permitted textbook record (uploaded PDF or maorif.tj)',
    () {
      final bookIds = books.map((book) => book['id']).toSet();
      for (final entry in entries) {
        expect(bookIds.contains(entry['sourceBookId']), isTrue);
        expect(entry['id'], isNotEmpty);
        expect(entry['title'], isNotEmpty);
        expect(entry['grade'], isNotEmpty);
        expect(entry['sourceSection'], isNotEmpty);
        expect(entry['summary'], isNotEmpty);
      }
      for (final book in books) {
        expect(book['title'], isNotEmpty);
        expect(book['author'], isNotEmpty);
        final sourceUrl = book['sourceUrl'].toString();
        expect(
          sourceUrl.startsWith('https://maorif.tj/') ||
              book['isUploadedBook'] == true ||
              book['localPath'] != null,
          isTrue,
        );
        expect(sourceUrl.contains('marifat.tj'), isFalse);
      }
    },
  );

  test('Yusen spelling remains traceable to the grade 6 textbook', () {
    final evsen = entries.firstWhere((entry) => entry['id'] == 'person-evsen');
    expect(evsen['title'], contains('Евсенҳо'));
    expect(evsen['grade'], '6');
    expect(evsen['sourceBookId'], 'history-6');
  });

  test('poems and oral-history cards are explicitly typed', () {
    expect(entries.any((entry) => entry['kind'] == 'poem'), isTrue);
    expect(entries.any((entry) => entry['kind'] == 'oral'), isTrue);
    for (final entry in entries.where((entry) => entry['kind'] == 'poem')) {
      expect(entry['keywords'], isNotEmpty);
    }
  });
}
