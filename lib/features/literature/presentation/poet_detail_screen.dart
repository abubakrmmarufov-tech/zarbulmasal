import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/recent_activity_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_author.dart';
import '../domain/literary_work.dart';
import '../../history/data/history_providers.dart';
import '../../history/domain/history_domain.dart';
import 'literary_author_display_text.dart';
import 'poet_detail_works.dart';

/// A detailed monograph view for a canonical Tajik author/poet,
/// displaying verified biography, source citations, curriculum links, and works.
class PoetDetailScreen extends ConsumerWidget {
  final String poetId;

  const PoetDetailScreen({super.key, required this.poetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);

    final authorAsync = ref.watch(authorByIdProvider(poetId));
    final worksAsync = ref.watch(worksByAuthorProvider(poetId));
    final canonAsync = ref.watch(schoolCanonByAuthorProvider(poetId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          AppTranslations.get('lit_poet_dossier', lang),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 18,
          ),
        ),
      ),
      body: authorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: AppTranslations.get('lit_poet_error_title', lang),
            subtitle: AppTranslations.get('lit_poet_error_sub', lang),
            action: OutlinedButton(
              onPressed: () => ref.invalidate(authorByIdProvider(poetId)),
              child: Text(AppTranslations.get('btn_retry', lang)),
            ),
          ),
        ),
        data: (poet) {
          if (poet == null) {
            return Center(
              child: EmptyState(
                icon: Icons.person_off_outlined,
                title: AppTranslations.get('lit_poet_not_found_title', lang),
                subtitle: AppTranslations.get('lit_poet_not_found_sub', lang),
                action: OutlinedButton(
                  onPressed: () => qalamBack(context),
                  child: Text(AppTranslations.get('btn_back', lang)),
                ),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(recentActivityProvider.notifier)
                .addActivity(
                  RecentActivity(
                    id: poet.id,
                    type: RecentActivityType.poet,
                    title: LiteraryAuthorDisplayText.name(poet, lang),
                    subtitle: LiteraryAuthorDisplayText.period(poet, lang),
                    titleTajik: poet.canonicalName,
                    titlePersian: poet.canonicalNamePersian,
                    subtitleTajik: poet.literaryPeriod,
                    subtitlePersian: poet.literaryPeriodPersian,
                    timestamp: DateTime.now(),
                    route: '/literature/poet/${poet.id}',
                  ),
                );
          });

          return _PoetDetailContent(
            poet: poet,
            worksAsync: worksAsync,
            canonAsync: canonAsync,
          );
        },
      ),
    );
  }
}

class _PoetDetailContent extends ConsumerStatefulWidget {
  final LiteraryAuthor poet;
  final AsyncValue<List<LiteraryWork>> worksAsync;
  final AsyncValue<List<dynamic>> canonAsync;

  const _PoetDetailContent({
    required this.poet,
    required this.worksAsync,
    required this.canonAsync,
  });

  @override
  ConsumerState<_PoetDetailContent> createState() => _PoetDetailContentState();
}

class _PoetDetailContentState extends ConsumerState<_PoetDetailContent> {
  @override
  Widget build(BuildContext context) {
    final poet = widget.poet;
    final worksAsync = widget.worksAsync;
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final period = LiteraryAuthorDisplayText.period(poet, lang);
    final periodHeading = period.split('|').first.trim();
    final birthPlace = LiteraryAuthorDisplayText.birthPlace(poet, lang);
    final lifespan = LiteraryAuthorDisplayText.lifespan(poet, lang);
    final officialTitles = LiteraryAuthorDisplayText.officialTitles(poet, lang);

    final name = LiteraryAuthorDisplayText.name(poet, lang);
    final altName = isPersian ? null : poet.canonicalNamePersian;

    final showPersianBiography = isPersian && poet.hasAuditablePersianBiography;
    final biography = isPersian
        ? (showPersianBiography ? poet.biographyFa! : '')
        : poet.biographyTj;
    final hasAuditableBiography = isPersian
        ? poet.hasAuditablePersianBiography
        : poet.hasAuditableTajikBiography;
    final biographySourceBooks = LiteraryAuthorDisplayText.biographySourceBooks(
      poet.biographySource,
    );
    final showBiography =
        (hasAuditableBiography && biography.trim().isNotEmpty) ||
        (isPersian && poet.hasAuditableTajikBiography);
    final compactHeader = MediaQuery.sizeOf(context).width < 380;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              QalamSpacing.pageH,
              20,
              QalamSpacing.pageH,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Keep the profile header concise; the full source-backed
                // period/context remains available below the biography.
                if (period.isNotEmpty || poet.isPublicDomain)
                  Row(
                    children: [
                      if (periodHeading.isNotEmpty)
                        Expanded(
                          child: Text(
                            periodHeading,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: QalamTypography.eyebrow(
                              color: colors.primary,
                            ),
                          ),
                        ),
                      if (poet.isPublicDomain) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: QalamColors.forest.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              QalamSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: QalamColors.forest.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.public,
                                size: 13,
                                color: QalamColors.forest,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppTranslations.get('lit_public_domain', lang),
                                style: QalamTypography.meta(
                                  color: QalamColors.forest,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 16),
                // Keep the source-backed portrait and canonical names
                // together in both Tajik/LTR and Persian/RTL layouts.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 112,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QalamPortrait(
                            portrait: poet.portrait,
                            label: name,
                            monogramName: poet.canonicalName,
                            persianName: poet.canonicalNamePersian,
                            width: 112,
                            height: 144,
                            unavailableLabel: AppTranslations.get(
                              'lit_portrait_unavailable',
                              lang,
                            ),
                            citationLabel:
                                LiteraryAuthorDisplayText.portraitCitation(
                                  poet.portrait,
                                  lang,
                                ),
                          ),
                          // The book and page the portrait is printed on.
                          if (poet.portrait?.isDisplayable ?? false) ...[
                            const SizedBox(height: 6),
                            ExcludeSemantics(
                              child: Text(
                                LiteraryAuthorDisplayText.portraitCitation(
                                  poet.portrait,
                                  lang,
                                ),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: QalamWholeWordTitle(
                              name,
                              textDirection: isPersian
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: QalamTypography.pageTitle(
                                color: colors.onSurface,
                                fontSize: compactHeader ? 28 : 34,
                              ),
                            ),
                          ),
                          if (altName != null && altName.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              altName,
                              textDirection: isPersian
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              style: QalamTypography.heroProverb(
                                color: colors.onSurfaceVariant,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Dates use localized year-only forms; source-language
                // birthplace text is withheld unless a Persian translation
                // has been reviewed.
                if (poet.hasAuditableBiographySource &&
                    (lifespan.isNotEmpty || birthPlace != null)) ...[
                  if (lifespan.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            lifespan,
                            softWrap: true,
                            style: QalamTypography.meta(
                              color: colors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (birthPlace != null) ...[
                    if (lifespan.isNotEmpty) const SizedBox(height: 6),
                    // Full-width row so a long birthplace wraps and stays fully
                    // readable on narrow phones without ellipsizing.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            birthPlace,
                            softWrap: true,
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 10),
                // Poem count badge (readable works)
                worksAsync.maybeWhen(
                  data: (works) {
                    final approvedCount = works.length;
                    // No badge for a poet with no poem: the works section
                    // says so in one line.
                    if (approvedCount == 0) return const SizedBox.shrink();
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories,
                                size: 16,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  AppTranslations.translate(
                                    'lit_poet_approved_works_count',
                                    lang,
                                    [
                                      AppTranslations.formatDigits(
                                        approvedCount.toString(),
                                        lang,
                                      ),
                                    ],
                                  ),
                                  softWrap: true,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                // Official Titles
                if (hasAuditableBiography && officialTitles.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: officialTitles.map((title) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          title,
                          style: QalamTypography.meta(
                            color: colors.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 24),
                // Biography, with the book it is copied from. A poet with no
                // biography text shows none: the reader is never told about
                // the team's pending page checks.
                if (showBiography) ...[
                  Text(
                    AppTranslations.get('lit_poet_biography', lang),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (hasAuditableBiography && biography.trim().isNotEmpty)
                    SelectableText(
                      biography,
                      textDirection: isPersian
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      textAlign: isPersian ? TextAlign.right : TextAlign.left,
                      style: QalamTypography.body(
                        color: colors.onSurface,
                        fontSize: 16,
                        height: 1.75,
                      ),
                    )
                  else
                    Text(
                      AppTranslations.get(
                        'lit_poet_bio_translation_pending',
                        lang,
                      ),
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  if (poet.hasAuditableBiographySource) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: colors.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get(
                              'lit_poet_bio_source_verified',
                              lang,
                            ),
                            style: QalamTypography.meta(color: colors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            biographySourceBooks,
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                if (period.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppTranslations.get('lit_poet_period_context', lang),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    period,
                    textDirection: isPersian
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    textAlign: isPersian ? TextAlign.right : TextAlign.left,
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],

                if (poet.relatedHistoryEntryIds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppTranslations.get('lit_poet_explore_world', lang),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslations.get('lit_poet_explore_world_sub', lang),
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      final entriesAsync = ref.watch(historyEntriesProvider);
                      final allEntries =
                          entriesAsync.valueOrNull ?? const <HistoryEntry>[];
                      final idSet = poet.relatedHistoryEntryIds.toSet();
                      final related = allEntries
                          .where((e) => idSet.contains(e.id))
                          .toList();
                      if (related.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final visibleEntries = related.where(
                        (entry) =>
                            !isPersian ||
                            (entry.titlePersian?.trim().isNotEmpty ?? false),
                      );
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: visibleEntries.map((entry) {
                          final title =
                              (isPersian && entry.titlePersian != null)
                              ? entry.titlePersian!
                              : entry.title;
                          return ActionChip(
                            avatar: const Icon(
                              Icons.account_balance_outlined,
                              size: 16,
                            ),
                            label: Text(title),
                            onPressed: () =>
                                context.push('/history/${entry.id}'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 24),
                // Works Section Title
                worksAsync.maybeWhen(
                  data: (works) => Text(
                    works.isEmpty
                        ? AppTranslations.get('lit_poet_works_header', lang)
                        : AppTranslations.translate(
                            'lit_poet_approved_works_header',
                            lang,
                            [
                              AppTranslations.formatDigits(
                                works.length.toString(),
                                lang,
                              ),
                            ],
                          ),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 22,
                    ),
                  ),
                  orElse: () => Text(
                    AppTranslations.get('lit_poet_works_header', lang),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        PoetWorksSliver(poet: poet, worksAsync: worksAsync),
        PoetBooksSliver(poet: poet),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}
