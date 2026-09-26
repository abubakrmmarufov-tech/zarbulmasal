// Phase 7 accessibility pass: Home, Explore, the poem list with its form
// chips, the reader and its Lexicon sheet, the poet page, History and the
// Lexicon, in light and dark, Tajik and Persian, at 100% and 200% text.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/data/history_repository.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/lookup_text.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/features/vocabulary/presentation/lexicon_sheet.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import 'helpers/file_asset_bundle.dart';
import 'helpers/test_helper.dart';

double contrast(Color a, Color b) {
  final (x, y) = (a.computeLuminance(), b.computeLuminance());
  return (math.max(x, y) + .05) / (math.min(x, y) + .05);
}

const _poem = '/literature/work/rudaki_buyi_juyi_muliyon_grade5_2017_p54';

/// Screens are measured at a phone's pixel density. The contrast guideline
/// reads each text's colour from the screenshot; at 1x a 12 px stroke is
/// mostly anti-aliased edge, and FreeType (the Linux CI runner) draws those
/// edges lighter than CoreText (macOS), so the measured colour depended on
/// the platform rather than on the theme.
const _phonePixelRatio = 3.0;

List<dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as List<dynamic>;

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

final _words = _json('assets/data/vocabulary/words.json')
    .whereType<Map<String, dynamic>>()
    .map(WordEntry.fromJson)
    .where((w) => w.term.isNotEmpty && w.definition.isNotEmpty)
    .toList();

final _entries = _json('assets/data/history/entries.json')
    .whereType<Map>()
    .map((m) => HistoryEntry.fromJson(Map<String, dynamic>.from(m)))
    .toList();

final _bundle = FileAssetBundle();

/// Every catalogue read from the repository files, settled synchronously.
final _overrides = [
  nowProvider.overrideWithValue(() => DateTime.utc(2026, 9, 25, 6)),
  literatureRepositoryProvider.overrideWithValue(
    LiteratureRepository(bundle: _bundle),
  ),
  historyRepositoryProvider.overrideWithValue(
    HistoryRepository(bundle: _bundle),
  ),
  approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
  literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
  historyEntriesProvider.overrideWith((ref) async => _entries),
  wordsProvider.overrideWith((ref) async => _words),
];

/// Each screen with the page title TalkBack must announce as a heading.
const _screens = <String, String>{
  '/': 'ЗАРБУЛМАСАЛ',
  '/explore': 'Кашф',
  '/literature/works?form=ghazal': 'Шеърҳо',
  _poem: 'Бӯйи Ҷӯйи Мулиён',
  '/literature/poet/rudaki': 'Абӯабдуллоҳи Рӯдакӣ',
  '/history': 'Таърихи халқи тоҷик',
  '/history/person-ayni': 'Садриддин Айнӣ',
  '/vocabulary': 'Луғатнома',
};

/// Taps [word] where it is printed in a line of the poem.
Future<void> _tapWord(WidgetTester tester, String word) async {
  final line = find.byWidgetPredicate(
    (w) => w is LookupText && w.text.contains(word),
  );
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: line.first, matching: find.byType(RichText)),
  );
  final start = tester.widget<LookupText>(line.first).text.indexOf(word);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + word.length),
      )
      .first
      .toRect();
  await tester.tapAt(paragraph.localToGlobal(box.center));
  await tester.pumpAndSettle();
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  for (final MapEntry(key: route, value: title) in _screens.entries) {
    for (final dark in [false, true]) {
      testWidgets('$route meets tap-target, label and contrast guidelines '
          '(${dark ? 'dark' : 'light'})', (tester) async {
        final semantics = tester.ensureSemantics();
        await openApp(
          tester,
          route: route,
          dark: dark,
          overrides: _overrides,
          pixelRatio: _phonePixelRatio,
        );
        await _expectGuidelines(tester);
        semantics.dispose();
      });
    }

    testWidgets('$route announces «$title» as a heading', (tester) async {
      final semantics = tester.ensureSemantics();
      await openApp(tester, route: route, overrides: _overrides);
      final heading = find.text(title).evaluate().isNotEmpty
          ? find.text(title)
          : find.text(title.toUpperCase());
      expect(tester.getSemantics(heading.first), isSemantics(isHeader: true));
      semantics.dispose();
    });

    for (final language in DisplayLanguage.values) {
      testWidgets('$route fits at 200% text in ${language.name}', (
        tester,
      ) async {
        await openApp(
          tester,
          route: route,
          width: 360,
          height: 800,
          scale: 2,
          language: language,
          overrides: _overrides,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the Lexicon sheet is a labelled, readable dialog', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      final semantics = tester.ensureSemantics();
      await openApp(
        tester,
        route: _poem,
        height: 2000,
        dark: dark,
        overrides: _overrides,
      );
      await _tapWord(tester, 'парниён');
      expect(find.byType(LexiconSheet), findsOneWidget);
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(LexiconSheet),
            matching: find.text('парниён'),
          ),
        ),
        isSemantics(isHeader: true),
      );
      await _expectGuidelines(tester);
      semantics.dispose();
    }
  });

  testWidgets('the Lexicon sheet fits at 200% text', (tester) async {
    await openApp(
      tester,
      route: _poem,
      width: 360,
      height: 2000,
      scale: 2,
      overrides: _overrides,
    );
    await _tapWord(tester, 'парниён');
    expect(find.byType(LexiconSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buttons that speak their own label still act on double tap', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final app = await openApp(tester, overrides: _overrides, height: 1400);
    final tile = find.byType(QalamFolioTile).first;
    expect(
      tester.getSemantics(tile),
      isSemantics(isButton: true, hasTapAction: true),
    );
    tester.semantics.tap(find.semantics.byLabel(RegExp(r'^Адабиёт\.')));
    await tester.pumpAndSettle();
    expect(app.router.state.uri.path, isNot('/'));

    await openApp(tester, route: _poem, height: 2000, overrides: _overrides);
    final next = find.semantics.byLabel(RegExp(r'^Баъдӣ: '));
    expect(next, findsOneWidget);
    expect(
      next.evaluate().single.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('TalkBack never stops on the "·" between reader details', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openApp(tester, route: _poem, overrides: _overrides);
    expect(find.bySemanticsLabel(RegExp(r'^\s*·\s*$')), findsNothing);
    // The poem is read line by line, in order.
    final lines = find.byType(LookupText);
    expect(lines, findsWidgets);
    final tops = [
      for (final element in lines.evaluate())
        tester.getTopLeft(find.byWidget(element.widget)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    semantics.dispose();
  });

  test('a selected chip label is readable in both themes', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final chips = theme.chipTheme;
      expect(
        contrast(chips.secondaryLabelStyle!.color!, chips.selectedColor!),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.brightness}',
      );
    }
  });
}
