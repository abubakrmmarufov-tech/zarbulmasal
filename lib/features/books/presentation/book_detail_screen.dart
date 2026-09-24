import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/utils/trusted_url_launcher.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/books_providers.dart';
import '../domain/book_domain.dart';
import '../../literature/data/literature_providers.dart';
import '../../literature/domain/domain.dart';
import '../../literature/presentation/literary_author_display_text.dart';
import 'book_category_display_text.dart';
import 'book_cover.dart';
import 'book_display_text.dart';
import 'book_source_metadata_disclosure.dart';

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
          action: OutlinedButton(
            onPressed: () {
              ref.invalidate(booksProvider);
              ref.invalidate(bookByIdProvider(bookId));
            },
            child: Text(AppTranslations.get('btn_retry', lang)),
          ),
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
    final relatedPoetIds = book.relatedPoetIds
        .where((id) => id != book.authorId)
        .toSet()
        .toList(growable: false);
    final relatedPoets = <LiteraryAuthor>[];
    for (final id in relatedPoetIds) {
      ref
          .watch(authorByIdProvider(id))
          .when(
            data: (author) {
              if (author != null) relatedPoets.add(author);
            },
            loading: () {},
            error: (_, _) {},
          );
    }

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
                    BookCover(
                      book: book,
                      width: 116,
                      height: 170,
                      placeholderTitle: BookDisplayText.title(book, lang),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            BookDisplayText.title(book, lang),
                            style: QalamTypography.pageTitle(
                              color: colors.onSurface,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            BookDisplayText.author(book, lang) ??
                                AppTranslations.get(
                                  'books_author_unavailable',
                                  lang,
                                ),
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
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
            if (BookDisplayText.originalTitle(book, lang) != null ||
                BookDisplayText.originalAuthor(book, lang) != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BookSourceMetadataDisclosure(
                    book: book,
                    language: lang,
                    compact: false,
                  ),
                ),
              ),
            if (edition != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ActionPanel(
                    book: book,
                    edition: edition,
                    lang: lang,
                    providerId: edition.providerId,
                  ),
                ),
              ),
            if (edition != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _MetadataGrid(edition: edition, lang: lang),
                ),
              ),
            if (BookDisplayText.description(book, lang).trim().isNotEmpty)
              SliverToBoxAdapter(
                child: _Section(
                  title: AppTranslations.get('books_description', lang),
                  child: Text(
                    BookDisplayText.description(book, lang),
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            if (BookDisplayText.author(book, lang)?.trim().isNotEmpty == true)
              SliverToBoxAdapter(
                child: _Section(
                  title: AppTranslations.get(
                    book.authorId == null
                        ? 'books_source_author'
                        : 'books_related_author',
                    lang,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline, color: colors.primary),
                    title: Text(BookDisplayText.author(book, lang) ?? ''),
                    trailing: book.authorId == null
                        ? null
                        : const QalamChevron(size: 20),
                    onTap: book.authorId == null
                        ? null
                        : () =>
                              context.push('/literature/poet/${book.authorId}'),
                  ),
                ),
              ),
            if (relatedPoets.isNotEmpty)
              SliverToBoxAdapter(
                child: _Section(
                  title: AppTranslations.get('books_related_poets', lang),
                  child: Column(
                    children: relatedPoets
                        .map((author) {
                          final title = LiteraryAuthorDisplayText.name(
                            author,
                            lang,
                          );
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.auto_stories_outlined,
                              color: colors.primary,
                            ),
                            title: Text(title),
                            trailing: const QalamChevron(size: 20),
                            onTap: () =>
                                context.push('/literature/poet/${author.id}'),
                          );
                        })
                        .toList(growable: false),
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
                          label: Text(
                            BookCategoryDisplayText.label(category, lang),
                          ),
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
                      _providerNameLabel(edition?.providerId, lang),
                      style: QalamTypography.body(color: colors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    if (edition?.metadataNote.trim().isNotEmpty == true)
                      Text(
                        lang == DisplayLanguage.persian
                            ? AppTranslations.get(
                                'books_metadata_note_translation_pending',
                                lang,
                              )
                            : edition!.metadataNote,
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
  final String providerId;

  const _ActionPanel({
    required this.book,
    required this.edition,
    required this.lang,
    required this.providerId,
  });

  Future<void> _open(BuildContext context, Uri uri) async {
    final didLaunch = await launchTrustedExternal(uri);
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
              ? () => _open(context, edition.readUri!)
              : null,
          icon: const Icon(Icons.open_in_new),
          label: Text(_providerReadLabel(providerId, lang)),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: edition.sourceUri == null
              ? null
              : () => _open(context, edition.sourceUri!),
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
    final items = <({String label, String value, TextDirection? direction})>[
      if (edition.publisher != null)
        (
          label: AppTranslations.get(
            lang == DisplayLanguage.persian
                ? 'books_original_publisher_tajik'
                : 'books_publisher',
            lang,
          ),
          value: edition.publisher!,
          direction: lang == DisplayLanguage.persian ? TextDirection.ltr : null,
        ),
      if (edition.publicationYear != null)
        (
          label: AppTranslations.get('books_year', lang),
          value: AppTranslations.formatDigits(edition.publicationYear!, lang),
          direction: null,
        ),
      if (edition.pageCount != null)
        (
          label: AppTranslations.get('books_pages', lang),
          value: AppTranslations.formatDigits(
            edition.pageCount.toString(),
            lang,
          ),
          direction: null,
        ),
      (
        label: AppTranslations.get('books_language', lang),
        value: _localizedBookLanguage(edition.language, lang),
        direction: null,
      ),
      if (edition.scripts.isNotEmpty)
        (
          label: AppTranslations.get('books_script', lang),
          value: edition.scripts
              .map((script) => _localizedBookScript(script, lang))
              .join(', '),
          direction: null,
        ),
    ];
    // One definition list with hairlines instead of five boxed tiles.
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    item.label,
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.value,
                    textDirection: item.direction,
                    style: QalamTypography.label(
                      color: colors.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _localizedBookLanguage(String value, DisplayLanguage lang) {
  if (!_isPersian(lang)) return value;
  final normalized = value.trim().toLowerCase();
  if (normalized == 'тоҷикӣ' || normalized == 'tajik') {
    return AppTranslations.get('books_language_tajik', lang);
  }
  return value;
}

String _localizedBookScript(String value, DisplayLanguage lang) {
  final normalized = value.trim().toLowerCase();
  final key = switch (normalized) {
    'cyrillic' || 'кириллӣ' => 'books_script_cyrillic',
    'arabic' || 'арабӣ' || 'persian' || 'форсӣ' => 'books_script_arabic',
    'latin' || 'лотинӣ' => 'books_script_latin',
    _ => null,
  };
  return key == null ? value : AppTranslations.get(key, lang);
}

bool _isPersian(DisplayLanguage lang) => lang == DisplayLanguage.persian;

/// Provider name label derived from the edition's provider id.
///
/// Falls back to the generic Kitobkhon label only for unknown provider ids,
/// so a khirad edition is never presented as Kitobkhon.
String _providerNameLabel(String? providerId, DisplayLanguage lang) {
  final key = 'books_provider_name_$providerId';
  if (providerId != null && AppTranslations.hasKey(key)) {
    return AppTranslations.get(key, lang);
  }
  return AppTranslations.get('books_provider_name', lang);
}

/// "Read on `provider`" button label derived from the edition's provider id.
String _providerReadLabel(String providerId, DisplayLanguage lang) {
  final key = 'books_read_on_provider_$providerId';
  if (AppTranslations.hasKey(key)) {
    return AppTranslations.get(key, lang);
  }
  return AppTranslations.get('books_read_on_provider', lang);
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
