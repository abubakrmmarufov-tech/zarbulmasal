// Behaviour added in Phase 3: Home exhibit, reader title card («Шаб»),
// «Атлас» covers, «Баёзи ман».
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/data/seed/seed_categories.dart';
import 'package:zarbulmasal/features/home/widgets/home_exhibit.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/providers/bayoz_provider.dart';
import 'package:zarbulmasal/shared/providers/reading_script_provider.dart';

import '../helpers/test_helper.dart';

const _rudakiId = 'rudaki_buyi_juyi_muliyon_grade5_2017_p54';

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

final List<SchoolCanonEntry> _canon =
    (jsonDecode(
              File(
                'assets/data/literature/school_canon.json',
              ).readAsStringSync(),
            )
            as List)
        .whereType<Map>()
        .map(
          (json) => SchoolCanonEntry.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();

final _worksOverrides = [
  approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
  literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
  schoolCanonProvider.overrideWith((ref) => Future.value(_canon)),
];

String tj(String key) => AppTranslations.get(key, DisplayLanguage.tajik);

void main() {
  group('Home exhibit', () {
    testWidgets('exhibits the daily proverb in Cyrillic with Persian below', (
      tester,
    ) async {
      final app = await openApp(tester, overrides: _worksOverrides);
      final daily = app.container.read(dailyProverbProvider)!;
      final exhibit = find.byType(HomeExhibit);
      expect(exhibit, findsOneWidget);
      final texts = tester
          .widgetList<Text>(
            find.descendant(of: exhibit, matching: find.byType(Text)),
          )
          .toList();
      final hero = texts.firstWhere((t) => t.data == daily.tajikCyrillic);
      expect(hero.style!.fontFamily, QalamTypography.display);
      final persian = texts.firstWhere((t) => t.data == daily.persianText);
      expect(persian.style!.fontFamily, QalamTypography.nastaliq);
    });

    testWidgets('Persian reading script puts Nastaliq in the hero', (
      tester,
    ) async {
      final app = await openApp(tester, overrides: _worksOverrides);
      await app.container
          .read(readingScriptPreferenceProvider.notifier)
          .setScript(ReadingScript.persian);
      await tester.pumpAndSettle();
      final daily = app.container.read(dailyProverbProvider)!;
      final hero = tester.widget<Text>(find.text(daily.persianText));
      expect(hero.style!.fontFamily, QalamTypography.nastaliq);
      expect(hero.style!.fontSize!, greaterThan(25));
    });

    testWidgets('grade lens opens the school canon on that grade', (
      tester,
    ) async {
      final app = await openApp(tester, overrides: _worksOverrides);
      // The grade lens closes the Home page.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
      await tester.pumpAndSettle();
      final chip = find.byType(ActionChip).first;
      final label = (tester.widget<ActionChip>(chip).label as Text).data!;
      await tester.tap(chip);
      await tester.pumpAndSettle();
      final screen = tester.widget<SchoolCanonScreen>(
        find.byType(SchoolCanonScreen),
      );
      expect(label, contains(screen.initialGrade!));
      expect(app.router.state.uri.path, '/literature/school');
    });
  });

  testWidgets(
    '«Шаб» opens the poem with a centred title card in sentence case',
    (tester) async {
      await openApp(
        tester,
        route: '/literature/work/$_rudakiId',
        dark: true,
        overrides: _worksOverrides,
      );
      // The title as written (only first letters capital), not in capitals.
      expect(find.text('Бӯйи Ҷӯйи Мулиён'), findsOneWidget);
      expect(find.text('БӮЙИ ҶӮЙИ МУЛИЁН'), findsNothing);
      expect(find.textContaining('Қасида'), findsWidgets);
    },
  );

  testWidgets('each proverb theme wears its own «Атлас» cover', (tester) async {
    await openApp(tester, route: '/categories');
    final covers = tester.widgetList<AtlasCover>(find.byType(AtlasCover));
    expect(covers.length, greaterThan(0));
    expect(
      covers.map((cover) => cover.seed).toSet().length,
      covers.length,
      reason: 'seeded from each collection id',
    );
    expect(
      AtlasPainter.stableHash(seedCategories.first.id),
      AtlasPainter.stableHash(seedCategories.first.id),
    );
  });

  group('«Баёзи ман»', () {
    testWidgets('a new Баёз is named and opens empty', (tester) async {
      final app = await openApp(tester, route: '/saved');
      expect(find.text(tj('saved_title')), findsOneWidget);

      await tester.tap(find.text(tj('bayoz_new')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Барои модарам');
      await tester.tap(find.text(tj('bayoz_create')));
      await tester.pumpAndSettle();

      expect(app.container.read(bayozProvider).single.title, 'Барои модарам');
      expect(find.text(tj('bayoz_empty')), findsOneWidget);
    });

    testWidgets('a poem is collected from the reader into a Баёз', (
      tester,
    ) async {
      final app = await openApp(
        tester,
        route: '/literature/work/$_rudakiId',
        overrides: _worksOverrides,
      );
      final id = await app.container
          .read(bayozProvider.notifier)
          .create('Бухоро');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(tj('bayoz_add_to')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Бухоро'));
      await tester.pumpAndSettle();

      final bayoz = app.container.read(bayozProvider).single;
      expect(bayoz.id, id);
      expect(bayoz.items, [const BayozItem(BayozItemKind.work, _rudakiId)]);
    });

    testWidgets('a text no longer published is shown as unavailable', (
      tester,
    ) async {
      final app = await openApp(tester, overrides: _worksOverrides);
      final notifier = app.container.read(bayozProvider.notifier);
      final id = await notifier.create('Кӯҳна');
      await notifier.toggle(
        id!,
        const BayozItem(BayozItemKind.work, 'withdrawn-work'),
      );
      app.router.go('/saved/bayoz/$id');
      await tester.pumpAndSettle();

      expect(find.text(tj('bayoz_item_unavailable')), findsOneWidget);
      await tester.tap(find.byTooltip(tj('bayoz_remove_item')));
      await tester.pumpAndSettle();
      expect(app.container.read(bayozProvider).single.items, isEmpty);
    });

    testWidgets('at the cap, no new Баёз is offered and the limit is said', (
      tester,
    ) async {
      final app = await openApp(tester);
      final notifier = app.container.read(bayozProvider.notifier);
      for (var i = 0; i < BayozNotifier.maxCollections; i++) {
        await notifier.create('Баёз $i');
      }
      app.router.go('/saved');
      await tester.pumpAndSettle();

      expect(find.text(tj('bayoz_new')), findsNothing);
      final limit = find.text(
        AppTranslations.get('bayoz_limit', DisplayLanguage.tajik, [
          '${BayozNotifier.maxCollections}',
        ]),
      );
      await tester.scrollUntilVisible(limit, 400);
      expect(limit, findsOneWidget);
      expect(find.text(tj('bayoz_new')), findsNothing);
    });

    testWidgets('a full Баёз cannot be ticked from the reader', (tester) async {
      final app = await openApp(
        tester,
        route: '/literature/work/$_rudakiId',
        overrides: _worksOverrides,
      );
      final notifier = app.container.read(bayozProvider.notifier);
      final id = await notifier.create('Пур');
      for (var i = 0; i < BayozNotifier.maxItems; i++) {
        await notifier.toggle(id!, BayozItem(BayozItemKind.proverb, '$i'));
      }
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(tj('bayoz_add_to')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Пур'));
      await tester.pumpAndSettle();

      final bayoz = app.container.read(bayozProvider).single;
      expect(bayoz.items, hasLength(BayozNotifier.maxItems));
      expect(
        bayoz.contains(const BayozItem(BayozItemKind.work, _rudakiId)),
        isFalse,
      );
    });
  });

  testWidgets('Home labels a generated Persian title in Continue reading', (
    tester,
  ) async {
    final app = await openApp(
      tester,
      route: '/literature/work/$_rudakiId',
      overrides: _worksOverrides,
    );
    await app.container
        .read(readingScriptPreferenceProvider.notifier)
        .setScript(ReadingScript.persian);
    app.router.go('/');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    final label = AppTranslations.get(
      'lit_generated_script_label',
      DisplayLanguage.tajik,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is QalamIndexRow &&
            widget.title == 'بوی جوی مولیان' &&
            (widget.subtitle ?? '').contains(label),
      ),
      findsOneWidget,
    );
  });
}
