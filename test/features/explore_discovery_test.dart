import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/features/explore/widgets/browse_strips.dart';
import 'package:zarbulmasal/features/explore/widgets/discover_today.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../helpers/test_helper.dart';

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

String tj(String key) => AppTranslations.get(key, DisplayLanguage.tajik);

void main() {
  testWidgets('Explore opens with a poem, a proverb and a word for today', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/explore',
      height: 2400,
      overrides: [
        approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
      ],
    );
    expect(find.byType(DiscoverToday), findsOneWidget);
    expect(
      find.text(tj('explore_discover_poem').toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(tj('explore_discover_proverb').toUpperCase()),
      findsOneWidget,
    );
    expect(find.byType(PoetEraStrip), findsOneWidget);
    expect(find.byType(HistoryTimelineStrip), findsOneWidget);
  });

  testWidgets('"again" draws a different proverb', (tester) async {
    await openApp(tester, route: '/explore', height: 2400);
    final proverbSlip = find.ancestor(
      of: find.text(tj('explore_discover_proverb').toUpperCase()),
      matching: find.byType(Column),
    );
    String texts() => tester
        .widgetList<Text>(
          find.descendant(of: proverbSlip.first, matching: find.byType(Text)),
        )
        .map((t) => t.data)
        .join('|');
    final before = texts();
    await tester.tap(find.byTooltip(tj('explore_discover_again')));
    await tester.pumpAndSettle();
    expect(texts(), isNot(before));
  });

  testWidgets('the poets list opens filtered by era', (tester) async {
    LiteraryAuthor poet(String id, String name, String born) =>
        LiteraryAuthor.fromJson({
          'id': id,
          'canonicalName': name,
          'birthYear': born,
          'literaryPeriod': '',
        });
    await openApp(
      tester,
      route: '/literature/poets?era=modern',
      height: 1600,
      overrides: [
        literaryAuthorsProvider.overrideWith(
          (ref) async => [
            poet('rudaki', 'Абӯабдуллоҳи Рӯдакӣ', '858'),
            poet('loiq', 'Лоиқ Шералӣ', '1941'),
          ],
        ),
        approvedWorksProvider.overrideWith((ref) async => const []),
      ],
    );
    final selected = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .where((c) => c.selected)
        .map((c) => (c.label as Text).data)
        .toList();
    expect(selected, [tj('lit_era_modern')]);
    expect(find.textContaining('Лоиқ'), findsWidgets);
    expect(find.textContaining('Рӯдакӣ'), findsNothing);

    await tester.tap(find.text(tj('lit_era_all')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Рӯдакӣ'), findsWidgets);
  });
}
