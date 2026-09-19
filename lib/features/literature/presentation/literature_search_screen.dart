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
    final isPersian = lang == DisplayLanguage.persian;

    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final worksAsync = ref.watch(approvedWorksProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: TextField(
          controller: _controller,
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
                    ref.invalidate(approvedWorksProvider);
                  },
                  child: Text(AppTranslations.get('btn_retry', lang)),
                ),
              ),
            )
          : _query.isEmpty
          ? _buildEmptyPrompt(
              context,
              isPersian,
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
    bool isPersian,
    DisplayLanguage lang,
    List<LiteraryAuthor> authors,
  ) {
    final colors = Theme.of(context).colorScheme;
    final suggestions = authors
        .where((author) => author.hasCanonicalName)
        .take(6)
        .map((author) {
          if (isPersian && author.canonicalNamePersian != null) {
            return author.canonicalNamePersian!;
          }
          return author.canonicalName;
        })
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

    final matchingWorks = works.where((w) {
      final title = LiteratureRepository.normalizeSearchText(w.title);
      final titleFa = LiteratureRepository.normalizeSearchText(
        w.titlePersian ?? '',
      );
      final incipit = LiteratureRepository.normalizeSearchText(w.incipit ?? '');
      return title.contains(_query) ||
          titleFa.contains(_query) ||
          incipit.contains(_query);
    }).toList();

    if (matchingAuthors.isEmpty && matchingWorks.isEmpty) {
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
              name: (isPersian && author.canonicalNamePersian != null)
                  ? author.canonicalNamePersian!
                  : author.canonicalName,
              dates: author.hasAuditableBiographySource
                  ? AppTranslations.formatDigits(author.lifespan, lang)
                  : AppTranslations.get('lit_search_dates_pending', lang),
              exactDates:
                  (author.hasAuditableBiographySource &&
                      (author.birthDateExact != null ||
                          author.deathDateExact != null))
                  ? AppTranslations.translate(
                      'lit_author_dates',
                      lang,
                      [
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
                      ],
                    )
                  : null,
              period: author.literaryPeriod,
              isPublicDomain: author.isPublicDomain,
              onTap: () => context.push('/literature/poet/${author.id}'),
            ),
          const SizedBox(height: 24),
        ],
        if (matchingWorks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              AppTranslations.get('lit_search_works_section', lang),
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
          ),
          for (final work in matchingWorks)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 4,
              ),
              title: Text(
                (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title,
                style: QalamTypography.sectionTitle(
                  color: colors.onSurface,
                  fontSize: 17,
                ),
              ),
              subtitle: work.incipit != null
                  ? Text(
                      '«${work.incipit}»',
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: const QalamChevron(size: 20),
              onTap: () => context.push('/literature/work/${work.id}'),
            ),
        ],
      ],
    );
  }
}
