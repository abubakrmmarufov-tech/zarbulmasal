import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_work.dart';
import '../../../core/utils/search_field_limits.dart';
import '../../../core/utils/search_normalizer.dart';
import 'literary_author_display_text.dart';
import 'literary_work_display_text.dart';

/// A screen listing all verified and approved literary works.
class WorksListScreen extends ConsumerStatefulWidget {
  const WorksListScreen({super.key});

  @override
  ConsumerState<WorksListScreen> createState() => _WorksListScreenState();
}

class _WorksListScreenState extends ConsumerState<WorksListScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Works whose title, first line or poet matches the query.
  List<LiteraryWork> _filter(List<LiteraryWork> works, DisplayLanguage lang) {
    if (_query.trim().isEmpty) return works;
    final authors = {
      for (final author
          in ref.read(literaryAuthorsProvider).valueOrNull ?? const [])
        author.id: author,
    };
    return works
        .where(
          (work) => SearchNormalizer.matchesAny([
            work.title,
            work.titlePersian ?? '',
            work.incipit ?? '',
            authors[work.authorId]?.canonicalName ?? '',
            ...?authors[work.authorId]?.aliases,
          ], _query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayLanguageProvider);
    ref.watch(literaryAuthorsProvider);
    final approvedWorksAsync = ref.watch(approvedWorksProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top back button bar
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
            // Page Header
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: AppTranslations.get('lit_works_eyebrow', lang),
                title: AppTranslations.get('lit_poems', lang),
                subtitle: AppTranslations.get('lit_works_subtitle', lang),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  4,
                  QalamSpacing.pageH,
                  12,
                ),
                child: TextField(
                  controller: _search,
                  inputFormatters: searchQueryFormatters,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: AppTranslations.get('lit_search', lang),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: AppTranslations.get('btn_clear', lang),
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ),
            ),
            // Works content
            approvedWorksAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: AppTranslations.get('lit_works_error_title', lang),
                    subtitle: AppTranslations.get('lit_works_error_sub', lang),
                    action: OutlinedButton(
                      onPressed: () => ref.invalidate(approvedWorksProvider),
                      child: Text(AppTranslations.get('btn_retry', lang)),
                    ),
                  ),
                ),
              ),
              data: (works) {
                if (works.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: AppTranslations.get(
                            'lit_works_empty_review_title',
                            lang,
                          ),
                          subtitle: AppTranslations.get(
                            'lit_works_empty_review_sub',
                            lang,
                          ),
                          action: OutlinedButton(
                            onPressed: () => context.push('/literature/poets'),
                            child: Text(
                              AppTranslations.get('lit_works_view_poets', lang),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final shown = _filter(works, lang);
                if (shown.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: AppTranslations.get('lit_no_results', lang),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final work = shown[index];
                    return _WorkListItem(work: work);
                  }, childCount: shown.length),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _WorkListItem extends ConsumerWidget {
  final LiteraryWork work;

  const _WorkListItem({required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final authorAsync = ref.watch(authorByIdProvider(work.authorId));
    final author = authorAsync.valueOrNull;

    final title = LiteraryWorkDisplayText.title(work, lang);
    final incipit = LiteraryWorkDisplayText.distinctIncipit(work, lang);

    final authorName = LiteraryAuthorDisplayText.nameOrFallback(
      author,
      lang,
      work.authorId,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QalamSpacing.pageH),
      child: QalamSlip(
        onTap: () => context.push('/literature/work/${work.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: QalamTypography.literaryTitle(
                color: colors.onSurface,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              authorName,
              style: QalamTypography.meta(color: colors.primary, fontSize: 13),
            ),
            if (incipit != null) ...[
              const SizedBox(height: 6),
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
          ],
        ),
      ),
    );
  }
}
