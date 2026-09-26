// Behaviour added in Phase 1 (report roadmap "NOW", N1–N8).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/verse_view.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/providers/reading_position_provider.dart';
import 'package:zarbulmasal/shared/providers/reading_script_provider.dart';

import '../helpers/test_helper.dart';

const _rudakiId = 'rudaki_buyi_juyi_muliyon_grade5_2017_p54';

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

Future<TestApp> _open(
  WidgetTester tester, {
  String route = '/',
  DisplayLanguage language = DisplayLanguage.tajik,
  double width = 390,
  List<Object>? oral,
  bool settle = true,
}) async {
  final app = await openApp(
    tester,
    route: route,
    language: language,
    width: width,
    settle: settle,
    overrides: [
      approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
      literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
      if (oral != null)
        oralHeritageProvider.overrideWith(
          (ref) => Future.value(const <OralHeritageEntry>[]),
        ),
    ],
  );
  if (!settle) await _frames(tester);
  return app;
}

/// Screens that load several local catalogs show an indeterminate loader;
/// advance a fixed number of frames instead of waiting for it to settle.
Future<void> _frames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String tj(String key, [List<Object> args = const []]) =>
    AppTranslations.get(key, DisplayLanguage.tajik, args);

/// Every string drawn on screen (plain and rich text).
Iterable<String> _visibleStrings(WidgetTester tester) sync* {
  for (final widget in tester.allWidgets) {
    if (widget is Text) {
      yield widget.data ?? widget.textSpan?.toPlainText() ?? '';
    } else if (widget is RichText) {
      yield widget.text.toPlainText();
    }
  }
}

void main() {
  group('N1 · one verification vocabulary', () {
    testWidgets('a page-checked work never reads as editorially verified', (
      tester,
    ) async {
      await _open(tester, route: '/literature/work/$_rudakiId');

      // No verification claim at all: the reader names its source only.
      expect(find.text(tj('prov_status_checked_two')), findsNothing);
      expect(find.text(tj('prov_status_approved')), findsNothing);
      expect(find.text('Матн санҷида шудааст'), findsNothing);
      expect(find.textContaining('Манбаъ: '), findsOneWidget);
    });
  });

  group('N2 · no internal data on screen', () {
    final leak = RegExp(
      r'Tier|minor-variant|significant-variant|\bexact\b|docs/|\.pdf|'
      r'policy|sourceAttested|primaryChecked|needsReview|[0-9a-f]{16}',
    );
    for (final language in DisplayLanguage.values) {
      testWidgets('reader and source line are clean in ${language.name}', (
        tester,
      ) async {
        for (final work in _works) {
          await _open(
            tester,
            route: '/literature/work/${work.id}',
            language: language,
          );
          for (final text in _visibleStrings(tester)) {
            expect(leak.hasMatch(text), isFalse, reason: '${work.id}: $text');
          }
        }
      });
    }
  });

  group('N3 · bayt layout', () {
    testWidgets('a qasida is laid out as six bayts', (tester) async {
      await _open(tester, route: '/literature/work/$_rudakiId');
      final view = tester.widget<VerseView>(find.byType(VerseView));
      expect(view.layout.isBaytText, isTrue);
      expect(view.layout.unitCount, 6);
    });

    testWidgets('a wrapped line keeps its text and indents the rest', (
      tester,
    ) async {
      const line = 'Оби Ҷайҳун аз нишоти рӯйи дӯст';
      const style = TextStyle(fontSize: 24);
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 200,
              child: HangingIndentLine(
                text: line,
                style: style,
                textDirection: TextDirection.ltr,
                indent: 36,
              ),
            ),
          ),
        ),
      );
      final parts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data!)
          .toList();
      expect(parts, hasLength(2));
      // The two parts rejoin to the exact original characters.
      expect(parts.join(), line);
      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.text(parts.last), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, const EdgeInsetsDirectional.only(start: 36));
    });
  });

  group('N4 · reading script is separate from interface language', () {
    testWidgets('proverb page has no app-wide script switch', (tester) async {
      await _open(tester, route: '/proverb/${seedProverbs.first.id}');
      expect(find.text('فارسی (عربی)'), findsNothing);
      expect(find.text('Тоҷикӣ (Кириллӣ)'), findsNothing);
    });

    testWidgets('Persian reading script keeps the Tajik interface', (
      tester,
    ) async {
      final app = await _open(
        tester,
        route: '/proverb/${seedProverbs.first.id}',
      );
      await app.container
          .read(readingScriptPreferenceProvider.notifier)
          .setScript(ReadingScript.persian);
      await tester.pumpAndSettle();

      final hero = tester.widget<SelectableText>(
        find.byType(SelectableText).first,
      );
      expect(hero.data, seedProverbs.first.persianText);
      expect(
        app.container.read(displayLanguageProvider),
        DisplayLanguage.tajik,
      );
      expect(find.text(tj('home_edition')), findsOneWidget);
    });
  });

  group('N5 · Persian script is shown without a disclaimer', () {
    testWidgets('the Persian text carries no transliteration note', (
      tester,
    ) async {
      await _open(tester, route: '/literature/work/$_rudakiId');
      await tester.tap(find.text(tj('lit_script_persian')));
      await tester.pumpAndSettle();
      // The owner removed the note (26 Sep 2026): the Persian script is shown
      // as it is, with no «табдили механикӣ» label.
      expect(find.textContaining('Хатти форсӣ —'), findsNothing);
      expect(find.textContaining('механикӣ'), findsNothing);
      expect(find.byIcon(Icons.info_outline), findsNothing);
      expect(find.textContaining('بوی جوی مولیان'), findsWidgets);
      // Interface language is untouched.
      expect(find.text(tj('lit_reader_title')), findsOneWidget);
    });
  });

  group('N6 · Continue reading', () {
    testWidgets('resumes the last text, not the last page visited', (
      tester,
    ) async {
      final app = await _open(tester, route: '/literature/work/$_rudakiId');
      app.router.go('/literature/poet/rudaki');
      await _frames(tester);
      app.router.go('/');
      await _frames(tester);

      // Continue reading sits below the daily exhibit on Home.
      final label = find.text(tj('home_continue_reading').toUpperCase());
      await tester.scrollUntilVisible(
        label,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(label, findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Бӯйи Ҷӯйи Мулиён'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Бӯйи Ҷӯйи Мулиён'), findsOneWidget);
    });

    testWidgets('shows and reopens at the stored bayt', (tester) async {
      final app = await _open(tester, route: '/literature/work/$_rudakiId');
      await app.container
          .read(readingPositionProvider.notifier)
          .updateAnchor(
            kind: ReadingKind.work,
            id: _rudakiId,
            anchor: 4,
            total: 6,
            isBayt: true,
          );
      app.router.go('/');
      await tester.pumpAndSettle();

      final subtitle = '${tj('lit_genre_poem')} · ${tj('resume_bayt', [4, 6])}';
      await tester.scrollUntilVisible(
        find.text(subtitle),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(subtitle), findsOneWidget);

      final row = find.widgetWithText(QalamIndexRow, 'Бӯйи Ҷӯйи Мулиён');
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PoemReaderScreen>(find.byType(PoemReaderScreen))
            .initialAnchor,
        4,
      );
    });

    testWidgets('home shows no Continue card before anything is read', (
      tester,
    ) async {
      await _open(tester);
      // Scroll the whole Home page: the Continue section must not exist.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(
        find.text(tj('home_continue_reading').toUpperCase()),
        findsNothing,
      );
    });
  });

  group('N7 · no character counters', () {
    for (final route in [
      '/search',
      '/proverbs',
      '/literature/poets',
      '/history',
    ]) {
      testWidgets('$route shows no counter and still limits input', (
        tester,
      ) async {
        await _open(tester, route: route, width: 1024, settle: false);
        final counter = RegExp(r'^\d+/256$');
        expect(_visibleStrings(tester).where(counter.hasMatch), isEmpty);
        if (route == '/history') {
          // History folds its search field behind an icon.
          await tester.tap(find.byIcon(Icons.search).last);
          await tester.pump();
        }

        for (
          var i = 0;
          i < 50 && find.byType(TextField).evaluate().isEmpty;
          i++
        ) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        final field = find.byType(TextField).first;
        await tester.enterText(field, 'а' * 300);
        await tester.pump();
        final editable = tester.widget<EditableText>(
          find.descendant(of: field, matching: find.byType(EditableText)),
        );
        expect(editable.controller.text.length, 256);
        expect(_visibleStrings(tester).where(counter.hasMatch), isEmpty);
      });
    }
  });

  test('no text field in lib/ draws a maxLength counter', () {
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => file.readAsStringSync().contains('maxLength:'))
        .map((file) => file.path)
        .toList();
    expect(offenders, isEmpty);
  });

  group('N8 · empty collections have no entry points', () {
    testWidgets('Explore hides empty oral heritage', (tester) async {
      await _open(tester, route: '/explore', oral: const []);
      expect(find.text(tj('explore_oral_title')), findsNothing);
    });

    testWidgets('a direct link to empty oral heritage lands on Literature', (
      tester,
    ) async {
      await _open(tester, route: '/literature/oral', oral: const []);
      expect(find.byType(OralHeritageScreen), findsNothing);
      expect(find.byType(LiteratureHubScreen), findsOneWidget);
    });
  });
}
