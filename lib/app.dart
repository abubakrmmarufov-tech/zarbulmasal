import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'shared/providers/app_providers.dart';
import 'shared/widgets/reading_room.dart';
import 'shared/widgets/splash_screen.dart';

class ZarbulmasalApp extends ConsumerWidget {
  const ZarbulmasalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final displayLang = ref.watch(displayLanguageProvider);
    final appTextScale = ref.watch(appTextScaleProvider);

    final locale = displayLang == DisplayLanguage.persian
        ? const Locale('fa')
        : const Locale('tg');

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        _TajikMaterialDelegate(),
        _TajikCupertinoDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tg'), Locale('fa')],
      routerConfig: appRouter,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: composeAppTextScaler(media.textScaler, appTextScale),
          ),
          child: Directionality(
            textDirection: displayLang == DisplayLanguage.persian
                ? TextDirection.rtl
                : TextDirection.ltr,
            // Paint the area beside the reading column with the theme
            // surface so it follows the in-app theme, not the browser's.
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: ReadingRoomFrame(
                router: appRouter,
                lang: displayLang,
                child: DailyRolloverScheduler(
                  child: SplashScreen(child: child ?? const SizedBox.shrink()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Composes the platform (OS accessibility) text scaler with the user's app
/// text scale choice.
///
/// At the default app scale (1.0) the platform scaler is returned unchanged,
/// preserving the OS Dynamic Type mapping exactly — including the non-linear
/// curve iOS applies for large accessibility sizes. Otherwise the app scale
/// multiplies every font size the platform scaler produces, shifting the
/// platform's own (potentially non-linear) per-font-size mapping instead of
/// flattening it into a single linear factor. Accessibility scaling is never
/// capped.
TextScaler composeAppTextScaler(TextScaler platform, double appScale) {
  if (appScale == AppTextScaleNotifier.defaultScale) return platform;
  return _AppScaledTextScaler(platform, appScale);
}

/// A [TextScaler] that scales every output of a wrapped platform scaler by a
/// fixed factor, keeping the wrapped scaler's mapping intact.
final class _AppScaledTextScaler extends TextScaler {
  const _AppScaledTextScaler(this._platform, this._factor);

  final TextScaler _platform;
  final double _factor;

  @override
  double scale(double fontSize) => _platform.scale(fontSize) * _factor;

  // The wrapped scaler's factor is the only estimate available; multiplying it
  // by our factor keeps the estimate consistent with scale().
  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => _platform.textScaleFactor * _factor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _AppScaledTextScaler &&
        other._factor == _factor &&
        other._platform == _platform;
  }

  @override
  int get hashCode => Object.hash(_platform, _factor);

  @override
  String toString() => '$_platform (app text scale $_factor)';
}

// The interface translations are owned by AppTranslations. Flutter has no
// Tajik Material delegate; use its standard English control strings as fallback.
class _TajikMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _TajikMaterialDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  @override
  bool shouldReload(_TajikMaterialDelegate old) => false;
}

class _TajikCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _TajikCupertinoDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  @override
  bool shouldReload(_TajikCupertinoDelegate old) => false;
}

/// Rolls the Tajikistan (UTC+5) daily edition over at local midnight while the
/// app stays open, and again when the app resumes after the boundary was
/// crossed in the background (an overdue timer fires on resume).
///
/// The timer is owned by this [State] so it is always cancelled in [dispose] —
/// including when the widget tree is torn down at the end of a widget test —
/// unlike a timer held inside an auto-dispose provider, whose disposal is not
/// guaranteed to run when the whole scope is unmounted.
class DailyRolloverScheduler extends ConsumerStatefulWidget {
  final Widget child;

  const DailyRolloverScheduler({super.key, required this.child});

  @override
  ConsumerState<DailyRolloverScheduler> createState() =>
      _DailyRolloverSchedulerState();
}

class _DailyRolloverSchedulerState
    extends ConsumerState<DailyRolloverScheduler> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextRollover();
  }

  void _scheduleNextRollover() {
    _timer?.cancel();
    final now = ref.read(nowProvider).call();
    final today = tajikistanDate(now);
    final nextMidnightUtc = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).add(const Duration(days: 1)).subtract(tajikistanUtcOffset);
    var until = nextMidnightUtc.difference(now.toUtc());
    if (until.isNegative) until = Duration.zero;
    _timer = Timer(until, () {
      if (!mounted) return;
      ref.invalidate(dailyDateProvider);
      _scheduleNextRollover();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
