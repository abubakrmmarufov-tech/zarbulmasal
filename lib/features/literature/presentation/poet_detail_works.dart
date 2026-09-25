import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../books/data/books_providers.dart';
import '../../books/presentation/book_cover.dart';
import '../../books/presentation/book_display_text.dart';
import '../data/literature_providers.dart';
import '../domain/literary_author.dart';
import '../domain/literary_work.dart';
import 'literary_work_display_text.dart';

/// The poet page's readable poems, as a sliver.
class PoetWorksSliver extends ConsumerWidget {
  const PoetWorksSliver({
    super.key,
    required this.poet,
    required this.worksAsync,
  });

  final LiteraryAuthor poet;
  final AsyncValue<List<LiteraryWork>> worksAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    return worksAsync.when(
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
              onPressed: () => ref.invalidate(worksByAuthorProvider(poet.id)),
              child: Text(AppTranslations.get('btn_retry', lang)),
            ),
          ),
        ),
      ),
      data: (works) {
        if (works.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: colors.outlineVariant, width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppTranslations.get('lit_poet_works_review_desc', lang),
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
            final workTitle = LiteraryWorkDisplayText.title(work, lang);

            final incipit = LiteraryWorkDisplayText.distinctIncipit(work, lang);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: QalamSlip(
                onTap: () => context.push('/literature/work/${work.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workTitle,
                      style: QalamTypography.literaryTitle(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                    if (incipit != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '«$incipit»',
                        style: QalamTypography.bodySecondary(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (!isPersian &&
                        work.hasAuditableCompositionEvidence &&
                        (work.compositionDate ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          AppTranslations.get(
                            'lit_poet_composition_year',
                            lang,
                            [
                              AppTranslations.formatDigits(
                                work.compositionDate!,
                                lang,
                              ),
                            ],
                          ),
                          if ((work.compositionContext ?? '').isNotEmpty)
                            work.compositionContext!,
                        ].join(' · '),
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }, childCount: works.length),
        );
      },
    );
  }
}

/// The poet's records still being checked, after the readable poems: a
/// count-labelled header that expands the (often long) list.
class PoetReviewWorksSliver extends ConsumerStatefulWidget {
  const PoetReviewWorksSliver({super.key, required this.reviewWorksAsync});

  final AsyncValue<List<LiteraryWork>> reviewWorksAsync;

  @override
  ConsumerState<PoetReviewWorksSliver> createState() =>
      _PoetReviewWorksSliverState();
}

class _PoetReviewWorksSliverState extends ConsumerState<PoetReviewWorksSliver> {
  /// Whether page-cited under-review records are expanded.
  ///
  /// Approved/readable works stay visible; the per-poet review list (often
  /// 100–265 rows) collapses behind a count-labeled header until the reader
  /// explicitly opens it, preserving source transparency and the reader route.
  bool _showReviewWorks = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reviewWorksAsync = widget.reviewWorksAsync;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: reviewWorksAsync.maybeWhen(
              data: (reviewWorks) {
                final unlinkedReviewCount = reviewWorks
                    .where((work) => !work.hasAuditableReviewCitation)
                    .length;
                if (reviewWorks.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Count-labeled expand/collapse header for the
                      // (often huge) under-review list; approved works
                      // above remain fully visible.
                      Tooltip(
                        message: AppTranslations.get(
                          _showReviewWorks
                              ? 'lit_search_review_hide_tooltip'
                              : 'lit_search_review_show_tooltip',
                          lang,
                        ),
                        child: InkWell(
                          key: const ValueKey('poet-detail-review-toggle'),
                          onTap: () => setState(
                            () => _showReviewWorks = !_showReviewWorks,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
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
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _showReviewWorks
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 20,
                                  color: colors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
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
          ),
        ),
        if (_showReviewWorks)
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
                  final workTitle = LiteraryWorkDisplayText.title(work, lang);
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
      ],
    );
  }
}

/// Library books by the poet, if any.
class PoetBooksSliver extends ConsumerWidget {
  const PoetBooksSliver({super.key, required this.poet});

  final LiteraryAuthor poet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final books = ref.watch(booksByAuthorProvider(poet.id));
    return SliverMainAxisGroup(
      slivers: [
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
              return QalamIndexRow(
                leadingWidget: BookCover(
                  book: book,
                  width: 48,
                  height: 68,
                  placeholderTitle: BookDisplayText.title(book, lang),
                ),
                title: BookDisplayText.title(book, lang),
                subtitle:
                    book.primaryEdition?.publicationYear ??
                    AppTranslations.get('books_provider', lang),
                onTap: () => context.push('/books/${book.id}'),
              );
            }, childCount: books.length),
          ),
        ],
      ],
    );
  }
}
