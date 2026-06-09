import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_translations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/proverb_card.dart';
import '../../shared/widgets/cultural_header.dart';
import '../../shared/widgets/pamir_silhouette.dart';
import '../../shared/widgets/tajik_pattern_divider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayLang = ref.watch(displayLanguageProvider);
    final dailyProverb = ref.watch(dailyProverbProvider);
    final proverbs = ref.watch(proverbsProvider);
    final recentProverbs = proverbs.take(3).toList();

    final proverbCount = AppTranslations.get(
      'proverb_count_label',
      displayLang,
      [proverbs.length.toString()],
    );

    if (dailyProverb == null) {
      return Scaffold(
        body: Column(
          children: [
            CulturalHeader(
              title: AppTranslations.get('app_name', displayLang),
              subtitle: AppTranslations.get('app_tagline', displayLang),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppTranslations.get('home_no_daily', displayLang),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          CulturalHeader(
            title: AppTranslations.get('app_name', displayLang),
            subtitle: AppTranslations.get('app_tagline', displayLang),
          ),
          PamirSilhouette(
            height: 32,
            darkMode: Theme.of(context).brightness == Brightness.dark,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            AppTranslations.get('home_greeting', displayLang),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              proverbCount,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        AppTranslations.get('home_subtitle', displayLang),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.today, size: 20, color: AppColors.accentGold),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslations.get('home_daily_proverb', displayLang),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ProverbCard(
                      proverb: dailyProverb,
                      onTap: () => context.push('/proverb/${dailyProverb.id}'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TajikPatternDivider(),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        AppTranslations.get('home_quick_actions', displayLang),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.quiz,
                              label: AppTranslations.get('quiz_title', displayLang),
                              description: AppTranslations.get('quiz_desc', displayLang),
                              gradientColors: const [Color(0xFFB91C1C), Color(0xFF9A3412)],
                              onTap: () => context.push('/quiz'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.style,
                              label: AppTranslations.get('flashcards_title', displayLang),
                              description: AppTranslations.get('flashcards_desc', displayLang),
                              gradientColors: const [Color(0xFF166534), Color(0xFF14532D)],
                              onTap: () => context.push('/flashcards'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.leaderboard,
                              label: AppTranslations.get('levels_title', displayLang),
                              description: AppTranslations.get('levels_desc', displayLang),
                              gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)],
                              onTap: () => context.push('/levels'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.auto_stories,
                              label: AppTranslations.get('daily_title', displayLang),
                              description: AppTranslations.get('daily_desc', displayLang),
                              gradientColors: const [Color(0xFFC2410C), Color(0xFF9A3412)],
                              onTap: () => context.push('/daily'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            AppTranslations.get('home_proverbs', displayLang),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.go('/proverbs'),
                            child: Text(AppTranslations.get('btn_see_all', displayLang)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recentProverbs.map(
                      (proverb) => ProverbCard(
                        proverb: proverb,
                        onTap: () => context.push('/proverb/${proverb.id}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withValues(alpha: 0.12),
                gradientColors[1].withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gradientColors[0].withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: gradientColors[0]),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'NotoSerif',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: gradientColors[0],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 12,
                  color: gradientColors[0].withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
