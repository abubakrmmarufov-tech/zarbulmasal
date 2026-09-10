import 'package:flutter/material.dart';
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
  biographySource: 'Ахтарони адаб, ҷ. 1, 2008',
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
    verifiedBy: 'Ҳайати таҳририя',
    verifiedDate: '2026-09-10',
    primarySourceChecked: true,
    secondSourceChecked: true,
    titleChecked: true,
    authorshipChecked: true,
    pageChecked: true,
    textLineByLineChecked: true,
    scriptChecked: true,
    copyrightChecked: true,
    finalStatus: VerificationStatus.approved,
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
    finalStatus: VerificationStatus.approved,
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
    AppConstants.prefsLanguage: language == DisplayLanguage.persian ? 'fa' : 'tj',
    AppConstants.prefsOnboardingComplete: true,
  });

  final container = ProviderContainer(
    overrides: [
      onboardingCompleteProvider.overrideWith((ref) => OnboardingNotifier()..state = true),
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
          works.where((w) => w.authorId == id).toList(),
        ),
      ),
      schoolCanonByAuthorProvider.overrideWith(
        (ref, id) => Future.value(
          canon.where((c) => c.authorId == id).toList(),
        ),
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
    testWidgets('Home screen includes QalamLiteratureCard that navigates to /literature',
        (tester) async {
      await pumpTestApp(tester, route: '/');

      expect(find.byType(QalamLiteratureCard), findsOneWidget);
      expect(find.text('Мероси адабӣ'), findsOneWidget);

      await tester.tap(find.byType(QalamLiteratureCard));
      await tester.pumpAndSettle();

      expect(find.byType(LiteratureHubScreen), findsOneWidget);
    });

    testWidgets('LiteratureHubScreen renders header, daily verse card and 4 section links',
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
    });

    testWidgets('Tapping Poets link in Hub navigates to PoetsListScreen',
        (tester) async {
      await pumpTestApp(tester, route: '/literature');

      await tester.tap(find.text('Шоирон'));
      await tester.pumpAndSettle();

      expect(find.byType(PoetsListScreen), findsOneWidget);
      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsOneWidget);
      expect(find.byType(QalamPoetCard), findsOneWidget);
    });

    testWidgets('PoetsListScreen search filters authors by name',
        (tester) async {
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
    });

    testWidgets('Tapping a poet card navigates to PoetDetailScreen',
        (tester) async {
      await pumpTestApp(tester, route: '/literature/poets');

      await tester.tap(find.byType(QalamPoetCard));
      await tester.pumpAndSettle();

      expect(find.byType(PoetDetailScreen), findsOneWidget);
      expect(find.text('Абӯабдуллоҳи Рӯдакӣ'), findsWidgets);
      expect(find.text('Сардафтари адабиёти классикии тоҷик.'), findsOneWidget);
      expect(find.text('Ахтарони адаб, ҷ. 1, 2008'), findsOneWidget);
      expect(find.text('Одамушшуаро'), findsOneWidget);
    });

    testWidgets('PoetDetailScreen renders works by author',
        (tester) async {
      await pumpTestApp(tester, route: '/literature/poet/rudaki');

      expect(find.byType(PoetDetailScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Бӯи ҷӯи Мӯлиён'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);
    });

    testWidgets('WorksListScreen renders list of approved works and navigates to reader',
        (tester) async {
      await pumpTestApp(tester, route: '/literature/works');

      expect(find.byType(WorksListScreen), findsOneWidget);
      expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);

      await tester.tap(find.text('Бӯи ҷӯи Мӯлиён'));
      await tester.pumpAndSettle();

      expect(find.byType(PoemReaderScreen), findsOneWidget);
    });

    testWidgets('PoemReaderScreen renders poem title, author, text and QalamSourceBadge',
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
    });

    testWidgets('PoemReaderScreen Source button opens SourcePanel bottom sheet',
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
    });

    testWidgets('SchoolCanonScreen displays entries grouped by grade',
        (tester) async {
      await pumpTestApp(tester, route: '/literature/school');

      expect(find.byType(SchoolCanonScreen), findsOneWidget);
      expect(find.text('Барномаи мактабӣ'), findsOneWidget);
      expect(find.text('СИНФИ 5'), findsOneWidget);
      expect(find.text('Адабиёти тоҷик (Синфи 5) (2018) — Маориф'), findsOneWidget);
      expect(find.text('Ҳатмӣ'), findsOneWidget);
    });

    testWidgets('OralHeritageScreen displays entries with genre tags and citation',
        (tester) async {
      await pumpTestApp(tester, route: '/literature/oral');

      expect(find.byType(OralHeritageScreen), findsOneWidget);
      expect(find.text('Мероси шифоҳӣ'), findsOneWidget);
      expect(find.text('Офтобро ба домон пӯшида намешавад.'), findsOneWidget);
      expect(find.textContaining('Б. Шермуҳаммадов. Зарбулмасалҳои тоҷикӣ'), findsOneWidget);
    });

    testWidgets('LiteratureSearchScreen searches across authors and works',
        (tester) async {
      await pumpTestApp(tester, route: '/literature/search');

      expect(find.byType(LiteratureSearchScreen), findsOneWidget);
      expect(find.text('Пешниҳодҳои ҷустуҷӯ:'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Мӯлиён');
      await tester.pumpAndSettle();

      expect(find.text('Бӯи ҷӯи Мӯлиён'), findsOneWidget);
    });
  });
}
