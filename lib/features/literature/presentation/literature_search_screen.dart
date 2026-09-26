import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_author.dart';
import '../domain/literary_work.dart';
import 'literary_author_display_text.dart';
import 'literary_work_display_text.dart';
import '../../../core/utils/search_field_limits.dart';
import '../../../core/utils/search_normalizer.dart';
import '../domain/literature_search.dart';

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
              _query = SearchNormalizer.normalize(val);
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
                  setState(() => _query = SearchNormalizer.normalize(term));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: QalamSpacing.sectionVTight),
          Text(
            AppTranslations.get('search_any_script_tip', lang),
            style: QalamTypography.meta(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
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
    final matchingAuthors = authors
        .where(
          (a) =>
              a.hasCanonicalName && LiteratureSearch.matchesAuthor(a, _query),
        )
        .toList();

    bool matches(LiteraryWork work) =>
        LiteratureSearch.matchesWork(work, _query);

    // Readers see readable poems only; records still being checked stay in
    // the data for the team.
    final readableWorks = works
        .where((work) => work.isDisplayable && matches(work))
        .toList(growable: false);

    if (matchingAuthors.isEmpty && readableWorks.isEmpty) {
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
                  : '',
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
}
