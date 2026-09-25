import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../books/data/books_providers.dart';
import '../history/data/history_providers.dart';
import '../literature/data/literature_providers.dart';
import '../vocabulary/data/words_provider.dart';
import 'widgets/browse_strips.dart';
import 'widgets/discover_today.dart';

/// Explore: things to discover today, ways to browse (poets by era, the
/// school grades, the history timeline), then the collection index —
/// every domain once, each with its parts.
///
/// A domain heading opens the domain itself (e.g. the Literature page with
/// the bayt of the day); the rows beneath open its parts. Empty collections
/// get no row; running numbers are not used.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);
    String n(int value) => AppTranslations.formatNumber(value, lang);
    String? count(String key, List<int>? values) => values == null
        ? null
        : AppTranslations.get(key, lang, values.map(n).toList());

    final hasOralHeritage =
        ref.watch(oralHeritageProvider).valueOrNull?.isNotEmpty ?? false;
    final poets = ref
        .watch(literaryAuthorsProvider)
        .valueOrNull
        ?.where((poet) => poet.hasCanonicalName)
        .length;
    final works = ref.watch(approvedWorksProvider).valueOrNull?.length;
    final proverbs = ref.watch(proverbsProvider).length;
    final topics = ref.watch(categoriesProvider).length;
    final history = ref.watch(historyEntriesProvider).valueOrNull?.length;
    final words = ref.watch(wordsProvider).valueOrNull?.length;
    final books = ref.watch(booksProvider).valueOrNull?.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('explore_title'),
          style: QalamTypography.monographTitle(
            color: colors.onSurface,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
        children: [
          QalamSearchEntry(label: tr('explore_search_placeholder')),
          const SizedBox(height: 20),
          const DiscoverToday(),
          const PoetEraStrip(),
          const GradeStrip(),
          const HistoryTimelineStrip(),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              tr('explore_all_sections').toUpperCase(),
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
          ),
          _Domain(
            seed: 'literature',
            icon: Icons.auto_stories_outlined,
            title: tr('home_col_literature'),
            subtitle: poets == null || works == null
                ? null
                : count('home_col_literature_sub', [poets, works]),
            onTap: () => context.push('/literature'),
            children: [
              QalamIndexRow(
                title: tr('explore_poets_title'),
                subtitle: tr('explore_poets_sub'),
                onTap: () => context.push('/literature/poets'),
              ),
              QalamIndexRow(
                title: tr('explore_works_title'),
                subtitle: tr('explore_works_sub'),
                onTap: () => context.push('/literature/works'),
              ),
              QalamIndexRow(
                title: tr('explore_school_title'),
                subtitle: tr('explore_school_sub'),
                onTap: () => context.push('/literature/school'),
              ),
              if (hasOralHeritage)
                QalamIndexRow(
                  title: tr('explore_oral_title'),
                  subtitle: tr('explore_oral_sub'),
                  onTap: () => context.push('/literature/oral'),
                ),
            ],
          ),
          _Domain(
            seed: 'proverbs',
            icon: Icons.format_quote_outlined,
            title: tr('home_col_proverbs'),
            subtitle: count('home_col_proverbs_sub', [proverbs, topics]),
            onTap: () => context.push('/proverbs'),
            children: [
              QalamIndexRow(
                title: tr('explore_topics_title'),
                subtitle: tr('explore_topics_sub'),
                onTap: () => context.push('/categories'),
              ),
              QalamIndexRow(
                title: tr('explore_all_title'),
                subtitle: tr('explore_all_sub'),
                onTap: () => context.push('/proverbs'),
              ),
            ],
          ),
          _Domain(
            seed: 'history',
            icon: Icons.account_balance_outlined,
            title: tr('home_col_history'),
            subtitle: history == null
                ? null
                : count('home_col_history_sub', [history]),
            onTap: () => context.push('/history'),
          ),
          _Domain(
            seed: 'lexicon',
            icon: Icons.translate,
            title: tr('home_col_lexicon'),
            subtitle: words == null
                ? null
                : count('home_col_lexicon_sub', [words]),
            onTap: () => context.push('/vocabulary'),
          ),
          _Domain(
            seed: 'library',
            icon: Icons.local_library_outlined,
            title: tr('home_col_library'),
            subtitle: books == null
                ? null
                : count('home_col_library_sub', [books]),
            onTap: () => context.push('/books'),
          ),
        ],
      ),
    );
  }
}

/// A domain as a large folio tile (its own ikat band) that opens the
/// domain, followed by its parts as catalogue slips.
class _Domain extends StatelessWidget {
  const _Domain({
    required this.seed,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.children = const [],
  });

  final String seed;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: QalamFolioTile(
              large: true,
              seed: seed,
              icon: icon,
              title: title,
              subtitle: subtitle,
              onTap: onTap,
            ),
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
