import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';
import '../providers/recent_activity_provider.dart';

/// Renders persisted recent activity safely when the selected locale changes.
///
/// Activity records preserve their original text for Tajik display. Persian
/// uses localized type labels because stored titles and subtitles may have
/// been captured before the user switched languages.
abstract final class RecentActivityDisplayText {
  static final RegExp _cyrillic = RegExp(r'[\u0400-\u04FF]');
  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F]');
  static final RegExp _latin = RegExp(r'[A-Za-z]');

  static String title(RecentActivity activity, DisplayLanguage language) {
    if (language == DisplayLanguage.persian) {
      final localized = activity.titlePersian?.trim() ?? '';
      if (localized.isNotEmpty) return localized;
      if (_arabic.hasMatch(activity.title) &&
          !_cyrillic.hasMatch(activity.title) &&
          !_latin.hasMatch(activity.title)) {
        return activity.title;
      }
    } else {
      final localized = activity.titleTajik?.trim() ?? '';
      if (localized.isNotEmpty) return localized;
      if (_cyrillic.hasMatch(activity.title) &&
          !_arabic.hasMatch(activity.title)) {
        return activity.title;
      }
    }

    final key = switch (activity.type) {
      RecentActivityType.proverb => 'nav_proverbs',
      RecentActivityType.poet => 'lit_poets',
      RecentActivityType.work => 'lit_works_title',
      RecentActivityType.history => 'explore_history_title',
      RecentActivityType.level => 'nav_learn',
    };
    return AppTranslations.get(key, language);
  }

  static String? subtitle(RecentActivity activity, DisplayLanguage language) {
    final localized = language == DisplayLanguage.persian
        ? activity.subtitlePersian?.trim()
        : activity.subtitleTajik?.trim();
    if (localized?.isNotEmpty ?? false) return localized;

    final subtitle = activity.subtitle?.trim();
    if (subtitle == null || subtitle.isEmpty) return null;
    if (language == DisplayLanguage.persian) {
      if (_arabic.hasMatch(subtitle) &&
          !_cyrillic.hasMatch(subtitle) &&
          !_latin.hasMatch(subtitle)) {
        return subtitle;
      }
    } else if (_cyrillic.hasMatch(subtitle) && !_arabic.hasMatch(subtitle)) {
      return subtitle;
    }
    return null;
  }
}
