import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({
    super.key,
    required this.child,
  });

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/proverb')) return 1;
    if (location == '/categories') return 2;
    if (location == '/favorites') return 3;
    if (location == '/settings') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getSelectedIndex(context);
    final displayLang = ref.watch(displayLanguageProvider);

    final labels = [
      AppTranslations.get('nav_home', displayLang),
      AppTranslations.get('nav_proverbs', displayLang),
      AppTranslations.get('nav_categories', displayLang),
      AppTranslations.get('nav_favorites', displayLang),
      AppTranslations.get('nav_settings', displayLang),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/proverbs');
              break;
            case 2:
              context.go('/categories');
              break;
            case 3:
              context.go('/favorites');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: labels[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.format_quote_outlined),
            selectedIcon: const Icon(Icons.format_quote),
            label: labels[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: labels[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: labels[3],
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: labels[4],
          ),
        ],
      ),
    );
  }
}
