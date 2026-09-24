import 'package:flutter/foundation.dart';
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
    final colors = Theme.of(context).colorScheme;
    final edition = book.primaryEdition;
    final coverUri = edition?.coverUri;
    final coverAssetPath = edition?.coverAssetPath;
    final placeholder = _PlaceholderCover(
      book: book,
      width: width,
      height: height,
      title: placeholderTitle ?? book.titleTj,
    );

    if (coverAssetPath != null && coverAssetPath.trim().isNotEmpty) {
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

    // Kitobkhon does not send CORS headers for its cover assets. Native
    // clients can display the verified remote image when no checked-in copy
    // exists; web safely uses the truthful placeholder rather than emitting
    // a broken-image request.
    if (kIsWeb || coverUri == null) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
      child: Image.network(
        coverUri.toString(),
        width: width,
        height: height,
        // Decode at the size shown, not the provider's full-size scan.
        cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: colors.surfaceContainerHighest,
            alignment: Alignment.center,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!,
              ),
            ),
          );
        },
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
