import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/poet_detail_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

// A long source-language birthplace that would previously be ellipsized on a
// narrow phone when forced onto the same row as the lifespan.
const _longBirthPlace =
    'Деҳаи Панҷрӯд, дар наздикии Қаротегин, дар доманаи қаторкӯҳи Зарафшон';

const _author = LiteraryAuthor(
  id: 'rudaki',
  canonicalName: 'Абӯабдуллоҳи Рӯдакӣ',
  birthYear: '858',
  deathYear: '941',
  birthPlace: _longBirthPlace,
  literaryPeriod: 'Асри IX-X',
  biographyTj: 'Сардафтари адабиёти классикии тоҷик.',
  biographySource: 'Адабиёти тоҷик, синфи 5, Маориф, Душанбе, 2017, с. 49',
  biographyTjProvenance: 'SOURCE_BACKED',
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Муаллифи асри X.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
);

void main() {
  testWidgets(
    'poet birthplace is fully readable on a narrow phone without ellipsis',
    (tester) async {
      tester.view.physicalSize = const Size(320, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          displayLanguageProvider.overrideWith(
            (ref) => DisplayLanguageNotifier()..state = DisplayLanguage.tajik,
          ),
          authorByIdProvider.overrideWith(
            (ref, id) => Future.value(id == 'rudaki' ? _author : null),
          ),
          worksByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <LiteraryWork>[]),
          ),
          worksUnderReviewByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <LiteraryWork>[]),
          ),
          schoolCanonByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <SchoolCanonEntry>[]),
          ),
          booksByAuthorProvider.overrideWith((ref, id) => const <Book>[]),
          historyEntriesProvider.overrideWith(
            (ref) => Future.value(const <HistoryEntry>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PoetDetailScreen(poetId: 'rudaki'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The full birthplace string is rendered on screen.
      final birthPlaceText = find.text(_longBirthPlace);
      expect(birthPlaceText, findsOneWidget);

      // It must not be ellipsized (the whole string is visible, no overflow).
      final textWidget = tester.widget<Text>(birthPlaceText);
      expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
      expect(textWidget.softWrap, isTrue);
    },
  );

  group('a poet the textbooks print no poem of', () {
    const noBio = LiteraryAuthor(
      id: 'prose',
      canonicalName: 'Сотим Улуғзода',
      birthYear: '1911',
      deathYear: '1997',
      birthPlace: 'Варзик',
      literaryPeriod: 'Асри XX',
      biographyTj: '',
      biographySource: '',
      rights: RightsRecord(
        status: RightsStatus.unknown,
        reasoning: 'x',
        fullTextAllowed: false,
        excerptAllowed: false,
      ),
    );
    const underReview = LiteraryWork(
      id: 'pending',
      authorId: 'prose',
      title: 'Сабти дар санҷиш',
      type: WorkType.poem,
      rights: RightsRecord(
        status: RightsStatus.unknown,
        reasoning: 'x',
        fullTextAllowed: false,
        excerptAllowed: false,
      ),
      verification: VerificationRecord(
        evidenceLevel: VerificationLevel.needsReview,
      ),
      primarySource: SourceEdition(
        bookTitle: 'Адабиёти тоҷик',
        publisher: 'Маориф',
        city: 'Душанбе',
        year: '2018',
        pageStart: 190,
        sourceType: SourceEditionType.officialTextbook,
        sourceReference: 'docs/literature/pdfs/adabiyet sinfi 11.pdf',
      ),
    );

    Future<void> pump(WidgetTester tester, DisplayLanguage language) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsLanguage: language == DisplayLanguage.persian
            ? 'fa'
            : 'tj',
      });
      final container = ProviderContainer(
        overrides: [
          authorByIdProvider.overrideWith(
            (ref, id) => Future.value(id == 'prose' ? noBio : null),
          ),
          worksByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <LiteraryWork>[]),
          ),
          worksUnderReviewByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const [underReview]),
          ),
          schoolCanonByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <SchoolCanonEntry>[]),
          ),
          booksByAuthorProvider.overrideWith((ref, id) => const <Book>[]),
          historyEntriesProvider.overrideWith(
            (ref) => Future.value(const <HistoryEntry>[]),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PoetDetailScreen(poetId: 'prose'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final language in DisplayLanguage.values) {
      testWidgets('shows one plain line and no review records ($language)', (
        tester,
      ) async {
        await pump(tester, language);
        expect(
          find.text(AppTranslations.get('lit_poet_no_textbook_poem', language)),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('poet-detail-review-toggle')),
          findsNothing,
        );
        expect(find.text('Сабти дар санҷиш'), findsNothing);
        // No «0» badge or «(0)» header around the line.
        expect(find.textContaining('0'), findsNothing);
        expect(find.textContaining('۰'), findsNothing);
        expect(find.byIcon(Icons.info_outline), findsNothing);
      });
    }

    testWidgets('readers never see review or page-citation wording', (
      tester,
    ) async {
      await pump(tester, DisplayLanguage.tajik);
      final shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join('\n');
      for (final wording in [
        'дар санҷиш',
        'саҳифадор',
        'таҳти санҷиш',
        'санҷиши саҳифа',
        'муқобала',
      ]) {
        expect(shown, isNot(contains(wording)), reason: wording);
      }
    });
  });
}
