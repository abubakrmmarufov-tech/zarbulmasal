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

  static const List<String> levelNamesFa = [
    'مبتدی',
    'آسان',
    'پایه',
    'عادی',
    'متوسط',
    'بالاتر از متوسط',
    'پیشرفته',
    'متخصص',
    'استاد',
    'دانشمند',
  ];

  static String getLevelName(int level) {
    if (level < 1 || level > 10) return 'Номаълум';
    return levelNames[level - 1];
  }

  static String getLevelNameFa(int level) {
    if (level < 1 || level > 10) return 'نامشخص';
    return levelNamesFa[level - 1];
  }
}
