import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../domain/book_domain.dart';

class BookCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final String? placeholderTitle;

  const BookCover({
    super.key,
    required this.book,
    this.width = 72,
    this.height = 104,
    this.placeholderTitle,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = _PlaceholderCover(
      book: book,
      width: width,
      height: height,
      title: placeholderTitle ?? book.titleTj,
    );
    final coverAssetPath = book.primaryEdition?.coverAssetPath?.trim() ?? '';
    // The app is offline: only a bundled cover is drawn; a book whose cover
    // exists only on the provider's site shows the typographic placeholder.
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

class _PlaceholderCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final String title;

  const _PlaceholderCover({
    required this.book,
    required this.width,
    required this.height,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, color: colors.primary, size: 24),
          const SizedBox(height: 6),
          // The title takes whatever height is left, so a short cover or a
          // large system text size never overflows the box.
          Flexible(
            child: Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: QalamTypography.meta(
                color: colors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
