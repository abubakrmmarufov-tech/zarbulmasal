// No poem is published twice (across books and editions) and no poem is
// given to two poets. Two readable records are the same poem when they
// share at least two lines and half the lines of the shorter one; reprints
// and fragments are merged per the catalogue's conventions
// (docs/literature/DUPLICATE_DECISIONS_2026-09-26.json).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lines compared without case, punctuation or spaces; ё as е.
String _norm(String line) => line
    .toLowerCase()
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '');

typedef Poem = ({String id, String author, Set<String> lines});

/// Pairs of [poems] that print the same poem.
List<(Poem, Poem, int)> samePoems(List<Poem> poems) {
  final byLine = <String, List<int>>{};
  for (final (index, poem) in poems.indexed) {
    for (final line in poem.lines) {
      (byLine[line] ??= []).add(index);
    }
  }
  final shared = <(int, int), int>{};
  for (final holders in byLine.values) {
    for (var a = 0; a < holders.length; a++) {
      for (var b = a + 1; b < holders.length; b++) {
        final key = (holders[a], holders[b]);
        shared[key] = (shared[key] ?? 0) + 1;
      }
    }
  }
  return [
    for (final MapEntry(key: (a, b), value: count) in shared.entries)
      if (count >= 2 &&
          count * 2 >=
              [
                poems[a].lines.length,
                poems[b].lines.length,
              ].reduce((x, y) => x < y ? x : y))
        (poems[a], poems[b], count),
  ];
}

Poem _poem(String id, String author, String text) => (
  id: id,
  author: author,
  lines: {
    for (final line in text.split('\n'))
      if (_norm(line).isNotEmpty) _norm(line),
  },
);

void main() {
  final works =
      (jsonDecode(File('assets/data/literature/works.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>()
          .where(
            (work) =>
                (work['verification'] as Map?)?['evidenceLevel'] ==
                    'primaryChecked' &&
                ((work['textTajik'] as String?)?.trim().isNotEmpty ?? false),
          )
          .toList();
  final poems = [
    for (final work in works)
      _poem(
        work['id'] as String,
        work['authorId'] as String,
        work['textTajik'] as String,
      ),
  ];

  test('the check finds a poem published twice and one given to two poets', () {
    const text = 'Мисраи якум,\nМисраи дуюм.\nМисраи сеюм,\nМисраи чорум.';
    final pairs = samePoems([
      _poem('a', 'p', text),
      _poem('b', 'p', 'Мисраи сеюм,\nМисраи чорум!'),
      _poem('c', 'q', text),
      _poem('d', 'p', 'Дигар шеър.\nДигар мисраъ.'),
    ]);
    expect(
      {for (final (x, y, _) in pairs) '${x.id}-${y.id}'},
      {'a-b', 'a-c', 'b-c'},
    );
  });

  test('no poem is published twice', () {
    final twice = [
      for (final (a, b, count) in samePoems(poems))
        if (a.author == b.author) '${a.id} = ${b.id} ($count lines)',
    ];
    expect(twice, isEmpty);
  });

  test('no poem is given to two poets', () {
    final twoPoets = [
      for (final (a, b, count) in samePoems(poems))
        if (a.author != b.author)
          '${a.id} (${a.author}) = ${b.id} (${b.author}), $count lines',
    ];
    expect(twoPoets, isEmpty);
  });

  test('readable verse carries no footnote numbers or glosses', () {
    final marked = [
      for (final work in works)
        for (final line in (work['textTajik'] as String).split('\n'))
          if (RegExp(r'\d').hasMatch(line)) '${work['id']}: $line',
    ];
    expect(marked, isEmpty);
  });
}
