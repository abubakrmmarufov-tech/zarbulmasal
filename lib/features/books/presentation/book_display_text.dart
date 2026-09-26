import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/book.dart';
import 'book_category_display_text.dart';

/// Locale-aware book values for widgets, keeping translation policy out of the
/// domain model and distinguishing source metadata from Persian display text.
abstract final class BookDisplayText {
  static String title(Book book, DisplayLanguage language) {
    final value = book.titleFor(language).trim();
    return value.isNotEmpty
        ? value
        : AppTranslations.get('books_title_translation_pending', language);
  }

  /// The title drawn on a typographic cover: the title in [language]; a
  /// book with no Persian title shows its category's name («شعر») rather
  /// than a sentence saying the title is missing.
  static String coverTitle(Book book, DisplayLanguage language) {
    final value = book.titleFor(language).trim();
    if (value.isNotEmpty) return value;
    for (final category in book.categoryIds) {
      final label = BookCategoryDisplayText.label(category, language);
      if (label !=
          AppTranslations.get('books_category_translation_pending', language)) {
        return label;
      }
    }
    return AppTranslations.get('books_title', language);
  }

  static String? author(Book book, DisplayLanguage language) {
    final value = book.authorFor(language)?.trim() ?? '';
    if (value.isNotEmpty) return value;
    if (language == DisplayLanguage.persian &&
        originalAuthor(book, language) != null) {
      return AppTranslations.get('books_author_translation_pending', language);
    }
    return null;
  }

  static String? originalTitle(Book book, DisplayLanguage language) {
    if (language != DisplayLanguage.persian ||
        book.titleFor(language).trim().isNotEmpty) {
      return null;
    }
    final value = book.titleTj.trim();
    return value.isEmpty ? null : value;
  }

  static String? originalAuthor(Book book, DisplayLanguage language) {
    if (language != DisplayLanguage.persian ||
        book.authorFor(language)?.trim().isNotEmpty == true) {
      return null;
    }
    final value = book.authorNameTj?.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static String description(Book book, DisplayLanguage language) =>
      book.descriptionFor(language);
}
