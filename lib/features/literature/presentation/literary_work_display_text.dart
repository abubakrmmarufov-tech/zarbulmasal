import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/literary_work.dart';

/// Language-safe display values for literary works.
abstract final class LiteraryWorkDisplayText {
  static String title(LiteraryWork work, DisplayLanguage language) {
    if (language != DisplayLanguage.persian) return work.title;
    final translated = work.titlePersian?.trim() ?? '';
    return translated.isNotEmpty
        ? translated
        : AppTranslations.get('lit_work_title_persian_pending', language);
  }

  /// The corpus stores only the source-language incipit; do not leak it into
  /// Persian UI until a reviewed Persian field is available.
  static String? incipit(LiteraryWork work, DisplayLanguage language) {
    if (language == DisplayLanguage.persian) return null;
    final value = work.incipit?.trim() ?? '';
    return value.isEmpty ? null : value;
  }
}
