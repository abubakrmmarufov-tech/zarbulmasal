class AppConstants {
  AppConstants._();

  static const String appName = 'Зарбулмасал';
  static const String privacyPolicyUrl =
      'https://abubakrmmarufov-tech.github.io/zarbulmasal/privacy.html';
  static const String prefsDarkMode = 'dark_mode';
  static const String prefsFavorites = 'favorites';
  static const String prefsLanguage = 'display_language';
  static const String prefsAppTextScale = 'app_text_scale';
  static const String prefsOnboardingComplete = 'onboarding_complete';
  static const String prefsLiteraryFavorites = 'literary_favorites';
  static const String prefsBookFavorites = 'book_favorites';
  static const String prefsMastery = 'proverb_mastery';

  static const List<String> levelNames = [
    'Оғозӣ',
    'Осон',
    'Асосӣ',
    'Миёна',
    'Мураккаб',
    'Мукаммал',
    'Пешрафта',
    'Кордон',
    'Устодӣ',
    'Олимӣ',
  ];

  static const List<String> levelNamesFa = [
    'مبتدی',
    'آسان',
    'پایه',
    'متوسط',
    'پیچیده',
    'پیشرفته',
    'کاردان',
    'تخصصی',
    'استادانه',
    'دانشمند',
  ];

  static String getLevelName(int level) {
    if (level < 1 || level > levelNames.length) return 'Номаълум';
    return levelNames[level - 1];
  }

  static String getLevelNameFa(int level) {
    if (level < 1 || level > levelNamesFa.length) return 'نامشخص';
    return levelNamesFa[level - 1];
  }
}
