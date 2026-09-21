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
  );

  testWidgets('portrait fallback is stable and accessible', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QalamPortrait(portrait: null, label: 'Абӯабдуллоҳи Рӯдакӣ'),
        ),
      ),
    );

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
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

  testWidgets('source-backed portrait exposes one citation-aware image node', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QalamPortrait(
            portrait: missingPortrait,
            label: 'Абӯабдуллоҳи Рӯдакӣ',
          ),
        ),
      ),
    );

    final portraitSemantics = tester.getSemantics(find.byType(QalamPortrait));
    expect(portraitSemantics.label, contains('Абӯабдуллоҳи Рӯдакӣ'));
    expect(portraitSemantics.label, contains('PDF p. 49'));
    expect(tester.getSemantics(find.byType(Image)), same(portraitSemantics));
    expect(tester.takeException(), isNull);
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
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
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
}
