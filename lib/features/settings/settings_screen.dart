import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
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

    return Scaffold(
      body: Column(
        children: [
          const CulturalHeader(
            title: 'Танзимот',
            subtitle: 'Танзимоти барнома',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Display section
                Text(
                  'Намоиш',
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
                        title: const Text('Режими торик'),
                        subtitle: Text(
                          themeMode == ThemeMode.dark ? 'Фаъол' : 'Гайрифаъол',
                        ),
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (_) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                          activeTrackColor: AppColors.accentGold.withValues(alpha: 0.5),
                          activeThumbColor: AppColors.accentGold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
                        title: const Text('Забон'),
                        subtitle: const Text('Тоҷикӣ / Форсӣ'),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Интихоби забон дар версияи оянда!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
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

                // Info section
                Text(
                  'Маълумот',
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
                        title: const Text('Дар бораи барнома'),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: AppConstants.appName,
                            applicationVersion: '1.0.0',
                            applicationLegalese: '2026 Зарбулмасал',
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                'Зарбулмасал — барнома барои омӯзиш, фаҳмиш ва '
                                'нигоҳдории мақолҳои тоҷикӣ.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          );
                        },
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
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
                        title: const Text('Мақолҳо'),
                        subtitle: Text('${ref.watch(proverbsProvider).length} мақол'),
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

                // Source section
                Text(
                  'Дар бораи сарчашма',
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
                            'Сарчашмаи мақолҳо',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Мақолҳои ин барнома бояд аз сарчашмаҳои боэътимоди тоҷикӣ, '
                        'аз китобҳои зарбулмасал, фолклори тоҷик ё захираҳои фарҳангии '
                        'тоҷикӣ гирифта шаванд.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Агар шумо сарчашмаи дурусти тоҷикиро медонед, лутфан '
                        'моҳиматро хабар диҳед.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Proverbs should come from verified Tajik cultural sources such as '
                          'Tajik proverb books, folklore collections, or reliable cultural resources. '
                          'If you know a verified source, please contribute.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Версия 1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Мақолҳои тоҷикӣ — мероси фарҳангӣ',
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
}
