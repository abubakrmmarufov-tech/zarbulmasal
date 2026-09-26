import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/design_system/qalam_reading_page.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/core/l10n/source_citation.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/data/models/source_ref.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

const _asrori = SourceRef(
  bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  authorEditor: 'В. Асрорӣ',
  year: 1956,
  city: 'Сталинобод',
  publisher: 'Нашриёти давлатии Тоҷикистон',
  pdfPage: 24,
  printedPage: 25,
  printedText: 'Илм хоҳӣ, такрор кун, ҳосил хоҳӣ, шудгор кун.',
);

const _textbook = SourceRef(
  bookTitle: 'Адабиёти тоҷик, синфи 5',
  year: 2017,
  city: 'Душанбе',
  publisher: 'Маориф',
  pdfPage: 40,
  printedPage: 40,
);

Proverb _proverb({
  String id = '900',
  SourceStatus status = SourceStatus.pageVerified,
  List<SourceRef> sources = const [_asrori],
  SourceRef? meaningSource,
  SourceRef? exampleSource,
  String? exampleAttribution,
  PersianOrigin persianOrigin = PersianOrigin.transliteration,
}) => Proverb(
  id: id,
  tajikCyrillic: 'Илм хоҳӣ, такрор кун, ҳосил хоҳӣ, шудгор кун.',
  persianText: 'علم خواهی، تکرار کن، حاصل خواهی، شیار کن.',
  simpleExplanationTj: 'Шарҳи содаи озмоишӣ.',
  meaningTj: 'Маънои озмоишӣ.',
  exampleSentenceTj: 'Мисоли озмоишӣ.',
  categoryId: 'ilm',
  level: 3,
  type: ProverbType.traditional,
  sourceStatus: status,
  sourceNote: status == SourceStatus.needsReview ? '' : 'Асрорӣ 1956',
  sources: sources,
  meaningSource: meaningSource,
  exampleSource: exampleSource,
  exampleAttribution: exampleAttribution,
  persianOrigin: persianOrigin,
);

/// The badge the owner removed (26 Sep 2026).
const _persianBadge = 'Хатти форсӣ: транслитератсия';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatSourceCitation', () {
    test('cites the book and year only, never the page', () {
      expect(
        formatSourceCitation(_asrori, DisplayLanguage.tajik),
        'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
      );
    });

    test('uses Persian digits in Persian and shows no page', () {
      final citation = formatSourceCitation(_textbook, DisplayLanguage.persian);
      expect(citation, contains('۲۰۱۷'));
      expect(citation, isNot(contains('ص.')));
      expect(citation, isNot(contains('۴۰')));
      expect(citation, isNot(contains('саҳ.')));
    });
  });

  group('Proverb provenance', () {
    test('page-verified needs both the status and a source', () {
      expect(_proverb().isPageVerified, isTrue);
      expect(_proverb(sources: const []).isPageVerified, isFalse);
      expect(
        _proverb(status: SourceStatus.needsReview).isPageVerified,
        isFalse,
      );
    });

    test('meaning and example are editorial unless a page is given', () {
      final editorial = _proverb();
      expect(editorial.isMeaningPrinted, isFalse);
      expect(editorial.isExamplePrinted, isFalse);
      final printed = _proverb(
        meaningSource: _textbook,
        exampleSource: _textbook,
      );
      expect(printed.isMeaningPrinted, isTrue);
      expect(printed.isExamplePrinted, isTrue);
    });

    test('copyWith keeps sources and provenance', () {
      final original = _proverb(
        meaningSource: _textbook,
        exampleSource: _textbook,
        exampleAttribution: 'Сотим Улуғзода',
        persianOrigin: PersianOrigin.printed,
      );
      final copy = original.copyWith(level: 5);
      expect(copy.sources, same(original.sources));
      expect(copy.meaningSource, same(_textbook));
      expect(copy.exampleSource, same(_textbook));
      expect(copy.exampleAttribution, 'Сотим Улуғзода');
      expect(copy.persianOrigin, PersianOrigin.printed);
    });

    test('SourceRef reads every field from JSON', () {
      final source = SourceRef.fromJson(const {
        'bookTitle': 'Китоб',
        'authorEditor': 'Муаллиф',
        'year': 1990,
        'pdfPage': 12,
        'printedPage': 10,
        'publisher': 'Адиб',
        'city': 'Душанбе',
        'printedText': 'Матн.',
        'note': 'Эзоҳ',
      });
      expect(source.publisher, 'Адиб');
      expect(source.city, 'Душанбе');
      expect(source.printedText, 'Матн.');
      expect(source.note, 'Эзоҳ');
      expect(source.printedPage, 10);
      expect(source.pdfPage, 12);
    });
  });

  group('Reading page', () {
    Future<void> pumpPage(
      WidgetTester tester,
      Proverb proverb, {
      String language = 'tj',
    }) async {
      tester.view.physicalSize = const Size(390, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsLanguage: language,
        AppConstants.prefsOnboardingComplete: true,
      });
      final container = ProviderContainer(
        overrides: [
          proverbsProvider.overrideWithValue([proverb]),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: QalamReadingPage(proverb: proverb)),
        ),
      );
      await tester.pumpAndSettle();
    }

    String tj(String key, [List<Object> args = const []]) =>
        AppTranslations.get(key, DisplayLanguage.tajik, args);

    testWidgets('lists each book with its printed form, without pages', (
      tester,
    ) async {
      await pumpPage(tester, _proverb(sources: const [_asrori, _textbook]));

      expect(find.textContaining(tj('proverb_sources')), findsOneWidget);
      final sources = tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .map((widget) => widget.data ?? '')
          .firstWhere((text) => text.contains('«${_asrori.printedText}»'));
      expect(sources, contains('Зарбулмасал ва мақолҳои тоҷикӣ (1956)'));
      expect(sources, contains('Адабиёти тоҷик, синфи 5 (2017)'));
      expect(sources, isNot(contains('саҳ.')));
      expect(sources, isNot(contains('В. Асрорӣ')));
      expect(find.textContaining('саҳ. '), findsNothing);
      expect(find.text(tj('proverb_no_printed_source')), findsNothing);
    });

    testWidgets('labels editorial sections, not the Persian script', (
      tester,
    ) async {
      await pumpPage(tester, _proverb());

      // Meaning, explanation and example are all editorial here.
      expect(find.text(tj('proverb_editorial')), findsNWidgets(3));
      // The Persian script is shown without a transliteration badge.
      expect(find.text(_persianBadge), findsNothing);
      expect(
        find.text('علم خواهی، تکرار کن، حاصل خواهی، شیار کن.'),
        findsWidgets,
      );
    });

    testWidgets('a printed example shows its signature and book', (
      tester,
    ) async {
      await pumpPage(
        tester,
        _proverb(
          meaningSource: _textbook,
          exampleSource: _textbook,
          exampleAttribution: 'Сотим Улуғзода',
          persianOrigin: PersianOrigin.printed,
        ),
      );

      final printedFrom = tj('proverb_printed_from', [
        formatSourceCitation(_textbook, DisplayLanguage.tajik),
      ]);
      expect(find.text(printedFrom), findsNWidgets(2));
      expect(printedFrom, 'Аз китоб: Адабиёти тоҷик, синфи 5 (2017)');
      // Only the simple explanation stays editorial.
      expect(find.text(tj('proverb_editorial')), findsOneWidget);
      expect(find.text('Мисоли озмоишӣ.\n— Сотим Улуғзода'), findsOneWidget);
      expect(find.text(_persianBadge), findsNothing);
    });

    testWidgets('an unsourced proverb says no printed source was found', (
      tester,
    ) async {
      await pumpPage(
        tester,
        _proverb(status: SourceStatus.needsReview, sources: const []),
      );

      expect(find.text(tj('proverb_no_printed_source')), findsOneWidget);
      expect(find.textContaining(tj('proverb_sources')), findsNothing);
    });

    testWidgets('the unsourced notice reads right-to-left in Persian', (
      tester,
    ) async {
      await pumpPage(
        tester,
        _proverb(status: SourceStatus.needsReview, sources: const []),
        language: 'fa',
      );

      final notice = tester.widget<Text>(
        find.text(
          AppTranslations.get(
            'proverb_no_printed_source',
            DisplayLanguage.persian,
          ),
        ),
      );
      expect(notice.textDirection, TextDirection.rtl);
    });
  });
}
