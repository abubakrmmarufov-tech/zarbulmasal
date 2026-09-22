import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/book.dart';

/// Locale-aware book values for widgets, keeping translation policy out of the
/// domain model and distinguishing source metadata from Persian display text.
abstract final class BookDisplayText {
  static String title(Book book, DisplayLanguage language) {
    final value = book.titleFor(language).trim();
    return value.isNotEmpty
        ? value
        : AppTranslations.get('books_title_translation_pending', language);
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
