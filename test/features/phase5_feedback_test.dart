// Behaviour from the owner's feedback round (24 Sep 2026): one-line source,
// no seal, end-aligned verse wraps, sentence-case titles, textbook portraits,
// the Learn redesign and the searchable works list.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/literary_author_display_text.dart';
import 'package:zarbulmasal/features/literature/presentation/literary_work_display_text.dart';
import 'package:zarbulmasal/features/literature/presentation/widgets/verse_view.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../helpers/test_helper.dart';

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

final _worksOverrides = [
  approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
  literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
];

String tj(String key, [List<Object> args = const []]) =>
    AppTranslations.get(key, DisplayLanguage.tajik, args);

void main() {
  group('source line', () {
    test('names the textbook, grade and year only, never the page', () {
      final work = _works.firstWhere(
        (w) =>
            (w.primarySource?.sourceReference ?? '').contains('sinfi 5') &&
            w.primarySource?.pageStart != null,
      );
      final citation = LiteraryWorkDisplayText.shortCitation(
        work,
        DisplayLanguage.tajik,
      )!;
      expect(citation, 'Адабиёти тоҷик, синфи 5 (2017)');
      expect(citation, isNot(contains('с. ${work.primarySource!.pageStart}')));
      // Nothing from the provenance record beyond the book.
      expect(citation, isNot(contains('.pdf')));
      expect(citation, isNot(contains('ISBN')));
    });

    test('Persian uses Persian digits and labels', () {
      final work = _works.firstWhere(
        (w) => (w.primarySource?.sourceReference ?? '').contains('sinfi'),
      );
      final citation = LiteraryWorkDisplayText.shortCitation(
        work,
        DisplayLanguage.persian,
      )!;
      expect(citation, contains('صنف'));
      expect(citation, isNot(contains(RegExp(r'[0-9]'))));
    });
  });

  test('lists show the first line only when it is not the title', () {
    final knownByFirstLine = _works.firstWhere(
      (w) => (w.incipit ?? '').toLowerCase().startsWith(
        LiteraryWorkDisplayText.title(w, DisplayLanguage.tajik).toLowerCase(),
      ),
    );
    final titled = _works.firstWhere(
      (w) =>
          w.incipit != null &&
          !w.incipit!.toLowerCase().startsWith(
            LiteraryWorkDisplayText.title(
              w,
              DisplayLanguage.tajik,
            ).toLowerCase(),
          ),
    );
    expect(
      LiteraryWorkDisplayText.distinctIncipit(
        knownByFirstLine,
        DisplayLanguage.tajik,
      ),
      isNull,
    );
    expect(
      LiteraryWorkDisplayText.distinctIncipit(titled, DisplayLanguage.tajik),
      titled.incipit,
    );
  });

  testWidgets('a wrapped hemistich continues flush to the end edge', (
    tester,
  ) async {
    const line = 'Оби Ҷайҳун аз нишоти рӯйи дӯст';
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            child: HangingIndentLine(
              text: line,
              style: TextStyle(fontSize: 24),
              textDirection: TextDirection.ltr,
              indent: 36,
            ),
          ),
        ),
      ),
    );
    final parts = tester.widgetList<Text>(find.byType(Text)).toList();
    expect(parts, hasLength(2));
    expect(parts.last.textAlign, TextAlign.end);
    // It sits to the right of the first line's start (LTR).
    expect(
      tester.getTopRight(find.text(parts.last.data!)).dx,
      greaterThan(tester.getTopRight(find.text(parts.first.data!)).dx - 1),
    );
  });

  testWidgets('the reader shows no seal and no «Сабт» in either theme', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      final work = _works.first;
      await openApp(
        tester,
        route: '/literature/work/${work.id}',
        dark: dark,
        height: 1600,
        overrides: _worksOverrides,
      );
      expect(find.text(tj('record_tab_record')), findsNothing);
      expect(find.byIcon(Icons.verified), findsNothing);
      expect(find.byIcon(Icons.verified_outlined), findsNothing);
      expect(find.textContaining('Манбаъ: '), findsOneWidget);
    }
  });

  group('portraits', () {
    test('a textbook portrait is shown and cited by its book', () {
      const portrait = PortraitRecord(
        assetPath: 'assets/data/literature/portraits/rudaki.jpeg',
        sourceType: PortraitSourceType.uploadedBook,
        sourceReference: 'docs/literature/pdfs/adabiet sinfi 5.pdf',
        sourcePage: 49,
      );
      // Rights stay as recorded ('unknown'); display follows the source.
      expect(portrait.isRightsCleared, isFalse);
      expect(portrait.isDisplayable, isTrue);
      expect(
        LiteraryAuthorDisplayText.portraitCitation(
          portrait,
          DisplayLanguage.tajik,
        ),
        'Сурат: Адабиёти тоҷик, синфи 5 (2017)',
      );
      expect(
        LiteraryAuthorDisplayText.portraitCitation(
          portrait,
          DisplayLanguage.persian,
        ),
        'تصویر: ادبیات تاجیک، صنف ۵ (۲۰۱۷)',
      );
    });

    test('a portrait from any other source stays a monogram', () {
      const portrait = PortraitRecord(
        assetPath: 'assets/data/literature/portraits/x.jpeg',
        sourceType: PortraitSourceType.userProvidedPhoto,
        sourceReference: 'https://example.com/x.jpg',
        sourcePage: 1,
      );
      expect(portrait.isDisplayable, isFalse);
    });
  });

  testWidgets('Learn opens with progress and four practice folios', (
    tester,
  ) async {
    await openApp(tester, route: '/learn', height: 1400);
    expect(find.text(tj('learn_your_progress')), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(QalamFolioTile), findsNWidgets(4));
    expect(find.text(tj('quiz_title')), findsOneWidget);
    expect(find.text(tj('flashcards_title')), findsOneWidget);
  });

  testWidgets('the works list filters by poet name', (tester) async {
    await openApp(
      tester,
      route: '/literature/works',
      height: 1400,
      overrides: _worksOverrides,
    );
    await tester.enterText(find.byType(TextField), 'Хайём');
    await tester.pumpAndSettle();
    final rows = find.byType(QalamSlip);
    expect(rows, findsWidgets);
    expect(find.text('Бӯйи Ҷӯйи Мулиён'), findsNothing);
  });
}
