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
import 'book_cover.dart';

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
                  providersAsync.valueOrNull?.firstOrNull,
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
        maxLength: 256,
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
    BookProvider? provider,
  ) {
    if (provider == null) return const SizedBox(height: 8);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.public, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: QalamTypography.label(color: colors.onSurface),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppTranslations.translate('books_provider_stats', lang, [
                      provider.catalogueSize ?? '—',
                      provider.authorCount ?? '—',
                      provider.categoryCount ?? '—',
                    ]),
                    style: QalamTypography.meta(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              provider.domain,
              style: QalamTypography.meta(color: colors.onSurfaceVariant),
            ),
          ],
        ),
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
    final key = switch (id) {
      'nazm' => 'books_poetry',
      'adabiyoti-klassiki' => 'books_classical',
      'adabiyoti-muosir' => 'books_modern',
      'tarikh' => 'books_history',
      'kitobhoi-darsi' || 'sinfi-11' => 'books_textbooks',
      _ => id,
    };
    return AppTranslations.get(key, lang);
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
    final edition = book.primaryEdition;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(book: book, placeholderTitle: book.titleFor(lang)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.titleFor(lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.literaryTitle(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      book.authorFor(lang) ??
                          AppTranslations.get('books_author_unavailable', lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MetaPill(
                          label: AppTranslations.get('books_pdf', lang),
                          colors: colors,
                        ),
                        if (edition?.publicationYear != null)
                          _MetaPill(
                            label: edition!.publicationYear!,
                            colors: colors,
                          ),
                        if (edition?.pageCount != null)
                          _MetaPill(
                            label: AppTranslations.translate(
                              'books_pages',
                              lang,
                              [edition!.pageCount!],
                            ),
                            colors: colors,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppTranslations.get(
                  isFavorite ? 'bookmark_remove' : 'bookmark_add',
                  lang,
                ),
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                ),
                color: isFavorite ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final ColorScheme colors;

  const _MetaPill({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: QalamTypography.meta(
          color: colors.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }
}
