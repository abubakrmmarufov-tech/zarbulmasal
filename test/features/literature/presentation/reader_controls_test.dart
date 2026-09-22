import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/reader_preferences_provider.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/poem_reader_screen.dart';

void main() {
  const testRudakiWork = LiteraryWork(
    id: 'rudaki-boyi-juyi-muliyon',
    authorId: 'rudaki',
    title: 'Бӯи ҷӯи Мӯлиён',
    titlePersian: 'بوی جوی مولیان',
    type: WorkType.qasida,
    textTajik: 'Бӯи ҷӯи Мӯлиён ояд ҳаме,\nЁди ёри меҳрубон ояд ҳаме.',
    textPersian: 'بوی جوی مولیان آید همی\nیاد یار مهربان آید همی',
    textStatus: TextStatus.verified,
    primarySource: SourceEdition(
      bookTitle: 'Осори Рӯдакӣ',
      publisher: 'Нашриёти давлатии Тоҷикистон',
      city: 'Сталинобод',
      year: '1958',
      pageStart: 45,
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

  const tajikOnlyWork = LiteraryWork(
    id: 'tajik-only',
    authorId: 'rudaki',
    title: 'Танҳо тоҷикӣ',
    type: WorkType.poem,
    textTajik: 'Матни тасдиқшудаи тоҷикӣ',
    textStatus: TextStatus.verified,
    primarySource: SourceEdition(
      bookTitle: 'Осори Рӯдакӣ',
      publisher: 'Нашриёти давлатии Тоҷикистон',
      city: 'Сталинобод',
      year: '1958',
      pageStart: 46,
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

  testWidgets('poem reader responds to A- and A+ font size controls', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({AppConstants.prefsLanguage: 'tj'});

    final container = ProviderContainer(
      overrides: [
        approvedWorksProvider.overrideWith(
          (ref) => Future.value(const [testRudakiWork]),
        ),
        literaryWorksProvider.overrideWith(
          (ref) => Future.value(const [testRudakiWork]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PoemReaderScreen(workId: 'rudaki-boyi-juyi-muliyon'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Бӯи ҷӯи Мӯлиён'), findsWidgets);

    // Initial font size delta is 0
    final initialPrefs = container.read(readerPreferencesProvider);
    expect(initialPrefs.fontSizeDelta, 0.0);

    // Tap font size increase button (A+)
    final increaseBtn = find.byIcon(Icons.text_increase);
    expect(increaseBtn, findsOneWidget);
    await tester.tap(increaseBtn);
    await tester.pumpAndSettle();

    final increasedPrefs = container.read(readerPreferencesProvider);
    expect(increasedPrefs.fontSizeDelta, 2.0);

    // Tap font size decrease button (A-) twice
    final decreaseBtn = find.byIcon(Icons.text_decrease);
    expect(decreaseBtn, findsOneWidget);
    await tester.tap(decreaseBtn);
    await tester.tap(decreaseBtn);
    await tester.pumpAndSettle();

    final decreasedPrefs = container.read(readerPreferencesProvider);
    expect(decreasedPrefs.fontSizeDelta, -2.0);
  });

  testWidgets(
    'poem reader supports switching between Cyrillic, Persian, and Parallel text views',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsLanguage: 'tj',
      });

      final container = ProviderContainer(
        overrides: [
          approvedWorksProvider.overrideWith(
            (ref) => Future.value(const [testRudakiWork]),
          ),
          literaryWorksProvider.overrideWith(
            (ref) => Future.value(const [testRudakiWork]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PoemReaderScreen(workId: 'rudaki-boyi-juyi-muliyon'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify chips are displayed
      expect(find.text('Тоҷикӣ (Кириллӣ)'), findsOneWidget);
      expect(find.text('Форсӣ (Арабӣ)'), findsOneWidget);
      expect(find.text('Матни мувозӣ'), findsOneWidget);

      // Initial mode is Cyrillic: Cyrillic text is present
      expect(find.textContaining('Бӯи ҷӯи Мӯлиён ояд ҳаме'), findsWidgets);

      // Switch to Persian
      await tester.tap(find.text('Форсӣ (Арабӣ)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('بوی جوی مولیان آید همی'), findsWidgets);

      // Switch to Parallel
      await tester.tap(find.text('Матни мувозӣ'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Бӯи ҷӯи Мӯлиён ояд ҳаме'), findsWidgets);
      expect(find.textContaining('بوی جوی مولیان آید همی'), findsWidgets);
    },
  );

  testWidgets(
    'parallel preference opens a genuinely bilingual work in parallel mode',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsLanguage: 'tj',
        'reader_default_mode': 'parallel',
      });

      final container = ProviderContainer(
        overrides: [
          approvedWorksProvider.overrideWith(
            (ref) => Future.value(const [testRudakiWork]),
          ),
          literaryWorksProvider.overrideWith(
            (ref) => Future.value(const [testRudakiWork]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PoemReaderScreen(workId: 'rudaki-boyi-juyi-muliyon'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final parallelChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Матни мувозӣ'),
      );
      expect(parallelChip.selected, isTrue);
      expect(find.textContaining('Бӯи ҷӯи Мӯлиён ояд ҳаме'), findsWidgets);
      expect(find.textContaining('بوی جوی مولیان آید همی'), findsWidgets);
    },
  );

  testWidgets('parallel preference preserves Persian unavailable state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefsLanguage: 'fa',
      'reader_default_mode': 'parallel',
    });

    final container = ProviderContainer(
      overrides: [
        approvedWorksProvider.overrideWith(
          (ref) => Future.value(const [tajikOnlyWork]),
        ),
        literaryWorksProvider.overrideWith(
          (ref) => Future.value(const [tajikOnlyWork]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PoemReaderScreen(workId: 'tajik-only'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('نسخهٔ فارسی در دسترس نیست'), findsOneWidget);
    final persianChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'فارسی (عربی)'),
    );
    expect(persianChip.selected, isTrue);
  });
}
