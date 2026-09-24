import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/features/literature/domain/portrait_record.dart';

void main() {
  const missingPortrait = PortraitRecord(
    assetPath: 'assets/data/literature/portraits/rudaki.png',
    sourceType: PortraitSourceType.uploadedBook,
    sourceReference: 'docs/literature/pdfs/adabiet sinfi 5.pdf',
    sourcePage: 49,
    rightsStatus: 'publicDomain',
  );
  // Every bundled portrait record today: rights not cleared.
  const rightsUnknownPortrait = PortraitRecord(
    assetPath: 'assets/data/literature/portraits/rudaki.png',
    sourceType: PortraitSourceType.uploadedBook,
    sourceReference: 'docs/literature/pdfs/adabiet sinfi 5.pdf',
    sourcePage: 49,
  );

  testWidgets('a textbook portrait is shown even with rights unrecorded', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QalamPortrait(
            portrait: rightsUnknownPortrait,
            label: 'Абӯабдуллоҳи Рӯдакӣ',
            persianName: 'ابوعبدالله رودکی',
            citationLabel: 'Сурат: Адабиёти тоҷик, синфи 5, с. 49',
          ),
        ),
      ),
    );

    // Portraits printed in the two approved sources are shown (owner
    // decision); the rights field is not treated as cleared.
    expect(rightsUnknownPortrait.isRightsCleared, isFalse);
    expect(find.byType(Image), findsOneWidget);
    final semantics = tester.getSemantics(find.byType(QalamPortrait));
    expect(semantics.label, contains('синфи 5, с. 49'));
    expect(semantics.label, isNot(contains('.pdf')));
  });

  testWidgets('portrait fallback is stable and accessible', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QalamPortrait(portrait: null, label: 'Абӯабдуллоҳи Рӯдакӣ'),
        ),
      ),
    );

    expect(find.byType(QalamMonogramPlate), findsOneWidget);
    final semantics = tester.getSemantics(find.byType(QalamPortrait));
    expect(semantics.label, contains('portrait unavailable'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('portrait fallback exposes the localized accessibility label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QalamPortrait(
            portrait: null,
            label: 'نام شاعر',
            unavailableLabel: 'پرتره در دسترس نیست',
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(QalamPortrait));
    expect(semantics.label, contains('پرتره در دسترس نیست'));
    expect(semantics.label, isNot(contains('portrait unavailable')));
  });

  testWidgets(
    'a rights-cleared, source-backed portrait exposes one citation-aware image node',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QalamPortrait(
              portrait: missingPortrait,
              label: 'Абӯабдуллоҳи Рӯдакӣ',
              citationLabel: 'Китоби дарсӣ, с. 49',
            ),
          ),
        ),
      );

      final portraitSemantics = tester.getSemantics(find.byType(QalamPortrait));
      expect(portraitSemantics.label, contains('Абӯабдуллоҳи Рӯдакӣ'));
      expect(portraitSemantics.label, contains('Китоби дарсӣ, с. 49'));
      expect(portraitSemantics.label, isNot(contains('.pdf')));
      expect(tester.getSemantics(find.byType(Image)), same(portraitSemantics));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('localized portrait citation hides source filenames', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QalamPortrait(
            portrait: missingPortrait,
            label: 'نام شاعر',
            citationLabel: 'منبع: کتاب درسی، صفحهٔ ۴۹',
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(QalamPortrait));
    expect(semantics.label, contains('منبع: کتاب درسی، صفحهٔ ۴۹'));
    expect(semantics.label, isNot(contains('adabiet sinfi 5.pdf')));
  });

  testWidgets('failed source-backed asset switches to unavailable semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QalamPortrait(
            portrait: missingPortrait,
            label: 'Абӯабдуллоҳи Рӯдакӣ',
            unavailableLabel: 'Портрет дастрас нест',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(find.byType(QalamPortrait));
    expect(semantics.label, contains('Портрет дастрас нест'));
    expect(semantics.label, isNot(contains('PDF p. 49')));
    expect(find.byType(QalamMonogramPlate), findsOneWidget);
  });

  testWidgets('poet card preserves a bounded portrait slot in Persian RTL', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QalamPoetCard(
              name: 'نام بسیار طولانی شاعر برای آزمون چیدمان راست به چپ',
              dates: '۸۵۸ – ۹۴۱',
              period: 'دورهٔ کلاسیک ادبیات فارسی و تاجیکی',
              portrait: missingPortrait,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(QalamPortrait), findsOneWidget);
    expect(
      find.text('نام بسیار طولانی شاعر برای آزمون چیدمان راست به چپ'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'poet card fits names, dates, and birthplace at 320px with 1.5x text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: QalamPoetCard(
                name: 'Абдурраҳмони Ҷомӣ',
                dates: 'Таваллуд: 1414 · Вафот: 1492',
                place: 'Ҷом, Хуросон',
                period: 'Асри XV',
                poemCountBadge: '24 асар',
                portrait: missingPortrait,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QalamPortrait), findsOneWidget);
      expect(find.text('Абдурраҳмони Ҷомӣ'), findsOneWidget);
      expect(find.text('Ҷом, Хуросон'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('poet card omits the place row when no birthplace is known', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: QalamPoetCard(
              name: 'Шоири бе зодгоҳ',
              dates: '1911 – 1977',
              period: 'Асри XX',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.place_outlined), findsNothing);
    expect(find.text('Шоири бе зодгоҳ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
