import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final recentActivities = ref.watch(recentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPersian ? 'ذخیره‌شده' : 'Маҳфузшуда',
          style: QalamTypography.sectionTitle(color: colors.onSurface, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Favorites Section
          Text(
            isPersian ? 'نشان‌شده‌ها' : 'Нишоншудаҳо',
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: colors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Icon(
                Icons.bookmark_outline,
                color: colors.primary,
                size: 28,
              ),
              title: Text(
                AppTranslations.get('nav_favorites', lang),
                style: QalamTypography.body(color: colors.onSurface),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/favorites'),
            ),
          ),
          const SizedBox(height: 32),

          // Recent Activity Section
          Text(
            isPersian ? 'فعالیت‌های اخیر' : 'Фаъолиятҳои ахир',
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          if (recentActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPersian
                          ? 'هنوز فعالیتی ندارید'
                          : 'Ҳоло фаъолияте надоред',
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentActivities.map((activity) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: colors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: QalamTypography.body(color: colors.onSurface),
                  ),
                  subtitle: activity.subtitle != null
                      ? Text(
                          activity.subtitle!,
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                          ),
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.push(activity.route),
                ),
              );
            }),
        ],
      ),
    );
  }
}
