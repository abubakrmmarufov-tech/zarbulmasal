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
import 'package:zarbulmasal/features/literature/presentation/literary_work_display_text.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
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

  testWidgets('the daily picks follow the shared Tajikistan day', (
    tester,
  ) async {
    Future<String> poemAt(DateTime now) async {
      await openApp(
        tester,
        route: '/explore',
        height: 2400,
        overrides: [
          nowProvider.overrideWithValue(() => now),
          approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
        ],
      );
      final slip = find.ancestor(
        of: find.text(tj('explore_discover_poem').toUpperCase()),
        matching: find.byType(Column),
      );
      return tester
          .widgetList<Text>(
            find.descendant(of: slip.first, matching: find.byType(Text)),
          )
          .map((t) => t.data)
          .join('|');
    }

    // 20:00 UTC on the 24th is already the 25th in Dushanbe (UTC+5).
    final evening = await poemAt(DateTime.utc(2026, 9, 24, 20));
    final morning = await poemAt(DateTime.utc(2026, 9, 25, 6));
    final nextDay = await poemAt(DateTime.utc(2026, 9, 26, 6));
    expect(morning, evening);
    expect(nextDay, isNot(morning));
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

  testWidgets('Explore offers poems by form, each with its count', (
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
    expect(find.byType(FormStrip), findsOneWidget);
    expect(find.text(tj('explore_forms_title').toUpperCase()), findsOneWidget);
    final ghazals = _works.where((w) => w.type == WorkType.ghazal).length;
    expect(ghazals, greaterThan(0));
    expect(find.text(tj('lit_genre_ghazal')), findsOneWidget);
    expect(
      find.text(
        AppTranslations.get('explore_poems_count', DisplayLanguage.tajik, [
          AppTranslations.formatNumber(ghazals, DisplayLanguage.tajik),
        ]),
      ),
      findsWidgets,
    );
  });

  testWidgets('the poem list opens filtered by form and can show all', (
    tester,
  ) async {
    LiteraryWork work(String id, String title, String type) =>
        LiteraryWork.fromJson({
          ..._works.first.toJson(),
          'id': id,
          'title': title,
          'incipit': title,
          'type': type,
        });
    await openApp(
      tester,
      route: '/literature/works?form=rubai',
      height: 1600,
      overrides: [
        approvedWorksProvider.overrideWith(
          (ref) async => [
            work('a', 'Рубоии нахуст', 'rubai'),
            work('b', 'Ғазали дуюм', 'ghazal'),
          ],
        ),
      ],
    );
    final selected = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .where((c) => c.selected)
        .map((c) => (c.label as Text).data)
        .toList();
    expect(selected, ['${tj('lit_genre_rubai')} · 1']);
    expect(find.text('Рубоии нахуст'), findsOneWidget);
    expect(find.text('Ғазали дуюм'), findsNothing);

    await tester.tap(find.text(tj('lit_form_all')));
    await tester.pumpAndSettle();
    expect(find.text('Ғазали дуюм'), findsOneWidget);
  });

  test('a masnavi is named «Маснавӣ», a qit\'a «Қитъа»', () {
    expect(
      LiteraryWorkDisplayText.form(WorkType.epic, DisplayLanguage.tajik),
      'Маснавӣ',
    );
    expect(
      LiteraryWorkDisplayText.form(WorkType.fragment, DisplayLanguage.tajik),
      'Қитъа',
    );
  });

  testWidgets('the word of the day opens that word in the Lexicon', (
    tester,
  ) async {
    const words = [
      WordEntry(
        term: 'Тилисм',
        definition: 'ҷоду.',
        sourceBook: 'adabiet sinfi 5.pdf',
        pdfPage: 17,
      ),
      WordEntry(
        term: 'Ҳарир',
        definition: 'матои абрешимӣ.',
        sourceBook: 'adabiet sinfi 5.pdf',
        pdfPage: 18,
      ),
    ];
    final app = await openApp(
      tester,
      route: '/explore',
      height: 2400,
      overrides: [
        approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
        wordsProvider.overrideWith((ref) async => words),
      ],
    );
    final shown = words.firstWhere(
      (w) => find.text(w.term).evaluate().isNotEmpty,
    );
    final other = words.firstWhere((w) => w != shown);
    await tester.tap(find.text(shown.term));
    await tester.pumpAndSettle();
    expect(app.router.state.uri.path, '/vocabulary');
    expect(app.router.state.uri.queryParameters['word'], shown.term);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      shown.term,
    );
    expect(find.text(other.definition), findsNothing);
  });
}
