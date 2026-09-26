import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'design_system.dart';
import '../l10n/app_translations.dart';
import '../l10n/source_citation.dart';
import '../../data/models/proverb.dart';
import '../../data/models/source_ref.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/bayoz_provider.dart';
import '../../shared/widgets/bayoz_dialogs.dart';
import '../../shared/providers/reading_position_provider.dart';
import '../../shared/providers/reading_script_provider.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/empty_state.dart';

/// A shared, script-aware reading page for the daily and collection routes.
class QalamReadingPage extends ConsumerStatefulWidget {
  final Proverb? proverb;
  final bool daily;
  const QalamReadingPage({
    super.key,
    required this.proverb,
    this.daily = false,
  });

  @override
  ConsumerState<QalamReadingPage> createState() => _QalamReadingPageState();
}

class _QalamReadingPageState extends ConsumerState<QalamReadingPage> {
  @override
  Widget build(BuildContext context) {
    final proverb = widget.proverb;
    final daily = widget.daily;
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final persian = lang == DisplayLanguage.persian;
    final p = proverb;
    // The hero follows the reading script, never the interface language.
    final heroPersian =
        ref.watch(readingScriptProvider) == ReadingScript.persian &&
        (p?.persianText.isNotEmpty ?? false);
    String tr(String key) => AppTranslations.get(key, lang);
    final categories = ref.watch(categoriesProvider);
    final proverbsById = {
      for (final proverb in ref.watch(proverbsProvider)) proverb.id: proverb,
    };
    final variantTexts = p == null
        ? const <String>[]
        : p.variants
              .map((variantId) {
                final variant = proverbsById[variantId];
                return heroPersian
                    ? variant?.persianText
                    : variant?.tajikCyrillic;
              })
              .whereType<String>()
              .toList(growable: false);
    final matches = categories.where((c) => c.id == p?.categoryId);
    final category = matches.isEmpty
        ? tr('detail_unknown')
        : QalamCategoryTile.nameFor(matches.first, lang);
    // Use the shared Tajikistan daily date so hero, reader and the proverb
    // selection always agree regardless of the viewer's local timezone.
    final now = ref.watch(dailyDateProvider);

    if (p != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(recentActivityProvider.notifier)
            .addActivity(
              RecentActivity(
                id: p.id,
                type: RecentActivityType.proverb,
                title: persian
                    ? (p.persianText.isNotEmpty
                          ? p.persianText
                          : p.tajikCyrillic)
                    : p.tajikCyrillic,
                subtitle: AppTranslations.getForIsPersian(
                  persian,
                  'kind_proverb',
                ),
                titleTajik: p.tajikCyrillic,
                titlePersian: p.persianText.isNotEmpty ? p.persianText : null,
                subtitleTajik: 'Зарбулмасал',
                subtitlePersian: 'ضرب‌المثل',
                timestamp: DateTime.now(),
                route: '/proverb/${p.id}',
              ),
            );
        ref
            .read(readingPositionProvider.notifier)
            .open(
              ReadingPosition(
                kind: ReadingKind.proverb,
                id: p.id,
                route: '/proverb/${p.id}',
                titleTajik: p.tajikCyrillic,
                titlePersian: p.persianText.isNotEmpty ? p.persianText : null,
                timestamp: DateTime.now(),
              ),
            );
      });
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: tr('back'),
          onPressed: () => qalamBack(context),
          icon: const BackButtonIcon(),
        ),
        title: Text(daily ? tr('daily_title') : tr('home_edition')),
        actions: [
          if (p != null) ...[
            IconButton(
              tooltip: tr('copy_proverb'),
              icon: const Icon(Icons.copy_outlined, size: 21),
              onPressed: () async {
                try {
                  await Clipboard.setData(
                    ClipboardData(
                      text:
                          '${p.tajikCyrillic}\n${p.persianText}\n\n${p.meaningTj}',
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(tr('copied'))));
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('copy_unavailable'))),
                    );
                  }
                }
              },
            ),
            IconButton(
              tooltip: tr('bayoz_add_to'),
              icon: const Icon(Icons.library_add_outlined, size: 21),
              onPressed: () => BayozPickerSheet.show(
                context,
                BayozItem(BayozItemKind.proverb, p.id),
              ),
            ),
            QalamBookmark(proverbId: p.id),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: p == null
          ? SingleChildScrollView(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: tr(daily ? 'daily_not_available' : 'detail_loading'),
                action: OutlinedButton(
                  onPressed: () => qalamBack(context),
                  child: Text(tr('btn_return')),
                ),
              ),
            )
          : SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  daily
                                      ? AppTranslations.formatDigits(
                                          '${now.day} ${AppTranslations.getMonthName(now.month, lang)} / ${now.year}',
                                          lang,
                                        )
                                      : category,
                                  style: QalamTypography.eyebrow(
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppTranslations.formatDigits(
                                  p.id
                                      .replaceAll(RegExp(r'[^0-9]'), '')
                                      .padLeft(3, '0'),
                                  lang,
                                ),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const Divider(),
                          const SizedBox(height: 32),
                          SelectableText(
                            heroPersian ? p.persianText : p.tajikCyrillic,
                            semanticsLabel: heroPersian
                                ? p.persianText
                                : p.tajikCyrillic,
                            textDirection: heroPersian
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: QalamTypography.heroProverb(
                              color: colors.onSurface,
                              fontSize:
                                  27, // Optimized for mobile compatibility
                              height: 1.42,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              width: 32,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SelectableText(
                            heroPersian ? p.tajikCyrillic : p.persianText,
                            semanticsLabel: heroPersian
                                ? p.tajikCyrillic
                                : p.persianText,
                            textDirection: heroPersian
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            style: QalamTypography.heroProverb(
                              color: colors.onSurfaceVariant,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Text(
                                category,
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                AppTranslations.get('badges_level', lang, [
                                  p.level,
                                ]),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                tr(
                                  p.type == ProverbType.traditional
                                      ? 'badges_traditional'
                                      : 'badges_modern',
                                ),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (p.meaningTj.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: AppTranslations.formatDigits('01', lang),
                        title: tr('detail_meaning'),
                        text: p.meaningTj,
                        emphasis: true,
                        provenance: _provenance(p.meaningSource, lang),
                        scriptBadge: persian
                            ? tr('reading_tajik_explanation')
                            : null,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  if (p.simpleExplanationTj.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: AppTranslations.formatDigits('02', lang),
                        title: tr('detail_simple_explanation'),
                        text: p.simpleExplanationTj,
                        provenance: tr('proverb_editorial'),
                        scriptBadge: persian
                            ? tr('reading_tajik_explanation')
                            : null,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  if (p.exampleSentenceTj.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: AppTranslations.formatDigits('03', lang),
                        title: tr('detail_example'),
                        text: _exampleText(p),
                        provenance: _provenance(p.exampleSource, lang),
                        scriptBadge: persian
                            ? tr('reading_tajik_explanation')
                            : null,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  if (variantTexts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: AppTranslations.formatDigits('04', lang),
                        title: AppTranslations.getForIsPersian(
                          persian,
                          'proverb_other_forms',
                        ),
                        text: variantTexts.join('\n\n'),
                        textDirection: heroPersian
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                  // The books that print the proverb, each with its printed
                  // form and page; or a plain statement that none was found.
                  if (p.sources.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: AppTranslations.formatDigits(
                          variantTexts.isNotEmpty ? '05' : '04',
                          lang,
                        ),
                        title: tr('proverb_sources'),
                        text: _sourcesText(p, lang),
                        textDirection: TextDirection.ltr,
                      ),
                    )
                  else if (p.sourceStatus == SourceStatus.needsReview ||
                      p.sourceNote.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Text(
                          p.sourceStatus == SourceStatus.needsReview
                              ? tr('proverb_no_printed_source')
                              : AppTranslations.get('lit_source_line', lang, [
                                  p.sourceNote,
                                ]),
                          textDirection:
                              persian &&
                                  p.sourceStatus == SourceStatus.needsReview
                              ? TextDirection.rtl
                              : _detectDirection(p.sourceNote),
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
                      child: _ProverbEndOfText(
                        proverb: p,
                        persianTitles: heroPersian,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  static String _provenance(SourceRef? source, DisplayLanguage lang) =>
      source == null
      ? AppTranslations.get('proverb_editorial', lang)
      : AppTranslations.get('proverb_printed_from', lang, [
          formatSourceCitation(source, lang),
        ]);

  /// The example, followed by its printed signature when it has one.
  static String _exampleText(Proverb p) {
    final attribution = p.exampleAttribution?.trim() ?? '';
    return attribution.isEmpty
        ? p.exampleSentenceTj
        : '${p.exampleSentenceTj}\n— $attribution';
  }

  /// One paragraph per book: the saying as that page prints it, then where.
  static String _sourcesText(Proverb p, DisplayLanguage lang) => p.sources
      .map((source) {
        final printed = source.printedText?.trim() ?? '';
        final citation = formatSourceCitation(source, lang);
        if (printed.isEmpty) return citation;
        // Some books print the saying in quotes already: «…» – мегӯяд ….
        final quoted = printed.startsWith('«') ? printed : '«$printed»';
        return '$quoted\n$citation';
      })
      .join('\n\n');

  static TextDirection _detectDirection(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

class _ReadingSection extends StatelessWidget {
  final String number;
  final String title;
  final String text;
  final bool emphasis;
  final String? scriptBadge;
  final TextDirection? textDirection;

  /// Printed (with its citation) or editorial; null for sections that are
  /// neither, such as the list of sources itself.
  final String? provenance;

  const _ReadingSection({
    required this.number,
    required this.title,
    required this.text,
    this.emphasis = false,
    this.scriptBadge,
    this.textDirection,
    this.provenance,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final direction =
        textDirection ??
        (RegExp(r'[\u0600-\u06FF]').hasMatch(text)
            ? TextDirection.rtl
            : TextDirection.ltr);

    return Container(
      decoration: BoxDecoration(
        color: emphasis
            ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
            : null,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: QalamSpacing.pageH,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A Wrap (rather than a Row) so a long script badge falls onto its
          // own line instead of overflowing the header on narrow widths or
          // under enlarged text; on a single line the title and badge sit at
          // opposite ends, as before.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '$number / $title',
                style: QalamTypography.eyebrow(color: colors.primary),
              ),
              if (scriptBadge != null)
                Text(
                  scriptBadge!,
                  textAlign: TextAlign.end,
                  style: QalamTypography.meta(color: colors.onSurfaceVariant),
                ),
            ],
          ),
          if (provenance != null) ...[
            const SizedBox(height: 6),
            Text(
              provenance!,
              style: QalamTypography.meta(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SelectableText(
            text,
            semanticsLabel: text,
            textDirection: direction,
            style: emphasis
                ? QalamTypography.heroProverb(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  )
                : QalamTypography.body(
                    color: colors.onSurface,
                    fontSize: 16,
                    height: 1.75,
                  ),
          ),
        ],
      ),
    );
  }
}

/// What follows a proverb: previous/next within its theme (in collection
/// order), a few more from the same theme, and the whole theme.
class _ProverbEndOfText extends ConsumerWidget {
  const _ProverbEndOfText({required this.proverb, required this.persianTitles});

  final Proverb proverb;

  /// Titles follow the reading script, like the hero.
  final bool persianTitles;

  static const int _maxSameTheme = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);
    final theme = ref
        .watch(proverbsProvider)
        .where((candidate) => candidate.categoryId == proverb.categoryId)
        .toList(growable: false);
    final index = theme.indexWhere((candidate) => candidate.id == proverb.id);
    if (index < 0) return const SizedBox.shrink();
    final categories = ref
        .watch(categoriesProvider)
        .where((category) => category.id == proverb.categoryId);
    final themeName = categories.isEmpty
        ? null
        : QalamCategoryTile.nameFor(categories.first, lang);

    String title(Proverb target) =>
        persianTitles && target.persianText.isNotEmpty
        ? target.persianText
        : target.tajikCyrillic;
    TextDirection direction(Proverb target) =>
        persianTitles && target.persianText.isNotEmpty
        ? TextDirection.rtl
        : TextDirection.ltr;
    QalamNeighbour? neighbour(int at, String labelKey) {
      if (at < 0 || at >= theme.length) return null;
      final target = theme[at];
      return QalamNeighbour(
        label: tr(labelKey),
        title: title(target),
        titleDirection: direction(target),
        onTap: () => context.push('/proverb/${target.id}'),
      );
    }

    final more = theme
        .skip(index + 2)
        .take(_maxSameTheme)
        .toList(growable: false);

    return QalamEndOfText(
      heading: tr('end_heading'),
      previous: neighbour(index - 1, 'end_previous'),
      next: neighbour(index + 1, 'end_next'),
      groups: [
        QalamRelatedGroup(
          title: tr('end_same_theme'),
          rows: [
            for (final other in more)
              QalamIndexRow(
                title: title(other),
                onTap: () => context.push('/proverb/${other.id}'),
              ),
            if (themeName != null && theme.length > 1)
              QalamIndexRow(
                title: AppTranslations.get('end_all_in_theme', lang, [
                  themeName,
                ]),
                onTap: () {
                  // Open the theme as a fresh browsing scope, as the theme
                  // covers do.
                  ref.read(selectedLevelProvider.notifier).state = null;
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(selectedCategoryProvider.notifier).state =
                      proverb.categoryId;
                  context.push('/proverbs');
                },
              ),
          ],
        ),
      ],
    );
  }
}
