import '../models/proverb.dart';
import '../models/source_ref.dart';

/// Seed proverbs 73–96; see seed_proverbs.dart.
const List<Proverb> seedProverbsPart3 = [
  Proverb(
    id: '73',
    tajikCyrillic: 'Деҳқон бошад, ҷаҳон обод аст.',
    persianText: 'دهقان باشد، جهان آباد است.',
    simpleExplanationTj:
        'Меҳнати деҳқон замин ва зиндагии мардумро обод мекунад.',
    meaningTj:
        'Кишоварзӣ ва меҳнати деҳқон барои таъмини ҷомеа аҳамияти асосӣ доранд.',
    exampleSentenceTj:
        'Деҳқонон заминро кишт карданд ва деҳа серҳосил шуд; деҳқон бошад, ҷаҳон обод аст.',
    categoryId: 'mehnat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '74',
    tajikCyrillic: 'Заминро об вайрон мекунад, одамро гап.',
    persianText: 'زمین را آب ویران می‌کند، آدم را گپ.',
    simpleExplanationTj:
        'Чунон ки оби зиёдатӣ заминро вайрон мекунад, сухани бад метавонад одамро зарар диҳад.',
    meaningTj:
        'Ғайбат, туҳмат ё сухани беэҳтиёт метавонад обрӯ ва зиндагии инсонро вайрон кунад.',
    exampleSentenceTj:
        'Як овозаи беасос ба обрӯи ӯ зарар расонд; заминро об вайрон мекунад, одамро гап.',
    categoryId: 'odob',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 51,
        printedPage: 54,
        printedText: 'Заминро об вайрон мекунад, одамро гап.',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 41,
        printedPage: 41,
        printedText: 'Заминро об вайрон мекунад, одамро – гап.',
      ),
    ],
  ),
  Proverb(
    id: '75',
    tajikCyrillic: 'Об аз сар лой.',
    persianText: 'آب از سر لای.',
    simpleExplanationTj:
        'Агар сарчашма лой бошад, об аз ҳамон ҷо ифлос мешавад.',
    meaningTj:
        'Бадкорӣ ё бесарусомонӣ аксар вақт аз роҳбарӣ ё қисми болоӣ оғоз мешавад.',
    exampleSentenceTj:
        'Вақте роҳбар қоидаҳоро риоя намекунад, дигарон ҳам беэътино мешаванд; об аз сар лой.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 62,
        printedPage: 65,
        printedText: 'Об аз сар лой.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 76,
        printedPage: 76,
        printedText: 'Об аз сар лой.',
      ),
    ],
  ),
  Proverb(
    id: '76',
    tajikCyrillic: 'Зарра-зарра мӯл шавад, Қатра-қатра кӯл шавад.',
    persianText: 'ذره‌ذره مول شود، قطره‌قطره کول شود.',
    simpleExplanationTj:
        'Зарраҳо ва қатраҳои хурд ҷамъ шуда чизи калон месозанд.',
    meaningTj: 'Кӯшиш ё пасандози кам-кам бо вақт ба натиҷаи калон мерасад.',
    exampleSentenceTj:
        'Ӯ ҳар рӯз андаке пул ҷамъ мекард; зарра-зарра мӯл шавад, қатра-қатра кӯл шавад.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote:
        'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо (1990)',
    sources: [
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 36,
        printedPage: 36,
        printedText: 'Зарра-зарра мӯл шавад, / Қатра-қатра кӯл шавад.',
        note: 'section «Сарфа»',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 80,
        printedPage: 83,
        printedText: 'Қатра-қатра ҷамъ гардад, он гаҳе дарьё шавад.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '77',
    tajikCyrillic: 'Сабр кунӣ, ғӯра ҳалво мешавад.',
    persianText: 'صبر کنی، غوره حلوا می‌شود.',
    simpleExplanationTj:
        'Бо сабр ҳатто ғӯраи турш метавонад ба чизи ширин табдил ёбад — ба маънои маҷозӣ.',
    meaningTj:
        'Вақт ва сабр метавонанд ҳолати душвор ё нопухтаро ба натиҷаи хуб расонанд.',
    exampleSentenceTj:
        'Ниҳол солҳои аввал мева надод, вале ӯ нигоҳубинро давом дод; сабр кунӣ, ғӯра ҳалво мешавад.',
    categoryId: 'sabr',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote:
        'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо (1990)',
    sources: [
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 32,
        printedPage: 32,
        printedText: 'Сабр кунӣ, ғӯра ҳалво мешавад.',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 42,
        printedPage: 45,
        printedText: 'Гар сабр кунӣ, аз ғӯра ҳалво мепазад.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '78',
    tajikCyrillic: 'Сабр талх аст, вале оқибаташ ширин.',
    persianText: 'صبر تلخ است، ولی عاقبتش شیرین.',
    simpleExplanationTj:
        'Сабр кардан душвор аст, аммо натиҷаи он метавонад хуш бошад.',
    meaningTj: 'Таҳаммул ва интизорӣ аксар вақт ба натиҷаи хуб меоранд.',
    exampleSentenceTj:
        'Омӯзиш тӯл кашид, вале баъд кори хуб ёфт; сабр талх аст, вале оқибаташ ширин.',
    categoryId: 'sabr',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 67,
        printedPage: 70,
        printedText: 'Сабр талх аст, вале оқибаташ ширин.',
      ),
    ],
  ),
  Proverb(
    id: '79',
    tajikCyrillic: 'Шитоб кори шайтон аст.',
    persianText: 'شتاب کار شیطان است.',
    simpleExplanationTj: 'Шитоби беандеша метавонад боиси хато шавад.',
    meaningTj:
        'Пеш аз амал кардан фикр ва эҳтиёт лозим аст; саросемагӣ хатар дорад.',
    exampleSentenceTj:
        'Ӯ пеш аз имзо ҳуҷҷатро боз як бор хонд; шитоб кори шайтон аст.',
    categoryId: 'sabr',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '80',
    tajikCyrillic: 'Дер ояду шер ояд.',
    persianText: 'دیر آید و شیر آید.',
    simpleExplanationTj:
        'Беҳтар аст чизе дертар, вале бо қуввату сифати хуб бирасад.',
    meaningTj: 'Дерӣ ҳамеша бад нест, агар натиҷаи ниҳоӣ арзанда бошад.',
    exampleSentenceTj:
        'Лоиҳа дертар омода шуд, вале хеле хуб баромад; дер ояду шер ояд.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 48,
        printedPage: 51,
        printedText: 'Дер ояду шер ояд.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 33,
        printedPage: 33,
        printedText: 'Дер ояду шер ояд.',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 42,
        printedPage: 42,
        printedText: '«Дер ояду шер ояд»',
        note: 'listed in an exercise',
      ),
    ],
  ),
  Proverb(
    id: '81',
    tajikCyrillic: 'Ҳар кор вақту соат дорад.',
    persianText: 'هر کار وقت و ساعت دارد.',
    simpleExplanationTj: 'Барои ҳар кор вақти муносиб вуҷуд дорад.',
    meaningTj: 'Корро дар вақти дуруст анҷом додан натиҷаро беҳтар мекунад.',
    exampleSentenceTj:
        'Ҳоло вақти баҳс набуд, барои ҳамин суҳбатро ба баъд гузоштанд; ҳар кор вақту соат дорад.',
    categoryId: 'vaqt',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote:
        'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо (1990)',
    sources: [
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 105,
        printedPage: 105,
        printedText: 'Ҳар кор вақту соат дорад.',
        note: 'section «Фурсат»',
      ),
    ],
  ),
  Proverb(
    id: '82',
    tajikCyrillic: 'Кори имрӯзаро ба фардо магузор.',
    persianText: 'کار امروزه را به فردا مگذار.',
    simpleExplanationTj: 'Кори имрӯзро бе сабаб ба рӯзи дигар нагузор.',
    meaningTj:
        'Ба таъхир андохтани кор метавонад мушкилро зиёд кунад; вазифаи имрӯза беҳтараш имрӯз анҷом ёбад.',
    exampleSentenceTj:
        'Вазифаро ҳамон шаб тамом кард; кори имрӯзаро ба фардо магузор.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 54,
        printedPage: 57,
        printedText: 'Кори имрӯзаро ба фардо магузор.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 46,
        printedPage: 46,
        printedText: 'Кори имрӯзаро ба фардо магузор.',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 9',
        authorEditor: 'Т. Мирзод, С. Давлатзода, Ф. Мирзода',
        year: 2026,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 318,
        printedPage: 318,
        printedText: '«Кори имрӯзаро ба фардо нагузор»',
        note: 'cited as a зарбулмасал',
      ),
    ],
  ),
  Proverb(
    id: '83',
    tajikCyrillic: 'Вақт аз тилло қиматтар аст.',
    persianText: 'وقت از طلا قیمت‌تر است.',
    simpleExplanationTj: 'Вақт аз молу тилло ҳам арзишмандтар аст.',
    meaningTj:
        'Пулро метавон дубора ба даст овард, аммо вақти гузашта барнамегардад.',
    exampleSentenceTj:
        'Ӯ вақти холиро беҳуда нагузаронд; вақт аз тилло қиматтар аст.',
    categoryId: 'vaqt',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '84',
    tajikCyrillic: 'Роҳаша бину аспаша гир, Очаша бину духтараша гир.',
    persianText: 'راهشه بین و اسپشه گیر، اوچه‌شه بین و دخترشه گیر.',
    simpleExplanationTj:
        'Ин мақоли анъанавӣ монандии тарбия ва одатҳои духтарро ба муҳити модарӣ таъкид мекунад.',
    meaningTj:
        'Пеш аз интихоби ҳамсар ба муҳити оилавӣ ва тарбия низ аҳамият медиҳанд; ин қоидаи қатъӣ дар бораи ҳар шахс нест.',
    exampleSentenceTj:
        'Пирон ҳангоми шиносоии ду оила ба муҳити тарбия ҳам менигаристанд: «Очаша бину духтараша гир».',
    categoryId: 'oila',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote:
        'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо (1990)',
    sources: [
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 92,
        printedPage: 92,
        printedText: 'Роҳаша бину аспаша гир, / Очаша бину духтараша гир.',
        note: 'section «Интихоби арӯс»',
      ),
    ],
  ),
  Proverb(
    id: '85',
    tajikCyrillic: 'Модар чӣ гуна, духтар намуна.',
    persianText: 'مادر چه گونه، دختر نمونه.',
    simpleExplanationTj:
        'Фарзанд бисёр рафтору одатҳоро аз модар ва муҳити хона меомӯзад.',
    meaningTj:
        'Тарбияи хонаводагӣ ба хислат ва рафтори фарзанд таъсир мерасонад, ҳарчанд ҳар шахс мустақил аст.',
    exampleSentenceTj:
        'Духтар аз модараш меҳмондориро омӯхта буд; модар чӣ гуна, духтар намуна.',
    categoryId: 'padaru_modar',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '86',
    tajikCyrillic: 'Дили оча ба бача, дили бача ба кӯча.',
    persianText: 'دل اوچه به بچه، دل بچه به کوچه.',
    simpleExplanationTj:
        'Модар ҳамеша дар фикри фарзанд аст, вале кӯдак бештар дар фикри бозӣ ва кӯча мешавад.',
    meaningTj:
        'Ғамхории волидайн нисбат ба фарзанд аксар вақт бештар аз он аст, ки кӯдак дарк мекунад.',
    exampleSentenceTj:
        'Модар дер омадани писарашро нигарон буд, аммо ӯ машғули бозӣ буд; дили оча ба бача, дили бача ба кӯча.',
    categoryId: 'padaru_modar',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 48,
        printedPage: 51,
        printedText: 'Дили оча ба бача, дили бача ба кӯча.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 98,
        printedPage: 98,
        printedText: 'Дили оча ба бача, / Дили бача ба кӯча.',
      ),
    ],
  ),
  Proverb(
    id: '87',
    tajikCyrillic: 'Духтарам, ба ту мегӯям, келинам ту шунав.',
    persianText: 'دخترم، به تو می‌گویم، کلینم تو شنو.',
    simpleExplanationTj:
        'Ба як кас мегӯянд, вале мақсад ин аст, ки шахси дигар ҳам пандро бифаҳмад.',
    meaningTj:
        'Суханеро ба касе равона карда, ба тариқи киноя ба каси дигар чизеро гӯшрас карданӣ шаванд, ин зарбулмасалро ба кор мебаранд.',
    exampleSentenceTj:
        'Шумо одами ҳилагар будаед, ба ман ба мисоли «духтарам, ба ту мегӯям, келинам, ту шунав!» гап задед.',
    categoryId: 'oila',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 50,
        printedPage: 53,
        printedText: 'Духтарам, ба ту мегӯям, келинам ту шунав.',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 40,
        printedPage: 40,
        printedText: 'ДУХТАРАМ, БА ТУ МЕГӮЯМ, КЕЛИНАМ, ТУ ШУНАВ!',
        note: 'lesson entry with printed meaning and a signed example',
      ),
    ],
    meaningSource: SourceRef(
      bookTitle: 'Адабиёти тоҷик, синфи 5',
      authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
      year: 2017,
      publisher: 'Маориф',
      city: 'Душанбе',
      pdfPage: 40,
      printedPage: 40,
    ),
    exampleSource: SourceRef(
      bookTitle: 'Адабиёти тоҷик, синфи 5',
      authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
      year: 2017,
      publisher: 'Маориф',
      city: 'Душанбе',
      pdfPage: 40,
      printedPage: 40,
    ),
    exampleAttribution: 'Сотим Улуғзода',
  ),
  Proverb(
    id: '88',
    tajikCyrillic: 'Ба ҷанги зану шӯй остона механдад.',
    persianText: 'به جنگ زن و شوی آستانه می‌خندد.',
    simpleExplanationTj:
        'Ҷанҷоли зану шавҳар бисёр вақт зуд мегузарад ва аз берун дахолат кардан метавонад беҳуда бошад.',
    meaningTj:
        '1. Алами ҷанги зану шӯ тезгузар аст, зану шӯ ҳарчанд бо ҳамдигар сахт биҷанганд ҳам, боз оштӣ мешаванд, 2. натиҷаи ба байни ҷанги зану шӯ даромадан шармандагӣ аст.',
    exampleSentenceTj:
        '— Сангинҷон, аз ман хафа шудӣ? Охир, «сухани рост талх мешавад».\n— Чӣ хафа мешавам? «Ба ҷанги зану шӯ остонаи дари хона механдад» мегӯянд. Ту хурсанд бошӣ, ман хурсанд.',
    categoryId: 'oila',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 37,
        printedPage: 40,
        printedText: 'Ба ҷанги зану шӯй остона механдад.',
      ),
      SourceRef(
        bookTitle:
            'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
        authorEditor: 'Муллоҷон Фозилов',
        year: 1975,
        publisher: 'Ирфон',
        city: 'Душанбе',
        pdfPage: 203,
        printedPage: 200,
        printedText: 'БА ҶАНГИ ЗАНУ ШӮ ОСТОНАИ ДАРИ ХОНА МЕХАНДАД.',
        note: 'variant',
      ),
    ],
    meaningSource: SourceRef(
      bookTitle:
          'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
      authorEditor: 'Муллоҷон Фозилов',
      year: 1975,
      publisher: 'Ирфон',
      city: 'Душанбе',
      pdfPage: 203,
      printedPage: 200,
      note: 'entry «Ба ҷанги зану шӯ остонаи дари хона механдад»',
    ),
    exampleSource: SourceRef(
      bookTitle:
          'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
      authorEditor: 'Муллоҷон Фозилов',
      year: 1975,
      publisher: 'Ирфон',
      city: 'Душанбе',
      pdfPage: 203,
      printedPage: 200,
    ),
    exampleAttribution: 'Раҳим Ҷалил',
  ),
  Proverb(
    id: '89',
    tajikCyrillic: 'Хонаи бехушдоман — майдони бе хошок.',
    persianText: 'خانهٔ بی‌خوشدامن — میدان بی‌خاشاک.',
    simpleExplanationTj:
        'Ин мақоли кӯҳна бо ҳазлу киноя мегӯяд, ки хона бе хушдоман оромтару камҷанҷолтар менамояд.',
    meaningTj:
        'Мақол муносибатҳои анъанавии пуртаниши келину хушдоманро ба шакли шӯхиомез инъикос мекунад; онро набояд ҳақиқати умумӣ донист.',
    exampleSentenceTj:
        'Пиразан ин мақоли қадимиро бо шӯхӣ гуфт: «Хонаи бехушдоман — майдони бе хошок».',
    categoryId: 'oila',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '90',
    tajikCyrillic: 'Фарзанд азиз, одобаш азизтар.',
    persianText: 'فرزند عزیز، ادبش عزیزتر.',
    simpleExplanationTj:
        'Фарзанд азиз аст, вале тарбияи хуби ӯ боз ҳам муҳимтар аст.',
    meaningTj:
        'Муҳаббат ба фарзанд бояд бо омӯзонидани одоб ва масъулият ҳамроҳ бошад.',
    exampleSentenceTj:
        'Падар ба фарзандаш танҳо тӯҳфа намедод, одоб ҳам меомӯзонд; фарзанд азиз, одобаш азизтар.',
    categoryId: 'padaru_modar',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '91',
    tajikCyrillic: 'Ватан аз остона сар мешавад.',
    persianText: 'وطن از آستانه سر می‌شود.',
    simpleExplanationTj:
        'Муҳаббат ба Ватан аз хона, маҳалла ва муҳити наздики инсон оғоз мешавад.',
    meaningTj:
        'Ғамхорӣ ба кишвар аз эҳтиром ва обод кардани ҷои зисти худ сар мешавад.',
    exampleSentenceTj:
        'Онҳо аввал кӯчаи худро тоза карданд; Ватан аз остона сар мешавад.',
    categoryId: 'zindagi',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '92',
    tajikCyrillic:
        'Хоки ватан аз тахти Сулаймон хуштар, Хори ватан аз лолаву райҳон хуштар.',
    persianText: 'خاک وطن از تخت سلیمان خوشتر، خار وطن از لاله و ریحان خوشتر.',
    simpleExplanationTj:
        'Ҳатто хоки Ватан аз сарвати бузургу шоҳона азизтар дониста мешавад.',
    meaningTj: 'Муҳаббат ба зодгоҳ ва Ватан аз молу мақом болотар аст.',
    exampleSentenceTj:
        'Ӯ дар хориҷ имкони хуб дошт, вале ҳамеша зодгоҳашро ёд мекард; хоки ватан аз тахти Сулаймон хуштар.',
    categoryId: 'zindagi',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote:
        'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо (1990)',
    sources: [
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 20,
        printedPage: 20,
        printedText:
            'Хоки ватан аз тахти Сулаймон хуштар, / Хори ватан аз лолаву райҳон хуштар.*',
        note:
            'section «Ватан»; footnote: the opening of a well-known folk rubai',
      ),
    ],
  ),
  Proverb(
    id: '93',
    tajikCyrillic: 'Ҷон фидои Ватан.',
    persianText: 'جان فدای وطن.',
    simpleExplanationTj:
        'Ин ибора омодагии инсонро барои фидокорӣ ба хотири Ватан ифода мекунад.',
    meaningTj:
        'Ватан арзише дониста мешавад, ки барои ҳифзу ободии он инсон аз манфиати шахсӣ мегузарад.',
    exampleSentenceTj:
        'Сарбозон барои амнияти кишвар хизмат мекарданд: «Ҷон фидои Ватан».',
    categoryId: 'zindagi',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '94',
    tajikCyrillic: 'Шахси беватан — булбули бечаман.',
    persianText: 'شخص بی‌وطن — بلبل بی‌چمن.',
    simpleExplanationTj: 'Одами бе Ватан мисли булбулест, ки чаман надорад.',
    meaningTj:
        'Инсон бе зодгоҳ ва ҳисси тааллуқ метавонад худро бегонаву бепаноҳ эҳсос кунад.',
    exampleSentenceTj:
        'Дар ғарибӣ ҳамеша зодгоҳашро ёд мекард; шахси беватан — булбули бечаман.',
    categoryId: 'zindagi',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 77,
        printedPage: 80,
        printedText: 'Шахси беватан—булбули бечаман.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 20,
        printedPage: 20,
        printedText: 'Одами беватан — мурдаи бекафан (булбули бечаман).',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '95',
    tajikCyrillic: 'Дӯст дар сафар шинохта мешавад.',
    persianText: 'دوست در سفر شناخته می‌شود.',
    simpleExplanationTj:
        'Дар сафар хислат ва муносибати дӯстон бештар маълум мешавад.',
    meaningTj:
        'Шароити душвор ё ғайриодӣ нишон медиҳад, ки дӯст то чӣ андоза боэътимод ва ҳамкор аст.',
    exampleSentenceTj:
        'Дар роҳ мошин вайрон шуд ва дӯсташ то охир ёрӣ дод; дӯст дар сафар шинохта мешавад.',
    categoryId: 'dusti',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '96',
    tajikCyrillic: 'Дӯстро дар рӯзи сахт шиносанд.',
    persianText: 'دوست را در روز سخت شناسند.',
    simpleExplanationTj: 'Дӯсти ҳақиқӣ дар вақти мушкилӣ маълум мешавад.',
    meaningTj:
        'Касе, ки дар рӯзи душвор паҳлӯи ту мемонад, дӯстии худро бо амал нишон медиҳад.',
    exampleSentenceTj:
        'Вақте бемор шуд, дӯсташ ҳар рӯз хабар мегирифт; дӯстро дар рӯзи сахт шиносанд.',
    categoryId: 'dusti',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
    variants: ['170'],
  ),
];
