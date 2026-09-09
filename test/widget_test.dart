import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/design_system/qalam_choice.dart';
import 'package:zarbulmasal/core/design_system/qalam_category_tile.dart';
import 'package:zarbulmasal/core/design_system/qalam_level_card.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/data/seed/seed_categories.dart';
import 'package:zarbulmasal/core/design_system/qalam_flash_card.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/router/app_router.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/widgets/onboarding_overlay.dart';

class TestApp {
  final ProviderContainer container;
  final GoRouter router;
  TestApp(this.container, this.router);
}

Future<TestApp> openApp(
  WidgetTester tester, {
  String route = '/',
  double width = 390,
  double height = 844,
  double scale = 1,
  DisplayLanguage language = DisplayLanguage.tajik,
  bool dark = false,
  bool onboardingComplete = true,
  bool disableAnimations = false,
  EdgeInsets safePadding = EdgeInsets.zero,
  List<Proverb>? catalog,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({
    AppConstants.prefsLanguage: language == DisplayLanguage.persian
        ? 'fa'
        : 'tj',
    AppConstants.prefsDarkMode: dark,
    AppConstants.prefsOnboardingComplete: onboardingComplete,
  });
  final container = ProviderContainer(
    overrides: [
      if (catalog != null) proverbsProvider.overrideWithValue(catalog),
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
      child: Consumer(
        builder: (context, ref, child) {
          final lang = ref.watch(displayLanguageProvider);
          final theme = ref.watch(themeModeProvider);
          return MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: disableAnimations,
                padding: safePadding,
                viewPadding: safePadding,
              ),
              child: Directionality(
                textDirection: lang == DisplayLanguage.persian
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return TestApp(container, router);
}

void main() {
  testWidgets('first launch tour fits a small phone and persists completion', (
    tester,
  ) async {
    await openApp(
      tester,
      width: 320,
      height: 568,
      scale: 1.3,
      onboardingComplete: false,
    );

    expect(find.byType(OnboardingOverlay), findsOneWidget);
    expect(find.text('Ҳикмати рӯз'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (final title in ['Мақолҳо ва ҷустуҷӯ', 'Маҳфузот', 'Танзимот']) {
      await tester.tap(find.text('Баъдӣ'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('onboarding-tooltip')),
          matching: find.text(title),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.text('Оғоз!'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingOverlay), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppConstants.prefsOnboardingComplete,
      ),
      isTrue,
    );
  });

  const onboardingSizes = [
    Size(320, 568),
    Size(360, 640),
    Size(375, 667),
    Size(390, 844),
    Size(393, 852),
    Size(430, 932),
  ];
  for (final size in onboardingSizes) {
    for (final language in DisplayLanguage.values) {
      testWidgets(
        'four-step tour stays in the safe area at ${size.width}x${size.height} in ${language.name}',
        (tester) async {
          final safePadding = EdgeInsets.fromLTRB(
            0,
            size.height >= 844 ? 59 : 47,
            0,
            34,
          );
          final dark = (size.width.toInt() + language.index).isEven;
          await openApp(
            tester,
            width: size.width,
            height: size.height,
            language: language,
            dark: dark,
            onboardingComplete: false,
            safePadding: safePadding,
          );

          final titleKeys = [
            'onboarding_home_title',
            'onboarding_search_title',
            'onboarding_favorites_title',
            'onboarding_settings_title',
          ];
          for (var step = 0; step < titleKeys.length; step++) {
            final tooltip = find.byKey(const ValueKey('onboarding-tooltip'));
            final tooltipContext = tester.element(tooltip);
            final rect = tester.getRect(tooltip);
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(size.width));
            expect(rect.top, greaterThanOrEqualTo(safePadding.top));
            expect(
              rect.bottom,
              lessThanOrEqualTo(size.height - safePadding.bottom),
            );
            expect(
              find.descendant(
                of: tooltip,
                matching: find.text(
                  AppTranslations.get(titleKeys[step], language),
                ),
              ),
              findsOneWidget,
            );
            expect(find.text('${step + 1} / 4'), findsOneWidget);
            expect(
              Directionality.of(tooltipContext),
              language == DisplayLanguage.persian
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            );
            expect(
              Theme.of(tooltipContext).brightness,
              dark ? Brightness.dark : Brightness.light,
            );
            expect(tester.takeException(), isNull);

            final actionKey = step == titleKeys.length - 1
                ? 'onboarding_finish'
                : 'onboarding_next';
            await tester.tap(
              find.text(AppTranslations.get(actionKey, language)),
            );
            await tester.pumpAndSettle();
          }

          expect(find.byType(OnboardingOverlay), findsNothing);
          expect(
            (await SharedPreferences.getInstance()).getBool(
              AppConstants.prefsOnboardingComplete,
            ),
            isTrue,
          );
        },
      );
    }
  }

  testWidgets('large Persian tour stays actionable inside iPhone safe areas', (
    tester,
  ) async {
    const safePadding = EdgeInsets.fromLTRB(0, 47, 0, 34);
    await openApp(
      tester,
      width: 320,
      height: 568,
      scale: 2,
      language: DisplayLanguage.persian,
      dark: true,
      onboardingComplete: false,
      safePadding: safePadding,
    );

    for (var step = 0; step < 4; step++) {
      final tooltip = find.byKey(const ValueKey('onboarding-tooltip'));
      final action = find.text(step == 3 ? 'شروع!' : 'بعدی');
      expect(tooltip, findsOneWidget);
      expect(action, findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(action);
      await tester.pump();
      final actionRect = tester.getRect(action);
      expect(actionRect.top, greaterThanOrEqualTo(safePadding.top));
      expect(actionRect.bottom, lessThanOrEqualTo(568 - safePadding.bottom));
      await tester.tap(action);
      await tester.pumpAndSettle();
    }

    expect(find.byType(OnboardingOverlay), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tour removes transition durations when motion is reduced', (
    tester,
  ) async {
    await openApp(tester, onboardingComplete: false, disableAnimations: true);

    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
    await tester.tap(find.text('Гузаштан'));
    await tester.pump();
    expect(find.byType(OnboardingOverlay), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppConstants.prefsOnboardingComplete,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tour can be skipped and launched again from settings', (
    tester,
  ) async {
    final app = await openApp(tester, onboardingComplete: false);
    await tester.tap(find.text('Гузаштан'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingOverlay), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppConstants.prefsOnboardingComplete,
      ),
      isTrue,
    );

    app.router.go('/settings');
    await tester.pumpAndSettle();
    final replay = find.text('Роҳнамои хусусиятҳо');
    await tester.scrollUntilVisible(
      replay,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(replay);
    await tester.pumpAndSettle();
    expect(app.router.routeInformationProvider.value.uri.path, '/');
    expect(find.byType(OnboardingOverlay), findsOneWidget);
    expect(find.text('Ҳикмати рӯз'), findsOneWidget);

    for (var step = 0; step < 3; step++) {
      await tester.tap(find.text('Баъдӣ'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Оғоз!'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingOverlay), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppConstants.prefsOnboardingComplete,
      ),
      isTrue,
    );
  });

  testWidgets('system back dismisses and remembers the first-launch tour', (
    tester,
  ) async {
    await openApp(tester, onboardingComplete: false);
    expect(find.byType(OnboardingOverlay), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingOverlay), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppConstants.prefsOnboardingComplete,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'returning users do not see onboarding and unknown routes are native',
    (tester) async {
      final app = await openApp(tester);
      expect(find.byType(OnboardingOverlay), findsNothing);

      app.router.go('/not-a-zarbulmasal-route');
      await tester.pumpAndSettle();
      expect(find.text('Саҳифа ёфт нашуд'), findsOneWidget);
      expect(find.text("Couldn't load object"), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reading copies real content and back handles pushed and direct routes',
    (tester) async {
      final target = seedProverbs.first;
      final app = await openApp(tester, route: '/proverb/${target.id}');
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.tap(find.byIcon(Icons.copy_outlined));
      await tester.pumpAndSettle();
      expect(
        copied,
        '${target.tajikCyrillic}\n${target.persianText}\n\n${target.meaningTj}',
      );
      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();
      expect(app.router.routeInformationProvider.value.uri.path, '/');
      app.router.go('/proverbs');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), target.tajikCyrillic);
      await tester.pumpAndSettle();
      app.router.push('/proverb/${target.id}');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();
      expect(app.router.routeInformationProvider.value.uri.path, '/proverbs');
      expect(app.container.read(searchQueryProvider), target.tajikCyrillic);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        target.tajikCyrillic,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in DisplayLanguage.values) {
    testWidgets(
      'physical flashcard swipes advance and return in ${language.name}',
      (tester) async {
        await openApp(tester, route: '/flashcards', language: language);
        final first = tester
            .widget<QalamFlashCard>(find.byType(QalamFlashCard))
            .proverb
            .id;
        await tester.drag(find.byType(QalamFlashCard), const Offset(-180, 0));
        await tester.pumpAndSettle();
        expect(
          tester.widget<QalamFlashCard>(find.byType(QalamFlashCard)).proverb.id,
          isNot(first),
        );
        await tester.drag(find.byType(QalamFlashCard), const Offset(180, 0));
        await tester.pumpAndSettle();
        expect(
          tester.widget<QalamFlashCard>(find.byType(QalamFlashCard)).proverb.id,
          first,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'incorrect quiz feedback has a cross and produces accurate mixed score',
    (tester) async {
      await openApp(tester, route: '/quiz');
      for (var question = 0; question < 5; question++) {
        final answer = find
            .byWidgetPredicate(
              (w) =>
                  w is QalamChoice &&
                  (question == 0 ? !w.isCorrect : w.isCorrect),
            )
            .first;
        await tester.ensureVisible(answer);
        await tester.tap(answer);
        await tester.pumpAndSettle();
        if (question == 0) {
          expect(find.byIcon(Icons.close), findsWidgets);
          expect(find.byIcon(Icons.check), findsOneWidget);
        }
        final next = find.text(
          AppTranslations.get(
            question == 4 ? 'btn_see_results' : 'btn_next_question',
            DisplayLanguage.tajik,
          ),
        );
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(find.text('80%'), findsOneWidget);
      expect(
        find.text(
          AppTranslations.get('quiz_correct_of', DisplayLanguage.tajik, [
            '4',
            '5',
          ]),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'categories and levels start a fresh filtered discovery session',
    (tester) async {
      final app = await openApp(tester, route: '/categories');
      app.container.read(searchQueryProvider.notifier).state = 'no-match-83971';
      app.container.read(selectedLevelProvider.notifier).state = 10;
      final firstCategory = find.byWidgetPredicate(
        (w) =>
            w is QalamCategoryTile && w.category.id == seedCategories.first.id,
      );
      await tester.ensureVisible(firstCategory);
      await tester.tap(firstCategory);
      await tester.pumpAndSettle();
      expect(app.router.routeInformationProvider.value.uri.path, '/proverbs');
      expect(
        app.container.read(selectedCategoryProvider),
        seedCategories.first.id,
      );
      expect(app.container.read(selectedLevelProvider), isNull);
      expect(app.container.read(searchQueryProvider), isEmpty);
      expect(app.container.read(filteredProverbsProvider), isNotEmpty);
      app.router.go('/levels');
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is SliverList && w.delegate.estimatedChildCount == 6,
        ),
        findsOneWidget,
      );
      app.container.read(searchQueryProvider.notifier).state = 'no-match-83971';
      final firstLevel = find.byWidgetPredicate(
        (w) => w is QalamLevelCard && w.level == 1,
      );
      await tester.ensureVisible(firstLevel);
      await tester.tap(firstLevel);
      await tester.pumpAndSettle();
      expect(app.router.routeInformationProvider.value.uri.path, '/proverbs');
      expect(app.container.read(selectedLevelProvider), 1);
      expect(app.container.read(selectedCategoryProvider), isNull);
      expect(app.container.read(searchQueryProvider), isEmpty);
      expect(app.container.read(filteredProverbsProvider), isNotEmpty);
    },
  );

  testWidgets('sparse catalogs expose only levels with real content', (
    tester,
  ) async {
    final sparseCatalog = [
      seedProverbs.first.copyWith(id: 'level-6', level: 6),
      seedProverbs.last.copyWith(id: 'level-2', level: 2),
    ];
    final app = await openApp(tester, route: '/levels', catalog: sparseCatalog);

    expect(find.text('Дастрас: 2 сатҳ'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is QalamLevelCard && w.level == 2),
      findsOneWidget,
    );
    final levelSix = find.byWidgetPredicate(
      (w) => w is QalamLevelCard && w.level == 6,
    );
    expect(levelSix, findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is QalamLevelCard && w.level == 7),
      findsNothing,
    );

    await tester.ensureVisible(levelSix);
    await tester.tap(levelSix);
    await tester.pumpAndSettle();
    expect(app.router.routeInformationProvider.value.uri.path, '/proverbs');
    expect(app.container.read(selectedLevelProvider), 6);
    expect(app.container.read(filteredProverbsProvider), hasLength(1));
    expect(find.byKey(const ValueKey('level-filter-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('level-filter-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('level-filter-6')), findsOneWidget);
    expect(find.byKey(const ValueKey('level-filter-7')), findsNothing);
  });

  testWidgets('Persian level counts use Persian digits on home and levels', (
    tester,
  ) async {
    final sparseCatalog = [
      seedProverbs.first.copyWith(id: 'level-2', level: 2),
      seedProverbs.last.copyWith(id: 'level-6', level: 6),
    ];
    final app = await openApp(
      tester,
      language: DisplayLanguage.persian,
      catalog: sparseCatalog,
    );

    expect(find.text('۲ سطح موجود'), findsOneWidget);
    app.router.go('/levels');
    await tester.pumpAndSettle();
    expect(find.text('۲ سطح موجود'), findsOneWidget);
    expect(find.textContaining('2 سطح'), findsNothing);
  });

  testWidgets(
    'empty catalog and invalid detail are recoverable without fake content',
    (tester) async {
      final app = await openApp(tester, catalog: []);
      for (final route in [
        '/',
        '/proverbs',
        '/levels',
        '/favorites',
        '/daily',
        '/quiz',
        '/flashcards',
        '/proverb/missing-id',
      ]) {
        app.router.go(route);
        await tester.pumpAndSettle();
        if (route == '/levels') {
          expect(find.text('Ҳоло сатҳе дастрас нест.'), findsOneWidget);
        }
        expect(tester.takeException(), isNull, reason: route);
        expect(
          find.textContaining(seedProverbs.first.tajikCyrillic),
          findsNothing,
        );
      }
    },
  );

  testWidgets(
    'settings language/theme and large-text about dialog remain usable',
    (tester) async {
      final app = await openApp(
        tester,
        route: '/settings',
        width: 360,
        scale: 2,
      );
      final dark = find.byType(Switch).first;
      await tester.ensureVisible(dark);
      await tester.tap(dark);
      await tester.pumpAndSettle();
      expect(app.container.read(themeModeProvider), ThemeMode.dark);
      final persian = find.text('فارسی');
      await tester.ensureVisible(persian);
      await tester.tap(persian);
      await tester.pumpAndSettle();
      expect(
        app.container.read(displayLanguageProvider),
        DisplayLanguage.persian,
      );
      expect(
        (await SharedPreferences.getInstance()).getString(
          AppConstants.prefsLanguage,
        ),
        'fa',
      );
      final about = find.text(
        AppTranslations.get('settings_about', DisplayLanguage.persian),
      );
      await tester.scrollUntilVisible(
        about,
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(about);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      app.router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    },
  );

  for (final width in [360.0, 390.0, 430.0]) {
    for (final language in DisplayLanguage.values) {
      testWidgets(
        'all destinations render and scroll at $width in ${language.name}',
        (tester) async {
          final app = await openApp(tester, width: width, language: language);
          for (final route in [
            '/',
            '/proverbs',
            '/categories',
            '/favorites',
            '/settings',
            '/proverb/${seedProverbs.first.id}',
            '/levels',
            '/quiz',
            '/flashcards',
            '/daily',
          ]) {
            app.router.go(route);
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$route initial at $width / $language',
            );
            final scrollable = find.byType(Scrollable);
            if (scrollable.evaluate().isNotEmpty) {
              await tester.drag(scrollable.first, const Offset(0, -1500));
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '$route scrolled at $width / $language',
              );
            }
          }
        },
      );
    }
  }

  testWidgets(
    'dark mode and enlarged text retain readable learning/settings layouts',
    (tester) async {
      final app = await openApp(tester, width: 360, scale: 1.5, dark: true);
      for (final route in [
        '/',
        '/settings',
        '/quiz',
        '/flashcards',
        '/proverb/${seedProverbs.last.id}',
      ]) {
        app.router.go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route at 150% text');
      }
    },
  );

  testWidgets(
    'search reacts to both scripts and reports empty results with keyboard',
    (tester) async {
      final app = await openApp(tester, route: '/proverbs', width: 360);
      final target = seedProverbs.first;
      for (final text in [
        target.tajikCyrillic,
        target.persianText,
        'no-match-83971',
      ]) {
        await tester.enterText(find.byType(TextField), text);
        await tester.pumpAndSettle();
        expect(app.container.read(searchQueryProvider), text);
        expect(
          app.container.read(filteredProverbsProvider),
          text == 'no-match-83971' ? isEmpty : contains(target),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'bookmark survives navigation and can be removed from saved list',
    (tester) async {
      final target = seedProverbs.first;
      final app = await openApp(tester, route: '/proverb/${target.id}');
      await tester.tap(find.byIcon(Icons.bookmark_outline).first);
      await tester.pumpAndSettle();
      expect(app.container.read(favoritesProvider), contains(target.id));
      app.router.go('/favorites');
      await tester.pumpAndSettle();
      expect(find.textContaining(target.tajikCyrillic), findsWidgets);
      final savedIcon = find.byIcon(Icons.bookmark);
      await tester.tap(savedIcon.first);
      await tester.pumpAndSettle();
      expect(app.container.read(favoritesProvider), isEmpty);
      expect(app.container.read(favoritesListProvider), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'quiz locks answers, scores all five questions and restarts cleanly',
    (tester) async {
      await openApp(tester, route: '/quiz');
      for (var question = 0; question < 5; question++) {
        final correct = find.byWidgetPredicate(
          (w) => w is QalamChoice && w.isCorrect,
        );
        expect(correct, findsOneWidget);
        await tester.ensureVisible(correct);
        await tester.tap(correct);
        await tester.pumpAndSettle();
        final choices = tester.widgetList<QalamChoice>(
          find.byType(QalamChoice),
        );
        expect(choices.every((c) => c.revealed && c.onTap == null), isTrue);
        final nextLabel = AppTranslations.get(
          question == 4 ? 'btn_see_results' : 'btn_next_question',
          DisplayLanguage.tajik,
        );
        final next = find.text(nextLabel);
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text('100%'), findsOneWidget);
      expect(
        find.text(
          AppTranslations.get('quiz_correct_of', DisplayLanguage.tajik, [
            '5',
            '5',
          ]),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.text(AppTranslations.get('btn_new_quiz', DisplayLanguage.tajik)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(
        tester
            .widgetList<QalamChoice>(find.byType(QalamChoice))
            .every((c) => !c.revealed),
        isTrue,
      );
    },
  );

  testWidgets(
    'flashcard reveals meaning and resets when moving next or previous',
    (tester) async {
      await openApp(tester, route: '/flashcards');
      final first = tester.widget<QalamFlashCard>(find.byType(QalamFlashCard));
      expect(first.showMeaning, isFalse);
      await tester.tap(find.byType(QalamFlashCard));
      await tester.pumpAndSettle();
      expect(
        tester.widget<QalamFlashCard>(find.byType(QalamFlashCard)).showMeaning,
        isTrue,
      );
      expect(find.text(first.proverb.meaningTj), findsOneWidget);
      await tester.tap(
        find.text(AppTranslations.get('btn_next', DisplayLanguage.tajik)),
      );
      await tester.pumpAndSettle();
      final second = tester.widget<QalamFlashCard>(find.byType(QalamFlashCard));
      expect(second.proverb.id, isNot(first.proverb.id));
      expect(second.showMeaning, isFalse);
      await tester.tap(
        find.text(AppTranslations.get('btn_previous', DisplayLanguage.tajik)),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<QalamFlashCard>(find.byType(QalamFlashCard)).proverb.id,
        first.proverb.id,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
