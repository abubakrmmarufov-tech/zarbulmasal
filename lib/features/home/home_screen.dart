import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/reading_position_provider.dart';
import '../../shared/providers/reading_script_provider.dart';
import 'widgets/bayt_of_the_day.dart';
import 'widgets/collection_index.dart';
import 'widgets/grade_lens.dart';
import 'widgets/home_exhibit.dart';

/// Home «Экспозиция»: the daily ritual first (proverb exhibit, bayt of the
/// day), then Continue reading, the collection index, and the grade lens.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final daily = ref.watch(dailyProverbProvider);
    final date = ref.watch(dailyDateProvider);
    final readingPersian =
        ref.watch(readingScriptProvider) == ReadingScript.persian;
    final categories = ref.watch(categoriesProvider);
    // Continue reading only ever points at a text (poem, proverb, history
    // entry), never at a hub, dossier, list, or search.
    final position = ref.watch(readingPositionProvider);

    String tr(String key) => AppTranslations.get(key, lang);
    final resumeTitle = position == null
        ? null
        : readingPersian
        ? (position.titlePersian ?? tr('lit_work_title_persian_pending'))
        : position.titleTajik;
    final categoryMatches = categories.where((c) => c.id == daily?.categoryId);
    final categoryName = categoryMatches.isEmpty
        ? ''
        : QalamCategoryTile.nameFor(categoryMatches.first, lang);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text(
            tr('app_name').toUpperCase(),
            style: QalamTypography.eyebrow(color: colors.primary, fontSize: 12),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: tr('nav_settings'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
          children: [
            QalamSearchEntry(label: tr('search_hint_global')),
            const SizedBox(height: 20),
            // The collections first: every part of the app one tap away.
            const CollectionIndex(),
            const SizedBox(height: 40),
            if (daily != null)
              HomeExhibit(
                proverb: daily,
                categoryName: categoryName,
                date: date,
                heroPersian: readingPersian,
                lang: lang,
                onOpen: () => context.push('/daily'),
              ),
            const SizedBox(height: 36),
            const BaytOfTheDay(),
            if (position != null && resumeTitle != null) ...[
              const SizedBox(height: 32),
              Text(
                tr('home_continue_reading').toUpperCase(),
                style: QalamTypography.eyebrow(color: colors.primary),
              ),
              QalamIndexRow(
                leading: _iconForKind(position.kind),
                title: resumeTitle,
                subtitle: _resumeSubtitle(position, lang),
                onTap: () => context.push(position.resumeRoute),
              ),
            ],
            const SizedBox(height: 36),
            const GradeLens(),
          ],
        ),
      ),
    );
  }

  static IconData _iconForKind(ReadingKind kind) => switch (kind) {
    ReadingKind.proverb => Icons.menu_book_outlined,
    ReadingKind.work => Icons.auto_stories_outlined,
    ReadingKind.history => Icons.timeline,
  };

  /// "Poem · Bayt 4 of 6" — the kind of text plus where the reader stopped.
  static String _resumeSubtitle(
    ReadingPosition position,
    DisplayLanguage lang,
  ) {
    final kind = switch (position.kind) {
      ReadingKind.work => AppTranslations.get('lit_genre_poem', lang),
      ReadingKind.proverb =>
        lang == DisplayLanguage.persian ? 'ضرب‌المثل' : 'Зарбулмасал',
      ReadingKind.history =>
        lang == DisplayLanguage.persian ? 'تاریخ' : 'Таърих',
    };
    final anchor = position.anchor;
    final total = position.anchorTotal;
    if (anchor == null || total == null || anchor < 2) return kind;
    final where = AppTranslations.get(
      position.anchorIsBayt ? 'resume_bayt' : 'resume_line',
      lang,
      [anchor, total],
    );
    return '$kind · $where';
  }
}
