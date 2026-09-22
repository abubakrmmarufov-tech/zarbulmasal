import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

import 'onboarding_overlay.dart';

final onboardingHomeKey = GlobalKey(debugLabel: 'onboarding-home');
final onboardingExploreKey = GlobalKey(debugLabel: 'onboarding-explore');
final onboardingLearnKey = GlobalKey(debugLabel: 'onboarding-learn');
final onboardingSavedKey = GlobalKey(debugLabel: 'onboarding-saved');

class AppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  bool _showOnboarding = false;

  Future<void> _dismissOnboarding() async {
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final done = ref.read(onboardingCompleteProvider);
      if (done == false) {
        setState(() => _showOnboarding = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;

    ref.listen<bool?>(onboardingCompleteProvider, (prev, next) {
      if (next == false && prev == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showOnboarding = true);
        });
      } else if (prev == true && next == false) {
        widget.navigationShell.goBranch(0, initialLocation: true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showOnboarding = true);
        });
      }
    });

    void goBranch(int index) {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }

    final navKeys = <int, GlobalKey>{
      0: onboardingHomeKey,
      1: onboardingExploreKey,
      2: onboardingLearnKey,
      3: onboardingSavedKey,
    };

    return PopScope(
      canPop: !_showOnboarding,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showOnboarding) _dismissOnboarding();
      },
      child: Stack(
        children: [
          Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNavItem(
                        context,
                        key: navKeys[0],
                        index: 0,
                        currentIndex: widget.navigationShell.currentIndex,
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                        label: AppTranslations.get('nav_home', lang),
                        onTap: () => goBranch(0),
                        colors: colors,
                      ),
                      _buildNavItem(
                        context,
                        key: navKeys[1],
                        index: 1,
                        currentIndex: widget.navigationShell.currentIndex,
                        icon: Icons.explore_outlined,
                        selectedIcon: Icons.explore,
                        label: AppTranslations.get('nav_explore', lang),
                        onTap: () => goBranch(1),
                        colors: colors,
                      ),
                      _buildNavItem(
                        context,
                        key: navKeys[2],
                        index: 2,
                        currentIndex: widget.navigationShell.currentIndex,
                        icon: Icons.school_outlined,
                        selectedIcon: Icons.school,
                        label: AppTranslations.get('nav_learn', lang),
                        onTap: () => goBranch(2),
                        colors: colors,
                      ),
                      _buildNavItem(
                        context,
                        key: navKeys[3],
                        index: 3,
                        currentIndex: widget.navigationShell.currentIndex,
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
          ),
          if (_showOnboarding)
            OnboardingOverlay(
              language: lang,
              steps: [
                OnboardingStep(
                  targetKey: onboardingHomeKey,
                  title: AppTranslations.get('onboarding_home_title', lang),
                  description: AppTranslations.get(
                    'onboarding_home_description',
                    lang,
                  ),
                  nextLabel: AppTranslations.get('onboarding_next', lang),
                  skipLabel: AppTranslations.get('onboarding_skip', lang),
                  finishLabel: AppTranslations.get('onboarding_finish', lang),
                ),
                OnboardingStep(
                  targetKey: onboardingExploreKey,
                  title: AppTranslations.get('onboarding_explore_title', lang),
                  description: AppTranslations.get(
                    'onboarding_explore_description',
                    lang,
                  ),
                  nextLabel: AppTranslations.get('onboarding_next', lang),
                  skipLabel: AppTranslations.get('onboarding_skip', lang),
                  finishLabel: AppTranslations.get('onboarding_finish', lang),
                ),
                OnboardingStep(
                  targetKey: onboardingLearnKey,
                  title: AppTranslations.get('onboarding_learn_title', lang),
                  description: AppTranslations.get(
                    'onboarding_learn_description',
                    lang,
                  ),
                  nextLabel: AppTranslations.get('onboarding_next', lang),
                  skipLabel: AppTranslations.get('onboarding_skip', lang),
                  finishLabel: AppTranslations.get('onboarding_finish', lang),
                ),
                OnboardingStep(
                  targetKey: onboardingSavedKey,
                  title: AppTranslations.get('onboarding_saved_title', lang),
                  description: AppTranslations.get(
                    'onboarding_saved_description',
                    lang,
                  ),
                  nextLabel: AppTranslations.get('onboarding_next', lang),
                  skipLabel: AppTranslations.get('onboarding_skip', lang),
                  finishLabel: AppTranslations.get('onboarding_finish', lang),
                ),
              ],
              onComplete: _dismissOnboarding,
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    Key? key,
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
            key: key,
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
