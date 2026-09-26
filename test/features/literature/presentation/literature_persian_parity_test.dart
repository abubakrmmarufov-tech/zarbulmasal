import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/presentation.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import 'literature_presentation_helpers.dart';

void main() {
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
      'PoetDetailScreen never lists records still under review in Persian',
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

        // Records still being checked stay in the data, not on screen.
        expect(find.text('مادر'), findsNothing);
        expect(find.text('Модар'), findsNothing);
        expect(find.textContaining('در بررسی'), findsNothing);
        expect(
          find.text('در کتاب‌های درسی شعری از او چاپ نشده است.'),
          findsOneWidget,
        );
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
