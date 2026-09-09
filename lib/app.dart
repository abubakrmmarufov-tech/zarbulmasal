import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'shared/providers/app_providers.dart';
import 'shared/widgets/splash_screen.dart';

class ZarbulmasalApp extends ConsumerWidget {
  const ZarbulmasalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final displayLang = ref.watch(displayLanguageProvider);

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
        return Directionality(
          textDirection: displayLang == DisplayLanguage.persian
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SplashScreen(child: child ?? const SizedBox.shrink()),
            ),
          ),
        );
      },
    );
  }
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
