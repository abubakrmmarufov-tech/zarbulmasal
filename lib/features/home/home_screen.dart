import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final daily = ref.watch(dailyProverbProvider);
    final recentActivities = ref.watch(recentActivityProvider);

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
            GestureDetector(
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
                        isPersian
                            ? 'جستجوی شاعر، شعر، تاریخ، ضرب‌المثل...'
                            : 'Ҷустуҷӯи шоир, шеър, таърих, зарбулмасал...',
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
            const SizedBox(height: 24),

            // Continue where you left off
            if (recentActivities.isNotEmpty) ...[
              Text(
                isPersian ? 'ادامه خواندن' : 'Идомаи хондан',
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
                  onTap: () => context.push(recentActivities.first.route),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recentActivities.first.title,
                                style: QalamTypography.body(
                                  color: colors.onPrimaryContainer,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (recentActivities.first.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  recentActivities.first.subtitle!,
                                  style: QalamTypography.meta(
                                    color: colors.onPrimaryContainer.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.play_arrow_rounded,
                          color: colors.onPrimaryContainer,
                          size: 28,
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
              isPersian ? 'کشف فرهنگ تاجیک' : 'Кашфи фарҳанги тоҷик',
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
                    onTap: () => context.push('/literature'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildShortcutCard(
                    context,
                    icon: Icons.timeline,
                    title: isPersian ? 'تاریخ' : 'Таърих',
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
                    onTap: () => context.push('/proverbs'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildShortcutCard(
                    context,
                    icon: Icons.stairs_outlined,
                    title: isPersian ? 'آموزش' : 'Омӯзиш',
                    onTap: () => context.go('/learn'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Today
            if (daily != null) ...[
              Text(
                isPersian ? 'امروز' : 'Имрӯз',
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

  Widget _buildShortcutCard(
    BuildContext context, {
    required IconData icon,
    required String title,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: 12),
              Text(title, style: QalamTypography.body(color: colors.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
