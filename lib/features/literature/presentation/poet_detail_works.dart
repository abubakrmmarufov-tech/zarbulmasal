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
          // One plain line: the permitted books print no poem of this poet
          // (docs/literature/POET_COVERAGE_PHASE11_2026-09-26.md).
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                QalamSpacing.pageH,
                4,
                QalamSpacing.pageH,
                16,
              ),
              child: Text(
                AppTranslations.get('lit_poet_no_textbook_poem', lang),
                style: QalamTypography.bodySecondary(
                  color: colors.onSurfaceVariant,
                  fontSize: 15,
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
                  placeholderTitle: BookDisplayText.coverTitle(book, lang),
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
