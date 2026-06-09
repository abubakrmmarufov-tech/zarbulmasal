import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'shared/providers/app_providers.dart';

class ZarbulmasalApp extends ConsumerWidget {
  const ZarbulmasalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final displayLang = ref.watch(displayLanguageProvider);

    final locale = displayLang == DisplayLanguage.persian
        ? const Locale('fa')
        : const Locale('tg');

    return Localizations.override(
      context: context,
      locale: locale,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
