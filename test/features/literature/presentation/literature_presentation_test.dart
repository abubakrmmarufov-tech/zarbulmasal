import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';
import 'package:zarbulmasal/router/app_router.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

// Test fixtures
const testAuthorRudaki = LiteraryAuthor(
  id: 'rudaki',
  canonicalName: 'Абӯабдуллоҳи Рӯдакӣ',
  canonicalNamePersian: 'ابوعبدالله رودکی',
  birthYear: '858',
  deathYear: '941',
  birthPlace: 'Панҷрӯд',
  literaryPeriod: 'Асри IX-X',
  biographyTj: 'Сардафтари адабиёти классикии тоҷик.',
  biographyFa: 'بنیان‌گذار ادبیات کلاسیک فارسی و تاجیکی.',
  biographySource: 'Адабиёти тоҷик, синфи 5, Маориф, Душанбе, 2017, с. 49',
  officialTitles: ['Одамушшуаро'],
  educationGrades: ['4', '5', '8', '10'],
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Author died in 941 CE, exceeding 50 years post mortem.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
);

const testWorkRudaki = LiteraryWork(
  id: 'rudaki-boyi-juyi-muliyon',
  authorId: 'rudaki',
  title: 'Бӯи ҷӯи Мӯлиён',
  titlePersian: 'بوی جوی مولیان',
  incipit: 'Бӯи ҷӯи Мӯлиён ояд ҳаме',
  type: WorkType.qasida,
  textTajik: 'Бӯи ҷӯи Мӯлиён ояд ҳаме,\nЁди ёри меҳрубон ояд ҳаме.',
  textPersian: 'بوی جوی مولیان آید همی\nیاد یار مهربان آید همی',
  textStatus: TextStatus.verified,
  primarySource: SourceEdition(
    bookTitle: 'Осори Рӯдакӣ',
    authorAsPrinted: 'Абӯабдуллоҳ Рӯдакӣ',
    editor: 'А. Мирзоев',
    publisher: 'Нашриёти давлатии Тоҷикистон',
    city: 'Сталинобод',
    year: '1958',
    pageStart: 45,
    pageEnd: 46,
    sourceType: SourceEditionType.criticalEdition,
    sourceImageVerified: true,
  ),
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Public domain author.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
  verification: VerificationRecord(
    evidenceLevel: VerificationLevel.editoriallyApproved,
    pageVerified: true,
  ),
);

const testCanonEntry = SchoolCanonEntry(
  id: 'canon-rudaki-g5',
  workId: 'rudaki-boyi-juyi-muliyon',
  authorId: 'rudaki',
  grade: '5',
  subject: 'Адабиёти тоҷик',
  textbookTitle: 'Адабиёти тоҷик (Синфи 5)',
  textbookAuthors: 'Т. Зиёев, Х. Шарифов',
  textbookPublisher: 'Маориф',
  textbookYear: '2018',
  curriculumType: 'mandatory',
  sourceEvidence: 'Барномаи таълимӣ барои синфи 5',
);

const testOralEntry = OralHeritageEntry(
  id: 'folk-maqol-001',
  text: 'Офтобро ба домон пӯшида намешавад.',
  type: OralHeritageType.maqol,
  region: 'Хатлон',
  collectionSource: 'Зарбулмасалҳои тоҷикӣ',
  collector: 'Б. Шермуҳаммадов',
  publisher: 'Дониш',
  year: '1980',
  page: '42',
  verification: VerificationRecord(
    evidenceLevel: VerificationLevel.editoriallyApproved,
  ),
  rights: RightsRecord(
    status: RightsStatus.folklore,
    reasoning: 'Traditional folklore cleared for publication.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
);

Future<void> pumpTestApp(
  WidgetTester tester, {
  String route = '/literature',
  List<LiteraryAuthor> authors = const [testAuthorRudaki],
  List<LiteraryWork> works = const [testWorkRudaki],
  List<SchoolCanonEntry> canon = const [testCanonEntry],
  List<OralHeritageEntry> oral = const [testOralEntry],
  DisplayLanguage language = DisplayLanguage.tajik,
}) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({
    AppConstants.prefsLanguage: language == DisplayLanguage.persian
        ? 'fa'
        : 'tj',
    AppConstants.prefsOnboardingComplete: true,
  });

  final container = ProviderContainer(
    overrides: [
      onboardingCompleteProvider.overrideWith(
        (ref) => OnboardingNotifier()..state = true,
      ),
      displayLanguageProvider.overrideWith(
        (ref) => DisplayLanguageNotifier()..state = language,
      ),
      literaryAuthorsProvider.overrideWith((ref) => Future.value(authors)),
      literaryWorksProvider.overrideWith((ref) => Future.value(works)),
      approvedWorksProvider.overrideWith(
        (ref) => Future.value(works.where((w) => w.isDisplayable).toList()),
      ),
      dailyVerseProvider.overrideWith(
        (ref) => Future.value(works.isNotEmpty ? works.first : null),
      ),
      schoolCanonProvider.overrideWith((ref) => Future.value(canon)),
      oralHeritageProvider.overrideWith((ref) => Future.value(oral)),
      authorByIdProvider.overrideWith(
        (ref, id) => Future.value(
          authors.cast<LiteraryAuthor?>().firstWhere(
            (a) => a?.id == id,
            orElse: () => null,
          ),
        ),
      ),
      worksByAuthorProvider.overrideWith(
        (ref, id) => Future.value(
          works.where((w) => w.authorId == id && w.isDisplayable).toList(),
        ),
      ),
      worksUnderReviewByAuthorProvider.overrideWith(
        (ref, id) => Future.value(
          works
              .where(
                (w) =>
                    w.authorId == id &&
                    w.verification.evidenceLevel ==
                        VerificationLevel.needsReview,
              )
              .toList(),
        ),
      ),
      schoolCanonByAuthorProvider.overrideWith(
        (ref, id) =>
            Future.value(canon.where((c) => c.authorId == id).toList()),
      ),
    ],
  );

  final router = GoRouter(
    initialLocation: route,
    errorBuilder: buildRouteErrorPage,
    routes: appRouter.configuration.routes,
  );

  addTearDown(container.dispose);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Literature Feature Presentation & Navigation', () {
    testWidgets(
      'Home screen includes QalamLiteratureCard that navigates to /literature',
      (tester) async {
        await pumpTestApp(tester, route: '/');

        expect(find.byType(QalamLiteratureCard), findsOneWidget);
        expect(find.text('Мероси адабӣ'), findsOneWidget);

        await tester.tap(find.byType(QalamLiteratureCard));
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

    testWidgets('Hub labels empty oral heritage as unavailable', (
      tester,
    ) async {
      await pumpTestApp(tester, route: '/literature', oral: const []);

      final disabledLinks = find.byWidgetPredicate(
        (widget) => widget is QalamSectionLink && widget.onTap == null,
      );
      expect(disabledLinks, findsOneWidget);
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
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
      'PoetDetailScreen exposes pending work titles and citations without text',
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

        expect(find.text('Осори тасдиқшуда дар барнома (0)'), findsOneWidget);
        expect(find.text('Сабтҳои асар дар санҷиш: 2'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Модар'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Модар'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Асари бе саҳифа'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.text('Рақами саҳифаи чопӣ ҳанӯз сабт нашудааст'),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Дар санҷиши сарчашма; матн ҳанӯз нашр нашудааст',
          ),
          findsNWidgets(2),
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
      'PoemReaderScreen renders poem title, author, text and QalamSourceBadge',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/work/rudaki-boyi-juyi-muliyon',
        );

        expect(find.byType(PoemReaderScreen), findsOneWidget);
        expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);
        expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
        expect(find.text('Матн санҷида шудааст'), findsOneWidget);
        expect(find.byType(QalamSourceBadge), findsOneWidget);
        expect(find.textContaining('Бӯи ҷӯи Мӯлиён ояд ҳаме'), findsWidgets);
      },
    );

    testWidgets(
      'PoemReaderScreen Source button opens SourcePanel bottom sheet',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/work/rudaki-boyi-juyi-muliyon',
        );

        final sourceButton = find.widgetWithText(OutlinedButton, 'Манбаъ');
        expect(sourceButton, findsOneWidget);

        await tester.tap(sourceButton);
        await tester.pumpAndSettle();

        expect(find.byType(SourcePanel), findsOneWidget);
        expect(find.text('Сарчашма ва санҷиш'), findsOneWidget);
        expect(find.text('Осори Рӯдакӣ'), findsOneWidget);
        expect(find.text('Тасдиқшуда'), findsOneWidget);
        expect(find.byTooltip('Бастан'), findsOneWidget);

        final panelScrollable = find.descendant(
          of: find.byType(SourcePanel),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.text('Моликияти умумӣ (Public Domain)'),
          300,
          scrollable: panelScrollable.first,
        );
        expect(find.text('Моликияти умумӣ (Public Domain)'), findsOneWidget);
      },
    );

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
  });

  group('Literature Feature Persian Language Parity', () {
    testWidgets('Home literature card uses Persian title and section label', (
      tester,
    ) async {
      await pumpTestApp(tester, route: '/', language: DisplayLanguage.persian);

      expect(find.text('میراث ادبی'), findsOneWidget);
      expect(find.text('۰۱ / ادبیات'), findsOneWidget);
      expect(find.text('Мероси адабӣ'), findsNothing);
    });

    testWidgets(
      'LiteratureHubScreen in Persian mode renders Persian title, formatted poet count, and search button',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature',
          language: DisplayLanguage.persian,
        );

        expect(find.byType(LiteratureHubScreen), findsOneWidget);
        expect(find.text('گنجینهٔ ادب تاجیک'), findsOneWidget);
        expect(find.text('میراث ادبی'), findsWidgets);
        expect(find.textContaining('۱ شاعر'), findsOneWidget);
        expect(find.byTooltip('جستجو'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      },
    );

    testWidgets(
      'PoetDetailScreen in Persian mode renders Persian canonical name, biography, and formatted lifespan',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/poet/rudaki',
          language: DisplayLanguage.persian,
        );

        expect(find.byType(PoetDetailScreen), findsOneWidget);
        expect(find.text('زندگینامه و آثار'), findsOneWidget);
        expect(find.text('ابوعبدالله رودکی'), findsWidgets);
        expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
        expect(find.text('۸۵۸ – ۹۴۱'), findsOneWidget);
        expect(
          find.text('بنیان‌گذار ادبیات کلاسیک فارسی و تاجیکی.'),
          findsOneWidget,
        );
        expect(find.text('مالکیت عمومی'), findsOneWidget);
      },
    );

    testWidgets(
      'PoetDetailScreen discloses Tajik biography fallback in Persian mode',
      (tester) async {
        final authorJson = testAuthorRudaki.toJson()..remove('biographyFa');
        final author = LiteraryAuthor.fromJson(authorJson);
        await pumpTestApp(
          tester,
          route: '/literature/poet/rudaki',
          language: DisplayLanguage.persian,
          authors: [author],
        );

        expect(
          find.text(
            'این زندگی‌نامه فعلاً به خط سیریلیک تاجیکی نمایش داده می‌شود.',
          ),
          findsOneWidget,
        );
        expect(find.text(author.biographyTj), findsOneWidget);
      },
    );

    testWidgets(
      'PoemReaderScreen in Persian mode renders Persian title, text, copy action, and Persian SourcePanel',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/work/rudaki-boyi-juyi-muliyon',
          language: DisplayLanguage.persian,
        );

        expect(find.byType(PoemReaderScreen), findsOneWidget);
        expect(find.text('خوانش شعر'), findsOneWidget);
        expect(find.text('بوی جوی مولیان'), findsOneWidget);
        expect(find.text('ابوعبدالله رودکی'), findsOneWidget);
        expect(find.text('متن تأیید شده است'), findsOneWidget);
        expect(find.textContaining('بوی جوی مولیان آید همی'), findsWidgets);
        expect(find.byIcon(Icons.copy_outlined), findsOneWidget);

        final sourceButton = find.widgetWithText(
          OutlinedButton,
          'منبع و اسناد',
        );
        expect(sourceButton, findsOneWidget);

        await tester.tap(sourceButton);
        await tester.pumpAndSettle();

        expect(find.byType(SourcePanel), findsOneWidget);
        expect(find.text('منبع و بررسی اصالت'), findsOneWidget);
        expect(find.text('Осори Рӯдакӣ'), findsOneWidget);
        expect(find.text('تأیید شده'), findsOneWidget);

        final panelScrollable = find.descendant(
          of: find.byType(SourcePanel),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.text('مالکیت عمومی (Public Domain)'),
          300,
          scrollable: panelScrollable.first,
        );
        expect(find.text('مالکیت عمومی (Public Domain)'), findsOneWidget);
      },
    );

    testWidgets('PoemReaderScreen reports clipboard failures', (tester) async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) {
        if (call.method == 'Clipboard.setData') {
          throw PlatformException(code: 'clipboard_unavailable');
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await pumpTestApp(
        tester,
        route: '/literature/work/rudaki-boyi-juyi-muliyon',
      );

      await tester.tap(find.byIcon(Icons.copy_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Нусхабардорӣ дастрас нест'), findsOneWidget);
    });

    testWidgets(
      'PoetDetailScreen renders exact dates, poem count badge, and composition metadata',
      (tester) async {
        const testAuthorWithDates = LiteraryAuthor(
          id: 'ayni',
          canonicalName: 'Садриддин Айнӣ',
          canonicalNamePersian: 'صدرالدین عینی',
          birthYear: '1878',
          deathYear: '1954',
          birthDateExact: '15.04.1878',
          deathDateExact: '15.07.1954',
          birthPlace: 'Соктаре, Бухоро',
          literaryPeriod: 'Асри XX',
          biographyTj: 'Сарвари адабиёти нави тоҷик.',
          biographySource: 'Сарчашмаи санҷиши тестӣ, с. 1',
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );

        const testWorkWithDates = LiteraryWork(
          id: 'ayni-marsh-hurriyat',
          authorId: 'ayni',
          title: 'Марши ҳуррият',
          compositionDate: '1918',
          compositionContext: 'Дар шаҳри Самарқанд',
          textTajik: 'Эй ситамдидагон, эй асирон,\nВақти озодии мо расид!',
          textStatus: TextStatus.verified,
          primarySource: SourceEdition(
            bookTitle: 'Куллиёт, ҷ. 1',
            publisher: 'Нашриёти давлатии Тоҷикистон',
            city: 'Душанбе',
            year: '1960',
            pageStart: 12,
            sourceType: SourceEditionType.criticalEdition,
          ),
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
            pageVerified: true,
          ),
        );

        await pumpTestApp(
          tester,
          route: '/literature/poet/ayni',
          authors: [testAuthorWithDates],
          works: [testWorkWithDates],
        );

        expect(find.textContaining('15.04.1878'), findsWidgets);
        expect(find.textContaining('15.07.1954'), findsWidgets);
        expect(
          find.textContaining('Санаҳо ва зодгоҳ то санҷиши саҳифаи сарчашма'),
          findsNothing,
        );
        expect(
          find.textContaining('Шеърҳои тасдиқшуда дар барнома: 1'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Осори тасдиқшуда дар барнома (1)'),
          findsOneWidget,
        );

        expect(find.textContaining('Дар шаҳри Самарқанд'), findsOneWidget);
      },
    );

    testWidgets(
      'PoemReaderScreen renders author exact lifespan and poem composition date & context',
      (tester) async {
        const testAuthorWithDates = LiteraryAuthor(
          id: 'ayni',
          canonicalName: 'Садриддин Айнӣ',
          canonicalNamePersian: 'صدرالدین عینی',
          birthYear: '1878',
          deathYear: '1954',
          birthDateExact: '15.04.1878',
          deathDateExact: '15.07.1954',
          birthPlace: 'Соктаре, Бухоро',
          literaryPeriod: 'Асри XX',
          biographyTj: 'Сарвари адабиёти нави тоҷик.',
          biographySource: 'Сарчашмаи санҷиши тестӣ, с. 1',
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );

        const testWorkWithDates = LiteraryWork(
          id: 'ayni-marsh-hurriyat',
          authorId: 'ayni',
          title: 'Марши ҳуррият',
          compositionDate: '1918',
          compositionContext: 'Дар шаҳри Самарқанд',
          textTajik: 'Эй ситамдидагон, эй асирон,\nВақти озодии мо расид!',
          textStatus: TextStatus.verified,
          primarySource: SourceEdition(
            bookTitle: 'Куллиёт, ҷ. 1',
            publisher: 'Нашриёти давлатии Тоҷикистон',
            city: 'Душанбе',
            year: '1960',
            pageStart: 12,
            sourceType: SourceEditionType.criticalEdition,
          ),
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
            pageVerified: true,
          ),
        );

        await pumpTestApp(
          tester,
          route: '/literature/work/ayni-marsh-hurriyat',
          authors: [testAuthorWithDates],
          works: [testWorkWithDates],
        );

        expect(find.textContaining('15.04.1878'), findsWidgets);
        expect(find.textContaining('15.07.1954'), findsWidgets);
        expect(find.textContaining('Санаи таълиф: 1918'), findsOneWidget);
        expect(
          find.textContaining('Муҳит: Дар шаҳри Самарқанд'),
          findsOneWidget,
        );
      },
    );

    testWidgets('PoetsListScreen renders exact dates and poem count badge', (
      tester,
    ) async {
      const testAuthorWithDates = LiteraryAuthor(
        id: 'ayni',
        canonicalName: 'Садриддин Айнӣ',
        canonicalNamePersian: 'صدرالدین عینی',
        birthYear: '1878',
        deathYear: '1954',
        birthDateExact: '15.04.1878',
        deathDateExact: '15.07.1954',
        birthPlace: 'Соктаре, Бухоро',
        literaryPeriod: 'Асри XX',
        biographyTj: 'Сарвари адабиёти нави тоҷик.',
        biographySource: 'Сарчашмаи санҷиши тестӣ, с. 1',
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
      );

      const testWorkWithDates = LiteraryWork(
        id: 'ayni-marsh-hurriyat',
        authorId: 'ayni',
        title: 'Марши ҳуррият',
        textTajik: 'Эй ситамдидагон, эй асирон,\nВақти озодии мо расид!',
        textStatus: TextStatus.verified,
        primarySource: SourceEdition(
          bookTitle: 'Куллиёт, ҷ. 1',
          publisher: 'Нашриёти давлатии Тоҷикистон',
          city: 'Душанбе',
          year: '1960',
          pageStart: 12,
          sourceType: SourceEditionType.criticalEdition,
        ),
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );

      await pumpTestApp(
        tester,
        route: '/literature/poets',
        authors: [testAuthorWithDates],
        works: [testWorkWithDates],
      );

      expect(find.textContaining('15.04.1878'), findsWidgets);
      expect(find.textContaining('1 асар'), findsOneWidget);
    });
  });
}
