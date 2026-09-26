import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/script_direction.dart';
import '../domain/book_domain.dart';

/// A book's cover: the bundled image when there is one, else a typographic
/// cover — the category's «Атлас» ikat band over the title and author in
/// the interface language ([placeholderTitle], [placeholderAuthor]).
class BookCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final String? placeholderTitle;

  /// The author in the interface language; none is shown when null.
  final String? placeholderAuthor;

  const BookCover({
    super.key,
    required this.book,
    this.width = 72,
    this.height = 104,
    this.placeholderTitle,
    this.placeholderAuthor,
  });

  /// The ikat seed of a book's first category, so every book of a category
  /// wears the same band.
  static String bandSeed(Book book) {
    final category = book.categoryIds.isEmpty
        ? 'books'
        : book.categoryIds.first;
    return 'book-category-$category';
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = _TypographicCover(
      seed: bandSeed(book),
      width: width,
      height: height,
      title: placeholderTitle ?? book.titleTj,
      author: placeholderAuthor,
    );
    final coverAssetPath = book.primaryEdition?.coverAssetPath?.trim() ?? '';
    // The app is offline: only a bundled cover is drawn; a book whose cover
    // exists only on the provider's site shows the typographic cover.
    if (coverAssetPath.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
      child: Image.asset(
        coverAssetPath,
        width: width,
        height: height,
        cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

/// Drawn like a picture of a cover: its title is read beside it, so it is
/// hidden from screen readers and its text keeps the size the box allows.
class _TypographicCover extends StatelessWidget {
  final String seed;
  final double width;
  final double height;
  final String title;
  final String? author;

  static const _lineHeight = 1.2;
  static const _authorGap = 4.0;

  const _TypographicCover({
    required this.seed,
    required this.width,
    required this.height,
    required this.title,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final large = width >= 100;
    final small = width < 64;
    final band = (height * 0.2).clamp(12.0, 36.0);
    final pad = large ? 10.0 : (small ? 4.0 : 6.0);
    final authorText = author?.trim() ?? '';
    final showAuthor = !small && authorText.isNotEmpty;
    final titleSize = large ? 14.0 : (small ? 8.0 : 10.5);
    final authorSize = large ? 10.5 : 8.5;
    // Text is not scaled on the cover, so the lines that fit are known: the
    // body under the band, less the author's two lines and their gap.
    final body = height - band - 1 - 2 * pad;
    final authorSpace = showAuthor
        ? 2 * authorSize * _lineHeight + _authorGap
        : 0.0;
    final titleLines = ((body - authorSpace) / (titleSize * _lineHeight))
        .floor()
        .clamp(1, 5);
    final paper = theme.brightness == Brightness.dark
        ? colors.surfaceContainer
        : colors.surfaceContainerLowest;
    return ExcludeSemantics(
      child: MediaQuery.withNoTextScaling(
        child: Container(
          width: width,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
            border: Border.all(color: colors.onSurface.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: band,
                child: RepaintBoundary(child: AtlasCover(seed: seed)),
              ),
              Container(
                height: 1,
                color: colors.onSurface.withValues(alpha: 0.22),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          textDirection: scriptDirection(title),
                          maxLines: titleLines,
                          overflow: TextOverflow.ellipsis,
                          style: QalamTypography.literaryTitle(
                            color: colors.onSurface,
                            fontSize: titleSize,
                            height: _lineHeight,
                          ),
                        ),
                      ),
                      if (showAuthor) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: _authorGap),
                          child: Text(
                            authorText,
                            textDirection: scriptDirection(authorText),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: QalamTypography.meta(
                              color: colors.onSurfaceVariant,
                              fontSize: authorSize,
                              height: _lineHeight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
