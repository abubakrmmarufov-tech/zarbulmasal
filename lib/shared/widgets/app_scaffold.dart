import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;
    const routes = ['/', '/proverbs', '/categories', '/favorites', '/settings'];
    const keys = [
      'nav_home',
      'nav_proverbs',
      'nav_categories',
      'nav_favorites',
      'nav_settings',
    ];
    const icons = [
      Icons.home_outlined,
      Icons.menu_book_outlined,
      Icons.format_list_bulleted,
      Icons.bookmark_outline,
      Icons.tune,
    ];
    final selected = routes.indexOf(path);
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < routes.length; i++)
                  Expanded(
                    child: Semantics(
                      selected: selected == i,
                      button: true,
                      label: AppTranslations.get(keys[i], lang),
                      child: Tooltip(
                        excludeFromSemantics: true,
                        message: AppTranslations.get(keys[i], lang),
                        child: InkWell(
                          onTap: () => context.go(routes[i]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 9,
                              horizontal: 2,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 2,
                                  width: 18,
                                  color: selected == i
                                      ? colors.primary
                                      : Colors.transparent,
                                ),
                                const SizedBox(height: 7),
                                ExcludeSemantics(
                                  child: Icon(
                                    icons[i],
                                    size: 22,
                                    color: selected == i
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ExcludeSemantics(
                                  child: Text(
                                    AppTranslations.get(keys[i], lang),
                                    textAlign: TextAlign.center,
                                    style: QalamTypography.navLabel(
                                      color: selected == i
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
