import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';

/// Labels for the long-form reading sections of the history detail screen.
/// The strings live in lib/core/l10n with the rest of the app's text.
abstract final class HistorySectionLabels {
  /// Eyebrow heading above the list of long-form reading sections.
  static String readingTitle(DisplayLanguage language) =>
      AppTranslations.get('hist_reading_title', language);

  /// Marks a Persian rendering as an editorial translation of the Tajik
  /// source witness, never as an independent original text.
  static String editorialNote(DisplayLanguage language) =>
      AppTranslations.get('hist_editorial_note', language);

  /// Caption shown when the section body falls back to the Tajik source
  /// witness (there is no Persian rendering of the body), so a Persian-mode
  /// reader knows the paragraph is the original source-language text.
  static String sourceLanguageNote(DisplayLanguage language) =>
      AppTranslations.get('hist_source_language_note', language);

  /// Caption naming the book a section cites when it differs from the entry's
  /// own source book (e.g. a poem drawn from a literature textbook).
  static String sourceBookCaption(DisplayLanguage language, String title) =>
      AppTranslations.get('hist_section_source', language, [title]);
}
