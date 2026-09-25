import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import 'literature_presentation_helpers.dart';

void main() {
  group('Literature Feature Presentation & Navigation', () {
    testWidgets(
      'Home screen includes Literature shortcut that navigates to /literature',
      (tester) async {
        await pumpTestApp(tester, route: '/');

        expect(find.text('Адабиёт'), findsOneWidget);

        await tester.tap(find.text('Адабиёт'));
        await tester.pumpAndSettle();

        expect(find.byType(LiteratureHubScreen), findsOneWidget);
      },
    );

    testWidgets(
      'LiteratureHubScreen renders header, daily verse card and section links',
      (tester) async {
        await pumpTestApp(tester, route: '/literature');

        expect(find.byType(LiteratureHubScreen), findsOneWidget);
        expect(find.text('Мероси адабӣ'), findsWidgets);
        expect(find.text('БАЙТИ РӮЗ'), findsOneWidget);
        expect(find.text('«Бӯи ҷӯи Мӯлиён ояд ҳаме»'), findsOneWidget);

        expect(find.text('Шоирон'), findsOneWidget);
        expect(find.text('Шеърҳо'), findsOneWidget);
        expect(find.text('Барномаи мактабӣ'), findsOneWidget);
        expect(find.text('Мероси шифоҳӣ'), findsOneWidget);
        expect(find.text('Ҷустуҷӯ'), findsOneWidget);
      },
    );

    testWidgets(
      'LiteratureHubScreen reports page-cited works still under review',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature',
          works: [testReviewWork],
        );
        expect(
          find.text('Сабтҳои саҳифадори асар дар санҷиш: 1'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Daily Verse card text meets normal-text contrast', (
      tester,
    ) async {
      for (final dark in [false, true]) {
        await pumpTestApp(tester, route: '/literature', dark: dark);

        final background = dark ? QalamColors.inkCard : QalamColors.ink;
        for (final label in [
          'БАЙТИ РӮЗ',
          'Абӯабдуллоҳи Рӯдакӣ',
          'Мутолиаи асар',
        ]) {
          final text = tester.widget<Text>(find.text(label));
          expect(
            contrastRatio(text.style!.color!, background),
            greaterThanOrEqualTo(4.5),
            reason: '$label on $background',
          );
        }
      }
    });

    testWidgets('Hub hides empty oral heritage and shows no running numbers', (
      tester,
    ) async {
      await pumpTestApp(tester, route: '/literature', oral: const []);

      expect(find.text('Мероси шифоҳӣ'), findsNothing);
      final disabledLinks = find.byWidgetPredicate(
        (widget) => widget is QalamSectionLink && widget.onTap == null,
      );
      expect(disabledLinks, findsNothing);
      // The literature index carries no running numbers (they meant nothing).
      final links = tester.widgetList<QalamSectionLink>(
        find.byType(QalamSectionLink),
      );
      expect(links, isNotEmpty);
      expect(links.every((link) => link.number == null), isTrue);
    });

    testWidgets('Tapping Poets link in Hub navigates to PoetsListScreen', (
      tester,
    ) async {
      await pumpTestApp(tester, route: '/literature');

      await tester.tap(find.text('Шоирон'));
      await tester.pumpAndSettle();

      expect(find.byType(PoetsListScreen), findsOneWidget);
      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
      expect(find.byType(QalamPoetCard), findsOneWidget);
    });

    testWidgets('PoetsListScreen search filters authors by name', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        route: '/literature/poets',
        authors: [
          testAuthorRudaki,
          const LiteraryAuthor(
            id: 'ferdowsi',
            canonicalName: 'Абулқосим Фирдавсӣ',
            literaryPeriod: 'Асри X-XI',
            biographyTj: 'Муаллифи Шоҳнома.',
            biographySource: 'Ахтарони адаб',
            rights: RightsRecord(
              status: RightsStatus.publicDomain,
              reasoning: 'Public domain',
              fullTextAllowed: true,
              excerptAllowed: true,
            ),
          ),
        ],
      );

      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
      expect(find.text('Абулқосим Фирдавсӣ'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Фирдавсӣ');
      await tester.pumpAndSettle();

      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsNothing);
      expect(find.text('Абулқосим Фирдавсӣ'), findsOneWidget);
      expect(find.byTooltip('Пок кардани ҷустуҷӯ'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
    });

    testWidgets('PoetsListScreen hides unnamed import placeholders', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        route: '/literature/poets',
        authors: [
          testAuthorRudaki,
          testAuthorRudaki.copyWith(
            id: 'unresolved-author',
            canonicalName: 'Unknown',
          ),
        ],
      );

      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.byType(QalamPoetCard), findsOneWidget);
    });

    testWidgets('LiteratureSearchScreen hides unresolved import placeholders', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        route: '/literature/search',
        authors: [
          testAuthorRudaki,
          testAuthorRudaki.copyWith(
            id: 'unresolved-author',
            canonicalName: 'Unknown',
          ),
        ],
      );

      expect(find.text('Unknown'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Unknown');
      await tester.pumpAndSettle();

      expect(find.byType(QalamPoetCard), findsNothing);
      expect(find.text('Мундариҷа ёфт нашуд'), findsOneWidget);
    });

    testWidgets('LiteratureSearchScreen matches Persian keyboard variants', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        route: '/literature/search',
        language: DisplayLanguage.persian,
        authors: [testAuthorRudaki],
      );

      await tester.enterText(find.byType(TextField), 'رودكي');
      await tester.pumpAndSettle();

      expect(find.byType(QalamPoetCard), findsOneWidget);
    });

    testWidgets('Tapping a poet card navigates to PoetDetailScreen', (
      tester,
    ) async {
      await pumpTestApp(tester, route: '/literature/poets');

      await tester.tap(find.byType(QalamPoetCard));
      await tester.pumpAndSettle();

      expect(find.byType(PoetDetailScreen), findsOneWidget);
      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsWidgets);
      expect(find.text('Сардафтари адабиёти классикии тоҷик.'), findsOneWidget);
      expect(find.text('Сарчашмаи истинод:'), findsOneWidget);
      expect(
        find.text('Адабиёти тоҷик, синфи 5, Маориф, Душанбе, 2017, с. 49'),
        findsOneWidget,
      );
      expect(find.text('Одамушшуаро'), findsOneWidget);
    });

    testWidgets('PoetDetailScreen withholds unpage-cited biography facts', (
      tester,
    ) async {
      final uncited = testAuthorRudaki.copyWith(
        biographySource: 'Маҷмӯаи мактабӣ',
        biographyTj: 'Маълумоти воридотии санҷиданашуда.',
      );
      await pumpTestApp(
        tester,
        route: '/literature/poet/rudaki',
        authors: [uncited],
      );

      expect(find.text('858 – 941'), findsNothing);
      expect(
        find.text(
          'Санаҳо ва зодгоҳ то санҷиши саҳифаи сарчашма дар интизоранд.',
        ),
        findsOneWidget,
      );
      expect(find.text('Маълумоти воридотии санҷиданашуда.'), findsNothing);
      expect(
        find.text('Сарчашмаи саҳифадори санҷидашуда сабт нашудааст:'),
        findsOneWidget,
      );
    });

    testWidgets('PoetDetailScreen renders works by author', (tester) async {
      await pumpTestApp(tester, route: '/literature/poet/rudaki');

      expect(find.byType(PoetDetailScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Бӯи ҷӯи Мӯлиён'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);
    });

    testWidgets(
      'PoetDetailScreen collapses pending work list and reveals titles with citations on expand',
      (tester) async {
        final pendingWork = testWorkRudaki.copyWith(
          id: 'rudaki-pending-textbook-work',
          title: 'Модар',
          textStatus: TextStatus.needsReview,
          textTajik: 'Ин матн то санҷиш дастрас нест.',
          rights: const RightsRecord(
            status: RightsStatus.excerptOnly,
            reasoning: 'Pending rights review',
            fullTextAllowed: false,
            excerptAllowed: true,
          ),
          primarySource: testWorkRudaki.primarySource!.copyWith(
            pageStart: 216,
            pageEnd: 216,
            sourceReference: 'docs/literature/pdfs/review.pdf',
          ),
          verification: const VerificationRecord(
            evidenceLevel: VerificationLevel.needsReview,
          ),
        );
        final pendingNoPageWork = pendingWork.copyWith(
          id: 'rudaki-pending-no-page',
          title: 'Асари бе саҳифа',
          primarySource: const SourceEdition(
            bookTitle: 'Адабиёти тоҷик',
            publisher: 'Маориф',
            city: 'Душанбе',
            year: '2018',
            sourceType: SourceEditionType.officialTextbook,
          ),
        );

        await pumpTestApp(
          tester,
          route: '/literature/poet/rudaki',
          works: [pendingWork, pendingNoPageWork],
        );

        expect(find.text('Осор барои хондан (0)'), findsOneWidget);
        expect(find.text('Сабтҳои асар дар санҷиш: 2'), findsOneWidget);
        expect(
          find.text(
            '1 сабти дигар то пайдо шудани истиноди саҳифадор дар рӯйхат нишон дода намешавад.',
          ),
          findsOneWidget,
        );

        // The under-review list is collapsed by default; pending titles are
        // withheld until the count-labeled header is expanded.
        expect(find.text('Модар'), findsNothing);
        expect(find.text('Асари бе саҳифа'), findsNothing);

        await tester.scrollUntilVisible(
          find.text('Сабтҳои асар дар санҷиш: 2'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Сабтҳои асар дар санҷиш: 2'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Модар'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Модар'), findsOneWidget);
        expect(find.text('Асари бе саҳифа'), findsNothing);
        expect(
          find.textContaining(
            'Дар санҷиши сарчашма; матн ҳанӯз нашр нашудааст',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('с. 216'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Модар'),
          -300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Модар'));
        await tester.pumpAndSettle();
        expect(find.byType(PoemReaderScreen), findsOneWidget);
        expect(find.text('Асар дар санҷиш аст'), findsOneWidget);
        expect(find.text('Ин матн то санҷиш дастрас нест.'), findsNothing);
      },
    );

    testWidgets(
      'WorksListScreen renders list of approved works and navigates to reader',
      (tester) async {
        await pumpTestApp(tester, route: '/literature/works');

        expect(find.byType(WorksListScreen), findsOneWidget);
        expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);

        await tester.tap(find.text('Бӯи ҷӯи Мӯлиён'));
        await tester.pumpAndSettle();

        expect(find.byType(PoemReaderScreen), findsOneWidget);
      },
    );

    testWidgets(
      'PoemReaderScreen renders poem title, author, text and provenance status',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/work/rudaki-boyi-juyi-muliyon',
        );

        expect(find.byType(PoemReaderScreen), findsOneWidget);
        expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);
        expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
        // No status sentence or seal: the source is one line under the poem.
        expect(
          find.text('Матн аз ҷониби муҳаррир тасдиқ шудааст.'),
          findsNothing,
        );
        expect(find.textContaining('Манбаъ: Осори Рӯдакӣ'), findsOneWidget);
        expect(find.textContaining('Бӯи ҷӯи Мӯлиён ояд ҳаме'), findsWidgets);
      },
    );

    testWidgets(
      'PoemReaderScreen names its source in one line: book and pages',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/work/rudaki-boyi-juyi-muliyon',
        );

        expect(find.textContaining('Манбаъ: Осори Рӯдакӣ'), findsOneWidget);
        expect(find.textContaining('с. 45–46'), findsOneWidget);
        // No record button, record tab, or secondary witness detail.
        expect(find.widgetWithText(OutlinedButton, 'Манбаъ'), findsNothing);
        expect(find.text('Сабт'), findsNothing);
        expect(find.text('Сарчашмаи дуввум'), findsNothing);
        // No raw labels, legacy badges, or page-image teaser.
        expect(find.text('Тасдиқшуда'), findsNothing);
        expect(find.text('Моликияти умумӣ (Public Domain)'), findsNothing);
        expect(find.text('Тасвири аслии саҳифаи китоб'), findsNothing);
      },
    );

    testWidgets('A second witness stays in the data, not on the page', (
      tester,
    ) async {
      final secondary = testWorkRudaki.primarySource!.copyWith(
        bookTitle: 'Гулшани адаб',
        publisher: 'Маориф',
        city: 'Душанбе',
        year: '2019',
        pageStart: 88,
        pageEnd: 89,
      );
      final work = testWorkRudaki.copyWith(secondarySource: secondary);

      await pumpTestApp(
        tester,
        route: '/literature/work/${work.id}',
        works: [work],
      );

      expect(find.textContaining('Манбаъ: Осори Рӯдакӣ'), findsOneWidget);
      expect(find.textContaining('Гулшани адаб'), findsNothing);
    });

    testWidgets(
      'PoemReaderScreen rejects a direct link to an unapproved work',
      (tester) async {
        final blockedWork = testWorkRudaki.copyWith(
          verification: const VerificationRecord(
            evidenceLevel: VerificationLevel.rejected,
          ),
        );
        await pumpTestApp(
          tester,
          route: '/literature/work/${blockedWork.id}',
          works: [blockedWork],
        );

        expect(find.text('Асар ёфт нашуд'), findsOneWidget);
        expect(find.textContaining('Бӯи ҷӯи Мӯлиён ояд ҳаме'), findsNothing);
      },
    );

    testWidgets(
      'PoemReaderScreen distinguishes a known pending textbook work',
      (tester) async {
        final pendingWork = testWorkRudaki.copyWith(
          textStatus: TextStatus.needsReview,
          verification: const VerificationRecord(
            evidenceLevel: VerificationLevel.needsReview,
          ),
        );
        await pumpTestApp(
          tester,
          route: '/literature/work/${pendingWork.id}',
          works: [pendingWork],
        );

        expect(find.text('Асар дар санҷиш аст'), findsOneWidget);
        expect(find.text('Бозгашт'), findsWidgets);
        expect(find.textContaining('Бӯи ҷӯи Мӯлиён ояд ҳаме'), findsNothing);
      },
    );

    testWidgets(
      'A pending work names its source in one line, with no image or review UI',
      (tester) async {
        final pendingWork = testWorkRudaki.copyWith(
          textStatus: TextStatus.needsReview,
          verification: const VerificationRecord(
            evidenceLevel: VerificationLevel.needsReview,
          ),
        );
        await pumpTestApp(
          tester,
          route: '/literature/work/${pendingWork.id}',
          works: [pendingWork],
        );

        expect(find.textContaining('Манбаъ: Осори Рӯдакӣ'), findsOneWidget);
        expect(find.text('Тасвири аслии саҳифаи китоб'), findsNothing);
        expect(find.text('Тасвири саҳифа маҳфуз аст'), findsNothing);
        expect(find.text('Дар баррасӣ'), findsNothing);
        expect(find.text('Моликияти умумӣ (Public Domain)'), findsNothing);
      },
    );

    testWidgets(
      'Approved poem without a source image has no image affordance',
      (tester) async {
        final noImageWork = testWorkRudaki.copyWith(
          primarySource: testWorkRudaki.primarySource!.copyWith(
            sourceImageVerified: false,
          ),
        );
        await pumpTestApp(
          tester,
          route: '/literature/work/${noImageWork.id}',
          works: [noImageWork],
        );

        expect(find.text('Тасвири саҳифа'), findsNothing);
        // Citation remains; no page-image affordance is offered.
        expect(find.textContaining('Осори Рӯдакӣ'), findsOneWidget);
        expect(find.text('Тасвири аслии саҳифаи китоб'), findsNothing);
        expect(find.text('Тасвири саҳифа маҳфуз аст'), findsNothing);
      },
    );

    testWidgets(
      'Verified image flag without a local image path has no image affordance',
      (tester) async {
        final noPathWork = testWorkRudaki.copyWith(
          primarySource: testWorkRudaki.primarySource!.copyWith(
            sourceImagePaths: const [],
          ),
        );
        await pumpTestApp(
          tester,
          route: '/literature/work/${noPathWork.id}',
          works: [noPathWork],
        );

        expect(find.textContaining('Осори Рӯдакӣ'), findsOneWidget);
        expect(find.text('Тасвири аслии саҳифаи китоб'), findsNothing);
        expect(find.text('Тасвири саҳифа маҳфуз аст'), findsNothing);
      },
    );

    testWidgets(
      'Pending reader does not advertise a page image before publication clearance',
      (tester) async {
        final pendingWork = testWorkRudaki.copyWith(
          textStatus: TextStatus.needsReview,
          verification: const VerificationRecord(
            evidenceLevel: VerificationLevel.needsReview,
          ),
        );
        await pumpTestApp(
          tester,
          route: '/literature/work/${pendingWork.id}',
          works: [pendingWork],
        );

        expect(find.text('Тасвири саҳифа'), findsNothing);
        expect(find.textContaining('Манбаъ: Осори Рӯдакӣ'), findsOneWidget);
      },
    );

    testWidgets('PoemReaderScreen keeps the pending state clear in Persian', (
      tester,
    ) async {
      final pendingWork = testWorkRudaki.copyWith(
        textStatus: TextStatus.needsReview,
        verification: const VerificationRecord(
          evidenceLevel: VerificationLevel.needsReview,
        ),
      );
      await pumpTestApp(
        tester,
        route: '/literature/work/${pendingWork.id}',
        works: [pendingWork],
        language: DisplayLanguage.persian,
      );

      expect(find.text('اثر در دست بررسی است'), findsOneWidget);
      expect(find.textContaining('بوی جوی مولیان'), findsNothing);
    });

    testWidgets('SchoolCanonScreen displays entries grouped by grade', (
      tester,
    ) async {
      await pumpTestApp(tester, route: '/literature/school');

      expect(find.byType(SchoolCanonScreen), findsOneWidget);

      expect(find.text('СИНФИ 5'), findsOneWidget);
      expect(
        find.text('Адабиёти тоҷик (Синфи 5) (2018) — Маориф'),
        findsOneWidget,
      );
      expect(find.text('Истинод дар санҷиш'), findsOneWidget);
      expect(find.text('Барномаи таълимӣ барои синфи 5'), findsOneWidget);
    });

    testWidgets(
      'OralHeritageScreen displays entries with genre tags and citation',
      (tester) async {
        await pumpTestApp(tester, route: '/literature/oral');

        expect(find.byType(OralHeritageScreen), findsOneWidget);

        expect(find.text('Офтобро ба домон пӯшида намешавад.'), findsOneWidget);
        expect(
          find.textContaining('Б. Шермуҳаммадов. Зарбулмасалҳои тоҷикӣ'),
          findsOneWidget,
        );
        final chips = find.byType(FilterChip);
        for (var index = 0; index < chips.evaluate().length; index++) {
          expect(
            tester.getSize(chips.at(index)).height,
            greaterThanOrEqualTo(48),
            reason: 'Oral heritage filters must retain a 48dp touch target.',
          );
        }
      },
    );

    testWidgets('LiteratureSearchScreen searches across authors and works', (
      tester,
    ) async {
      await pumpTestApp(tester, route: '/literature/search');

      expect(find.byType(LiteratureSearchScreen), findsOneWidget);
      expect(find.text('Пешниҳодҳои ҷустуҷӯ:'), findsOneWidget);
      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
      expect(find.text('Саъдӣ'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Мӯлиён');
      await tester.pumpAndSettle();

      expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);
      expect(find.byTooltip('Пок кардани ҷустуҷӯ'), findsOneWidget);
    });

    testWidgets(
      'LiteratureSearchScreen keeps readable works primary and hides pending behind review header',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/search',
          works: [testWorkRudaki, testReviewWork],
        );

        // A readable match stays in the primary works section, unchanged.
        await tester.enterText(find.byType(TextField), 'Мӯлиён');
        await tester.pumpAndSettle();
        expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);
        expect(find.text('Сабти санҷишии Рӯдакӣ'), findsNothing);
        expect(find.text('Сабтҳои асар дар санҷиш: 1'), findsNothing);

        // A review-only match must not look like a dead end: a compact
        // readable-empty note plus the collapsed count-labeled review header.
        await tester.enterText(find.byType(TextField), 'Сабти');
        await tester.pumpAndSettle();
        expect(find.text('Мундариҷа ёфт нашуд'), findsNothing);
        expect(
          find.textContaining('шеъри хондашаванда ёфт нашуд'),
          findsOneWidget,
        );
        expect(find.text('Сабтҳои асар дар санҷиш: 1'), findsOneWidget);
        expect(find.text('Сабти санҷишии Рӯдакӣ'), findsNothing);
      },
    );

    testWidgets(
      'LiteratureSearchScreen expanding the review header reveals pending rows and routes to pending reader',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/search',
          works: [testWorkRudaki, testReviewWork],
        );

        await tester.enterText(find.byType(TextField), 'Сабти');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Сабтҳои асар дар санҷиш: 1'));
        await tester.pumpAndSettle();

        expect(find.text('Сабти санҷишии Рӯдакӣ'), findsOneWidget);
        expect(
          find.textContaining(
            'Дар санҷиши сарчашма; матн ҳанӯз нашр нашудааст',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('Адабиёти тоҷик — с. 12'), findsOneWidget);

        await tester.tap(find.text('Сабти санҷишии Рӯдакӣ'));
        await tester.pumpAndSettle();
        expect(find.byType(PoemReaderScreen), findsOneWidget);
        expect(find.text('Асар дар санҷиш аст'), findsOneWidget);
      },
    );

    testWidgets(
      'LiteratureSearchScreen review header localizes count in Persian',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/search',
          works: [testReviewWork],
          language: DisplayLanguage.persian,
        );

        await tester.enterText(find.byType(TextField), 'Сабти');
        await tester.pumpAndSettle();

        expect(find.text('محتوا یافت نشد'), findsNothing);
        expect(find.text('رکوردهای آثار در بررسی: ۱'), findsOneWidget);
        expect(find.text('Сабти санҷишии Рӯдакӣ'), findsNothing);
      },
    );
  });
}
