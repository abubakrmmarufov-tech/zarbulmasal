import '../../shared/providers/app_providers.dart';

class AppTranslations {
  AppTranslations._();

  static const Map<String, String> tj = {
    // Navigation
    'nav_home': 'Асосӣ',
    'nav_proverbs': 'Мақолҳо',
    'nav_categories': 'Гурӯҳҳо',
    'nav_favorites': 'Дӯст',
    'nav_settings': 'Танзимот',
    // Buttons
    'btn_back_home': 'Бозгашт ба асос',
    'btn_see_more': 'Бештар бинед',
    'btn_previous': 'Қаблӣ',
    'btn_next': 'Баъдӣ',
    'btn_start_over': 'Оғоз',
    'btn_show_meaning': 'Нишон додани маъно',
    'btn_clear_filters': 'Пок кардан',
    'btn_see_all': 'Ҳамаро бинед',
    'btn_next_question': 'Саволи нав',
    'btn_see_results': 'Натиҷаро бинед',
    'btn_new_quiz': 'Квизи нав',
    'btn_return': 'Бозгашт',
    // Home
    'home_greeting': 'Салом!',
    'home_subtitle': 'Имрӯз як мақоли навро омӯз.',
    'home_daily_proverb': 'Мақоли рӯз',
    'home_quick_actions': 'Квиз ва Флешкортҳо',
    'home_proverbs': 'Мақолҳо',
    'home_no_daily': 'Ҳоло мақоле дастрас нест.',
    // Quiz
    'quiz_title': 'Квиз',
    'quiz_question_of': 'Савол ${0} аз ${1}',
    'quiz_choose_meaning': 'Маънои дурустро интихоб кунед:',
    'quiz_correct_of': '${0} аз ${1} дуруст',
    'quiz_excellent': 'Аъло!',
    'quiz_good': 'Хуб!',
    'quiz_needs_work': 'Кобили қабул.',
    'quiz_loading': 'Загрузка...',
    // Flashcards
    'flashcards_title': 'Флешкортҳо',
    'flashcards_loading': 'Загрузка...',
    'flashcards_card_of': 'Карта ${0} аз ${1}',
    'flashcards_meaning': 'Маъно',
    'flashcards_explanation': 'Шарҳ',
    'flashcards_tap_to_hide': 'Тез клик кунед барои пинҳон кардан',
    'flashcards_tap_to_show': 'Барои пинҳон кардан клик кунед',
    // Settings
    'settings_title': 'Танзимот',
    'settings_subtitle': 'Танзимоти барнома',
    'settings_display': 'Намоиш',
    'settings_dark_mode': 'Режими торик',
    'settings_language': 'Забон',
    'settings_info': 'Маълумот',
    'settings_about': 'Дар бораи барнома',
    'settings_proverbs_count': '${0} мақол',
    'settings_source': 'Дар бораи сарчашма',
    'settings_source_title': 'Сарчашмаи мақолҳо',
    'settings_source_text':
        'Мақолҳои ин барнома аз сарчашмаҳои боэътимоди тоҷикӣ, '
        'аз китобҳои зарбулмасал, фолклори тоҷик ва захираҳои фарҳангии '
        'тоҷикӣ гирифта шудаанд.',
    'settings_source_text2':
        'Агар шумо сарчашмаи дурусти тоҷикиро медонед, лутфан '
        'пешниҳодҳоятонро ба мо фиристед.',
    'settings_contact': 'Пешниҳодҳо',
    'settings_contact_title': 'Тамос',
    'settings_contact_text': 'Агар шумо пешниҳодҳо ё таклифҳо доред, ба мо нависед:',
    'settings_version': 'Версия 1.0.0',
    'settings_year': '2026 Зарбулмасал',
    'settings_tagline': 'Мақолҳои тоҷикӣ — мероси фарҳангӣ',
    'settings_active': 'Фаъол',
    'settings_inactive': 'Гайрифаъол',
    'settings_about_text':
        'Зарбулмасал — барнома барои омӯзиш, фаҳмиш ва '
        'нигоҳдории мақолҳои тоҷикӣ.',
    'settings_close': 'Закрыть',
    // Empty states
    'empty_no_favorites': 'Ҳоло ягон мақол дӯст дошта нашудааст.',
    'empty_no_favorites_hint': 'Мақолҳоро ба даст бигиред.',
    'empty_no_proverbs_found': 'Мақол ёфт нашуд',
    'empty_change_filters': 'Филтрҳоро тағир диҳед',
    'empty_no_daily_proverb': 'Ҳоло мақоле барои имрӯз дастрас нест.',
    // Levels
    'levels_title': 'Сатҳҳо',
    'levels_subtitle': 'Аз оғоз то олим — 10 сатҳ',
    'levels_level': 'Сатҳ ${0}',
    'levels_proverbs': 'мақол',
    // Categories
    'categories_title': 'Гурӯҳҳо',
    'categories_subtitle': 'Гурӯҳҳои мақолҳо',
    // Daily
    'daily_title': 'Мақоли рӯз',
    'daily_not_available': 'Ҳоло мақоле барои имрӯз дастрас нест.',
    // Proverbs list
    'proverbs_title': 'Мақолҳо',
    'proverbs_search_hint': 'Ҷустуҷӯи мақол...',
    'proverbs_all_levels': 'Ҳама',
    'proverbs_no_results': 'Мақол ёфт нашуд',
    'proverbs_change_filters': 'Филтрҳоро тағир диҳед',
    // Proverb detail
    'detail_simple_explanation': 'Шарҳи оддӣ',
    'detail_meaning': 'Маъно',
    'detail_example': 'Мисол',
    'detail_source': 'Сарчашма',
    'detail_unknown': 'Номаълум',
    'detail_no_proverbs': 'Рӯйхати мақолҳо холӣ аст.',
    'detail_loading': 'Ҳоло мақол дастрас нест',
    // Badges
    'badges_traditional': 'Анъанавӣ',
    'badges_modern': 'Адабӣ',
    'badges_verified': 'Тасдиқшуда',
    'badges_unverified': 'Номаълум',
    'badges_level': 'Сатҳ ${0}',
    // Quick action descriptions
    'quiz_desc': 'Санҷиши дониш',
    'flashcards_desc': 'Флешкортҳо',
    'levels_desc': 'Аз оғоз то олим',
    'daily_desc': 'Мундариҷа',
    // Level descriptions
    'level_desc_1': 'Мақолҳои оддӣ барои оғоз',
    'level_desc_2': 'Мақолҳои осон',
    'level_desc_3': 'Мақолҳои асосӣ',
    'level_desc_4': 'Мақолҳои содда',
    'level_desc_5': 'Мақолҳои миёна',
    'level_desc_6': 'Мақолҳои мураккал',
    'level_desc_7': 'Мақолҳои хуби қавӣ',
    'level_desc_8': 'Мақолҳои бисёр мураккал',
    'level_desc_9': 'Мақолҳои усто',
    'level_desc_10': 'Мақолҳои олимӣ',
    // Progression labels
    'progression_beginner': 'Оғоз',
    'progression_intermediate': 'Миёна',
    'progression_advanced': 'Продвинута',
    'progression_master': 'Олим',
    // App
    'app_name': 'Зарбулмасал',
    'app_tagline': 'Ҳикмати ҳазорсолаи тоҷик',
    'proverb_count_label': '${0} мақол',
  };

  static const Map<String, String> fa = {
    // Navigation
    'nav_home': 'خانه',
    'nav_proverbs': 'ضرب‌المثل‌ها',
    'nav_categories': 'دسته‌ها',
    'nav_favorites': 'علاقه‌مندی‌ها',
    'nav_settings': 'تنظیمات',
    // Buttons
    'btn_back_home': 'بازگشت به خانه',
    'btn_see_more': 'بیشتر ببینید',
    'btn_previous': 'قبلی',
    'btn_next': 'بعدی',
    'btn_start_over': 'شروع',
    'btn_show_meaning': 'نمایش معنی',
    'btn_clear_filters': 'پاک کردن',
    'btn_see_all': 'همه را ببینید',
    'btn_next_question': 'سؤال بعدی',
    'btn_see_results': 'مشاهده نتایج',
    'btn_new_quiz': 'کوئیز جدید',
    'btn_return': 'بازگشت',
    // Home
    'home_greeting': 'سلام!',
    'home_subtitle': 'امروز یک ضرب‌المثل جدید بیاموزید.',
    'home_daily_proverb': 'ضرب‌المثل روز',
    'home_quick_actions': 'کوئیز و فلش‌کارت‌ها',
    'home_proverbs': 'ضرب‌المثل‌ها',
    'home_no_daily': 'ضرب‌المثلی در حال حاضر موجود نیست.',
    // Quiz
    'quiz_title': 'کوئیز',
    'quiz_question_of': 'سؤال ${0} از ${1}',
    'quiz_choose_meaning': 'معنی صحیح را انتخاب کنید:',
    'quiz_correct_of': '${0} از ${1} درست',
    'quiz_excellent': 'عالی!',
    'quiz_good': 'خوب!',
    'quiz_needs_work': 'قابل قبول.',
    'quiz_loading': 'بارگذاری...',
    // Flashcards
    'flashcards_title': 'فلش‌کارت‌ها',
    'flashcards_loading': 'بارگذاری...',
    'flashcards_card_of': 'کارت ${0} از ${1}',
    'flashcards_meaning': 'معنی',
    'flashcards_explanation': 'توضیح',
    'flashcards_tap_to_hide': 'برای پنهان کردن سریع کلیک کنید',
    'flashcards_tap_to_show': 'برای پنهان کردن کلیک کنید',
    // Settings
    'settings_title': 'تنظیمات',
    'settings_subtitle': 'تنظیمات برنامه',
    'settings_display': 'نمایش',
    'settings_dark_mode': 'حالت تاریک',
    'settings_language': 'زبان',
    'settings_info': 'اطلاعات',
    'settings_about': 'درباره برنامه',
    'settings_proverbs_count': '${0} ضرب‌المثل',
    'settings_source': 'درباره منابع',
    'settings_source_title': 'منابع ضرب‌المثل‌ها',
    'settings_source_text':
        'ضرب‌المثل‌های این برنامه از منابع معتبر تاجیکی، '
        'از کتاب‌های ضرب‌المثل، فولکلور تاجیکی و منابع فرهنگی '
        'تاجیکی گردآوری شده‌اند.',
    'settings_source_text2':
        'اگر منبع صحیح تاجیکی را می‌دانید، لطفاً '
        'پیشنهادهایتان را برای ما ارسال کنید.',
    'settings_contact': 'پیشنهادها',
    'settings_contact_title': 'تماس',
    'settings_contact_text': 'اگر پیشنهاد یا انتقادی دارید، به ما بنویسید:',
    'settings_version': 'نسخه 1.0.0',
    'settings_year': '2026 زرابول‌ماسال',
    'settings_tagline': 'ضرب‌المثل‌های تاجیکی — میراث فرهنگی',
    'settings_active': 'فعال',
    'settings_inactive': 'غیرفعال',
    'settings_about_text':
        'زرابول‌ماسال — برنامه‌ای برای آموزش، درک و '
        'حفظ ضرب‌المثل‌های تاجیکی.',
    'settings_close': 'بستن',
    // Empty states
    'empty_no_favorites': 'هنوز هیچ ضرب‌المثلی علاقه‌مندی نشده است.',
    'empty_no_favorites_hint': 'ضرب‌المثل‌ها را دوست بدارید.',
    'empty_no_proverbs_found': 'ضرب‌المثلی یافت نشد',
    'empty_change_filters': 'فیلترها را تغییر دهید',
    'empty_no_daily_proverb': 'ضرب‌المثلی برای امروز موجود نیست.',
    // Levels
    'levels_title': 'سطوح',
    'levels_subtitle': 'از مبتدی تا دانشمند — ۱۰ سطح',
    'levels_level': 'سطح ${0}',
    'levels_proverbs': 'ضرب‌المثل',
    // Categories
    'categories_title': 'دسته‌ها',
    'categories_subtitle': 'دسته‌بندی ضرب‌المثل‌ها',
    // Daily
    'daily_title': 'ضرب‌المثل روز',
    'daily_not_available': 'ضرب‌المثلی برای امروز موجود نیست.',
    // Proverbs list
    'proverbs_title': 'ضرب‌المثل‌ها',
    'proverbs_search_hint': 'جستجوی ضرب‌المثل...',
    'proverbs_all_levels': 'همه',
    'proverbs_no_results': 'ضرب‌المثلی یافت نشد',
    'proverbs_change_filters': 'فیلترها را تغییر دهید',
    // Proverb detail
    'detail_simple_explanation': 'توضیح ساده',
    'detail_meaning': 'معنی',
    'detail_example': 'مثال',
    'detail_source': 'منبع',
    'detail_unknown': 'نامشخص',
    'detail_no_proverbs': 'لیست ضرب‌المثل‌ها خالی است.',
    'detail_loading': 'ضرب‌المثل در حال حاضر موجود نیست',
    // Badges
    'badges_traditional': 'سنتی',
    'badges_modern': 'ادبی',
    'badges_verified': 'تأیید شده',
    'badges_unverified': 'نامشخص',
    'badges_level': 'سطح ${0}',
    // Quick action descriptions
    'quiz_desc': 'آزمون دانش',
    'flashcards_desc': 'فلش‌کارت‌ها',
    'levels_desc': 'از مبتدی تا دانشمند',
    'daily_desc': 'محتوا',
    // Level descriptions
    'level_desc_1': 'ضرب‌المثل‌های ساده برای شروع',
    'level_desc_2': 'ضرب‌المثل‌های آسان',
    'level_desc_3': 'ضرب‌المثل‌های پایه',
    'level_desc_4': 'ضرب‌المثل‌های ساده',
    'level_desc_5': 'ضرب‌المثل‌های متوسط',
    'level_desc_6': 'ضرب‌المثل‌های پیچیده',
    'level_desc_7': 'ضرب‌المثل‌های خوب و قوی',
    'level_desc_8': 'ضرب‌المثل‌های بسیار پیچیده',
    'level_desc_9': 'ضرب‌المثل‌های استادانه',
    'level_desc_10': 'ضرب‌المثل‌های دانشگاهی',
    // Progression labels
    'progression_beginner': 'مبتدی',
    'progression_intermediate': 'متوسط',
    'progression_advanced': 'پیشرفته',
    'progression_master': 'دانشمند',
    // App
    'app_name': 'زرابول‌ماسال',
    'app_tagline': 'حکمت هزارساله تاجیکی',
    'proverb_count_label': '${0} ضرب‌المثل',
  };

  static String get(String key, DisplayLanguage lang, [List<Object> args = const []]) {
    final map = lang == DisplayLanguage.persian ? fa : tj;
    String result = map[key] ?? tj[key] ?? key;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('\${$i}', args[i].toString());
    }
    return result;
  }

  static const List<String> monthNamesTj = [
    '', 'Январ', 'Феврал', 'Март', 'Апрел', 'Май', 'Июн',
    'Июл', 'Август', 'Сентябр', 'Октябр', 'Ноябр', 'Декабр',
  ];

  static const List<String> monthNamesFa = [
    '', 'ژانویه', 'فوریه', 'مارس', 'آوریل', 'مه', 'ژوئن',
    'ژوئیه', 'اوت', 'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر',
  ];

  static String getMonthName(int month, DisplayLanguage lang) {
    if (month < 1 || month > 12) return '';
    return lang == DisplayLanguage.persian ? monthNamesFa[month] : monthNamesTj[month];
  }
}
