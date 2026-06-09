import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/cultural_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final displayLang = ref.watch(displayLanguageProvider);

    return Scaffold(
      body: Column(
        children: [
          CulturalHeader(
            title: AppTranslations.get('settings_title', displayLang),
            subtitle: AppTranslations.get('settings_subtitle', displayLang),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  AppTranslations.get('settings_display', displayLang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    color: colorScheme.surface,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(AppTranslations.get('settings_dark_mode', displayLang)),
                        subtitle: Text(
                          themeMode == ThemeMode.dark
                              ? AppTranslations.get('settings_active', displayLang)
                              : AppTranslations.get('settings_inactive', displayLang),
                        ),
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (_) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                          activeTrackColor: AppColors.accentGold.withValues(alpha: 0.5),
                          activeThumbColor: AppColors.accentGold,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      ),
                      Divider(height: 1, indent: 72, endIndent: 16, color: colorScheme.outline.withValues(alpha: 0.1)),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.language,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(AppTranslations.get('settings_language', displayLang)),
                        subtitle: Text(
                          displayLang == DisplayLanguage.persian ? 'Форсӣ' : 'Тоҷикӣ',
                        ),
                        trailing: SegmentedButton<DisplayLanguage>(
                          segments: [
                            ButtonSegment(
                              value: DisplayLanguage.tajik,
                              label: Text(
                                displayLang == DisplayLanguage.tajik ? 'Тоҷ' : 'Тоҷ',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            ButtonSegment(
                              value: DisplayLanguage.persian,
                              label: Text(
                                displayLang == DisplayLanguage.persian ? 'Форс' : 'Форс',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          selected: {displayLang},
                          onSelectionChanged: (selected) {
                            ref.read(displayLanguageProvider.notifier).setLanguage(selected.first);
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            textStyle: WidgetStatePropertyAll(
                              theme.textTheme.labelSmall,
                            ),
                          ),
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppTranslations.get('settings_info', displayLang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    color: colorScheme.surface,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(AppTranslations.get('settings_about', displayLang)),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onTap: () => _showAboutCard(context, theme, colorScheme, displayLang),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      ),
                      Divider(height: 1, indent: 72, endIndent: 16, color: colorScheme.outline.withValues(alpha: 0.1)),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.format_quote,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(AppTranslations.get('home_proverbs', displayLang)),
                        subtitle: Text(AppTranslations.get(
                          'settings_proverbs_count',
                          displayLang,
                          [ref.watch(proverbsProvider).length.toString()],
                        )),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppTranslations.get('settings_contact', displayLang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    color: colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email_outlined, color: colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslations.get('settings_contact_title', displayLang),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppTranslations.get('settings_contact_text', displayLang),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: SelectableText(
                          'Telegram: @imarufov',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: 'NotoSans',
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppTranslations.get('settings_source', displayLang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    color: colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslations.get('settings_source_title', displayLang),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppTranslations.get('settings_source_text', displayLang),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppTranslations.get('settings_source_text2', displayLang),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppTranslations.get('app_name', displayLang),
                        style: const TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTranslations.get('settings_version', displayLang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTranslations.get('settings_year', displayLang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTranslations.get('settings_tagline', displayLang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutCard(BuildContext context, ThemeData theme, ColorScheme colorScheme, DisplayLanguage displayLang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(AppTranslations.get('app_name', displayLang)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.get('settings_about_text', displayLang),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppTranslations.get('settings_version', displayLang), style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(AppTranslations.get('settings_year', displayLang), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.get('settings_close', displayLang)),
          ),
        ],
      ),
    );
  }
}
