import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

/// Personal reading preferences and the collection's publication information.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(displayLanguageProvider);
    final isPersian = language == DisplayLanguage.persian;
    final count = ref.watch(proverbsProvider).length;
    String tr(String key) => AppTranslations.get(key, language);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: isPersian ? '۰۵ / ترجیح‌ها' : '05 / ИНТИХОБ',
                title: tr('settings_title'),
                subtitle: tr('settings_subtitle'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                QalamSpacing.pageH,
                24,
                QalamSpacing.pageH,
                48,
              ),
              sliver: SliverList.list(
                children: [
                  _SectionLabel(title: tr('settings_display')),
                  QalamSettingRow(
                    title: tr('settings_dark_mode'),
                    subtitle: tr(
                      themeMode == ThemeMode.dark
                          ? 'settings_active'
                          : 'settings_inactive',
                    ),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) =>
                          ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  const SizedBox(height: 34),
                  _SectionLabel(title: tr('settings_language')),
                  _LanguageRow(
                    title: 'Тоҷикӣ',
                    subtitle: isPersian ? 'خط سیریلیک' : 'Хатти кириллӣ',
                    selected: language == DisplayLanguage.tajik,
                    direction: TextDirection.ltr,
                    onTap: () => ref
                        .read(displayLanguageProvider.notifier)
                        .setLanguage(DisplayLanguage.tajik),
                  ),
                  _LanguageRow(
                    title: 'فارسی',
                    subtitle: isPersian ? 'خط فارسی' : 'Хатти форсӣ',
                    selected: isPersian,
                    direction: TextDirection.rtl,
                    onTap: () => ref
                        .read(displayLanguageProvider.notifier)
                        .setLanguage(DisplayLanguage.persian),
                  ),
                  const SizedBox(height: 36),
                  _SectionLabel(title: tr('settings_info')),
                  QalamSettingRow(
                    title: tr('settings_about'),
                    trailing: const Icon(Icons.arrow_forward, size: 20),
                    onTap: () => _showInformation(
                      context,
                      language,
                      title: tr('app_name'),
                      paragraphs: [
                        tr('settings_about_text'),
                        tr('settings_version'),
                        tr('settings_year'),
                      ],
                    ),
                  ),
                  QalamSettingRow(
                    title: tr('home_proverbs'),
                    subtitle: AppTranslations.get(
                      'settings_proverbs_count',
                      language,
                      ['$count'],
                    ),
                  ),
                  QalamSettingRow(
                    title: tr('settings_source'),
                    trailing: const Icon(Icons.arrow_forward, size: 20),
                    onTap: () => _showInformation(
                      context,
                      language,
                      title: tr('settings_source_title'),
                      paragraphs: [
                        isPersian
                            ? 'این مجموعه شامل ضرب‌المثل‌های سنتی و متن‌های آموزشی معاصر است. یادداشت منبع و وضعیت بررسی در صفحهٔ هر متن نمایش داده می‌شود.'
                            : 'Маҷмӯа мақолҳои анъанавӣ ва матнҳои таълимии муосирро дар бар мегирад. Сарчашма ва ҳолати санҷиш дар саҳифаи ҳар матн нишон дода мешаванд.',
                        tr('settings_source_text2'),
                      ],
                    ),
                  ),
                  QalamSettingRow(
                    title: tr('settings_contact'),
                    subtitle: 'Telegram · @imarufov',
                    trailing: const Icon(Icons.arrow_forward, size: 20),
                    onTap: () => _showInformation(
                      context,
                      language,
                      title: tr('settings_contact_title'),
                      paragraphs: [tr('settings_contact_text')],
                      contact: true,
                    ),
                  ),
                  QalamSettingRow(
                    title: tr('settings_show_guide'),
                    subtitle: tr('settings_show_guide_hint'),
                    trailing: const Icon(Icons.play_arrow_outlined, size: 20),
                    onTap: () =>
                        ref.read(onboardingCompleteProvider.notifier).reset(),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    tr('app_name'),
                    style: QalamTypography.sectionTitle(
                      color: colors.primary,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr('settings_tagline'),
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tr('settings_version'),
                    style: QalamTypography.meta(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInformation(
    BuildContext context,
    DisplayLanguage language, {
    required String title,
    required List<String> paragraphs,
    bool contact = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: Text(
          title,
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 25,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final paragraph in paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  paragraph,
                  style: QalamTypography.body(
                    color: colors.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
            if (contact)
              SelectableText(
                'Telegram: @imarufov',
                textDirection: TextDirection.ltr,
                style: QalamTypography.body(
                  color: colors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppTranslations.get('settings_close', language)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title.toUpperCase(),
      style: QalamTypography.eyebrow(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 11,
      ),
    ),
  );
}

class _LanguageRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final TextDirection direction;
  final VoidCallback onTap;
  const _LanguageRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.direction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textDirection: direction,
                        style: QalamTypography.sectionTitle(
                          color: selected ? colors.primary : colors.onSurface,
                          fontSize: 27,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 24,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
