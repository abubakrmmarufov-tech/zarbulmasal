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
import '../shared/widgets/app_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
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
      ],
    ),
    GoRoute(
      path: '/proverb/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProverbDetailScreen(proverbId: id);
      },
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelsScreen(),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/flashcards',
      builder: (context, state) => const FlashcardsScreen(),
    ),
    GoRoute(
      path: '/daily',
      builder: (context, state) => const DailyProverbScreen(),
    ),
  ],
);
