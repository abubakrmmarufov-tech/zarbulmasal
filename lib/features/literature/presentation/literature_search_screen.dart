import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../data/literature_repository.dart';
import '../domain/literary_author.dart';
import '../domain/literary_work.dart';
import 'literary_author_display_text.dart';
import 'literary_work_display_text.dart';
import '../../../core/utils/search_field_limits.dart';

/// A unified search screen querying across canonical authors and literary works.
class LiteratureSearchScreen extends ConsumerStatefulWidget {
  const LiteratureSearchScreen({super.key});

  @override
  ConsumerState<LiteratureSearchScreen> createState() =>
      _LiteratureSearchScreenState();
}

class _LiteratureSearchScreenState
    extends ConsumerState<LiteratureSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  /// Whether page-cited under-review work records are expanded.
  ///
  /// Readable/approved works are always visible; review-only records stay
  /// collapsed behind a count-labeled header until the reader opens them.
  bool _showReviewWorks = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);

    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final worksAsync = ref.watch(searchableLiteraryWorksProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: TextField(
          controller: _controller,
          inputFormatters: searchQueryFormatters,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppTranslations.get('lit_search_hint', lang),
            border: InputBorder.none,
            hintStyle: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
            ),
          ),
          style: QalamTypography.body(color: colors.onSurface),
          onChanged: (val) {
            setState(() {
              _query = LiteratureRepository.normalizeSearchText(val);
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              tooltip: AppTranslations.get('lit_search_clear_tooltip', lang),
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: (authorsAsync.isLoading || worksAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : (authorsAsync.hasError || worksAsync.hasError)
          ? Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: AppTranslations.get('lit_search_error_title', lang),
                subtitle: AppTranslations.get('lit_search_error_sub', lang),
                action: OutlinedButton(
                  onPressed: () {
                    ref.invalidate(literaryAuthorsProvider);
                    ref.invalidate(searchableLiteraryWorksProvider);
                  },
                  child: Text(AppTranslations.get('btn_retry', lang)),
                ),
              ),
            )
          : _query.isEmpty
          ? _buildEmptyPrompt(
              context,
              lang,
              authorsAsync.valueOrNull ?? const [],
            )
          : _buildSearchResults(
              context,
              authorsAsync.valueOrNull ?? [],
              worksAsync.valueOrNull ?? [],
              lang,
            ),
    );
  }

  Widget _buildEmptyPrompt(
    BuildContext context,
    DisplayLanguage lang,
    List<LiteraryAuthor> authors,
  ) {
    final colors = Theme.of(context).colorScheme;
    final suggestions = authors
        .where(
          (author) =>
              author.hasCanonicalName &&
              (lang != DisplayLanguage.persian ||
                  (author.canonicalNamePersian?.trim().isNotEmpty ?? false)),
        )
        .take(6)
        .map((author) => LiteraryAuthorDisplayText.name(author, lang))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('lit_search_suggestions', lang),
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((term) {
              return ActionChip(
                label: Text(term),
                onPressed: () {
                  _controller.text = term;
                  setState(
                    () =>
                        _query = LiteratureRepository.normalizeSearchText(term),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<LiteraryAuthor> authors,
    List<LiteraryWork> works,
    DisplayLanguage lang,
  ) {
    final isPersian = lang == DisplayLanguage.persian;
    final matchingAuthors = authors.where((a) {
      if (!a.hasCanonicalName) return false;
      final name = LiteratureRepository.normalizeSearchText(a.canonicalName);
      final fa = LiteratureRepository.normalizeSearchText(
        a.canonicalNamePersian ?? '',
      );
      final period = LiteratureRepository.normalizeSearchText(a.literaryPeriod);
      final place = LiteratureRepository.normalizeSearchText(
        a.birthPlace ?? '',
      );
      final aliases = a.aliases.any(
        (x) => LiteratureRepository.normalizeSearchText(x).contains(_query),
      );
      return name.contains(_query) ||
          fa.contains(_query) ||
          period.contains(_query) ||
          place.contains(_query) ||
          aliases;
    }).toList();

    bool matches(LiteraryWork work) {
      final title = LiteratureRepository.normalizeSearchText(work.title);
      final titleFa = LiteratureRepository.normalizeSearchText(
        work.titlePersian ?? '',
      );
      final incipit = LiteratureRepository.normalizeSearchText(
        work.incipit ?? '',
      );
      return title.contains(_query) ||
          titleFa.contains(_query) ||
          incipit.contains(_query);
    }

    // Readable/approved works stay in the primary list; page-cited pending
    // records are kept discoverable but collapsed behind a count-labeled header.
    final readableWorks = works
        .where((work) => work.isDisplayable && matches(work))
        .toList(growable: false);
    final reviewWorks = works
        .where((work) => !work.isDisplayable && matches(work))
        .toList(growable: false);

    if (matchingAuthors.isEmpty &&
        readableWorks.isEmpty &&
        reviewWorks.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off,
          title: AppTranslations.get('lit_no_results', lang),
          subtitle: AppTranslations.translate(
            'lit_search_no_results_for',
            lang,
            [_query],
          ),
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;
    // A query matching only pending records must never look like a dead end:
    // surface the review section intentionally instead of the generic empty state.
    final showReadableEmptyNote =
        matchingAuthors.isEmpty &&
        readableWorks.isEmpty &&
        reviewWorks.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (matchingAuthors.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              AppTranslations.get('lit_search_poets_section', lang),
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
          ),
          for (final author in matchingAuthors)
            QalamPoetCard(
              name: LiteraryAuthorDisplayText.name(author, lang),
              portrait: author.portrait,
              portraitUnavailableLabel: AppTranslations.get(
                'lit_portrait_unavailable',
                lang,
              ),
              portraitCitationLabel: LiteraryAuthorDisplayText.portraitCitation(
                author.portrait,
                lang,
              ),
              dates:
                  author.hasAuditableBiographySource &&
                      LiteraryAuthorDisplayText.lifespan(
                        author,
                        lang,
                      ).isNotEmpty
                  ? LiteraryAuthorDisplayText.lifespan(author, lang)
                  : AppTranslations.get('lit_search_dates_pending', lang),
              exactDates:
                  (!isPersian &&
                      author.hasAuditableBiographySource &&
                      (author.birthDateExact != null ||
                          author.deathDateExact != null))
                  ? AppTranslations.translate('lit_author_dates', lang, [
                      AppTranslations.formatDigits(
                        author.birthDateExact ?? author.birthYear ?? '—',
                        lang,
                      ),
                      AppTranslations.formatDigits(
                        author.deathDateExact ??
                            author.deathYear ??
                            AppTranslations.get('lit_author_alive', lang),
                        lang,
                      ),
                    ])
                  : null,
              place: LiteraryAuthorDisplayText.birthPlace(author, lang),
              period: LiteraryAuthorDisplayText.period(author, lang),
              isPublicDomain: author.isPublicDomain,
              onTap: () => context.push('/literature/poet/${author.id}'),
            ),
          const SizedBox(height: 24),
        ],
        if (readableWorks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              AppTranslations.get('lit_search_works_section', lang),
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
          ),
          for (final work in readableWorks)
            _buildReadableWorkTile(context, work, lang),
        ],
        if (showReadableEmptyNote) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Text(
              AppTranslations.translate('lit_search_readable_empty', lang, [
                _query,
              ]),
              style: QalamTypography.bodySecondary(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ],
        if (reviewWorks.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildReviewWorksSection(context, reviewWorks, lang),
        ],
      ],
    );
  }

  Widget _buildReadableWorkTile(
    BuildContext context,
    LiteraryWork work,
    DisplayLanguage lang,
  ) {
    final colors = Theme.of(context).colorScheme;
    final incipit = LiteraryWorkDisplayText.distinctIncipit(work, lang);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        LiteraryWorkDisplayText.title(work, lang),
        style: QalamTypography.sectionTitle(
          color: colors.onSurface,
          fontSize: 17,
        ),
      ),
      subtitle: incipit == null
          ? null
          : Text(
              '«$incipit»',
              style: QalamTypography.bodySecondary(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: const QalamChevron(size: 20),
      onTap: () => context.push('/literature/work/${work.id}'),
    );
  }

  /// Count-labeled, collapsed-by-default header plus, when expanded, the same
  /// transparent pending rows poet detail uses (source label preserved).
  Widget _buildReviewWorksSection(
    BuildContext context,
    List<LiteraryWork> reviewWorks,
    DisplayLanguage lang,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Tooltip(
          message: AppTranslations.get(
            _showReviewWorks
                ? 'lit_search_review_hide_tooltip'
                : 'lit_search_review_show_tooltip',
            lang,
          ),
          child: InkWell(
            key: const ValueKey('literature-search-review-toggle'),
            onTap: () => setState(() => _showReviewWorks = !_showReviewWorks),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppTranslations.translate(
                        'lit_poet_works_in_review_label',
                        lang,
                        [reviewWorks.length],
                      ),
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showReviewWorks ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showReviewWorks)
          for (final work in reviewWorks)
            _buildReviewWorkTile(context, work, lang),
      ],
    );
  }

  Widget _buildReviewWorkTile(
    BuildContext context,
    LiteraryWork work,
    DisplayLanguage lang,
  ) {
    final colors = Theme.of(context).colorScheme;
    final sourceLabel = LiteraryWorkDisplayText.sourceCitation(
      work.primarySource,
      lang,
    );
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(Icons.hourglass_empty, size: 18, color: colors.primary),
      title: Text(
        LiteraryWorkDisplayText.title(work, lang),
        style: QalamTypography.sectionTitle(
          color: colors.onSurface,
          fontSize: 17,
        ),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('lit_poet_work_in_review_sub', lang),
            style: QalamTypography.meta(color: colors.primary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (sourceLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              sourceLabel,
              style: QalamTypography.meta(color: colors.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      trailing: const QalamChevron(size: 20),
      onTap: () => context.push('/literature/work/${work.id}'),
    );
  }
}
