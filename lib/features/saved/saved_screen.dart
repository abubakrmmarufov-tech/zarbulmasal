import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/recent_activity_display_text.dart';
import '../literature/data/literature_providers.dart';
import '../literature/presentation/literary_work_display_text.dart';
import '../books/data/books_providers.dart';
import '../books/presentation/book_display_text.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final favoriteProverbs = ref.watch(favoritesListProvider);
    final bookmarkedWorks =
        ref.watch(literaryFavoriteWorksProvider).valueOrNull ?? const [];
    final bookmarkedBooks =
        ref.watch(favoriteBooksProvider).valueOrNull ?? const [];

    final recentActivities = ref.watch(recentActivityProvider);
    String tr(String key) => AppTranslations.get(key, lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('saved_title'),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Saved Section Header
          Text(
            isPersian ? 'نشان‌شده‌ها' : 'Маҳфузҳо',
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),

          if (favoriteProverbs.isEmpty &&
              bookmarkedWorks.isEmpty &&
              bookmarkedBooks.isEmpty)
            Card(
              elevation: 0,
              color: colors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 40,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('saved_empty'),
                      style: QalamTypography.body(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('saved_empty_hint'),
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (favoriteProverbs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  '${tr('saved_proverbs')} (${favoriteProverbs.length})',
                  style: QalamTypography.eyebrow(color: colors.primary),
                ),
              ),
              ...favoriteProverbs.map((proverb) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: colors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.menu_book_outlined,
                      color: colors.primary,
                      size: 24,
                    ),
                    title: Text(
                      isPersian
                          ? (proverb.persianText.isNotEmpty
                                ? proverb.persianText
                                : proverb.tajikCyrillic)
                          : proverb.tajikCyrillic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.body(color: colors.onSurface),
                    ),
                    subtitle: Text(
                      isPersian
                          ? '${tr('reading_tajik_explanation')}: ${proverb.meaningTj}'
                          : proverb.meaningTj,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, size: 22),
                      color: colors.primary,
                      tooltip: tr('bookmark_remove'),
                      onPressed: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(proverb.id),
                    ),
                    onTap: () => context.push('/proverb/${proverb.id}'),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
            if (bookmarkedWorks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  '${tr('saved_works')} (${bookmarkedWorks.length})',
                  style: QalamTypography.eyebrow(color: colors.primary),
                ),
              ),
              ...bookmarkedWorks.map((work) {
                final incipit = LiteraryWorkDisplayText.incipit(work, lang);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: colors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.auto_stories_outlined,
                      color: colors.primary,
                      size: 24,
                    ),
                    title: Text(
                      LiteraryWorkDisplayText.title(work, lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.body(color: colors.onSurface),
                    ),
                    subtitle: incipit != null
                        ? Text(
                            incipit,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QalamTypography.meta(
                              color: colors.onSurfaceVariant,
                            ),
                          )
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, size: 22),
                      color: colors.primary,
                      tooltip: tr('bookmark_remove'),
                      onPressed: () => ref
                          .read(literaryFavoritesProvider.notifier)
                          .toggle(work.id),
                    ),
                    onTap: () => context.push('/literature/work/${work.id}'),
                  ),
                );
              }),
            ],
            if (bookmarkedBooks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 16),
                child: Text(
                  '${tr('books_saved')} (${bookmarkedBooks.length})',
                  style: QalamTypography.eyebrow(color: colors.primary),
                ),
              ),
              ...bookmarkedBooks.map((book) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: colors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.local_library_outlined,
                      color: colors.primary,
                    ),
                    title: Text(
                      BookDisplayText.title(book, lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.body(color: colors.onSurface),
                    ),
                    subtitle: BookDisplayText.author(book, lang) == null
                        ? null
                        : Text(
                            BookDisplayText.author(book, lang)!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QalamTypography.meta(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, size: 22),
                      color: colors.primary,
                      tooltip: tr('bookmark_remove'),
                      onPressed: () => ref
                          .read(bookFavoritesProvider.notifier)
                          .toggle(book.id),
                    ),
                    onTap: () => context.push('/books/${book.id}'),
                  ),
                );
              }),
            ],
          ],

          const SizedBox(height: 32),

          // Recent Activity Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tr('recent_activity'),
                  style: QalamTypography.sectionTitle(color: colors.onSurface),
                ),
              ),
              if (recentActivities.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClearHistory(context, ref, lang),
                  child: Text(
                    tr('recent_clear'),
                    style: QalamTypography.label(
                      color: colors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (recentActivities.isEmpty)
            Card(
              elevation: 0,
              color: colors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 40,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('recent_empty'),
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentActivities.map((activity) {
              final subtitle = RecentActivityDisplayText.subtitle(
                activity,
                lang,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: colors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    _iconForActivity(activity.type),
                    color: colors.primary,
                    size: 24,
                  ),
                  title: Text(
                    RecentActivityDisplayText.title(activity, lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: QalamTypography.body(color: colors.onSurface),
                  ),
                  subtitle: subtitle != null
                      ? Text(
                          subtitle,
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                          ),
                        )
                      : null,
                  trailing: const QalamChevron(size: 20),
                  onTap: () => context.push(activity.route),
                ),
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static IconData _iconForActivity(RecentActivityType type) {
    switch (type) {
      case RecentActivityType.proverb:
        return Icons.menu_book_outlined;
      case RecentActivityType.poet:
        return Icons.person_outline;
      case RecentActivityType.work:
        return Icons.auto_stories_outlined;
      case RecentActivityType.history:
        return Icons.timeline;
      case RecentActivityType.level:
        return Icons.stairs_outlined;
    }
  }

  void _confirmClearHistory(
    BuildContext context,
    WidgetRef ref,
    DisplayLanguage lang,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.get('recent_activity', lang)),
        content: Text(AppTranslations.get('recent_clear_confirm', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppTranslations.get('dialog_cancel', lang)),
          ),
          TextButton(
            onPressed: () {
              ref.read(recentActivityProvider.notifier).clearAll();
              Navigator.of(ctx).pop();
            },
            child: Text(
              AppTranslations.get('dialog_yes', lang),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
