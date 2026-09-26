import '../../../shared/providers/app_providers.dart';

/// Small dedicated strings for the long-form reading sections of the history
/// detail screen.
///
/// Kept local to the history feature (rather than added to the global
/// translation bundle) because these labels exist only for the new reading
/// block and would otherwise touch translations owned by other features.
abstract final class HistorySectionLabels {
  /// Eyebrow heading above the list of long-form reading sections.
  static String readingTitle(DisplayLanguage language) =>
      language == DisplayLanguage.persian ? 'خوانش تفصیلی' : 'Хониши муфассал';

  /// Marks a Persian rendering as an editorial translation of the Tajik
  /// source witness, never as an independent original text.
  static String editorialNote(DisplayLanguage language) =>
      language == DisplayLanguage.persian
      ? 'ترجمهٔ ویراستاری از متن تاجیکی (سند اصلی به تاجیکی است)'
      : 'Тарҷумаи таҳрирӣ аз матни тоҷикӣ (сарчашма ба забони тоҷикӣ аст)';

  /// Caption shown when the section body falls back to the Tajik source
  /// witness (there is no Persian rendering of the body), so a Persian-mode
  /// reader knows the paragraph is the original source-language text.
  static String sourceLanguageNote(DisplayLanguage language) =>
      language == DisplayLanguage.persian
      ? 'متن اصلی به زبان تاجیکی (سیریلیک) است'
      : 'Матни аслӣ ба забони тоҷикӣ (кириллӣ) аст';

  /// Caption naming the book a section cites when it differs from the entry's
  /// own source book (e.g. a poem drawn from a literature textbook).
  static String sourceBookCaption(DisplayLanguage language, String title) =>
      language == DisplayLanguage.persian
      ? 'منبع این بخش: $title'
      : 'Сарчашмаи ин бахш: $title';
}
