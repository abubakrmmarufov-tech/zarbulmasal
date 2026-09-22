import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/recent_activity_display_text.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final daily = ref.watch(dailyProverbProvider);
    final recentActivities = ref.watch(recentActivityProvider);
    final recentActivity = recentActivities.firstOrNull;
    final recentActivitySubtitle = recentActivity == null
        ? null
        : RecentActivityDisplayText.subtitle(recentActivity, lang);

    String tr(String key) => AppTranslations.get(key, lang);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(QalamSpacing.radiusXs),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: Text(
                tr('app_name').toUpperCase(),
                style: QalamTypography.eyebrow(color: colors.primary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: tr('nav_settings'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Search Bar
            Semantics(
              button: true,
              excludeSemantics: true,
              label: tr('search_hint_global'),
              onTap: () => context.push('/search'),
              child: GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr('search_hint_global'),
                          style: QalamTypography.body(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Continue where you left off
            if (recentActivity != null) ...[
              Text(
                tr('home_continue_reading'),
                style: QalamTypography.sectionTitle(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: colors.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: InkWell(
                  onTap: () => context.push(recentActivity.route),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _iconForActivity(recentActivity.type),
                          color: colors.onPrimaryContainer,
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                RecentActivityDisplayText.title(
                                  recentActivity,
                                  lang,
                                ),
                                style: QalamTypography.body(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (recentActivitySubtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  recentActivitySubtitle,
                                  style: QalamTypography.meta(
                                    color: colors.onPrimaryContainer.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: colors.onPrimaryContainer,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Explore Tajik Culture
            Text(
              tr('home_explore_culture'),
              style: QalamTypography.sectionTitle(color: colors.onSurface),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildShortcutCard(
                    context,
                    icon: Icons.auto_stories_outlined,
                    title: isPersian ? 'ادبیات' : 'Адабиёт',
                    subtitle: isPersian
                        ? 'شاعران، شعرها و کتاب‌ها'
                        : 'Шоирон, шеърҳо ва китобҳо',
                    onTap: () => context.push('/literature'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildShortcutCard(
                    context,
                    icon: Icons.timeline,
                    title: isPersian ? 'تاریخ' : 'Таърих',
                    subtitle: isPersian
                        ? 'شخصیت‌ها و دوره‌ها'
                        : 'Шахсиятҳо ва давраҳо',
                    onTap: () => context.push('/history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildShortcutCard(
                    context,
                    icon: Icons.menu_book_outlined,
                    title: isPersian ? 'ضرب‌المثل‌ها' : 'Зарбулмасалҳо',
                    subtitle: isPersian
                        ? 'حکمت مردم تاجیک'
                        : 'Ҳикмати халқи тоҷик',
                    onTap: () => context.push('/proverbs'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildShortcutCard(
                    context,
                    icon: Icons.school_outlined,
                    title: isPersian ? 'آموزش' : 'Омӯзиш',
                    subtitle: isPersian
                        ? 'گام به گام بیاموزید'
                        : 'Қадам ба қадам омӯзед',
                    onTap: () => context.go('/learn'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Today
            if (daily != null) ...[
              Text(
                tr('home_today'),
                style: QalamTypography.sectionTitle(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              QalamDailyHero(
                proverb: daily,
                onOpen: () => context.push('/daily'),
              ),
            ],
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  static IconData _iconForActivity(RecentActivityType type) {
    switch (type) {
      case RecentActivityType.proverb:
        return Icons.menu_book_outlined;
      case RecentActivityType.poet:
        return Icons.person_outline;
      case RecentActivityType.work:
        return Icons.auto_stories_outlined;
      case RecentActivityType.history:
        return Icons.timeline;
      case RecentActivityType.level:
        return Icons.stairs_outlined;
    }
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary, size: 26),
              const SizedBox(height: 10),
              Text(
                title,
                style: QalamTypography.body(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: QalamTypography.meta(color: colors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
