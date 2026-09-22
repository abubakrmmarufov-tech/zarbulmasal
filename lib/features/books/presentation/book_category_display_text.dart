import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';

abstract final class BookCategoryDisplayText {
  static String label(String sourceValue, DisplayLanguage language) {
    final value = sourceValue.trim().toLowerCase();
    final key = switch (value) {
      'nazm' || 'назм' => 'books_poetry',
      'nasr' || 'наср' => 'books_prose',
      'zindaginoma' || 'зиндагинома' => 'books_biographies',
      'ilmi' || 'илмӣ' => 'books_science',
      'adabiyoti-klassiki' || 'адабиёти классикӣ' => 'books_classical',
      'adabiyoti-muosir' || 'адабиёти муосир' => 'books_modern',
      'tarikh' || 'таърих' => 'books_history',
      'kitobhoi-darsi' || 'китобҳои дарсӣ' => 'books_textbooks',
      'sinfi-11' || 'синфи 11' => 'books_grade_11',
      _ => null,
    };

    if (key != null) return AppTranslations.get(key, language);
    return language == DisplayLanguage.persian
        ? AppTranslations.get('books_category_translation_pending', language)
        : sourceValue;
  }
}
