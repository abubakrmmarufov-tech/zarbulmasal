import 'package:flutter/material.dart';
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
      routerConfig: appRouter,
      builder: (context, child) {
        return SplashScreen(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
