import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';

import '../../../helpers/test_helper.dart';

const _longBirthplacePoet = LiteraryAuthor(
  id: 'rudaki',
  canonicalName: 'Абӯабдуллоҳи Рӯдакӣ',
  canonicalNamePersian: 'ابوعبدالله رودکی',
  birthYear: '858',
  deathYear: '941',
  // A long, realistic birthplace that far exceeds one 320px line width.
  birthPlace:
      'Таваллуд ёфтааст дар деҳаи Панҷрӯд, наздикии шаҳри Панҷакент, '
      'дар вилояти Суғди Тоҷикистон',
  literaryPeriod: 'Асри IX-X',
  biographyTj: 'Сардафтари адабиёти классикии тоҷик.',
  biographySource: 'Адабиёти тоҷик, синфи 5, Маориф, Душанбе, 2017, с. 49',
  biographyTjProvenance: 'SOURCE_BACKED',
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Author died in 941 CE.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
);

void main() {
  group('PoetsListScreen birthplace readability', () {
    testWidgets('full birthplace wraps readably at 320px without truncation', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/literature/poets',
        width: 320,
        height: 1600,
        overrides: [
          literaryAuthorsProvider.overrideWith(
            (ref) async => const [_longBirthplacePoet],
          ),
          approvedWorksProvider.overrideWith((ref) async => const []),
        ],
      );

      expect(find.byType(PoetsListScreen), findsOneWidget);
      expect(find.byType(QalamPoetCard), findsOneWidget);

      // The whole birthplace string must be laid out, not clipped to "...".
      final placeFinder = find.text(_longBirthplacePoet.birthPlace!);
      expect(placeFinder, findsOneWidget);

      final placeRender = tester.renderObject<RenderParagraph>(placeFinder);
      expect(
        placeRender.didExceedMaxLines,
        isFalse,
        reason: 'birthplace must never be ellipsized',
      );

      // It wraps onto more than one line rather than staying a clipped row.
      final placeSize = tester.getSize(placeFinder);
      expect(
        placeSize.height,
        greaterThan(25),
        reason: 'birthplace should wrap onto several lines',
      );

      // No overflow/layout exception and the dates stay visible.
      expect(tester.takeException(), isNull);
      expect(find.textContaining('858 – 941'), findsOneWidget);
    });
  });
}
