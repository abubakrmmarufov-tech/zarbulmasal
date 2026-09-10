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

