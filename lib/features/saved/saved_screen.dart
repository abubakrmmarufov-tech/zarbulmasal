import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/bayoz_provider.dart';
import '../../shared/providers/reading_position_provider.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/recent_activity_display_text.dart';
import '../literature/data/literature_providers.dart';
import '../literature/presentation/literary_work_display_text.dart';
import '../books/data/books_providers.dart';
import '../books/presentation/book_display_text.dart';
import 'widgets/bayoz_cover.dart';
import '../../shared/widgets/bayoz_dialogs.dart';

/// «Баёзи ман» — the reader's own anthologies (typeset covers), then every
/// saved text, then reading history. Everything stays on this device.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    String tr(String key) => AppTranslations.get(key, lang);

    final collections = ref.watch(bayozProvider);
    final favoriteProverbs = ref.watch(favoritesListProvider);
    final bookmarkedWorks =
        ref.watch(literaryFavoriteWorksProvider).valueOrNull ?? const [];
    final bookmarkedBooks =
        ref.watch(favoriteBooksProvider).valueOrNull ?? const [];
    final recentActivities = ref.watch(recentActivityProvider);
    final savedCount =
        favoriteProverbs.length +
        bookmarkedWorks.length +
        bookmarkedBooks.length;
    final meta = QalamTypography.meta(color: colors.onSurfaceVariant);
    Widget eyebrow(String text) => Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 4),
      child: Text(text, style: QalamTypography.eyebrow(color: colors.primary)),
    );
    Widget remove(VoidCallback onPressed) => IconButton(
      icon: const Icon(Icons.bookmark, size: 22),
      color: colors.primary,
      tooltip: tr('bookmark_remove'),
      onPressed: onPressed,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('saved_title'),
          style: QalamTypography.monographTitle(
            color: colors.onSurface,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
        children: [
          Text(tr('bayoz_intro'), style: meta),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final columns = (constraints.maxWidth / 200).floor().clamp(2, 4);
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final bayoz in collections)
                    SizedBox(
                      width: width,
                      child: BayozCover(
                        title: bayoz.title,
                        countLabel: AppTranslations.get('bayoz_count', lang, [
                          AppTranslations.formatNumber(
                            bayoz.items.length,
                            lang,
                          ),
                        ]),
                        onTap: () => context.push('/saved/bayoz/${bayoz.id}'),
                      ),
                    ),
                  SizedBox(
                    width: width,
                    child: BayozCover(
                      title: tr('bayoz_new'),
                      isNew: true,
                      onTap: () async {
                        final name = await askBayozName(context, lang);
                        if (name == null) return;
                        final id = await ref
                            .read(bayozProvider.notifier)
                            .create(name);
                        if (id != null && context.mounted) {
                          await context.push('/saved/bayoz/$id');
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          if (collections.isEmpty) ...[
            const SizedBox(height: 8),
            Text(tr('bayoz_none_yet'), style: meta),
          ],
          eyebrow(
            '${tr('bayoz_all_saved').toUpperCase()} '
            '(${AppTranslations.formatNumber(savedCount, lang)})',
          ),
          if (savedCount == 0) ...[
            const SizedBox(height: 8),
            Text(
              tr('saved_empty'),
              style: QalamTypography.body(color: colors.onSurface),
            ),
            Text(tr('saved_empty_hint'), style: meta),
          ],
          for (final proverb in favoriteProverbs)
            _SavedRow(
              title: isPersian && proverb.persianText.isNotEmpty
                  ? proverb.persianText
                  : proverb.tajikCyrillic,
              subtitle: isPersian
                  ? '${tr('reading_tajik_explanation')}: ${proverb.meaningTj}'
                  : proverb.meaningTj,
              trailing: remove(
                () => ref.read(favoritesProvider.notifier).toggle(proverb.id),
              ),
              onTap: () => context.push('/proverb/${proverb.id}'),
            ),
          for (final work in bookmarkedWorks)
            _SavedRow(
              title: LiteraryWorkDisplayText.title(work, lang),
              subtitle: LiteraryWorkDisplayText.distinctIncipit(work, lang),
              trailing: remove(
                () => ref
                    .read(literaryFavoritesProvider.notifier)
                    .toggle(work.id),
              ),
              onTap: () => context.push('/literature/work/${work.id}'),
            ),
          for (final book in bookmarkedBooks)
            _SavedRow(
              title: BookDisplayText.title(book, lang),
              subtitle: BookDisplayText.author(book, lang),
              trailing: remove(
                () => ref.read(bookFavoritesProvider.notifier).toggle(book.id),
              ),
              onTap: () => context.push('/books/${book.id}'),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: eyebrow(tr('recent_activity').toUpperCase())),
              if (recentActivities.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClearHistory(context, ref, lang),
                  child: Text(tr('recent_clear')),
                ),
            ],
          ),
          if (recentActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(tr('recent_empty'), style: meta),
            ),
          for (final activity in recentActivities)
            _SavedRow(
              title: RecentActivityDisplayText.title(activity, lang),
              subtitle: RecentActivityDisplayText.subtitle(activity, lang),
              onTap: () => context.push(activity.route),
            ),
        ],
      ),
    );
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
              ref.read(readingPositionProvider.notifier).clear();
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

/// A saved text as a catalogue slip, with an optional trailing action such
/// as "remove bookmark".
class _SavedRow extends StatelessWidget {
  const _SavedRow({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return QalamSlip(
      onTap: onTap,
      showChevron: trailing == null,
      padding: EdgeInsetsDirectional.fromSTEB(
        16,
        12,
        trailing == null ? 12 : 4,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.literaryTitle(
                    color: colors.onSurface,
                    fontSize: 18,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: QalamTypography.meta(color: colors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
