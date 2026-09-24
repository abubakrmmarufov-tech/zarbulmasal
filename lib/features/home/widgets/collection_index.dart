import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../books/data/books_providers.dart';
import '../../history/data/history_providers.dart';
import '../../literature/data/literature_providers.dart';
import '../../vocabulary/data/words_provider.dart';

/// «Ганҷина»: every collection as a folio tile wearing its own ikat band,
/// with real counts. A count appears only once its catalogue has loaded —
/// never a placeholder.
class CollectionIndex extends ConsumerWidget {
  const CollectionIndex({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    String n(int value) => AppTranslations.formatNumber(value, lang);
    String? sub(String key, List<int>? counts) => counts == null
        ? null
        : AppTranslations.get(key, lang, counts.map(n).toList());

    final poets = ref
        .watch(literaryAuthorsProvider)
        .valueOrNull
        ?.where((poet) => poet.hasCanonicalName)
        .length;
    final works = ref.watch(approvedWorksProvider).valueOrNull?.length;
    final proverbs = ref.watch(proverbsProvider).length;
    final categories = ref.watch(categoriesProvider).length;
    final history = ref.watch(historyEntriesProvider).valueOrNull?.length;
    final words = ref.watch(wordsProvider).valueOrNull?.length;
    final books = ref.watch(booksProvider).valueOrNull?.length;

    String tr(String key) => AppTranslations.get(key, lang);
    return QalamTileGrid(
      children: [
        QalamFolioTile(
          seed: 'literature',
          icon: Icons.auto_stories_outlined,
          title: tr('home_col_literature'),
          subtitle: poets == null || works == null
              ? null
              : sub('home_col_literature_sub', [poets, works]),
          onTap: () => context.push('/literature'),
        ),
        QalamFolioTile(
          seed: 'proverbs',
          icon: Icons.format_quote_outlined,
          title: tr('home_col_proverbs'),
          subtitle: sub('home_col_proverbs_sub', [proverbs, categories]),
          onTap: () => context.push('/categories'),
        ),
        QalamFolioTile(
          seed: 'history',
          icon: Icons.account_balance_outlined,
          title: tr('home_col_history'),
          subtitle: history == null
              ? null
              : sub('home_col_history_sub', [history]),
          onTap: () => context.push('/history'),
        ),
        QalamFolioTile(
          seed: 'lexicon',
          icon: Icons.translate,
          title: tr('home_col_lexicon'),
          subtitle: words == null ? null : sub('home_col_lexicon_sub', [words]),
          onTap: () => context.push('/vocabulary'),
        ),
        QalamFolioTile(
          seed: 'library',
          icon: Icons.local_library_outlined,
          title: tr('home_col_library'),
          subtitle: books == null ? null : sub('home_col_library_sub', [books]),
          onTap: () => context.push('/books'),
        ),
        QalamFolioTile(
          seed: 'learn',
          icon: Icons.school_outlined,
          title: tr('learn_title'),
          subtitle: tr('home_col_learn_sub'),
          onTap: () => context.go('/learn'),
        ),
      ],
    );
  }
}
