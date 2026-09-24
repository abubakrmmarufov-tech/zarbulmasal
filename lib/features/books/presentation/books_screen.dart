import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/utils/search_normalizer.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/books_providers.dart';
import '../domain/book_domain.dart';
import 'book_category_display_text.dart';
import 'book_cover.dart';
import 'book_display_text.dart';
import 'book_source_metadata_disclosure.dart';
import '../../../core/utils/search_field_limits.dart';

class BooksScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialAuthorId;

  const BooksScreen({super.key, this.initialCategory, this.initialAuthorId});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;
    final booksAsync = ref.watch(booksProvider);
    final providersAsync = ref.watch(bookProvidersProvider);
    final favorites = ref.watch(bookFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          AppTranslations.get('books_title', lang),
          style: QalamTypography.sectionTitle(color: colors.onSurface),
        ),
        actions: [
          IconButton(
            tooltip: AppTranslations.get('search_hint_global', lang),
            icon: const Icon(Icons.search),
            onPressed: () => _searchController.text.isEmpty
                ? FocusScope.of(context).requestFocus()
                : setState(() {
                    _searchController.clear();
                    _query = '';
                  }),
          ),
        ],
      ),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: EmptyState(
            icon: Icons.menu_book_outlined,
            title: AppTranslations.get('books_load_error', lang),
            subtitle: AppTranslations.get('books_load_error_sub', lang),
            action: OutlinedButton(
              onPressed: () => ref.invalidate(booksProvider),
              child: Text(AppTranslations.get('btn_retry', lang)),
            ),
          ),
        ),
        data: (books) {
          final filtered = _filterBooks(books);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: QalamPageHeader(
                  eyebrow: AppTranslations.get('books_eyebrow', lang),
                  title: AppTranslations.get('books_title', lang),
                  subtitle: AppTranslations.get('books_subtitle', lang),
                ),
              ),
              SliverToBoxAdapter(child: _buildSearchField(context, lang)),
              SliverToBoxAdapter(
                child: _buildProviderSummary(
                  context,
                  lang,
                  providersAsync.valueOrNull ?? const [],
                ),
              ),
              SliverToBoxAdapter(
                child: _buildCategoryFilters(context, lang, books),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: AppTranslations.get('books_no_results', lang),
                    subtitle: AppTranslations.get('books_no_results_sub', lang),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      AppTranslations.translate('books_count', lang, [
                        filtered.length,
                      ]),
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final book = filtered[index];
                      return _BookListTile(
                        book: book,
                        lang: lang,
                        isFavorite: favorites.contains(book.id),
                        onTap: () => context.push('/books/${book.id}'),
                        onToggleFavorite: () => ref
                            .read(bookFavoritesProvider.notifier)
                            .toggle(book.id),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Book> _filterBooks(List<Book> books) {
    final query = SearchNormalizer.normalize(_query);
    return books
        .where((book) {
          final matchesQuery = query.isEmpty || book.matches(query);
          final matchesCategory =
              _category == null || book.categoryIds.contains(_category);
          final matchesAuthor =
              widget.initialAuthorId == null ||
              book.authorId == widget.initialAuthorId;
          return matchesQuery && matchesCategory && matchesAuthor;
        })
        .toList(growable: false);
  }

  Widget _buildSearchField(BuildContext context, DisplayLanguage lang) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        inputFormatters: searchQueryFormatters,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: AppTranslations.get('books_search_hint', lang),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: AppTranslations.get('btn_clear', lang),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.clear),
                ),
          filled: true,
          fillColor: colors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSummary(
    BuildContext context,
    DisplayLanguage lang,
    List<BookProvider> providers,
  ) {
    if (providers.isEmpty) return const SizedBox(height: 8);
    final colors = Theme.of(context).colorScheme;
    // Plain lines, no box. Catalogue figures appear only when all three
    // are recorded (no "— китоб · — муаллиф").
    String? stats(BookProvider provider) {
      final size = provider.catalogueSize;
      final authors = provider.authorCount;
      final categories = provider.categoryCount;
      if (size == null || authors == null || categories == null) return null;
      return AppTranslations.translate('books_provider_stats', lang, [
        size,
        authors,
        categories,
      ]);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final provider in providers)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: provider.name,
                          style: QalamTypography.label(color: colors.onSurface),
                        ),
                        TextSpan(
                          text: '  ${provider.domain}',
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (stats(provider) != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      stats(provider)!,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    DisplayLanguage lang,
    List<Book> books,
  ) {
    final categories = books
        .expand((book) => book.categoryIds)
        .toSet()
        .toList(growable: false);
    // Keep the horizontal filter rail at least 48 logical pixels high. The
    // previous 54px viewport left only 38px for the chip after vertical
    // padding, which made the visible control smaller than the Android
    // touch-target guidance on physical devices.
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final id = index == 0 ? null : categories[index - 1];
          return FilterChip(
            label: Text(
              id == null
                  ? AppTranslations.get('books_all', lang)
                  : _categoryLabel(id, lang),
            ),
            selected: _category == id,
            onSelected: (_) => setState(() => _category = id),
          );
        },
      ),
    );
  }

  String _categoryLabel(String id, DisplayLanguage lang) {
    return BookCategoryDisplayText.label(id, lang);
  }
}

class _BookListTile extends StatelessWidget {
  final Book book;
  final DisplayLanguage lang;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _BookListTile({
    required this.book,
    required this.lang,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return QalamSlip(
      onTap: onTap,
      showChevron: false,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            book: book,
            placeholderTitle: BookDisplayText.title(book, lang),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BookDisplayText.title(book, lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.literaryTitle(
                    color: colors.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  BookDisplayText.author(book, lang) ??
                      AppTranslations.get('books_author_unavailable', lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                BookSourceMetadataDisclosure(book: book, language: lang),
                if (_editionLine(book, lang) case final line?) ...[
                  const SizedBox(height: 6),
                  Text(
                    line,
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: AppTranslations.get(
              isFavorite ? 'bookmark_remove' : 'bookmark_add',
              lang,
            ),
            onPressed: onToggleFavorite,
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_outline),
            color: isFavorite ? colors.primary : colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// Format, year and pages as one meta line ("PDF · 2015 · 240 саҳ.").
String? _editionLine(Book book, DisplayLanguage lang) {
  final edition = book.primaryEdition;
  if (edition == null) return null;
  return [
    _formatLabel(edition.format, lang),
    ?edition.publicationYear,
    if (edition.pageCount != null)
      AppTranslations.translate('books_page_count', lang, [edition.pageCount!]),
  ].join(' · ');
}

/// Format badge label derived from the edition's real format so an online
/// HTML reader is never presented as a PDF.
String _formatLabel(BookFormat format, DisplayLanguage lang) {
  final key = switch (format) {
    BookFormat.pdf => 'books_format_pdf',
    BookFormat.epub => 'books_format_epub',
    BookFormat.html => 'books_format_html',
    BookFormat.externalReader => 'books_format_external_reader',
    BookFormat.catalogue => 'books_format_catalogue',
  };
  return AppTranslations.get(key, lang);
}
