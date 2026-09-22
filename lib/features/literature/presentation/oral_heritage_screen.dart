import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../history/data/history_providers.dart';
import '../../history/domain/history_entry.dart';
import '../data/literature_providers.dart';
import '../domain/oral_heritage_entry.dart';

/// A screen showcasing authenticated oral heritage: proverbs, folklore,
/// riddles, and folk quatrains.
class OralHeritageScreen extends ConsumerStatefulWidget {
  const OralHeritageScreen({super.key});

  @override
  ConsumerState<OralHeritageScreen> createState() => _OralHeritageScreenState();
}

class _OralHeritageScreenState extends ConsumerState<OralHeritageScreen> {
  OralHeritageType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final oralAsync = ref.watch(oralHeritageProvider);
    final historyEntries =
        ref.watch(historyEntriesProvider).valueOrNull ?? const <HistoryEntry>[];
    final textbookOral = historyEntries
        .where((entry) => entry.kind == HistoryEntryKind.oral)
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top back button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    tooltip: AppTranslations.get('btn_back', lang),
                    icon: const BackButtonIcon(),
                    onPressed: () => qalamBack(context),
                  ),
                ),
              ),
            ),
            // Header
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: AppTranslations.get('lit_oral_eyebrow', lang),
                title: AppTranslations.get('lit_oral_title', lang),
                subtitle: AppTranslations.get('lit_oral_subtitle', lang),
              ),
            ),
            // Type Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 72,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: QalamSpacing.pageH,
                    vertical: 12,
                  ),
                  children: [
                    FilterChip(
                      selected: _selectedType == null,
                      label: Text(
                        AppTranslations.get('lit_oral_filter_all', lang),
                      ),
                      onSelected: (_) => setState(() => _selectedType = null),
                    ),
                    const SizedBox(width: 8),
                    ...OralHeritageType.values.map((type) {
                      final selected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: selected,
                          label: Text(_typeName(type, lang)),
                          onSelected: (_) => setState(
                            () => _selectedType = selected ? null : type,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // Main content
            oralAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: AppTranslations.get('lit_oral_error_title', lang),
                    subtitle: AppTranslations.get('lit_oral_error_sub', lang),
                    action: OutlinedButton(
                      onPressed: () {
                        ref.invalidate(oralHeritageProvider);
                        ref.invalidate(historyEntriesProvider);
                      },
                      child: Text(AppTranslations.get('btn_retry', lang)),
                    ),
                  ),
                ),
              ),
              data: (entries) {
                final filtered = _selectedType == null
                    ? entries
                    : entries.where((e) => e.type == _selectedType).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: AppTranslations.get(
                          'lit_oral_empty_title',
                          lang,
                        ),
                        subtitle: AppTranslations.get(
                          'lit_oral_empty_sub',
                          lang,
                        ),
                      ),
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _OralLogicGuide(lang: lang, isPersian: isPersian),
                    ),
                    if (textbookOral.isNotEmpty) ...[
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = textbookOral[index];
                          return _TextbookOralCard(
                            entry: entry,
                            lang: lang,
                            isPersian: isPersian,
                          );
                        }, childCount: textbookOral.length),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    ],
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = filtered[index];
                        return _OralEntryCard(
                          entry: entry,
                          lang: lang,
                          isPersian: isPersian,
                        );
                      }, childCount: filtered.length),
                    ),
                  ],
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  static String _typeName(OralHeritageType type, DisplayLanguage lang) {
    switch (type) {
      case OralHeritageType.zarbulmasal:
        return AppTranslations.get('lit_oral_type_zarbulmasal', lang);
      case OralHeritageType.maqol:
        return AppTranslations.get('lit_oral_type_maqol', lang);
      case OralHeritageType.chiston:
        return AppTranslations.get('lit_oral_type_chiston', lang);
      case OralHeritageType.dubaytiKhalqi:
        return AppTranslations.get('lit_oral_type_dubaytiKhalqi', lang);
      case OralHeritageType.rubaiKhalqi:
        return AppTranslations.get('lit_oral_type_rubaiKhalqi', lang);
      case OralHeritageType.afsona:
        return AppTranslations.get('lit_oral_type_afsona', lang);
      case OralHeritageType.other:
        return AppTranslations.get('lit_oral_type_other', lang);
    }
  }
}

class _OralLogicGuide extends StatelessWidget {
  final DisplayLanguage lang;
  final bool isPersian;

  const _OralLogicGuide({required this.lang, required this.isPersian});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('lit_oral_guide_eyebrow', lang),
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            AppTranslations.get('lit_oral_guide_body', lang),
            style: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GuidePill(
                label: AppTranslations.get('lit_oral_guide_pill1', lang),
              ),
              _GuidePill(
                label: AppTranslations.get('lit_oral_guide_pill2', lang),
              ),
              _GuidePill(
                label: AppTranslations.get('lit_oral_guide_pill3', lang),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuidePill extends StatelessWidget {
  final String label;

  const _GuidePill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: QalamTypography.meta(color: colors.primary)),
    );
  }
}

class _TextbookOralCard extends StatelessWidget {
  final HistoryEntry entry;
  final DisplayLanguage lang;
  final bool isPersian;

  const _TextbookOralCard({
    required this.entry,
    required this.lang,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final gradeLabel = AppTranslations.translate('lit_grade', lang, [
      AppTranslations.formatDigits(entry.grade, lang),
    ]);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('lit_oral_textbook_eyebrow', lang),
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            (isPersian && entry.titlePersian != null)
                ? entry.titlePersian!
                : entry.title,
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isPersian ? TextAlign.right : TextAlign.left,
            style: QalamTypography.sectionTitle(
              color: colors.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (isPersian && entry.summaryPersian != null)
                ? entry.summaryPersian!
                : entry.summary,
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isPersian ? TextAlign.right : TextAlign.left,
            style: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${entry.sourceSection} · $gradeLabel',
            style: QalamTypography.meta(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _OralEntryCard extends StatelessWidget {
  final OralHeritageEntry entry;
  final DisplayLanguage lang;
  final bool isPersian;

  const _OralEntryCard({
    required this.entry,
    required this.lang,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final displayText =
        (isPersian &&
            entry.textPersian != null &&
            entry.textPersian!.isNotEmpty)
        ? entry.textPersian!
        : entry.text;

    final isRtl = isPersian;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: QalamSpacing.pageH,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: type, region, verification badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _OralHeritageScreenState._typeName(entry.type, lang),
                  style: QalamTypography.meta(
                    color: colors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
              if (entry.region != null && entry.region!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '•  ${entry.region}',
                  style: QalamTypography.meta(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              if (entry.isVerified)
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: QalamColors.forest,
                ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 16),
                tooltip: AppTranslations.get('btn_copy', lang),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: displayText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppTranslations.get('lit_copied_toast', lang),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Folklore Text
          SelectableText(
            displayText,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: QalamTypography.heroProverb(
              color: colors.onSurface,
              fontSize: 20,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          // Citation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.book_outlined,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.citation,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
