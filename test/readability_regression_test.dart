import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/app.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/design_system/qalam_reading_page.dart';
import 'package:zarbulmasal/core/design_system/qalam_typography.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/settings/settings_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer freshContainer({
    DateTime Function()? now,
    Map<String, Object>? prefs,
  }) {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefsLanguage: 'tj',
      AppConstants.prefsDarkMode: false,
      AppConstants.prefsOnboardingComplete: true,
      ...?prefs,
    });
    return ProviderContainer(
      overrides: [if (now != null) nowProvider.overrideWithValue(now)],
    );
  }

  /// Renders [home] under the same MediaQuery scaling that [ZarbulmasalApp]
  /// applies: the OS accessibility scale is multiplied by the user's app text
  /// scale choice, then every interface Text inherits it.
  Widget appHarness(
    ProviderContainer container,
    Widget home, {
    bool applyAppScale = false,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          final lang = ref.watch(displayLanguageProvider);
          final appTextScale = applyAppScale
              ? ref.watch(appTextScaleProvider)
              : 1.0;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              Widget content = child!;
              if (applyAppScale) {
                final media = MediaQuery.of(context);
                content = MediaQuery(
                  data: media.copyWith(
                    textScaler: composeAppTextScaler(
                      media.textScaler,
                      appTextScale,
                    ),
                  ),
                  child: content,
                );
              }
              return Directionality(
                textDirection: lang == DisplayLanguage.persian
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: content,
              );
            },
            home: home,
          );
        },
      ),
    );
  }

  Future<ProviderContainer> pumpSettings(
    WidgetTester tester, {
    Map<String, Object>? prefs,
    DateTime Function()? now,
  }) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = freshContainer(prefs: prefs, now: now);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      appHarness(container, const SettingsScreen(), applyAppScale: true),
    );
    await tester.pumpAndSettle();
    return container;
  }

  group('App text scaling', () {
    testWidgets('app text scale choice resizes interface text immediately', (
      tester,
    ) async {
      final container = await pumpSettings(tester);
      // Measure the laid-out text itself: the label's box is stretched to the
      // column width, so the box size would not change with the scale.
      double labelWidth() => tester
          .renderObject<RenderParagraph>(find.text('ХОНДАН'))
          .getMaxIntrinsicWidth(double.infinity);
      final before = labelWidth();

      await tester.tap(find.text('Хеле калон'));
      await tester.pumpAndSettle();

      expect(
        container.read(appTextScaleProvider),
        closeTo(AppTextScaleNotifier.maximum, 0.001),
      );
      final after = labelWidth();
      // TextScaler scales only fontSize, so the section label's fixed
      // letterSpacing dilutes the growth slightly below 1.2× (≈1.18× for the
      // real font); a clear ~1.2× change is asserted rather than a no-op or a
      // single-step (1.1×) change.
      expect(after / before, greaterThan(1.15));
      expect(after / before, lessThan(1.25));
    });

    testWidgets('app text scale choice persists across a restart', (
      tester,
    ) async {
      final first = await pumpSettings(tester);
      await tester.tap(find.text('Хеле калон'));
      await tester.pumpAndSettle();
      expect(first.read(appTextScaleProvider), closeTo(1.2, 0.001));

      // Second launch: do not reset the mock preferences store, so the
      // persisted choice is what a real restart would load.
      final second = ProviderContainer();
      addTearDown(second.dispose);
      await tester.pumpWidget(
        appHarness(second, const SettingsScreen(), applyAppScale: true),
      );
      await tester.pumpAndSettle();

      expect(second.read(appTextScaleProvider), closeTo(1.2, 0.001));
    });

    testWidgets('OS accessibility scale is honored on top of app text scale', (
      tester,
    ) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      // The probe reports the effective text scaler it inherits through the
      // same pipeline ZarbulmasalApp builds (platformScale × appTextScale).
      final container = freshContainer();
      addTearDown(container.dispose);

      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      await tester.pumpWidget(
        appHarness(container, const _ScaleProbe(), applyAppScale: true),
      );
      await tester.pump();
      expect(find.text('scale=1.5'), findsOneWidget);

      tester.platformDispatcher.textScaleFactorTestValue = 1.0;
      await tester.pump();
      expect(find.text('scale=1.0'), findsOneWidget);
    });

    testWidgets('invalid persisted app text scale falls back to default', (
      tester,
    ) async {
      final container = await pumpSettings(
        tester,
        prefs: {AppConstants.prefsAppTextScale: double.nan},
      );
      expect(
        container.read(appTextScaleProvider),
        closeTo(AppTextScaleNotifier.defaultScale, 0.001),
      );
    });

    testWidgets('out-of-range persisted app text scale clamps to the range', (
      tester,
    ) async {
      final tooLarge = await pumpSettings(
        tester,
        prefs: {AppConstants.prefsAppTextScale: 5.0},
      );
      expect(
        tooLarge.read(appTextScaleProvider),
        closeTo(AppTextScaleNotifier.maximum, 0.001),
      );

      final tooSmall = await pumpSettings(
        tester,
        prefs: {AppConstants.prefsAppTextScale: 0.1},
      );
      expect(
        tooSmall.read(appTextScaleProvider),
        closeTo(AppTextScaleNotifier.minimum, 0.001),
      );
    });

    test('app text scale steps are the defined range', () {
      expect(AppTextScaleNotifier.minimum, 0.9);
      expect(AppTextScaleNotifier.defaultScale, 1.0);
      expect(AppTextScaleNotifier.largeScale, 1.1);
      expect(AppTextScaleNotifier.maximum, 1.2);
    });
  });

  group('Default typography is the smaller readability set', () {
    test('default sizes match the readability targets', () {
      const black = Colors.black;
      expect(QalamTypography.heroProverb(color: black).fontSize, 25);
      expect(QalamTypography.monographTitle(color: black).fontSize, 32);
      expect(QalamTypography.literaryTitle(color: black).fontSize, 20);
      expect(QalamTypography.verseText(color: black).fontSize, 19);
      expect(QalamTypography.hemistich(color: black).fontSize, 17);
      expect(QalamTypography.pageTitle(color: black).fontSize, 30);
      expect(QalamTypography.sectionTitle(color: black).fontSize, 21);
    });
  });

  group('Tajikistan UTC+5 daily date', () {
    test('same instant maps to the same Tajikistan date across time zones', () {
      final instant = DateTime.utc(2026, 9, 22, 12, 0);
      // The same instant, represented by a device whose local clock is far
      // behind or ahead of UTC.
      final behindLocal = instant.toLocal();
      expect(behindLocal.toUtc(), instant);

      expect(tajikistanDate(instant), DateTime.utc(2026, 9, 22));
      expect(tajikistanDate(behindLocal), DateTime.utc(2026, 9, 22));
      // Two instants that straddle the UTC day boundary can still fall on the
      // same Tajikistan day: 23:59 UTC = 04:59 and 00:01 UTC = 05:01 on Sep 23.
      expect(
        tajikistanDate(DateTime.utc(2026, 9, 22, 23, 59)),
        tajikistanDate(DateTime.utc(2026, 9, 23, 0, 1)),
      );
    });

    test('date flips exactly at the UTC+5 midnight boundary', () {
      // 18:59:59 UTC = 23:59:59 in Tajikistan (still Sep 22).
      expect(
        tajikistanDate(DateTime.utc(2026, 9, 22, 18, 59, 59)),
        DateTime.utc(2026, 9, 22),
      );
      // 19:00:00 UTC = 00:00:00 in Tajikistan (Sep 23).
      expect(
        tajikistanDate(DateTime.utc(2026, 9, 22, 19, 0, 0)),
        DateTime.utc(2026, 9, 23),
      );
    });

    test('dailyDateProvider exposes the Tajikistan calendar date', () {
      final container = freshContainer(
        now: () => DateTime.utc(2026, 9, 22, 23, 0), // 04:00 TJK Sep 23
      );
      addTearDown(container.dispose);
      expect(container.read(dailyDateProvider), DateTime.utc(2026, 9, 23));
    });

    test('daily proverb is identical for the same Tajikistan calendar day', () {
      Proverb? pick(DateTime instant) {
        final container = freshContainer(now: () => instant);
        final proverb = container.read(dailyProverbProvider);
        container.dispose();
        return proverb;
      }

      final lateEveningUtc = pick(DateTime.utc(2026, 9, 22, 22, 0));
      final earlyNextUtc = pick(DateTime.utc(2026, 9, 23, 0, 30));
      // Both are in the Tajikistan calendar day Sep 23 (03:00 / 05:30).
      expect(lateEveningUtc, isNotNull);
      expect(earlyNextUtc, isNotNull);
      expect(lateEveningUtc!.id, earlyNextUtc!.id);

      // The same UTC instant expressed with different local wall clocks maps
      // to the same daily proverb: tajikistanDate normalizes via toUtc, so
      // any representation of the same moment selects the same calendar day.
      final sameInstant = DateTime.utc(2026, 9, 22, 12, 0);
      final localReading = pick(sameInstant.toLocal());
      final utcReading = pick(sameInstant.toUtc());
      expect(localReading!.id, utcReading!.id);

      // A different Tajikistan calendar day selects a different proverb.
      final previousDay = pick(DateTime.utc(2026, 9, 22, 1, 0));
      expect(previousDay!.id, isNot(lateEveningUtc.id));
    });

    testWidgets('rollover scheduler flips the date at the UTC+5 boundary and is '
        'disposed safely', (tester) async {
      // Pin "now" to one second before UTC+5 midnight so the scheduler has a
      // real rollover timer pending while mounted.
      var now = DateTime.utc(2026, 9, 22, 18, 59, 59);
      final container = freshContainer(now: () => now);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DailyRolloverScheduler(child: _DailyDateProbe()),
        ),
      );
      await tester.pump();
      expect(find.text('2026-09-22'), findsOneWidget);

      // Cross the UTC+5 midnight boundary and let the one-second timer fire.
      now = DateTime.utc(2026, 9, 22, 19, 0, 0);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('2026-09-23'), findsOneWidget);

      // Unmounting the scheduler cancels its rollover Timer via State.dispose.
      // If it were not cancelled, the test fails at teardown with
      // "A Timer is still pending".
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('Source citation', () {
    testWidgets('a verified proverb lists its books; no status sentence', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = freshContainer();
      addTearDown(container.dispose);

      final proverb = seedProverbs.firstWhere((p) => p.isPageVerified);

      await tester.pumpWidget(
        appHarness(container, QalamReadingPage(proverb: proverb)),
      );
      await tester.pumpAndSettle();

      // The sources section: the printed form and page of each book. No
      // status sentence and no record tab.
      final heading = find.textContaining(
        AppTranslations.get('proverb_sources', DisplayLanguage.tajik),
      );
      await tester.scrollUntilVisible(
        heading,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(heading, findsOneWidget);
      expect(
        find.textContaining('«${proverb.sources.first.printedText}»'),
        findsOneWidget,
      );
      expect(
        find.text(
          AppTranslations.get('source_book_attested', DisplayLanguage.tajik),
        ),
        findsNothing,
      );
      expect(
        find.text(
          AppTranslations.get('record_tab_record', DisplayLanguage.tajik),
        ),
        findsNothing,
      );
    });

    testWidgets('an unsourced proverb says so instead of naming a book', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = freshContainer();
      addTearDown(container.dispose);

      final proverb = seedProverbs.firstWhere(
        (p) => p.sourceStatus == SourceStatus.needsReview,
      );
      expect(proverb.sourceNote, isEmpty);

      await tester.pumpWidget(
        appHarness(container, QalamReadingPage(proverb: proverb)),
      );
      await tester.pumpAndSettle();

      final notice = find.text(
        AppTranslations.get('proverb_no_printed_source', DisplayLanguage.tajik),
      );
      await tester.scrollUntilVisible(
        notice,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(notice, findsOneWidget);
    });
  });

  group('Small viewports, RTL, and enlarged text', () {
    /// Sets up a raised OS accessibility scale and app text scale, pumps [home]
    /// through the same scaling pipeline, then scrolls [anchor] into view so
    /// every lazily-built child between the top and [anchor] lays out. Any
    /// layout overflow is surfaced by [WidgetTester.takeException], which each
    /// call site asserts is null before and after scrolling.
    Future<void> pumpEnlargedTo(
      WidgetTester tester,
      ProviderContainer container,
      Widget home,
      Finder anchor, {
      Size size = const Size(320, 900),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;

      await tester.pumpWidget(appHarness(container, home, applyAppScale: true));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        anchor,
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(anchor, findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    testWidgets(
      'proverb reading page lays out at 320px RTL with enlarged text',
      (tester) async {
        final container = freshContainer(
          prefs: {
            AppConstants.prefsLanguage: 'fa',
            AppConstants.prefsAppTextScale: 1.2,
          },
        );
        addTearDown(container.dispose);

        final proverb = seedProverbs.firstWhere((p) => p.isPageVerified);

        // The proverb itself is at the top of the page, so its presence is
        // asserted before any scrolling.
        await tester.pumpWidget(
          appHarness(
            container,
            QalamReadingPage(proverb: proverb),
            applyAppScale: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SelectableText), findsWidgets);
        expect(tester.takeException(), isNull);

        // Scrolling to the sources section at the bottom forces every sliver
        // (meaning, explanation, example, variants) to lay out under the narrow
        // RTL, enlarged-text viewport.
        final citation = find.textContaining(
          AppTranslations.get('proverb_sources', DisplayLanguage.persian),
        );
        await tester.scrollUntilVisible(
          citation,
          300,
          // SelectableText fields carry their own Scrollables; target the
          // page's scroll view.
          scrollable: find.byType(Scrollable).first,
        );
        expect(citation, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('settings screen lays out at 320px LTR with enlarged text', (
      tester,
    ) async {
      final container = freshContainer(
        prefs: {
          AppConstants.prefsLanguage: 'tj',
          AppConstants.prefsAppTextScale: 1.2,
        },
      );
      addTearDown(container.dispose);

      // Reach the poem-size control first (the reading section may start below
      // the fold at this width and scale), then the bottom version footer.
      await pumpEnlargedTo(
        tester,
        container,
        const SettingsScreen(),
        find.text('Андозаи шеър'),
      );
      await tester.scrollUntilVisible(
        find.text('Нусхаи 2.0.0'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings screen lays out at 390px RTL with enlarged text', (
      tester,
    ) async {
      final container = freshContainer(
        prefs: {
          AppConstants.prefsLanguage: 'fa',
          AppConstants.prefsAppTextScale: 1.2,
        },
      );
      addTearDown(container.dispose);

      await pumpEnlargedTo(
        tester,
        container,
        const SettingsScreen(),
        find.text('اندازهٔ شعر'),
        size: const Size(390, 1400),
      );
      await tester.scrollUntilVisible(
        find.text('نسخه ۲.۰.۰'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

/// A minimal consumer of [dailyDateProvider]; shows the current Tajikistan
/// date so the rollover scheduler's effect is observable in tests.
class _DailyDateProbe extends ConsumerWidget {
  const _DailyDateProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dailyDateProvider);
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text('${date.year}-$mm-$dd'),
    );
  }
}

/// Reports the effective text scaler it inherits through the same MediaQuery
/// pipeline [ZarbulmasalApp] builds (OS accessibility scale × the user's app
/// text scale choice), as a printable "scale=X" string. Exact and independent
/// of the loaded font's glyph metrics.
class _ScaleProbe extends StatelessWidget {
  const _ScaleProbe();

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final effective = scaler.scale(16) / 16;
    return Text('scale=$effective', style: const TextStyle(fontSize: 12));
  }
}
