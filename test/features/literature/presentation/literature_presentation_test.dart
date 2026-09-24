import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/design_system/design_system.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/router/app_router.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

double _contrastRatio(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return (math.max(first, second) + .05) / (math.min(first, second) + .05);
}

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
  biographyTjProvenance: 'SOURCE_BACKED',
  biographyFaProvenance: 'EDITORIAL_TRANSLATION',
  officialTitles: ['Одамушшуаро'],
  educationGrades: ['4', '5', '8', '10'],
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Author died in 941 CE, exceeding 50 years post mortem.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
);

const testUntranslatedHistoryEntry = HistoryEntry(
  id: 'history-no-persian-title',
  kind: HistoryEntryKind.dynasty,
  title: 'Сомониён',
  summary: 'Шоҳигарии санҷишӣ',
  period: 'Асри X',
  grade: '5',
  sourceBookId: 'test-book',
  sourceSection: 'test-section',
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
    sourceImagePaths: [
      'assets/data/literature/page_images/rudaki_gar_bar_sari_nafsi_grade6_2014_p12.png',
    ],
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

const testTajikOnlyWork = LiteraryWork(
  id: 'tajik-only-work',
  authorId: 'rudaki',
  title: 'Унвони тоҷикӣ',
  incipit: 'Мисраи тоҷикӣ',
  type: WorkType.poem,
  textTajik: 'Матни тоҷикӣ набояд худкор нишон дода шавад.',
  textStatus: TextStatus.verified,
  primarySource: SourceEdition(
    bookTitle: 'Китоби манбаъ',
    authorAsPrinted: 'Муаллиф',
    publisher: 'Нашриёт',
    city: 'Душанбе',
    year: '2020',
    pageStart: 10,
    pageEnd: 10,
    sourceType: SourceEditionType.criticalEdition,
  ),
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Test fixture.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
  verification: VerificationRecord(
    evidenceLevel: VerificationLevel.editoriallyApproved,
    pageVerified: true,
  ),
);

const testReviewWork = LiteraryWork(
  id: 'rudaki-review-record',
  authorId: 'rudaki',
  title: 'Сабти санҷишии Рӯдакӣ',
  type: WorkType.poem,
  primarySource: SourceEdition(
    bookTitle: 'Адабиёти тоҷик',
    authorAsPrinted: 'Маориф',
    publisher: 'Маориф',
    city: 'Душанбе',
    year: '2026',
    pageStart: 12,
    pageEnd: 12,
    sourceType: SourceEditionType.officialTextbook,
    sourceReference: 'docs/literature/pdfs/adabiyet sinfi 9.pdf',
    sourceImageVerified: true,
    sourceImagePaths: [
      'assets/data/literature/page_images/saadi_bani_adam_grade9_2026_p39.png',
    ],
  ),
  rights: RightsRecord(
    status: RightsStatus.unknown,
    reasoning: 'Review fixture has no publication clearance.',
    fullTextAllowed: false,
    excerptAllowed: false,
  ),
  verification: VerificationRecord(
    evidenceLevel: VerificationLevel.primaryChecked,
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
  List<HistoryEntry> historyEntries = const [],
  DisplayLanguage language = DisplayLanguage.tajik,
  bool dark = false,
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
      historyEntriesProvider.overrideWith(
        (ref) => Future.value(historyEntries),
      ),
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
      searchableLiteraryWorksProvider.overrideWith(
        (ref) => Future.value(works),
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

  await container.read(searchableLiteraryWorksProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

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
            _contrastRatio(text.style!.color!, background),
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

  group('Literature Feature Persian Language Parity', () {
    testWidgets('Home literature shortcut uses Persian title', (tester) async {
      await pumpTestApp(tester, route: '/', language: DisplayLanguage.persian);

      expect(find.text('ادبیات'), findsOneWidget);
      expect(find.text('Адабиёт'), findsNothing);
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
      'Literature Hub shows Persian section titles without running numbers',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature',
          language: DisplayLanguage.persian,
        );

        // The index has no running numbers in either script (they carried no
        // meaning); the section titles are Persian.
        for (final number in ['۰۰', '۰۱', '۰۶', '00', '01', '06']) {
          expect(find.text(number), findsNothing);
        }
        expect(
          find.text(AppTranslations.get('lit_poets', DisplayLanguage.persian)),
          findsOneWidget,
        );
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
        expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsNothing);
        expect(find.text('ولادت: ۸۵۸ · وفات: ۹۴۱'), findsOneWidget);
        expect(
          find.text('بنیان‌گذار ادبیات کلاسیک فارسی و تاجیکی.'),
          findsOneWidget,
        );
        expect(find.text('مالکیت عمومی'), findsOneWidget);
        expect(find.text('Асри IX-X'), findsNothing);
        expect(find.text('Панҷрӯд'), findsNothing);
        expect(find.text('Одамушшуаро'), findsNothing);
      },
    );

    testWidgets(
      'compact poet detail keeps long names readable and the full literary period available',
      (tester) async {
        final authorJson = testAuthorRudaki.toJson()
          ..['canonicalName'] = 'Камоли Хуҷандӣ'
          ..['literaryPeriod'] =
              'Асри XIV ва ибтидои асри XV | Давлати Ҷалоириён, Урдаи Тиллоӣ ва лашкаркашиҳои Амир Темур';
        final author = LiteraryAuthor.fromJson(authorJson);
        await pumpTestApp(
          tester,
          route: '/literature/poet/rudaki',
          authors: [author],
        );

        tester.view.physicalSize = const Size(320, 900);
        await tester.pumpAndSettle();

        final name = tester.widget<Text>(find.text(author.canonicalName));
        expect(name.style?.fontSize, lessThanOrEqualTo(28));
        expect(find.text('Давра ва заминаи адабӣ'), findsOneWidget);
        expect(find.text(author.literaryPeriod), findsOneWidget);
      },
    );

    testWidgets(
      'Persian poet detail keeps unavailable-name fallback RTL and source name LTR',
      (tester) async {
        final author = LiteraryAuthor.fromJson(
          testAuthorRudaki.toJson()..remove('canonicalNamePersian'),
        );
        await pumpTestApp(
          tester,
          route: '/literature/poet/rudaki',
          language: DisplayLanguage.persian,
          authors: [author],
        );

        final pendingName = tester.widget<Text>(
          find.text('نام فارسی ثبت نشده است').first,
        );
        expect(pendingName.textDirection, TextDirection.rtl);
        expect(find.text(author.canonicalName), findsNothing);
      },
    );

    testWidgets(
      'Persian poet detail omits untranslated history titles instead of leaking Tajik',
      (tester) async {
        final authorJson = testAuthorRudaki.toJson()
          ..['relatedHistoryEntryIds'] = ['history-no-persian-title'];
        final author = LiteraryAuthor.fromJson(authorJson);
        await pumpTestApp(
          tester,
          route: '/literature/poet/rudaki',
          language: DisplayLanguage.persian,
          authors: [author],
          historyEntries: [testUntranslatedHistoryEntry],
        );

        expect(find.text('جهان او را بشناسید'), findsOneWidget);
        expect(find.text('Сомониён'), findsNothing);
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
            'ترجمهٔ فارسی این زندگی‌نامه هنوز بررسی نشده است؛ متن تاجیکی نمایش داده نمی‌شود.',
          ),
          findsOneWidget,
        );
        expect(find.text(author.biographyTj), findsNothing);
      },
    );

    testWidgets(
      'PoetDetailScreen review header collapses pending list in Persian',
      (tester) async {
        final pendingWork = testWorkRudaki.copyWith(
          id: 'rudaki-pending-textbook-work',
          title: 'Модар',
          titlePersian: 'مادر',
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

        await pumpTestApp(
          tester,
          route: '/literature/poet/rudaki',
          works: [pendingWork],
          language: DisplayLanguage.persian,
        );

        expect(find.text('رکوردهای آثار در بررسی: ۱'), findsOneWidget);
        expect(find.text('مادر'), findsNothing);
        expect(find.text('Модар'), findsNothing);

        await tester.scrollUntilVisible(
          find.text('رکوردهای آثار در بررسی: ۱'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('رکوردهای آثار در بررسی: ۱'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('مادر'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('مادر'), findsOneWidget);
        expect(find.text('Модар'), findsNothing);
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
        expect(find.text('متن از سوی ویراستار تأیید شده است.'), findsNothing);
        expect(find.textContaining('بوی جوی مولیان آید همی'), findsWidgets);
        expect(find.byIcon(Icons.copy_outlined), findsOneWidget);

        // The source is one line: «منبع: book, pages».
        expect(find.textContaining('منبع: Осори Рӯдакӣ'), findsOneWidget);
        expect(
          find.widgetWithText(OutlinedButton, 'منبع و اسناد'),
          findsNothing,
        );
        expect(find.text('تأیید شده'), findsNothing);
        expect(find.text('مالکیت عمومی (Public Domain)'), findsNothing);
      },
    );

    testWidgets(
      'Persian reader withholds Tajik-only title, incipit, and poem text by default',
      (tester) async {
        await pumpTestApp(
          tester,
          route: '/literature/work/tajik-only-work',
          works: const [testTajikOnlyWork],
          language: DisplayLanguage.persian,
        );

        await tester.scrollUntilVisible(
          find.text('نسخهٔ فارسی در دسترس نیست'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Унвони тоҷикӣ'), findsNothing);
        expect(find.text('Мисраи тоҷикӣ'), findsNothing);
        // Wrapped verse lines are set with a hanging indent, so match on the
        // opening words rather than the whole line.
        expect(find.textContaining('Матни тоҷикӣ набояд'), findsNothing);
        expect(find.text('نسخهٔ فارسی در دسترس نیست'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('تاجیکی (سیریلیک)'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('تاجیکی (سیریلیک)'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.textContaining('Матни тоҷикӣ набояд'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Матни тоҷикӣ набояд'), findsOneWidget);
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
          biographyTjProvenance: 'SOURCE_BACKED',
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
        expect(find.textContaining('Шеърҳо барои хондан: 1'), findsOneWidget);
        expect(find.textContaining('Осор барои хондан (1)'), findsOneWidget);

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
          biographyTjProvenance: 'SOURCE_BACKED',
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
        biographyTjProvenance: 'SOURCE_BACKED',
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

    testWidgets(
      'PoetsListScreen shows birthplace and fits at 320px with 1.5x text',
      (tester) async {
        const testAuthorWithPlace = LiteraryAuthor(
          id: 'jomi',
          canonicalName: 'Абдурраҳмони Ҷомӣ',
          canonicalNamePersian: 'نورالدین عبدالرحمان جامی',
          birthYear: '1414',
          deathYear: '1492',
          birthPlace: 'Ҷом, Хуросон',
          literaryPeriod: 'Асри XV',
          biographyTj: 'Шоири бузурги форсу тоҷик.',
          biographySource: 'Сарчашмаи санҷиши тестӣ, с. 2',
          biographyTjProvenance: 'SOURCE_BACKED',
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );

        await pumpTestApp(
          tester,
          route: '/literature/poets',
          authors: [testAuthorWithPlace],
          works: const [],
        );

        tester.view.physicalSize = const Size(320, 1600);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();

        expect(find.text('Абдурраҳмони Ҷомӣ'), findsOneWidget);
        expect(find.text('Ҷом, Хуросон'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('PoetsListScreen title-cases all-caps display names', (
      tester,
    ) async {
      const allCapsAuthor = LiteraryAuthor(
        id: 'anvari',
        canonicalName: 'АНВАРӢ',
        canonicalNamePersian: 'انوری ابیوردی',
        birthYear: '1126',
        deathYear: '1189',
        literaryPeriod: 'Асри XII',
        biographyTj: 'Шоири донишманд.',
        biographySource: 'Сарчашмаи санҷиши тестӣ, с. 3',
        biographyTjProvenance: 'SOURCE_BACKED',
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
      );

      await pumpTestApp(
        tester,
        route: '/literature/poets',
        authors: [allCapsAuthor],
        works: const [],
      );

      expect(find.text('Анварӣ'), findsOneWidget);
      expect(find.text('АНВАРӢ'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
