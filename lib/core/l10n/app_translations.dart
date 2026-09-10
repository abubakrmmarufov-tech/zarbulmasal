import '../../shared/providers/app_providers.dart';

class AppTranslations {
  AppTranslations._();

  static const Map<String, String> tj = {
    'home_headline': 'Як рӯз.\nЯк ҳикмат.',
    'home_edition': 'ДАФТАРИ ҲИКМАТ',
    'home_learn': 'Хонед. Дар ёд доред.',
    'home_explore': 'Аз ганҷина',
    'home_learning': 'Омӯзиш',
    'home_read': 'Бихонед',
    'bookmark_add': 'Маҳфуз кардан',
    'bookmark_remove': 'Аз маҳфузот баровардан',
    'favorites_title': 'Маҳфузот',
    'favorites_count': 'мақоли маҳфуз',
    'favorites_empty': 'Саҳифаи аввал ҳанӯз холист.',
    'favorites_empty_hint':
        'Мақолеро, ки ба дил наздик аст, маҳфуз кунед. Он ҳамеша дар ин ҷо хоҳад буд.',
    'proverbs_found': 'Дар ганҷина',
    'copy_proverb': 'Нусхаи матн',
    'copied': 'Матн нусха шуд',
    'reading_script': 'Хатти хониш',
    'back': 'Бозгашт',
    'source_unverified': 'Сарчашма тасдиқ нашудааст',
    // Navigation
    'nav_home': 'Асосӣ',
    'nav_proverbs': 'Мақолҳо',
    'nav_categories': 'Гурӯҳҳо',
    'nav_favorites': 'Маҳфуз',
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
    'quiz_question_of': 'Савол \${0} аз \${1}',
    'quiz_choose_meaning': 'Маънои дурустро интихоб кунед:',
    'quiz_correct_of': '\${0} аз \${1} дуруст',
    'quiz_excellent': 'Аъло!',
    'quiz_good': 'Хуб!',
    'quiz_needs_work': 'Кобили қабул.',
    'quiz_loading': 'Боргирӣ...',
    // Flashcards
    'flashcards_title': 'Флешкортҳо',
    'flashcards_loading': 'Боргирӣ...',
    'flashcards_card_of': 'Карта \${0} аз \${1}',
    'flashcards_meaning': 'Маъно',
    'flashcards_explanation': 'Шарҳ',
    'flashcards_tap_to_hide': 'Тез клик кунед барои пинҳон кардан',
    'flashcards_tap_to_show': 'Барои дидани маъно ламс кунед',
    // Settings
    'settings_title': 'Танзимот',
    'settings_subtitle': 'Танзимоти барнома',
    'settings_display': 'Намоиш',
    'settings_dark_mode': 'Режими торик',
    'settings_language': 'Забон',
    'settings_info': 'Маълумот',
    'settings_about': 'Дар бораи барнома',
    'settings_proverbs_count': '\${0} мақол',
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
    'settings_contact_text':
        'Агар шумо пешниҳодҳо ё таклифҳо доред, ба мо дар Telegram нависед: @imarufov',
    'settings_version': 'Версия 1.0.0',
    'settings_year': '2026 Зарбулмасал',
    'settings_tagline': 'Мақолҳои тоҷикӣ — мероси фарҳангӣ',
    'settings_active': 'Фаъол',
    'settings_inactive': 'Ғайрифаъол',
    'settings_about_text':
        'Зарбулмасал — барнома барои омӯзиш, фаҳмиш ва '
        'нигоҳдории мақолҳои тоҷикӣ.',
    'settings_close': 'Пӯшидан',
    // Empty states
    'empty_no_favorites': 'Ҳоло ягон мақол дӯст дошта нашудааст.',
    'empty_no_favorites_hint': 'Мақолҳоро ба даст бигиред.',
    'empty_no_proverbs_found': 'Мақол ёфт нашуд',
    'empty_change_filters': 'Филтрҳоро тағир диҳед',
    'empty_no_daily_proverb': 'Ҳоло мақоле барои имрӯз дастрас нест.',
    // Levels
    'levels_title': 'Сатҳҳо',
    'levels_subtitle': 'Дастрас: \${0} сатҳ',
    'levels_level': 'Сатҳ \${0}',
    'levels_proverbs': 'мақол',
    'levels_none': 'Ҳоло сатҳе дастрас нест.',
    'levels_none_hint': 'Пас аз илова шудани мақолҳо сатҳҳо пайдо мешаванд.',
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
    'badges_level': 'Сатҳ \${0}',
    // Quick action descriptions
    'quiz_desc': 'Санҷиши дониш',
    'flashcards_desc': 'Флешкортҳо',
    'levels_desc': 'Сатҳҳои дастрас аз рӯйи мундариҷа',
    'daily_desc': 'Мундариҷа',
    // Level descriptions
    'level_desc_1': 'Мақолҳои оддӣ барои оғоз',
    'level_desc_2': 'Мақолҳои осон',
    'level_desc_3': 'Мақолҳои асосӣ',
    'level_desc_4': 'Мақолҳои содда',
    'level_desc_5': 'Мақолҳои миёна',
    'level_desc_6': 'Мақолҳои мураккал',
    'level_desc_7': 'Мақолҳои пешрафта',
    'level_desc_8': 'Мақолҳои коршиносӣ',
    'level_desc_9': 'Мақолҳои устодӣ',
    'level_desc_10': 'Мақолҳои олимӣ',
    // Progression labels
    'progression_beginner': 'Оғоз',
    'progression_intermediate': 'Миёна',
    'progression_advanced': 'Пешрафта',
    'progression_master': 'Олим',
    // App
    'app_name': 'Зарбулмасал',
    'app_tagline': 'Ҳикмати ҳазорсолаи тоҷик',
    'proverb_count_label': '\${0} мақол',
    // Onboarding
    'settings_show_guide': 'Роҳнамои хусусиятҳо',
    'settings_show_guide_hint': 'Роҳнамои кӯтоҳро дубора бинед',
    'onboarding_home_title': 'Ҳикмати рӯз',
    'onboarding_home_description': 'Мақоли рӯзро бихонед ва бо машқҳо омӯзед.',
    'onboarding_search_title': 'Мақолҳо ва ҷустуҷӯ',
    'onboarding_search_description': 'Ҳар мақолро зуд пайдо кунед.',
    'onboarding_favorites_title': 'Маҳфузот',
    'onboarding_favorites_description':
        'Мақолҳои писандидаро барои баъд маҳфуз кунед.',
    'onboarding_settings_title': 'Танзимот',
    'onboarding_settings_description':
        'Забон, намоиш ва ин роҳнаморо идора кунед.',
    'onboarding_next': 'Баъдӣ',
    'onboarding_skip': 'Гузаштан',
    'onboarding_finish': 'Оғоз!',
    'route_error_title': 'Саҳифа ёфт нашуд',
    'route_error_description': 'Ин саҳифа дастрас нест.',
    'copy_unavailable': 'Нусхабардорӣ дастрас нест',

    // Literature Feature
    'lit_title': 'Мероси адабӣ',
    'lit_poets': 'Шоирон',
    'lit_poems': 'Шеърҳо',
    'lit_school': 'Барномаи мактабӣ',
    'lit_oral': 'Мероси шифоҳӣ',
    'lit_daily_verse': 'Байти рӯз',
    'lit_source': 'Манбаъ',
    'lit_verified': 'Матн санҷида шудааст',
    'lit_publisher': 'Нашриёт',
    'lit_year': 'Сол',
    'lit_page': 'Саҳифа',
    'lit_search_hint': 'Ҷустуҷӯ...',
    'lit_no_results': 'Мундариҷа ёфт нашуд',
    'lit_read_more': 'Муфассал',
    'lit_city': 'Шаҳр',
    'lit_editor': 'Муҳаррир',
    'lit_access_date': 'Санаи дастрасӣ',
    'lit_mandatory': 'Ҳатмӣ',
    'lit_recommended': 'Тавсияшаванда',
    'lit_grade': 'Синфи \${0}',
    'lit_author': 'Муаллиф',
    'lit_period': 'Давраи адабӣ',
    'lit_biography': 'Зиндагинома',
    'lit_major_works': 'Осори муҳим',
    'lit_book': 'Китоб',
    'lit_volume': 'Ҷилд',
    'lit_institution': 'Муассиса',
    'lit_rights': 'Ҳуқуқи муаллиф',
    'lit_public_domain': 'Моликияти умумӣ',
    'lit_excerpt_only': 'Танҳо иқтибос',
    'lit_needs_review': 'Ниёз ба баррасӣ дорад',
    'lit_oral_type_zarbulmasal': 'Зарбулмасал',
    'lit_oral_type_maqol': 'Мақол',
    'lit_oral_type_chiston': 'Чистон',
    'lit_oral_type_dubaytiKhalqi': 'Дубайтии халқӣ',
    'lit_oral_type_rubaiKhalqi': 'Рубоии халқӣ',
    'lit_oral_type_afsona': 'Афсона',
    'lit_oral_type_other': 'Дигар',
  };

  static const Map<String, String> fa = {
    'home_headline': 'یک روز.\nیک حکمت.',
    'home_edition': 'دفتر حکمت',
    'home_learn': 'بخوانید. به یاد بسپارید.',
    'home_explore': 'از گنجینه',
    'home_learning': 'یادگیری',
    'home_read': 'بخوانید',
    'bookmark_add': 'ذخیره کردن',
    'bookmark_remove': 'حذف از ذخیره‌ها',
    'favorites_title': 'ذخیره‌ها',
    'favorites_count': 'ضرب‌المثل ذخیره‌شده',
    'favorites_empty': 'صفحهٔ اول هنوز خالی است.',
    'favorites_empty_hint':
        'ضرب‌المثلی را که دوست دارید ذخیره کنید. همیشه اینجا خواهد بود.',
    'proverbs_found': 'در گنجینه',
    'copy_proverb': 'کپی متن',
    'copied': 'متن کپی شد',
    'reading_script': 'خط خواندن',
    'back': 'بازگشت',
    'source_unverified': 'منبع تأیید نشده است',
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
    'quiz_question_of': 'سؤال \${0} از \${1}',
    'quiz_choose_meaning': 'معنی صحیح را انتخاب کنید:',
    'quiz_correct_of': '\${0} از \${1} درست',
    'quiz_excellent': 'عالی!',
    'quiz_good': 'خوب!',
    'quiz_needs_work': 'قابل قبول.',
    'quiz_loading': 'بارگذاری...',
    // Flashcards
    'flashcards_title': 'فلش‌کارت‌ها',
    'flashcards_loading': 'بارگذاری...',
    'flashcards_card_of': 'کارت \${0} از \${1}',
    'flashcards_meaning': 'معنی',
    'flashcards_explanation': 'توضیح',
    'flashcards_tap_to_hide': 'برای پنهان کردن سریع کلیک کنید',
    'flashcards_tap_to_show': 'برای دیدن معنی لمس کنید',
    // Settings
    'settings_title': 'تنظیمات',
    'settings_subtitle': 'تنظیمات برنامه',
    'settings_display': 'نمایش',
    'settings_dark_mode': 'حالت تاریک',
    'settings_language': 'زبان',
    'settings_info': 'اطلاعات',
    'settings_about': 'درباره برنامه',
    'settings_proverbs_count': '\${0} ضرب‌المثل',
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
    'settings_contact_text':
        'اگر پیشنهاد یا انتقادی دارید، به ما در Telegram بنویسید: @imarufov',
    'settings_version': 'نسخه 1.0.0',
    'settings_year': '2026 ضرب‌المثل',
    'settings_tagline': 'ضرب‌المثل‌های تاجیکی — میراث فرهنگی',
    'settings_active': 'فعال',
    'settings_inactive': 'غیرفعال',
    'settings_about_text':
        'ضرب‌المثل — برنامه‌ای برای آموزش، درک و '
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
    'levels_subtitle': '\${0} سطح موجود',
    'levels_level': 'سطح \${0}',
    'levels_proverbs': 'ضرب‌المثل',
    'levels_none': 'در حال حاضر سطحی موجود نیست.',
    'levels_none_hint':
        'پس از افزوده‌شدن ضرب‌المثل‌ها، سطوح نمایش داده می‌شوند.',
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
    'badges_level': 'سطح \${0}',
    // Quick action descriptions
    'quiz_desc': 'آزمون دانش',
    'flashcards_desc': 'فلش‌کارت‌ها',
    'levels_desc': 'سطوح موجود بر پایهٔ محتوا',
    'daily_desc': 'محتوا',
    // Level descriptions
    'level_desc_1': 'ضرب‌المثل‌های ساده برای شروع',
    'level_desc_2': 'ضرب‌المثل‌های آسان',
    'level_desc_3': 'ضرب‌المثل‌های پایه',
    'level_desc_4': 'ضرب‌المثل‌های ساده',
    'level_desc_5': 'ضرب‌المثل‌های متوسط',
    'level_desc_6': 'ضرب‌المثل‌های پیچیده',
    'level_desc_7': 'ضرب‌المثل‌های پیشرفته',
    'level_desc_8': 'ضرب‌المثل‌های تخصصی',
    'level_desc_9': 'ضرب‌المثل‌های استادانه',
    'level_desc_10': 'ضرب‌المثل‌های دانشگاهی',
    // Progression labels
    'progression_beginner': 'مبتدی',
    'progression_intermediate': 'متوسط',
    'progression_advanced': 'پیشرفته',
    'progression_master': 'دانشمند',
    // App
    'app_name': 'ضرب‌المثل',
    'app_tagline': 'حکمت هزارساله تاجیکی',
    'proverb_count_label': '\${0} ضرب‌المثل',
    // Onboarding
    'settings_show_guide': 'راهنمای ویژگی‌ها',
    'settings_show_guide_hint': 'راهنمای کوتاه را دوباره ببینید',
    'onboarding_home_title': 'حکمت روز',
    'onboarding_home_description':
        'ضرب‌المثل روز را بخوانید و با تمرین‌ها یاد بگیرید.',
    'onboarding_search_title': 'ضرب‌المثل‌ها و جستجو',
    'onboarding_search_description': 'هر ضرب‌المثلی را سریع پیدا کنید.',
    'onboarding_favorites_title': 'ذخیره‌ها',
    'onboarding_favorites_description':
        'ضرب‌المثل‌های دلخواه را برای بعد ذخیره کنید.',
    'onboarding_settings_title': 'تنظیمات',
    'onboarding_settings_description':
        'زبان، نمایش و این راهنما را مدیریت کنید.',
    'onboarding_next': 'بعدی',
    'onboarding_skip': 'رد شدن',
    'onboarding_finish': 'شروع!',
    'route_error_title': 'صفحه پیدا نشد',
    'route_error_description': 'این صفحه در دسترس نیست.',
    'copy_unavailable': 'کپی در دسترس نیست',

    // Literature Feature
    'lit_title': 'میراث ادبی',
    'lit_poets': 'شاعران',
    'lit_poems': 'شعرها',
    'lit_school': 'برنامهٔ مکتبی',
    'lit_oral': 'میراث شفاهی',
    'lit_daily_verse': 'بیت روز',
    'lit_source': 'منبع',
    'lit_verified': 'متن بررسی شده است',
    'lit_publisher': 'نشریات',
    'lit_year': 'سال',
    'lit_page': 'صفحه',
    'lit_search_hint': 'جستجو...',
    'lit_no_results': 'محتوا یافت نشد',
    'lit_read_more': 'مفصل',
    'lit_city': 'شهر',
    'lit_editor': 'محرر',
    'lit_access_date': 'تاریخ دسترسی',
    'lit_mandatory': 'حتما',
    'lit_recommended': 'توصیه شونده',
    'lit_grade': 'صنف \${0}',
    'lit_author': 'مؤلف',
    'lit_period': 'دوره ادبی',
    'lit_biography': 'زندگینامه',
    'lit_major_works': 'آثار مهم',
    'lit_book': 'کتاب',
    'lit_volume': 'جلد',
    'lit_institution': 'مؤسسه',
    'lit_rights': 'حقوق مؤلف',
    'lit_public_domain': 'مالکیت عمومی',
    'lit_excerpt_only': 'فقط اقتباس',
    'lit_needs_review': 'نیاز به بررسی دارد',
    'lit_oral_type_zarbulmasal': 'ضرب‌المثل',
    'lit_oral_type_maqol': 'مقال',
    'lit_oral_type_chiston': 'چیستان',
    'lit_oral_type_dubaytiKhalqi': 'دوبیتی خلقی',
    'lit_oral_type_rubaiKhalqi': 'رباعی خلقی',
    'lit_oral_type_afsona': 'افسانه',
    'lit_oral_type_other': 'دیگر',
  };

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

  static String _formatArgument(Object argument, DisplayLanguage language) {
    final value = argument.toString();
    if (language != DisplayLanguage.persian) return value;
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    return value.split('').map((character) {
      final index = western.indexOf(character);
      return index < 0 ? character : persian[index];
    }).join();
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
