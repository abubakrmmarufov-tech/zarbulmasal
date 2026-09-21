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
import '../domain/verification_record.dart';
import '../../history/data/history_providers.dart';
import '../../history/domain/history_domain.dart';
import '../../books/data/books_providers.dart';
import '../../books/presentation/book_cover.dart';

/// A detailed monograph view for a canonical Tajik author/poet,
/// displaying verified biography, source citations, curriculum links, and works.
class PoetDetailScreen extends ConsumerWidget {
  final String poetId;

  const PoetDetailScreen({super.key, required this.poetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final authorAsync = ref.watch(authorByIdProvider(poetId));
    final worksAsync = ref.watch(worksByAuthorProvider(poetId));
    final reviewWorksAsync = ref.watch(
      worksUnderReviewByAuthorProvider(poetId),
    );
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
                    title: isPersian && poet.canonicalNamePersian != null
                        ? poet.canonicalNamePersian!
                        : poet.canonicalName,
                    subtitle: poet.literaryPeriod,
                    timestamp: DateTime.now(),
                    route: '/literature/poet/${poet.id}',
                  ),
                );
          });

          return _PoetDetailContent(
            poet: poet,
            worksAsync: worksAsync,
            reviewWorksAsync: reviewWorksAsync,
            canonAsync: canonAsync,
          );
        },
      ),
    );
  }
}

class _PoetDetailContent extends ConsumerWidget {
  final LiteraryAuthor poet;
  final AsyncValue<List<LiteraryWork>> worksAsync;
  final AsyncValue<List<LiteraryWork>> reviewWorksAsync;
  final AsyncValue<List<dynamic>> canonAsync;

  const _PoetDetailContent({
    required this.poet,
    required this.worksAsync,
    required this.reviewWorksAsync,
    required this.canonAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final books = ref.watch(booksByAuthorProvider(poet.id));

    final name = (isPersian && poet.canonicalNamePersian != null)
        ? poet.canonicalNamePersian!
        : poet.canonicalName;

    final altName = (isPersian && poet.canonicalNamePersian != null)
        ? poet.canonicalName
        : poet.canonicalNamePersian;

    final showPersianBiography = isPersian && poet.hasAuditablePersianBiography;
    final biography = showPersianBiography
        ? poet.biographyFa!
        : poet.biographyTj;
    final hasAuditableBiography = showPersianBiography
        ? poet.hasAuditablePersianBiography
        : poet.hasAuditableTajikBiography;
    final biographySourceLabel = hasAuditableBiography
        ? AppTranslations.get('lit_poet_bio_source_verified', lang)
        : AppTranslations.get('lit_poet_bio_source_unverified', lang);
    final biographySourceText = hasAuditableBiography
        ? poet.biographySource
        : AppTranslations.translate('lit_poet_source_tag', lang, [
            poet.biographySource,
          ]);

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
                // Period & Public Domain badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        poet.literaryPeriod.toUpperCase(),
                        style: QalamTypography.eyebrow(color: colors.primary),
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
                    QalamPortrait(
                      portrait: poet.portrait,
                      label: name,
                      width: 112,
                      height: 144,
                      unavailableLabel: AppTranslations.get(
                        'lit_portrait_unavailable',
                        lang,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            textDirection:
                                (isPersian && poet.canonicalNamePersian != null)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: QalamTypography.pageTitle(
                              color: colors.onSurface,
                              fontSize: 34,
                            ),
                          ),
                          if (altName != null && altName.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              altName,
                              textDirection:
                                  (isPersian &&
                                      poet.canonicalNamePersian != null)
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
                // Dates and birthplace
                if (hasAuditableBiography) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppTranslations.formatDigits(poet.lifespan, lang),
                        style: QalamTypography.meta(
                          color: colors.primary,
                          fontSize: 14,
                        ),
                      ),
                      if (poet.birthPlace != null &&
                          poet.birthPlace!.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            poet.birthPlace!,
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else if (poet.lifespan.isNotEmpty ||
                    (poet.birthPlace?.isNotEmpty ?? false))
                  Text(
                    AppTranslations.get('lit_poet_header_dates_pending', lang),
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                if (hasAuditableBiography &&
                    (poet.birthDateExact != null ||
                        poet.deathDateExact != null)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_edu,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppTranslations.translate('lit_author_dates', lang, [
                            AppTranslations.formatDigits(
                              poet.birthDateExact ?? poet.birthYear ?? '—',
                              lang,
                            ),
                            AppTranslations.formatDigits(
                              poet.deathDateExact ??
                                  poet.deathYear ??
                                  AppTranslations.get('lit_author_alive', lang),
                              lang,
                            ),
                          ]),
                          style: QalamTypography.meta(
                            color: colors.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Poem count badge (Approved + Review candidates)
                worksAsync.maybeWhen(
                  data: (works) {
                    final reviewWorks = reviewWorksAsync.valueOrNull ?? [];
                    final approvedCount = works.length;
                    final reviewCount = reviewWorks.length;
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
                              Text(
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
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (reviewCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  size: 15,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppTranslations.translate(
                                    'lit_poet_review_works_count',
                                    lang,
                                    [
                                      AppTranslations.formatDigits(
                                        reviewCount.toString(),
                                        lang,
                                      ),
                                    ],
                                  ),
                                  style: QalamTypography.meta(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
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
                if (hasAuditableBiography &&
                    poet.officialTitles.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: poet.officialTitles.map((title) {
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
                // Biography Section
                Text(
                  AppTranslations.get('lit_poet_biography', lang),
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 14),
                if (hasAuditableBiography && biography.trim().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPersian && !showPersianBiography) ...[
                        Text(
                          AppTranslations.get(
                            'lit_poet_bio_cyrillic_fallback',
                            lang,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SelectableText(
                        biography,
                        textDirection: (isPersian && poet.biographyFa != null)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        textAlign: (isPersian && poet.biographyFa != null)
                            ? TextAlign.right
                            : TextAlign.left,
                        style: QalamTypography.body(
                          color: colors.onSurface,
                          fontSize: 16,
                          height: 1.75,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    AppTranslations.get('lit_poet_bio_pending', lang),
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 16),
                // Biography Source Box
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
                        biographySourceLabel,
                        style: QalamTypography.meta(color: colors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        biographySourceText,
                        style: QalamTypography.bodySecondary(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

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
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: related.map((entry) {
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
                    AppTranslations.translate(
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
                reviewWorksAsync.maybeWhen(
                  data: (reviewWorks) {
                    final unlinkedReviewCount = reviewWorks
                        .where((work) => !work.hasAuditableReviewCitation)
                        .length;
                    return reviewWorks.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.translate(
                                    'lit_poet_works_in_review_label',
                                    lang,
                                    [
                                      AppTranslations.formatDigits(
                                        reviewWorks.length.toString(),
                                        lang,
                                      ),
                                    ],
                                  ),
                                  style: QalamTypography.meta(
                                    color: colors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                                if (unlinkedReviewCount > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    AppTranslations.translate(
                                      'lit_poet_review_unlinked',
                                      lang,
                                      [
                                        AppTranslations.formatDigits(
                                          unlinkedReviewCount.toString(),
                                          lang,
                                        ),
                                      ],
                                    ),
                                    style: QalamTypography.meta(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        // Works list by this author
        worksAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (_, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EmptyState(
                icon: Icons.error_outline,
                title: AppTranslations.get('lit_works_error_title', lang),
                subtitle: AppTranslations.get('lit_works_error_sub', lang),
                action: OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(worksByAuthorProvider(poet.id)),
                  child: Text(AppTranslations.get('btn_retry', lang)),
                ),
              ),
            ),
          ),
          data: (works) {
            if (works.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppTranslations.get(
                              'lit_poet_works_review_desc',
                              lang,
                            ),
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final work = works[index];
                final workTitle = (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title;

                return InkWell(
                  onTap: () => context.push('/literature/work/${work.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colors.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workTitle,
                                style: QalamTypography.sectionTitle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                ),
                              ),
                              if (work.incipit != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '«${work.incipit}»',
                                  style: QalamTypography.bodySecondary(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (work.hasAuditableCompositionEvidence &&
                                  work.compositionDate != null &&
                                  work.compositionDate!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 13,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppTranslations.translate(
                                        'lit_poet_composition_year',
                                        lang,
                                        [
                                          AppTranslations.formatDigits(
                                            work.compositionDate!,
                                            lang,
                                          ),
                                        ],
                                      ),
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (work.hasAuditableCompositionEvidence &&
                                        work.compositionContext != null &&
                                        work
                                            .compositionContext!
                                            .isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '· ${work.compositionContext}',
                                          style: QalamTypography.meta(
                                            color: colors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (work.verification.evidenceLevel ==
                            VerificationLevel.editoriallyApproved)
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: QalamColors.forest,
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          isRtl ? Icons.chevron_left : Icons.chevron_right,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: works.length),
            );
          },
        ),
        reviewWorksAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (reviewWorks) {
            final sourcedReviewWorks = reviewWorks
                .where((work) => work.hasAuditableReviewCitation)
                .toList(growable: false);
            if (sourcedReviewWorks.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final work = sourcedReviewWorks[index];
                final workTitle = (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title;
                final citation = work.primarySource?.citation;
                final hasPageCitation = work.primarySource?.pageStart != null;

                return InkWell(
                  onTap: () => context.push('/literature/work/${work.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QalamSpacing.pageH,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.18,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: colors.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 18,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workTitle,
                                style: QalamTypography.sectionTitle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppTranslations.get(
                                  'lit_poet_work_in_review_sub',
                                  lang,
                                ),
                                style: QalamTypography.meta(
                                  color: colors.primary,
                                  fontSize: 12,
                                ),
                              ),
                              if (hasPageCitation &&
                                  citation != null &&
                                  citation.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  citation,
                                  style: QalamTypography.meta(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ] else ...[
                                const SizedBox(height: 4),
                                Text(
                                  AppTranslations.get(
                                    'lit_poet_page_not_recorded',
                                    lang,
                                  ),
                                  style: QalamTypography.meta(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isRtl ? Icons.chevron_left : Icons.chevron_right,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: sourcedReviewWorks.length),
            );
          },
        ),
        if (books.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Text(
                AppTranslations.get('books_author_books', lang),
                style: QalamTypography.sectionTitle(
                  color: colors.onSurface,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final book = books[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 6,
                ),
                leading: BookCover(
                  book: book,
                  width: 48,
                  height: 68,
                  placeholderTitle: book.titleFor(lang),
                ),
                title: Text(
                  book.titleFor(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.body(color: colors.onSurface),
                ),
                subtitle: Text(
                  book.primaryEdition?.publicationYear ??
                      AppTranslations.get('books_provider', lang),
                  style: QalamTypography.meta(color: colors.onSurfaceVariant),
                ),
                trailing: Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: colors.onSurfaceVariant,
                ),
                onTap: () => context.push('/books/${book.id}'),
              );
            }, childCount: books.length),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}
