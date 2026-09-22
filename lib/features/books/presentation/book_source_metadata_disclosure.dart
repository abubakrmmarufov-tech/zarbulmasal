import 'package:flutter/material.dart';

import '../../../core/design_system/qalam_typography.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/book.dart';
import 'book_display_text.dart';

/// Makes source-language book metadata discoverable without presenting it as
/// a Persian translation.
class BookSourceMetadataDisclosure extends StatelessWidget {
  final Book book;
  final DisplayLanguage language;
  final bool compact;

  const BookSourceMetadataDisclosure({
    super.key,
    required this.book,
    required this.language,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final title = BookDisplayText.originalTitle(book, language);
    final author = BookDisplayText.originalAuthor(book, language);
    if (title == null && author == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            _OriginalSourceField(
              label: AppTranslations.get(
                'books_original_title_tajik',
                language,
              ),
              value: title,
              colors: colors,
              compact: compact,
            ),
          if (author != null) ...[
            if (title != null) const SizedBox(height: 4),
            _OriginalSourceField(
              label: AppTranslations.get(
                'books_original_author_tajik',
                language,
              ),
              value: author,
              colors: colors,
              compact: compact,
            ),
          ],
        ],
      ),
    );
  }
}

class _OriginalSourceField extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colors;
  final bool compact;

  const _OriginalSourceField({
    required this.label,
    required this.value,
    required this.colors,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: QalamTypography.eyebrow(color: colors.primary)),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            maxLines: compact ? 2 : null,
            overflow: compact ? TextOverflow.ellipsis : TextOverflow.clip,
            style: QalamTypography.meta(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
