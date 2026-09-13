import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/proverbs/proverbs_list_screen.dart';
import '../features/proverbs/proverb_detail_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/levels/levels_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/flashcards/flashcards_screen.dart';
import '../features/daily/daily_proverb_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/literature/presentation/presentation.dart';
import '../features/literature/poets_list_screen.dart' as legacy_poets;
import '../features/literature/poems_list_screen.dart' as legacy_poems;
import '../features/literature/poet_detail_screen.dart' as legacy_poet_detail;
import '../features/literature/poem_detail_screen.dart' as legacy_poem_detail;
import '../shared/widgets/app_scaffold.dart';
import '../core/design_system/design_system.dart';
import '../core/l10n/app_translations.dart';
import '../shared/providers/app_providers.dart';

Widget buildRouteErrorPage(BuildContext context, GoRouterState state) =>
    const ZarbulmasalRouteErrorPage();

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: buildRouteErrorPage,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/proverbs',
          builder: (context, state) => const ProverbsListScreen(),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/poets',
          builder: (context, state) => const legacy_poets.PoetsListScreen(),
        ),
        GoRoute(
          path: '/poems',
          builder: (context, state) => const legacy_poems.PoemsListScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/proverb/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProverbDetailScreen(proverbId: id);
      },
    ),
    GoRoute(path: '/levels', builder: (context, state) => const LevelsScreen()),
    GoRoute(path: '/quiz', builder: (context, state) => const QuizScreen()),
    GoRoute(
      path: '/flashcards',
      builder: (context, state) => const FlashcardsScreen(),
    ),
    GoRoute(
      path: '/daily',
      builder: (context, state) => const DailyProverbScreen(),
    ),
    // Literature Feature routes
    GoRoute(
      path: '/literature',
      builder: (context, state) => const LiteratureHubScreen(),
    ),
    GoRoute(
      path: '/literature/poets',
      builder: (context, state) => const PoetsListScreen(),
    ),
    GoRoute(
      path: '/literature/poet/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PoetDetailScreen(poetId: id);
      },
    ),
    GoRoute(
      path: '/poet/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return legacy_poet_detail.PoetDetailScreen(poetId: id);
      },
    ),
    GoRoute(
      path: '/literature/works',
      builder: (context, state) => const WorksListScreen(),
    ),
    GoRoute(
      path: '/literature/work/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PoemReaderScreen(workId: id);
      },
    ),
    GoRoute(
      path: '/poem/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return legacy_poem_detail.PoemDetailScreen(poemId: id);
      },
    ),
    GoRoute(
      path: '/literature/school',
      builder: (context, state) => const SchoolCanonScreen(),
    ),
    GoRoute(
      path: '/literature/oral',
      builder: (context, state) => const OralHeritageScreen(),
    ),
    GoRoute(
      path: '/literature/search',
      builder: (context, state) => const LiteratureSearchScreen(),
    ),
  ],
);

/// Polished error page shown when a route is not found or navigation fails.
class ZarbulmasalRouteErrorPage extends ConsumerWidget {
  const ZarbulmasalRouteErrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final language = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, language);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined, size: 56, color: colors.primary),
                const SizedBox(height: 24),
                Text(
                  tr('route_error_title'),
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('route_error_description'),
                  textAlign: TextAlign.center,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined, size: 20),
                  label: Text(tr('btn_back_home')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
