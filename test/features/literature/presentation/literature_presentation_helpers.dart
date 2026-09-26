/// Fixtures and helpers shared by the literature presentation tests.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/router/app_router.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

double contrastRatio(Color a, Color b) {
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
  textbookTitle: 'Адабиёти тоҷик',
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
