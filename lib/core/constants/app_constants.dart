class AppConstants {
  AppConstants._();

  static const String appName = 'Зарбулмасал';
  static const String prefsDarkMode = 'dark_mode';
  static const String prefsFavorites = 'favorites';
  static const String prefsLanguage = 'display_language';

  static const List<String> levelNames = [
    'Оғоз',
    'Осон',
    'Асосӣ',
    'Нормалӣ',
    'Миёна',
    'Аз миёна баланд',
    'Продвинута',
    'Эксперт',
    'Усто',
    'Олим',
  ];

  static String getLevelName(int level) {
    if (level < 1 || level > 10) return 'Номаълум';
    return levelNames[level - 1];
  }
}
