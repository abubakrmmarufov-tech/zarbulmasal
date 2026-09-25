import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/lookup_text.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/presentation/lexicon_sheet.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../../helpers/test_helper.dart';

// Рӯдакӣ, «Бӯйи Ҷӯйи Мулиён» (grade 5, p. 54): «Зери поям парниён ояд ҳаме.»
const _poem = '/literature/work/rudaki_buyi_juyi_muliyon_grade5_2017_p54';

String tj(String key) => AppTranslations.get(key, DisplayLanguage.tajik);

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

final _overrides = [
  approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
  literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
  wordsProvider.overrideWith((ref) async => _lexicon),
];

final _lexicon = [
  const WordEntry(
    term: 'Парниён',
    definition: 'матои нафис, ҳарир.',
    sourceBook: 'adabiet sinfi 5.pdf',
    pdfPage: 54,
  ),
];

/// Taps the first occurrence of [word] in a line of the poem.
Future<void> tapWord(WidgetTester tester, String word) async {
  final line = find.byWidgetPredicate(
    (w) => w is LookupText && w.text.contains(word),
  );
  expect(line, findsWidgets);
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: line.first, matching: find.byType(RichText)),
  );
  final text = (tester.widget<LookupText>(line.first)).text;
  final start = text.indexOf(word);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + word.length),
      )
      .first
      .toRect();
  await tester.tapAt(paragraph.localToGlobal(box.center));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a word in the poem shows its Lexicon meaning', (
    tester,
  ) async {
    await openApp(tester, route: _poem, height: 2000, overrides: _overrides);
    expect(find.text(tj('reader_word_hint')), findsOneWidget);

    await tapWord(tester, 'парниён');

    expect(find.byType(LexiconSheet), findsOneWidget);
    expect(find.text('матои нафис, ҳарир.'), findsOneWidget);
    expect(
      find.text(
        AppTranslations.get('lex_sheet_source', DisplayLanguage.tajik, [
          '5',
          '54',
        ]),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a word not in the Lexicon says so and offers the Lexicon', (
    tester,
  ) async {
    await openApp(tester, route: _poem, height: 2000, overrides: _overrides);
    await tapWord(tester, 'Зери');
    expect(find.text(tj('lex_sheet_not_found')), findsOneWidget);
    expect(find.text(tj('lex_sheet_open')), findsOneWidget);
  });

  testWidgets('in Persian script words are not looked up', (tester) async {
    await openApp(
      tester,
      route: _poem,
      height: 2000,
      language: DisplayLanguage.persian,
      overrides: _overrides,
    );
    expect(find.byType(LookupText), findsNothing);
    expect(
      find.text(
        AppTranslations.get('reader_word_hint', DisplayLanguage.persian),
      ),
      findsNothing,
    );
  });
}
