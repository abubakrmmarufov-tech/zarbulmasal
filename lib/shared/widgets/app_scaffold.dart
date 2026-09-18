import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;

    void goBranch(int index) {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return Scaffold(
      body: navigationShell,
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
                _buildNavItem(
                  context,
                  index: 0,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: AppTranslations.get('nav_home', lang),
                  onTap: () => goBranch(0),
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore,
                  label: AppTranslations.get('nav_explore', lang),
                  onTap: () => goBranch(1),
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.school_outlined,
                  selectedIcon: Icons.school,
                  label: AppTranslations.get('nav_learn', lang),
                  onTap: () => goBranch(2),
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.bookmark_outline,
                  selectedIcon: Icons.bookmark,
                  label: AppTranslations.get('nav_saved', lang),
                  onTap: () => goBranch(3),
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    final selected = index == currentIndex;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: Tooltip(
          excludeFromSemantics: true,
          message: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 2,
                      width: 18,
                      color: selected ? colors.primary : Colors.transparent,
                    ),
                    const SizedBox(height: 6),
                    ExcludeSemantics(
                      child: Icon(
                        selected ? selectedIcon : icon,
                        size: 24,
                        color: selected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ExcludeSemantics(
                      child: SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            style: QalamTypography.navLabel(
                              color: selected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
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
        ),
      ),
    );
  }
}
