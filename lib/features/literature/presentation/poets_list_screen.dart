import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/domain.dart';
import 'literary_author_display_text.dart';
import '../../../core/utils/search_field_limits.dart';
import '../../../core/utils/search_normalizer.dart';
import '../domain/literature_search.dart';

/// A screen presenting canonical Tajik literary authors and poets.
class PoetsListScreen extends ConsumerStatefulWidget {
  const PoetsListScreen({super.key, this.initialEra});

  /// Opens the list filtered to one era (Explore links here).
  final PoetEra? initialEra;

  @override
  ConsumerState<PoetsListScreen> createState() => _PoetsListScreenState();
}

class _PoetsListScreenState extends ConsumerState<PoetsListScreen> {
  final TextEditingController _filterController = TextEditingController();
  String _filterQuery = '';
  late PoetEra? _era = widget.initialEra;

  Widget _eraChips(DisplayLanguage lang) {
    Widget chip(PoetEra? era, String key) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(AppTranslations.get(key, lang)),
        selected: _era == era,
        onSelected: (_) => setState(() => _era = era),
      ),
    );
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        children: [
          chip(null, 'lit_era_all'),
          for (final era in PoetEra.values) chip(era, era.labelKey),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final worksAsync = ref.watch(approvedWorksProvider);
    final worksCountByAuthor = <String, int>{};
    for (final work in worksAsync.valueOrNull ?? const <LiteraryWork>[]) {
      worksCountByAuthor[work.authorId] =
          (worksCountByAuthor[work.authorId] ?? 0) + 1;
    }

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
                eyebrow: AppTranslations.get('lit_poets_eyebrow', lang),
                title: AppTranslations.get('lit_poets', lang),
                subtitle: AppTranslations.get('lit_poets_subtitle', lang),
              ),
            ),
            // Filter Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: TextField(
                  controller: _filterController,
                  inputFormatters: searchQueryFormatters,
                  onChanged: (val) {
                    setState(() {
                      _filterQuery = SearchNormalizer.normalize(val);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppTranslations.get(
                      'lit_poets_search_hint',
                      lang,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _filterQuery.isNotEmpty
                        ? IconButton(
                            tooltip: AppTranslations.get(
                              'lit_search_clear_tooltip',
                              lang,
                            ),
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _filterController.clear();
                              setState(() {
                                _filterQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _eraChips(lang)),
            // Poets list
            authorsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: AppTranslations.get('lit_poets_error_title', lang),
                    subtitle: AppTranslations.get('lit_poets_error_sub', lang),
                    action: OutlinedButton(
                      onPressed: () => ref.invalidate(literaryAuthorsProvider),
                      child: Text(AppTranslations.get('btn_retry', lang)),
                    ),
                  ),
                ),
              ),
              data: (authors) {
                final filtered = authors.where((author) {
                  if (!author.hasCanonicalName) return false;
                  if (_era != null && PoetEra.of(author) != _era) return false;
                  if (_filterQuery.isEmpty) return true;
                  return LiteratureSearch.matchesAuthor(author, _filterQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: AppTranslations.get(
                          'lit_poets_empty_title',
                          lang,
                        ),
                        subtitle: AppTranslations.get(
                          'lit_poets_empty_sub',
                          lang,
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final poet = filtered[index];
                    final name = LiteraryAuthorDisplayText.name(poet, lang);
                    final poemCount = worksCountByAuthor[poet.id] ?? 0;
                    final poemCountBadge = poemCount > 0
                        ? '${AppTranslations.formatDigits(poemCount.toString(), lang)} ${AppTranslations.get('lit_works_unit', lang)}'
                        : null;
                    final lifespan = LiteraryAuthorDisplayText.lifespan(
                      poet,
                      lang,
                    );
                    final dates =
                        poet.hasAuditableBiographySource && lifespan.isNotEmpty
                        ? lifespan
                        : '';
                    final exactDates =
                        (!isPersian &&
                            poet.hasAuditableBiographySource &&
                            (poet.birthDateExact != null ||
                                poet.deathDateExact != null))
                        ? AppTranslations.translate('lit_author_dates', lang, [
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
                          ])
                        : null;
                    return QalamPoetCard(
                      name: name,
                      monogramName: poet.canonicalName,
                      persianName: poet.canonicalNamePersian,
                      portrait: poet.portrait,
                      portraitUnavailableLabel: AppTranslations.get(
                        'lit_portrait_unavailable',
                        lang,
                      ),
                      portraitCitationLabel:
                          LiteraryAuthorDisplayText.portraitCitation(
                            poet.portrait,
                            lang,
                          ),
                      dates: dates,
                      exactDates: exactDates,
                      place: LiteraryAuthorDisplayText.birthPlace(poet, lang),
                      period: LiteraryAuthorDisplayText.period(poet, lang),
                      isPublicDomain: poet.isPublicDomain,
                      poemCountBadge: poemCountBadge,
                      onTap: () => context.push('/literature/poet/${poet.id}'),
                    );
                  }, childCount: filtered.length),
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
