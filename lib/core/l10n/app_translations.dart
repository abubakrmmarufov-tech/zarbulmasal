import '../../shared/providers/app_providers.dart';
import 'strings_fa_a.dart';
import 'strings_fa_b.dart';
import 'strings_tj_a.dart';
import 'strings_tj_b.dart';

class AppTranslations {
  AppTranslations._();

  static const Map<String, String> tj = {...tajikStringsA, ...tajikStringsB};

  static const Map<String, String> fa = {
    ...persianStringsA,
    ...persianStringsB,
  };

  /// Whether a key is present in both language maps, so callers can branch on
  /// provider-specific labels without leaking the raw key as display text.
  static bool hasKey(String key) => tj.containsKey(key) && fa.containsKey(key);

  static String get(
    String key,
    DisplayLanguage lang, [
    List<Object> args = const [],
  ]) {
    final map = lang == DisplayLanguage.persian ? fa : tj;
    String result = map[key] ?? tj[key] ?? key;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('\${$i}', _formatArgument(args[i], lang));
    }
    return result;
  }

  static String translate(
    String key,
    DisplayLanguage lang, [
    List<Object> args = const [],
  ]) => get(key, lang, args);

  static String getForLang(
    String langCode,
    String key, [
    List<Object> args = const [],
  ]) {
    final lang = langCode == 'fa'
        ? DisplayLanguage.persian
        : DisplayLanguage.tajik;
    return get(key, lang, args);
  }

  static String getForIsPersian(
    bool isPersian,
    String key, [
    List<Object> args = const [],
  ]) {
    return get(
      key,
      isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik,
      args,
    );
  }

  static String formatDigits(String text, DisplayLanguage lang) {
    if (lang != DisplayLanguage.persian) return text;
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    return text.split('').map((character) {
      final index = western.indexOf(character);
      return index < 0 ? character : persian[index];
    }).join();
  }

  static String formatNumber(Object number, DisplayLanguage lang) {
    return formatDigits(number.toString(), lang);
  }

  static String _formatArgument(Object argument, DisplayLanguage language) {
    return formatNumber(argument, language);
  }

  static const List<String> monthNamesTj = [
    '',
    'Январ',
    'Феврал',
    'Март',
    'Апрел',
    'Май',
    'Июн',
    'Июл',
    'Август',
    'Сентябр',
    'Октябр',
    'Ноябр',
    'Декабр',
  ];

  static const List<String> monthNamesFa = [
    '',
    'ژانویه',
    'فوریه',
    'مارس',
    'آوریل',
    'مه',
    'ژوئن',
    'ژوئیه',
    'اوت',
    'سپتامبر',
    'اکتبر',
    'نوامبر',
    'دسامبر',
  ];

  static String getMonthName(int month, DisplayLanguage lang) {
    if (month < 1 || month > 12) return '';
    return lang == DisplayLanguage.persian
        ? monthNamesFa[month]
        : monthNamesTj[month];
  }
}
