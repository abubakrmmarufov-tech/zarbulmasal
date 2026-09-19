import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../domain/book_domain.dart';

class BookCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;

  const BookCover({
    super.key,
    required this.book,
    this.width = 72,
    this.height = 104,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final edition = book.primaryEdition;
    final coverUrl = edition?.coverUrl;
    final placeholder = _PlaceholderCover(
      book: book,
      width: width,
      height: height,
    );

    // Kitobkhon does not send CORS headers for its cover assets. Native
    // clients can display the verified remote image, while web safely uses
    // the truthful placeholder instead of emitting a broken-image request.
    if (kIsWeb || coverUrl == null || coverUrl.trim().isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
      child: Image.network(
        coverUrl,
        width: width,
        height: height,
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

  const _PlaceholderCover({
    required this.book,
    required this.width,
    required this.height,
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
          Text(
            book.titleTj,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: QalamTypography.meta(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
