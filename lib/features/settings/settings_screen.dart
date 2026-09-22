import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../literature/data/reader_preferences_provider.dart';

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
    final readerPrefs = ref.watch(readerPreferencesProvider);
    final readerNotifier = ref.read(readerPreferencesProvider.notifier);
    final appTextScale = ref.watch(appTextScaleProvider);

    String tr(String key) => AppTranslations.get(key, language);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          tr('settings_title'),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: tr('app_name').toUpperCase(),
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
                  // --- Section 1: Appearance ---
                  _SectionLabel(title: tr('settings_display')),
                  Text(
                    tr('settings_theme_mode'),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ThemeModeRow(
                    title: tr('settings_theme_system'),
                    selected: themeMode == ThemeMode.system,
                    icon: Icons.brightness_auto_outlined,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                  _ThemeModeRow(
                    title: tr('settings_theme_light'),
                    selected: themeMode == ThemeMode.light,
                    icon: Icons.light_mode_outlined,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                  _ThemeModeRow(
                    title: tr('settings_theme_dark'),
                    selected: themeMode == ThemeMode.dark,
                    icon: Icons.dark_mode_outlined,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(height: 32),

                  // --- Section 2: Reading Controls ---
                  _SectionLabel(title: tr('settings_reading')),
                  Text(
                    tr('settings_font_size'),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(tr('settings_font_size_small')),
                        selected: appTextScale == AppTextScaleNotifier.minimum,
                        onSelected: (_) => ref
                            .read(appTextScaleProvider.notifier)
                            .setScale(AppTextScaleNotifier.minimum),
                      ),
                      ChoiceChip(
                        label: Text(tr('settings_font_size_default')),
                        selected:
                            appTextScale == AppTextScaleNotifier.defaultScale,
                        onSelected: (_) => ref
                            .read(appTextScaleProvider.notifier)
                            .setScale(AppTextScaleNotifier.defaultScale),
                      ),
                      ChoiceChip(
                        label: Text(tr('settings_font_size_xlarge')),
                        selected: appTextScale == AppTextScaleNotifier.maximum,
                        onSelected: (_) => ref
                            .read(appTextScaleProvider.notifier)
                            .setScale(AppTextScaleNotifier.maximum),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  QalamSettingRow(
                    title: tr('settings_poem_font_size'),
                    subtitle: isPersian
                        ? '${AppTranslations.formatDigits('${(100 + readerPrefs.fontSizeDelta * 5).round()}', language)}٪'
                        : '${(100 + readerPrefs.fontSizeDelta * 5).round()}%',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: isPersian ? 'کاهش اندازه' : 'Хурд кардан',
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 22,
                          ),
                          onPressed:
                              readerPrefs.fontSizeDelta >
                                  ReaderPreferencesNotifier.minDelta
                              ? () => readerNotifier.decreaseFontSize()
                              : null,
                        ),
                        IconButton(
                          tooltip: isPersian
                              ? 'اندازه پیش‌فرض'
                              : 'Андозаи аввала',
                          icon: const Icon(Icons.restart_alt, size: 20),
                          onPressed: readerPrefs.fontSizeDelta != 0.0
                              ? () => readerNotifier.resetFontSize()
                              : null,
                        ),
                        IconButton(
                          tooltip: isPersian ? 'افزایش اندازه' : 'Калон кардан',
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          onPressed:
                              readerPrefs.fontSizeDelta <
                                  ReaderPreferencesNotifier.maxDelta
                              ? () => readerNotifier.increaseFontSize()
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('settings_line_spacing'),
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(tr('settings_line_spacing_compact')),
                        selected: readerPrefs.lineHeightMultiplier <= 1.45,
                        onSelected: (_) =>
                            readerNotifier.setLineHeightMultiplier(1.4),
                      ),
                      ChoiceChip(
                        label: Text(tr('settings_line_spacing_normal')),
                        selected:
                            readerPrefs.lineHeightMultiplier > 1.45 &&
                            readerPrefs.lineHeightMultiplier < 1.75,
                        onSelected: (_) =>
                            readerNotifier.setLineHeightMultiplier(1.6),
                      ),
                      ChoiceChip(
                        label: Text(tr('settings_line_spacing_relaxed')),
                        selected: readerPrefs.lineHeightMultiplier >= 1.75,
                        onSelected: (_) =>
                            readerNotifier.setLineHeightMultiplier(1.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    tr('settings_reader_mode'),
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(tr('settings_reader_mode_standard')),
                        selected: readerPrefs.defaultReaderMode == 'standard',
                        onSelected: (_) =>
                            readerNotifier.setDefaultReaderMode('standard'),
                      ),
                      ChoiceChip(
                        label: Text(tr('settings_reader_mode_parallel')),
                        selected: readerPrefs.defaultReaderMode == 'parallel',
                        onSelected: (_) =>
                            readerNotifier.setDefaultReaderMode('parallel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- Section 3: Language ---
                  _SectionLabel(title: tr('settings_language')),
                  _LanguageRow(
                    title: 'Тоҷикӣ',
                    subtitle: tr('settings_script_cyrillic'),
                    selected: language == DisplayLanguage.tajik,
                    direction: TextDirection.ltr,
                    onTap: () => ref
                        .read(displayLanguageProvider.notifier)
                        .setLanguage(DisplayLanguage.tajik),
                  ),
                  _LanguageRow(
                    title: 'فارسی',
                    subtitle: tr('settings_script_persian'),
                    selected: isPersian,
                    direction: TextDirection.rtl,
                    onTap: () => ref
                        .read(displayLanguageProvider.notifier)
                        .setLanguage(DisplayLanguage.persian),
                  ),
                  const SizedBox(height: 32),

                  // --- Section 4: Data & History ---
                  _SectionLabel(title: tr('settings_data')),
                  QalamSettingRow(
                    title: tr('settings_clear_recent'),
                    subtitle: tr('settings_clear_recent_desc'),
                    trailing: const Icon(Icons.delete_outline, size: 20),
                    onTap: () => _confirmClearActivity(context, ref, language),
                  ),
                  QalamSettingRow(
                    title: tr('settings_show_guide'),
                    subtitle: tr('settings_show_guide_hint'),
                    trailing: const Icon(Icons.play_arrow_outlined, size: 20),
                    onTap: () {
                      ref.read(onboardingCompleteProvider.notifier).reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isPersian
                                ? 'راهنمای برنامه در بازگشت به صفحهٔ اصلی نمایش داده می‌شود.'
                                : 'Дастурамал ҳангоми бозгашт ба саҳифаи аввал намоиш дода мешавад.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- Section 5: Information & Legal ---
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
                      [AppTranslations.formatNumber(count, language)],
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
                    title: tr('settings_privacy'),
                    trailing: const Icon(Icons.arrow_forward, size: 20),
                    onTap: () => _showInformation(
                      context,
                      language,
                      title: tr('settings_privacy_title'),
                      paragraphs: [tr('settings_privacy_text')],
                    ),
                  ),
                  QalamSettingRow(
                    title: tr('settings_licenses'),
                    trailing: const Icon(Icons.arrow_forward, size: 20),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: tr('app_name'),
                      applicationVersion: '2.0.0',
                      applicationLegalese: tr('settings_year'),
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

  void _confirmClearActivity(
    BuildContext context,
    WidgetRef ref,
    DisplayLanguage language,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppTranslations.get('recent_clear', language),
          style: QalamTypography.sectionTitle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        content: Text(
          AppTranslations.get('recent_clear_confirm', language),
          style: QalamTypography.body(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppTranslations.get('dialog_cancel', language)),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(recentActivityProvider.notifier).clearAll();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppTranslations.get(
                        'settings_clear_recent_success',
                        language,
                      ),
                    ),
                  ),
                );
              }
            },
            child: Text(AppTranslations.get('dialog_yes', language)),
          ),
        ],
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

class _ThemeModeRow extends StatelessWidget {
  final String title;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  const _ThemeModeRow({
    required this.title,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: QalamTypography.body(
                      color: selected ? colors.primary : colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 22,
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
