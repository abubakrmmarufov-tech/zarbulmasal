import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/search/global_search_screen.dart';
import '../../helpers/test_helper.dart';

const testAuthorRudaki = LiteraryAuthor(
  id: 'rudaki',
  canonicalName: 'Абӯабдуллоҳи Рӯдакӣ',
  canonicalNamePersian: 'ابوعبدالله رودکی',
  birthYear: '858',
  deathYear: '941',
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
    reasoning: 'Author died in 941 CE, exceeding 50 years post mortem.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
  verification: VerificationRecord(
    evidenceLevel: VerificationLevel.editoriallyApproved,
    pageVerified: true,
  ),
);

const testHistoryEntry = HistoryEntry(
  id: 'spitamen',
  kind: HistoryEntryKind.person,
  title: 'Спитамен',
  summary:
      'Сарлашкар ва қаҳрамони муборизаи халқҳои Суғду Бохтар бар зидди лашкари Искандари Мақдунӣ.',
  period: 'Солҳои 329–327 пеш аз милод',
  grade: '5',
  sourceBookId: 'history-5',
  sourceSection: 'Муборизаи Спитамен',
  significance: 'Рамзи фидокории миллӣ ва озодихоҳӣ дар таърихи тоҷикон.',
  dates: '329–327 п.м.',
);

void main() {
  final overrides = [
    literaryAuthorsProvider.overrideWith(
      (ref) => Future.value([testAuthorRudaki]),
    ),
    approvedWorksProvider.overrideWith((ref) => Future.value([testWorkRudaki])),
    historyEntriesProvider.overrideWith(
      (ref) => Future.value([testHistoryEntry]),
    ),
  ];

  group('GlobalSearchScreen', () {
    testWidgets('renders initial empty search prompt', (tester) async {
      await openApp(
        tester,
        route: '/search',
        catalog: seedProverbs,
        overrides: overrides,
      );

      expect(find.byType(GlobalSearchScreen), findsOneWidget);
      expect(find.text('Ҷустуҷӯ дар кулли Зарбулмасал'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('searching for a poet displays literary author result', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/search',
        catalog: seedProverbs,
        overrides: overrides,
      );

      // Enter query with diacritic folding
      await tester.enterText(find.byType(TextField), 'Рудаки');
      await tester.pumpAndSettle();

      // Should find Rudaki
      expect(find.textContaining('Рӯдакӣ'), findsWidgets);
      expect(find.textContaining('Шоирон'), findsWidgets);
    });

    testWidgets(
      'searching with Latin characters (rudaki) finds Cyrillic poet',
      (tester) async {
        await openApp(
          tester,
          route: '/search',
          catalog: seedProverbs,
          overrides: overrides,
        );

        await tester.enterText(find.byType(TextField), 'rudaki');
        await tester.pumpAndSettle();

        expect(find.textContaining('Рӯдакӣ'), findsWidgets);
        expect(find.textContaining('Шоирон'), findsWidgets);
      },
    );

    testWidgets('searching for a proverb displays proverb result', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/search',
        catalog: seedProverbs,
        overrides: overrides,
      );

      // Proverb search query
      await tester.enterText(find.byType(TextField), 'дил');
      await tester.pumpAndSettle();

      expect(find.textContaining('Зарбулмасалҳо'), findsWidgets);
    });

    testWidgets('searching for a history entry displays history result', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/search',
        catalog: seedProverbs,
        overrides: overrides,
      );

      // History search query
      await tester.enterText(find.byType(TextField), 'Спитамен');
      await tester.pumpAndSettle();

      expect(find.textContaining('Таърих'), findsWidgets);
      expect(find.textContaining('Спитамен'), findsWidgets);
    });

    testWidgets('clear button clears input and returns to empty state', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/search',
        catalog: seedProverbs,
        overrides: overrides,
      );

      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pumpAndSettle();

      // Clear button should be visible
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Should be back in empty state
      expect(find.text('Ҷустуҷӯ дар кулли Зарбулмасал'), findsOneWidget);
    });

    testWidgets('back button returns to previous screen', (tester) async {
      await openApp(
        tester,
        route: '/',
        catalog: seedProverbs,
        overrides: overrides,
      );

      // Navigate to search
      await tester.tap(find.byIcon(Icons.search).first);
      await tester.pumpAndSettle();

      expect(find.byType(GlobalSearchScreen), findsOneWidget);

      // Tap back button
      final backButton = find.byTooltip('Бозгашт');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should be back on Home
      expect(find.byType(GlobalSearchScreen), findsNothing);
    });
  });
}
