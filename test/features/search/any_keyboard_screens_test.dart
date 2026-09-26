// A reader finds a poet or poem from any keyboard in every search box:
// global search, literature search and the poet list's filter.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../../helpers/test_helper.dart';
import 'global_search_test.dart' show testAuthorRudaki, testWorkRudaki;

const _jomi = LiteraryAuthor(
  id: 'jomi',
  canonicalName: 'Абдурраҳмони Ҷомӣ',
  canonicalNamePersian: 'عبدالرحمن جامی',
  literaryPeriod: 'Асри XV',
  biographyTj: 'Test fixture.',
  biographySource: 'Test fixture.',
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Test fixture.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
);

/// Queries a reader might type for Рӯдакӣ, by keyboard.
const _rudakiQueries = {
  'Tajik': 'Рӯдакӣ',
  'Russian': 'Рудаки',
  'Persian': 'رودکی',
  'Latin': 'Rudaki',
  'Latin, -iy': 'Rudakiy',
  'Latin, macrons': 'Rūdakī',
  'one typo': 'Rudakki',
};

/// Queries for the poem «Бӯи ҷӯи Мӯлиён», by its first line.
const _poemQueries = {
  'poem, Russian': 'Буи джуи Мулиён',
  'poem, Persian': 'بوی جوی مولیان',
  'poem, Latin': 'bui jui mulion',
  'poem, Latin, hyphens': 'Bu-yi Ju-yi Muliyon',
  'poem, English-style Persian': 'Buye juye Muliyan',
  'poem, partial words': 'buy ju mul',
};

final _overrides = [
  literaryAuthorsProvider.overrideWith(
    (ref) async => const [testAuthorRudaki, _jomi],
  ),
  approvedWorksProvider.overrideWith((ref) async => const [testWorkRudaki]),
  searchableLiteraryWorksProvider.overrideWith(
    (ref) async => const [testWorkRudaki],
  ),
  historyEntriesProvider.overrideWith((ref) async => const []),
  booksProvider.overrideWith((ref) async => const []),
];

Future<void> _search(WidgetTester tester, String route, String query) async {
  await openApp(
    tester,
    route: route,
    catalog: seedProverbs,
    overrides: _overrides,
  );
  await tester.enterText(find.byType(TextField), query);
  await tester.pumpAndSettle();
}

/// Every query in [_rudakiQueries] finds the poet on [route], and every
/// query in [_poemQueries] finds the poem.
void _findsPoetAndPoem(String route) {
  for (final MapEntry(key: keyboard, value: query) in _rudakiQueries.entries) {
    testWidgets('«$query» ($keyboard) finds the poet', (tester) async {
      await _search(tester, route, query);
      expect(
        find.textContaining('Абӯабдуллоҳи Рӯдакӣ', findRichText: true),
        findsWidgets,
      );
    });
  }
  for (final MapEntry(key: keyboard, value: query) in _poemQueries.entries) {
    testWidgets('«$query» ($keyboard) finds the poem', (tester) async {
      await _search(tester, route, query);
      expect(
        find.textContaining('Бӯи ҷӯи Мӯлиён', findRichText: true),
        findsWidgets,
      );
    });
  }
}

void main() {
  group('poet list filter', () {
    for (final MapEntry(key: keyboard, value: query)
        in _rudakiQueries.entries) {
      testWidgets('finds Рӯдакӣ from «$query» ($keyboard)', (tester) async {
        await _search(tester, '/literature/poets', query);
        expect(find.textContaining('Рӯдакӣ'), findsWidgets);
        expect(find.textContaining('Ҷомӣ'), findsNothing);
      });
    }

    testWidgets('finds Ҷомӣ from «Jami» and «Jomi»', (tester) async {
      for (final query in ['Jami', 'Jomi']) {
        await _search(tester, '/literature/poets', query);
        expect(find.textContaining('Ҷомӣ'), findsWidgets, reason: query);
        expect(find.textContaining('Рӯдакӣ'), findsNothing, reason: query);
      }
    });

    testWidgets('the hint says Latin works', (tester) async {
      await openApp(tester, route: '/literature/poets', overrides: _overrides);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.hintText, contains('Rudaki'));
    });
  });

  group('works list filter', () {
    for (final MapEntry(key: keyboard, value: query) in {
      ..._poemQueries,
      'poet, Latin': 'Rudaki',
    }.entries) {
      testWidgets('«$query» ($keyboard) keeps the poem', (tester) async {
        await _search(tester, '/literature/works', query);
        expect(
          find.textContaining('Бӯи ҷӯи Мӯлиён', findRichText: true),
          findsWidgets,
        );
      });
    }

    testWidgets('«Jomi» leaves no poem of Рӯдакӣ', (tester) async {
      await _search(tester, '/literature/works', 'Jomi');
      expect(
        find.textContaining('Бӯи ҷӯи Мӯлиён', findRichText: true),
        findsNothing,
      );
    });
  });

  group('literature search', () {
    _findsPoetAndPoem('/literature/search');

    testWidgets('the empty page says any alphabet works', (tester) async {
      await openApp(tester, route: '/literature/search', overrides: _overrides);
      expect(
        find.text(
          AppTranslations.get('search_any_script_tip', DisplayLanguage.tajik),
        ),
        findsOneWidget,
      );
    });
  });

  group('global search', () {
    _findsPoetAndPoem('/search');

    testWidgets('the empty page says any alphabet works, in Persian too', (
      tester,
    ) async {
      for (final lang in DisplayLanguage.values) {
        await openApp(
          tester,
          route: '/search',
          language: lang,
          catalog: seedProverbs,
          overrides: _overrides,
        );
        expect(
          find.text(AppTranslations.get('search_any_script_tip', lang)),
          findsOneWidget,
          reason: lang.name,
        );
      }
    });
  });
}
