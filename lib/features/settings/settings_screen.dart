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
    final displayLang = ref.watch(displayLanguageProvider);

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
                        subtitle: Text(
                          displayLang == DisplayLanguage.persian ? 'Форсӣ' : 'Тоҷикӣ',
                        ),
                        trailing: SegmentedButton<DisplayLanguage>(
                          segments: const [
                            ButtonSegment(
                              value: DisplayLanguage.tajik,
                              label: Text('Тоҷ'),
                            ),
                            ButtonSegment(
                              value: DisplayLanguage.persian,
                              label: Text('Форс'),
                            ),
                          ],
                          selected: {displayLang},
                          onSelectionChanged: (selected) {
                            ref.read(displayLanguageProvider.notifier)
                                .setLanguage(selected.first);
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
                        onTap: () => _showAboutCard(context, theme, colorScheme),
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

                // Contact section
                Text(
                  'Пешниҳодҳо',
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
                            'Тамос',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Агар шумо пешниҳодҳо ё таклифҳо доред, ба мо нависед:',
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
                          'abubakrmmarufov@gmail.com',
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
                        'Мақолҳои ин барнома аз сарчашмаҳои боэътимоди тоҷикӣ, '
                        'аз китобҳои зарбулмасал, фолклори тоҷик ва захираҳои фарҳангии '
                        'тоҷикӣ гирифта шудаанд.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Агар шумо сарчашмаи дурусти тоҷикиро медонед, лутфан '
                        'пешниҳодҳоятонро ба мо фиристед.',
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

  void _showAboutCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text(AppConstants.appName),
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
              'Зарбулмасал — барнома барои омӯзиш, фаҳмиш ва '
              'нигоҳдории мақолҳои тоҷикӣ.',
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
                  Text('Версия 1.0.0', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('2026 Зарбулмасал', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
