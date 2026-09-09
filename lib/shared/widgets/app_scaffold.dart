import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';
import 'onboarding_overlay.dart';

/// GlobalKeys for onboarding coach marks. Exposed so the overlay can locate
/// each navigation target on screen.
final onboardingSearchKey = GlobalKey(debugLabel: 'onboarding-search');
final onboardingFavoritesKey = GlobalKey(debugLabel: 'onboarding-favorites');
final onboardingSettingsKey = GlobalKey(debugLabel: 'onboarding-settings');
final onboardingHomeKey = GlobalKey(debugLabel: 'onboarding-home');

class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

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
    // Delay so that the frame renders before we read widget positions.
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
    final path = GoRouterState.of(context).uri.path;
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;

    // Listen for onboarding reset from Settings
    ref.listen<bool?>(onboardingCompleteProvider, (prev, next) {
      if (next == false && prev != false) {
        // Navigate home first so the coach marks can see the nav bar
        context.go('/');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showOnboarding = true);
        });
      }
    });

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

    // Assign GlobalKeys to specific nav items for onboarding targeting
    final navKeys = <int, GlobalKey>{
      0: onboardingHomeKey,
      1: onboardingSearchKey, // Proverbs tab (has search)
      3: onboardingFavoritesKey, // Favorites tab
      4: onboardingSettingsKey, // Settings tab
    };

    final selected = routes.indexOf(path);

    return PopScope(
      canPop: !_showOnboarding,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showOnboarding) _dismissOnboarding();
      },
      child: Stack(
        children: [
          Scaffold(
            body: widget.child,
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
                      for (var i = 0; i < routes.length; i++)
                        Expanded(
                          key: navKeys[i],
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
          ),

          // Coach marks overlay
          if (_showOnboarding)
            OnboardingOverlay(
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
                  targetKey: onboardingSearchKey,
                  title: AppTranslations.get('onboarding_search_title', lang),
                  description: AppTranslations.get(
                    'onboarding_search_description',
                    lang,
                  ),
                  nextLabel: AppTranslations.get('onboarding_next', lang),
                  skipLabel: AppTranslations.get('onboarding_skip', lang),
                  finishLabel: AppTranslations.get('onboarding_finish', lang),
                ),
                OnboardingStep(
                  targetKey: onboardingFavoritesKey,
                  title: AppTranslations.get(
                    'onboarding_favorites_title',
                    lang,
                  ),
                  description: AppTranslations.get(
                    'onboarding_favorites_description',
                    lang,
                  ),
                  nextLabel: AppTranslations.get('onboarding_next', lang),
                  skipLabel: AppTranslations.get('onboarding_skip', lang),
                  finishLabel: AppTranslations.get('onboarding_finish', lang),
                ),
                OnboardingStep(
                  targetKey: onboardingSettingsKey,
                  title: AppTranslations.get('onboarding_settings_title', lang),
                  description: AppTranslations.get(
                    'onboarding_settings_description',
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
}
