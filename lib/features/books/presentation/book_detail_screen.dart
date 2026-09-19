import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/books_providers.dart';
import '../domain/book_domain.dart';
import 'book_cover.dart';

class BookDetailScreen extends ConsumerWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final bookAsync = ref.watch(bookByIdProvider(bookId));
    return bookAsync.when(
      loading: () => Scaffold(
        appBar: _appBar(context, lang),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: _appBar(context, lang),
        body: EmptyState(
          icon: Icons.error_outline,
          title: AppTranslations.get('books_load_error', lang),
          subtitle: AppTranslations.get('books_load_error_sub', lang),
        ),
      ),
      data: (book) => book == null
          ? Scaffold(
              appBar: _appBar(context, lang),
              body: EmptyState(
                icon: Icons.menu_book_outlined,
                title: AppTranslations.get('books_no_results', lang),
                subtitle: AppTranslations.get('books_no_results_sub', lang),
              ),
            )
          : _BookDetailBody(book: book),
    );
  }

  AppBar _appBar(BuildContext context, DisplayLanguage lang) {
    return AppBar(
      leading: IconButton(
        tooltip: AppTranslations.get('btn_back', lang),
        icon: const BackButtonIcon(),
        onPressed: () => qalamBack(context),
      ),
      title: Text(AppTranslations.get('books_title', lang)),
    );
  }
}

class _BookDetailBody extends ConsumerWidget {
  final Book book;

  const _BookDetailBody({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;
    final edition = book.primaryEdition;
    final isFavorite = ref.watch(bookFavoritesProvider).contains(book.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(AppTranslations.get('books_title', lang)),
        actions: [
          IconButton(
            tooltip: AppTranslations.get(
              isFavorite ? 'bookmark_remove' : 'bookmark_add',
              lang,
            ),
            onPressed: () =>
                ref.read(bookFavoritesProvider.notifier).toggle(book.id),
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_outline),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(book: book, width: 116, height: 170),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.titleFor(lang),
                            style: QalamTypography.pageTitle(
                              color: colors.onSurface,
                              fontSize: 26,
                            ),
                          ),
                          if (book.authorFor(lang) != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              book.authorFor(lang)!,
                              style: QalamTypography.bodySecondary(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          if (edition != null)
                            _AvailabilityBadge(edition: edition, lang: lang),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (edition != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ActionPanel(book: book, edition: edition, lang: lang),
                ),
              ),
            if (edition != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _MetadataGrid(edition: edition, lang: lang),
                ),
              ),
            if (book.descriptionFor(lang).trim().isNotEmpty)
              SliverToBoxAdapter(
                child: _Section(
                  title: AppTranslations.get('books_description', lang),
                  child: Text(
                    book.descriptionFor(lang),
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            if (book.authorId != null)
              SliverToBoxAdapter(
                child: _Section(
                  title: AppTranslations.get('books_related_author', lang),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline, color: colors.primary),
                    title: Text(book.authorFor(lang) ?? ''),
                    trailing: const QalamChevron(size: 20),
                    onTap: () =>
                        context.push('/literature/poet/${book.authorId}'),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _Section(
                title: AppTranslations.get('books_category', lang),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (edition?.categories ?? book.categoryIds)
                      .map(
                        (category) => Chip(
                          label: Text(category),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _Section(
                title: AppTranslations.get('books_provider', lang),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Китобхон · kitobkhon.net',
                      style: QalamTypography.body(color: colors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      edition?.metadataNote ?? '',
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final Book book;
  final BookEdition edition;
  final DisplayLanguage lang;

  const _ActionPanel({
    required this.book,
    required this.edition,
    required this.lang,
  });

  Future<void> _open(BuildContext context, String url) async {
    final didLaunch = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.get('books_link_error', lang))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: edition.canRead
              ? () => _open(context, edition.readUrl!)
              : null,
          icon: const Icon(Icons.open_in_new),
          label: Text(AppTranslations.get('books_read_on_provider', lang)),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: edition.sourceUrl.isEmpty
              ? null
              : () => _open(context, edition.sourceUrl),
          icon: const Icon(Icons.source_outlined),
          label: Text(AppTranslations.get('books_source_page', lang)),
        ),
        const SizedBox(height: 10),
        if (edition.rightsStatus == BookRightsStatus.rightsUnclear)
          Text(
            AppTranslations.get('books_rights_unclear', lang),
            textAlign: TextAlign.center,
            style: QalamTypography.meta(color: colors.error),
          ),
        if (edition.rightsStatus == BookRightsStatus.rightsUnclear)
          const SizedBox(height: 6),
        Text(
          AppTranslations.get('books_external_note', lang),
          textAlign: TextAlign.center,
          style: QalamTypography.meta(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final BookEdition edition;
  final DisplayLanguage lang;

  const _AvailabilityBadge({required this.edition, required this.lang});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        edition.canRead
            ? AppTranslations.get('books_read', lang)
            : AppTranslations.get('books_catalogue_only', lang),
        style: QalamTypography.meta(color: colors.onPrimaryContainer),
      ),
    );
  }
}

class _MetadataGrid extends StatelessWidget {
  final BookEdition edition;
  final DisplayLanguage lang;

  const _MetadataGrid({required this.edition, required this.lang});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      if (edition.publisher != null)
        (AppTranslations.get('books_publisher', lang), edition.publisher!),
      if (edition.publicationYear != null)
        (AppTranslations.get('books_year', lang), edition.publicationYear!),
      if (edition.pageCount != null)
        (
          AppTranslations.get('books_pages', lang),
          edition.pageCount.toString(),
        ),
      (AppTranslations.get('books_language', lang), edition.language),
      if (edition.scripts.isNotEmpty)
        (AppTranslations.get('books_script', lang), edition.scripts.join(', ')),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              constraints: const BoxConstraints(minWidth: 130),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: QalamTypography.meta(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: QalamTypography.label(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
