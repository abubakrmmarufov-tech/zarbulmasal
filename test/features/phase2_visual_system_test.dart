// Behaviour added in Phase 2 (visual system): tokens, typography, seal,
// «Дар бора | Сабт» tabs, typographic lists.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../helpers/test_helper.dart';

const _rudakiId = 'rudaki_buyi_juyi_muliyon_grade5_2017_p54';

final List<LiteraryWork> _works = expandRuntimeWorks(
  jsonDecode(
    File('assets/data/literature/runtime_works.json').readAsStringSync(),
  ),
).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();

String tj(String key) => AppTranslations.get(key, DisplayLanguage.tajik);

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('tokens', () {
    for (final dark in [false, true]) {
      test('text roles meet 4.5:1 on the ${dark ? 'Шаб' : 'Муҳр'} ground', () {
        final scheme =
            (dark ? AppTheme.darkTheme : AppTheme.lightTheme).colorScheme;
        for (final (name, color) in [
          ('onSurface', scheme.onSurface),
          ('onSurfaceVariant', scheme.onSurfaceVariant),
          ('primary', scheme.primary),
        ]) {
          expect(
            _contrast(color, scheme.surface),
            greaterThanOrEqualTo(4.5),
            reason: name,
          );
        }
      });
    }

    test('night ground is lapis-black and the accent is vermilion', () {
      expect(AppTheme.darkTheme.colorScheme.surface, QalamColors.lapis);
      expect(AppTheme.lightTheme.colorScheme.primary, QalamColors.vermilion);
      expect(
        AppTheme.darkTheme.colorScheme.primary,
        QalamColors.vermilionNight,
      );
    });
  });

  test('type roles use the approved families', () {
    const ink = Colors.black;
    expect(QalamTypography.heroProverb(color: ink).fontFamily, 'EBGaramond');
    expect(QalamTypography.monographTitle(color: ink).fontFamily, 'EBGaramond');
    expect(QalamTypography.verseText(color: ink).fontFamily, 'PTSerif');
    expect(QalamTypography.body(color: ink).fontFamily, 'GolosText');
    expect(
      QalamTypography.nastaliqVerse(color: ink).fontFamily,
      'NotoNastaliqUrdu',
    );
    // Persian script in a Cyrillic face falls back to Persian faces.
    expect(
      QalamTypography.body(color: ink).fontFamilyFallback!.first,
      'Vazirmatn',
    );
  });

  group('reader source', () {
    testWidgets('a poem shows one source line, no seal and no record tab', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/literature/work/$_rudakiId',
        height: 1600,
        overrides: [
          approvedWorksProvider.overrideWith((ref) => Future.value(_works)),
          literaryWorksProvider.overrideWith((ref) => Future.value(_works)),
        ],
      );
      final work = _works.firstWhere((w) => w.id == _rudakiId);
      final source = work.primarySource!;
      // The book only: «Манбаъ: Адабиёти тоҷик, синфи 5 (2017)», no page.
      expect(
        find.text(
          AppTranslations.get('lit_source_line', DisplayLanguage.tajik, [
            'Адабиёти тоҷик, синфи 5 (2017)',
          ]),
        ),
        findsOneWidget,
      );
      expect(source.pageStart, isNotNull, reason: 'the page stays in the data');
      expect(find.textContaining('с. ${source.pageStart}'), findsNothing);
      expect(find.text(tj('record_tab_record')), findsNothing);
      expect(find.textContaining(tj('prov_check_pending')), findsNothing);
    });
  });

  testWidgets('Explore and Learn lists are typographic, not boxed cards', (
    tester,
  ) async {
    // Collections are folio tiles and list items are slips — never
    // Material cards.
    for (final route in ['/explore', '/learn']) {
      await openApp(tester, route: route);
      expect(find.byType(Card), findsNothing, reason: route);
      expect(find.byType(QalamFolioTile), findsWidgets, reason: route);
    }
  });
}
