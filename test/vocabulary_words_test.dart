import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/core/design_system/qalam_colors.dart';
import 'package:zarbulmasal/features/vocabulary/presentation/vocabulary_screen.dart';

import 'helpers/test_helper.dart';

/// The five reviewed headwords that appear together on p.17 of the source PDF.
/// These are the screenshot's canonical rows and the minimum the Luғатномa
/// must render.
const p17Terms = <String>['Тилисм', 'Раҳнамо', 'Каманд', 'Камон', 'Урду'];

/// Definitions that are not dictionary headword rows — proverb text, history
/// titles, and author biographies from the old aggregator. None may leak into
/// the Luғатномa screen.
const nonWordFragments = <String>[
  'Садриддин Айнӣ',
  'Зарбулмасал',
  'Охири асри XIX',
];

/// WCAG relative luminance of a color in [0, 1].
double _relativeLuminance(Color color) {
  double linear(int channel) {
    final v = channel / 255.0;
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  int channel(double value) => (value * 255.0).round().clamp(0, 255);
  return 0.2126 * linear(channel(color.r)) +
      0.7152 * linear(channel(color.g)) +
      0.0722 * linear(channel(color.b));
}

/// WCAG contrast ratio between two colors (>= 1.0).
double _contrast(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

WordEntry _entry(String term, String definition, {int page = 17}) {
  return WordEntry(
    term: term,
    definition: definition,
    sourceBook: 'adabiet sinfi 5.pdf',
    pdfPage: page,
  );
}

final _fixture = <WordEntry>[
  _entry('Тилисм', 'ҷоду.'),
  _entry('Раҳнамо', 'ба маънои нақша, план омадааст.'),
  _entry('Каманд', 'асбоби ҷангӣ, мисли арғамчин, ки ҳалқадавак дорад.'),
  _entry(
    'Камон',
    'асбоби ҷангӣ, чӯби хамидае, ки ду нӯги онро бо зеҳ таранг '
        'мебанданд ва ба воситаи он тирро сар медиҳанд.',
  ),
  _entry('Урду', 'лашкар, сипоҳ.'),
];

Future<List<WordEntry>> _loadBundled() async {
  final raw =
      jsonDecode(
            await rootBundle.loadString('assets/data/vocabulary/words.json'),
          )
          as List<dynamic>;
  return raw
      .whereType<Map<String, dynamic>>()
      .map(WordEntry.fromJson)
      .where((w) => w.term.isNotEmpty && w.definition.isNotEmpty)
      .toList(growable: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WordEntry model', () {
    test('parses a JSON object and keeps source metadata', () {
      const json = {
        'term': 'Тилисм',
        'definition': 'ҷоду.',
        'sourceBook': 'adabiet sinfi 5.pdf',
        'pdfPage': 17,
      };
      final entry = WordEntry.fromJson(json);
      expect(entry.term, 'Тилисм');
      expect(entry.definition, 'ҷоду.');
      expect(entry.sourceBook, 'adabiet sinfi 5.pdf');
      expect(entry.pdfPage, 17);
    });

    test('bundled word list carries only reviewed lexical pairs', () async {
      final words = await _loadBundled();

      // The full reviewed list: 284 headword–definition pairs. All 284 source
      // entries are kept — none are dropped. Five headwords legitimately
      // repeat across different source PDF pages (e.g. «Гил», «Кадхудо»), so
      // uniqueness is keyed by the (term, pdfPage) pair, not by term alone.
      expect(words, hasLength(284));
      expect(words.every((w) => w.term.isNotEmpty), isTrue);
      expect(words.every((w) => w.definition.isNotEmpty), isTrue);
      final termPageKeys = words.map((w) => (w.term, w.pdfPage)).toSet();
      expect(termPageKeys, hasLength(284));
      // The five repeat on different pages, so there are 279 distinct terms.
      expect(words.map((w) => w.term).toSet(), hasLength(279));

      // The five p.17 terms from the screenshot are present.
      final terms = words.map((w) => w.term).toSet();
      for (final term in p17Terms) {
        expect(terms, contains(term), reason: 'missing p.17 headword $term');
      }

      // No old aggregator rows (proverbs, history, author bios) exist here.
      for (final fragment in nonWordFragments) {
        expect(words.where((w) => w.term.contains(fragment)), isEmpty);
        expect(words.where((w) => w.definition.contains(fragment)), isEmpty);
      }

      // Source provenance survives on the model even though it is not shown.
      expect(words.every((w) => w.sourceBook.isNotEmpty), isTrue);
      expect(words.every((w) => w.pdfPage > 0), isTrue);
    });
  });

  group('Luғатнома screen', () {
    testWidgets('each headword is its own card with its meaning below', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/vocabulary',
        width: 390,
        height: 1600,
        overrides: [
          wordsProvider.overrideWith((ref) => Future.value(_fixture)),
        ],
      );

      for (final entry in _fixture) {
        // The headword and its definition are separate texts.
        expect(find.text(entry.term), findsOneWidget);
        expect(find.text(entry.definition), findsOneWidget);
      }
      // Grouped under Tajik letters, e.g. «К» for Каманд/Камон.
      expect(find.text('К'), findsWidgets);

      // Old aggregator rows are absent from the lexicon.
      for (final fragment in nonWordFragments) {
        expect(find.textContaining(fragment, findRichText: true), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('search filters by word or meaning and says when empty', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/vocabulary',
        width: 390,
        height: 1600,
        overrides: [
          wordsProvider.overrideWith((ref) => Future.value(_fixture)),
        ],
      );

      await tester.enterText(find.byType(TextField), 'камон');
      await tester.pumpAndSettle();
      // «Камон» is highlighted, so its card title is rich text.
      expect(find.text('Камон', findRichText: true), findsOneWidget);
      expect(find.text('Тилисм'), findsNothing);

      await tester.enterText(find.byType(TextField), 'ққққ');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('the alphabet strip narrows the list to one letter', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/vocabulary',
        width: 390,
        height: 1600,
        overrides: [
          wordsProvider.overrideWith((ref) => Future.value(_fixture)),
        ],
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Т'));
      await tester.pumpAndSettle();
      expect(find.text('Тилисм'), findsOneWidget);
      expect(find.text('Камон'), findsNothing);
    });

    testWidgets('follows the dark theme with legible headwords', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/vocabulary',
        width: 390,
        dark: true,
        overrides: [
          wordsProvider.overrideWith((ref) => Future.value(_fixture)),
        ],
      );

      final context = tester.element(find.byType(VocabularyScreen));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.dark);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, isNot(QalamColors.paper));

      final headword = tester.widget<Text>(find.text(p17Terms.first));
      expect(
        _contrast(headword.style!.color!, theme.colorScheme.surfaceContainer),
        greaterThanOrEqualTo(4.5),
        reason: 'headword must meet 4.5:1 on the night card',
      );
    });

    test('sorts in Tajik alphabetical order', () {
      final sorted = TajikAlphabet.sort([
        _entry('Ҳавас', 'a'),
        _entry('Ғам', 'b'),
        _entry('Хона', 'c'),
        _entry('Гул', 'd'),
      ]).map((w) => w.term);
      expect(sorted, ['Гул', 'Ғам', 'Хона', 'Ҳавас']);
    });

    testWidgets('long definitions wrap at 320px width', (tester) async {
      final long = _entry(
        'Камон',
        'асбоби ҷангӣ, чӯби хамидае, ки ду нӯги онро бо зеҳ таранг '
            'мебанданд ва ба воситаи он тирро сар медиҳанд.',
      );

      await openApp(
        tester,
        route: '/vocabulary',
        width: 320,
        overrides: [
          wordsProvider.overrideWith((ref) => Future.value([long])),
        ],
      );

      expect(find.text(long.term), findsOneWidget);
      expect(find.textContaining('таранг'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
