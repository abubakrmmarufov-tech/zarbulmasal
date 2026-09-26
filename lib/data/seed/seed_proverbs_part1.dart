import '../models/proverb.dart';
import '../models/source_ref.dart';

/// Seed proverbs 21–43; see seed_proverbs.dart.
const List<Proverb> seedProverbsPart1 = [
  Proverb(
    id: '21',
    tajikCyrillic: 'Мисли модар ёру мисли Ватан диёре нест.',
    persianText: 'مثل مادر یار و مثل وطن دیاری نیست.',
    simpleExplanationTj: 'Модару Ватан барои инсон азизу беҳамтоянд.',
    meaningTj:
        'Ҳеҷ меҳру паноҳе мисли меҳри модар ва ҳеҷ диёре мисли Ватан нест.',
    exampleSentenceTj:
        'Ӯ баъди солҳои дурӣ ба зодгоҳ баргашт ва гуфт: «Мисли модар ёру мисли Ватан диёре нест».',
    categoryId: 'padaru_modar',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '22',
    tajikCyrillic: 'Паррандаро бо парвозаш баҳо диҳанд, одамро ба кораш.',
    persianText: 'پرنده را با پروازش بها دهند، آدم را به کارش.',
    simpleExplanationTj:
        'Паррандаро аз парвозаш ва одамро аз кори анҷомдодааш баҳо медиҳанд.',
    meaningTj:
        'Арзиши инсон аз амал ва натиҷаи кораш маълум мешавад, на аз суханҳои ӯ.',
    exampleSentenceTj:
        'Ӯ бисёр ваъда намедод, вале кораш ҳамеша хуб буд; одамро ба кораш баҳо медиҳанд.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '23',
    tajikCyrillic: 'Офтоб гармӣ дораду модар меҳр.',
    persianText: 'آفتاب گرمی دارد و مادر مهر.',
    simpleExplanationTj:
        'Офтоб бо гармӣ ва модар бо меҳру муҳаббат инсонро фаро мегиранд.',
    meaningTj:
        'Меҳри модар барои фарзанд мисли гармии офтоб ҳаётбахш ва бебаҳост.',
    exampleSentenceTj:
        'Вақте бемор шуд, модараш шабу рӯз парасторӣ кард; офтоб гармӣ дораду модар меҳр.',
    categoryId: 'padaru_modar',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '24',
    tajikCyrillic: 'Илм хоҳӣ, такрор кун, ҳосил хоҳӣ, шудгор кун.',
    persianText: 'علم خواهی، تکرار کن، حاصل خواهی، شیار کن.',
    simpleExplanationTj:
        'Барои омӯхтани илм такрор ва барои гирифтани ҳосил шудгору меҳнат лозим аст.',
    meaningTj:
        'Ҳар натиҷа роҳи худро дорад ва бе машқу меҳнати мувофиқ ба даст намеояд.',
    exampleSentenceTj:
        'Ӯ ҳар рӯз дарсҳоро аз нав мехонд, зеро медонист: «Илм хоҳӣ, такрор кун, ҳосил хоҳӣ, шудгор кун».',
    categoryId: 'ilm',
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
        pdfPage: 24,
        printedPage: 25,
        printedText: 'Илм хоҳӣ, такрор кун, ҳосил хоҳӣ, шудгор кун.',
      ),
    ],
  ),
  Proverb(
    id: '25',
    tajikCyrillic: 'Меҳнати имрӯз роҳати фардост.',
    persianText: 'محنت امروز راحت فرداست.',
    simpleExplanationTj:
        'Меҳнате, ки имрӯз мекунӣ, метавонад фардо зиндагиро осонтар кунад.',
    meaningTj: 'Кӯшиши имрӯз барои оянда шароити беҳтар ва осудагӣ меорад.',
    exampleSentenceTj:
        'Ӯ ҳоло сахт мехонад, то баъдтар касби хуб дошта бошад; меҳнати имрӯз роҳати фардост.',
    categoryId: 'mehnat',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '26',
    tajikCyrillic: 'Дасти одамизод — гул.',
    persianText: 'دست آدمیزاد — گل.',
    simpleExplanationTj: 'Дасти инсон қодир аст чизҳои зебо ва фоиданок созад.',
    meaningTj:
        '1. Одамизод ҳар кореро ба хубӣ иҷро намояд, 2. ҳар неъмату зебоие, ки дар ҷаҳон ҳаст, маҳсули меҳнати одамон аст.',
    exampleSentenceTj:
        '«Дасти одамизод гул аст» – мегӯяд зарбулмасали тоҷик. Мо ба ин калима «озод»-ро ҳамроҳ карда мегӯем: «Дасти одами озод гул аст». Чунки меҳнати озод набудагӣ барои одамизод ранҷу кулфат аст. Меҳнат озод бошад, гул аст, ки димоғи одамизоди меҳнаткашро муаттар мекунад.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Адабиёти тоҷик, синфи 5 (2017)',
    sources: [
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 38,
        printedPage: 38,
        printedText: 'Дасти одамизод – гул.',
        note: 'lesson «Зарбулмасалу мақолҳо», list of proverbs',
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
        printedText: 'Дасти одамизод гул.',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 47,
        printedPage: 50,
        printedText: 'Дасти одамизод гул аст.',
        note: 'variant',
      ),
      SourceRef(
        bookTitle:
            'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
        authorEditor: 'Муллоҷон Фозилов',
        year: 1975,
        publisher: 'Ирфон',
        city: 'Душанбе',
        pdfPage: 366,
        printedPage: 363,
        printedText: 'ДАСТИ ОДАМИЗОД (ОДАМ) ГУЛ (АСТ).',
        note: 'main entry with printed meaning and examples',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик (давраи нав), синфи 11',
        authorEditor: 'Х. Асозода, А. Кӯчаров',
        year: 2018,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 234,
        printedPage: 234,
        printedText: '«Дасти одамизод гул аст» – мегӯяд зарбулмасали тоҷик.',
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
      pdfPage: 366,
      printedPage: 363,
    ),
    exampleSource: SourceRef(
      bookTitle: 'Адабиёти тоҷик (давраи нав), синфи 11',
      authorEditor: 'Х. Асозода, А. Кӯчаров',
      year: 2018,
      publisher: 'Маориф',
      city: 'Душанбе',
      pdfPage: 234,
      printedPage: 234,
    ),
    exampleAttribution: 'Раҳим Ҷалил',
  ),
  Proverb(
    id: '27',
    tajikCyrillic: 'Ба як ҷавон чил ҳунар кам.',
    persianText: 'به یک جوان چهل هنر کم.',
    simpleExplanationTj:
        'Ҷавон ҳар қадар ҳунару малака омӯзад, боз ҳам ба фоидаи ӯст.',
    meaningTj:
        'Мард ҳарчи бештар ҳунар омӯзад, хуб аст, ҳар як ҳунар вақте ҳатман ба кор меояд.',
    exampleSentenceTj:
        'Ҳарчанд ӯ чун наългар ном бароварда бошад ҳам, ба мақоли «ба як мард чил ҳунар кам аст» амал намуда, ҳам мисгару ҳам оҳангар, ҳам дегрезу ҳам кандакори бомаҳорате шуда буд.',
    categoryId: 'omuzish',
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
        pdfPage: 45,
        printedPage: 45,
        printedText: 'Ба як ҷавон чил ҳунар кам.',
        note: 'section «Касбу ҳунар»',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 37,
        printedPage: 40,
        printedText: 'Ба як ҷавонмард 40 ҳунар кам аст.',
        note: 'variant',
      ),
      SourceRef(
        bookTitle:
            'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
        authorEditor: 'Муллоҷон Фозилов',
        year: 1975,
        publisher: 'Ирфон',
        city: 'Душанбе',
        pdfPage: 195,
        printedPage: 192,
        printedText: 'БА ЯК МАРД (ЙИГИТ, ҶАВОН) ЧИЛ ҲУНАР КАМ АСТ.',
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
      pdfPage: 195,
      printedPage: 192,
      note: 'entry «Ба як мард (йигит, ҷавон) чил ҳунар кам аст»',
    ),
    exampleSource: SourceRef(
      bookTitle:
          'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
      authorEditor: 'Муллоҷон Фозилов',
      year: 1975,
      publisher: 'Ирфон',
      city: 'Душанбе',
      pdfPage: 195,
      printedPage: 192,
    ),
    exampleAttribution: 'Раҳим Ҷалил',
  ),
  Proverb(
    id: '28',
    tajikCyrillic: 'Инсон бо забонаш не, бояд бо амалаш сухан гӯяд.',
    persianText: 'انسان با زبانش نی، باید با عملش سخن گوید.',
    simpleExplanationTj:
        'Сухан танҳо даъво аст; амал нишон медиҳад, ки инсон воқеан чӣ мекунад.',
    meaningTj: 'Одамро аз рӯи кораш бишинос, на танҳо аз рӯи гуфтаҳояш.',
    exampleSentenceTj:
        'Ӯ нагуфт, ки кӯмак мекунад — омаду корро анҷом дод; инсон бояд бо амалаш сухан гӯяд.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.modernCustom,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '29',
    tajikCyrillic: 'Сухан зар аст, сабр гавҳар.',
    persianText: 'سخن زر است، صبر گوهر.',
    simpleExplanationTj:
        'Сухани хуб арзишманд аст ва сабр низ арзиши бисёр баланд дорад.',
    meaningTj:
        'Дар муносибат бо дигарон ҳам сухани дуруст ва ҳам сабру таҳаммул муҳиманд.',
    exampleSentenceTj:
        'Дар баҳс ӯ ором монд ва баъд боандеша ҷавоб дод; сухан зар аст, сабр гавҳар.',
    categoryId: 'sabr',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '30',
    tajikCyrillic: 'Адаб беҳтарин ганҷ аст.',
    persianText: 'ادب بهترین گنج است.',
    simpleExplanationTj:
        'Одобу рафтори хуб аз сарвати моддӣ ҳам арзишмандтар аст.',
    meaningTj: 'Беҳтарин хислати неки ҳар кас хулқу одоби хуби ӯст.',
    exampleSentenceTj:
        'Ҳама ӯро барои муомилаи хубаш эҳтиром мекарданд; адаб беҳтарин ганҷ аст.',
    categoryId: 'odob',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I (1975)',
    sources: [
      SourceRef(
        bookTitle:
            'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
        authorEditor: 'Муллоҷон Фозилов',
        year: 1975,
        publisher: 'Ирфон',
        city: 'Душанбе',
        pdfPage: 55,
        printedPage: 54,
        printedText:
            '1. АДАБ БЕҲТАРИН ГАНҶ АСТ. 2. АДАБИ МАРД БЕҲТАР АЗ ЗАР(Р)И ӮСТ.',
        note: 'main entry, printed meaning',
      ),
    ],
    meaningSource: SourceRef(
      bookTitle:
          'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
      authorEditor: 'Муллоҷон Фозилов',
      year: 1975,
      publisher: 'Ирфон',
      city: 'Душанбе',
      pdfPage: 55,
      printedPage: 54,
    ),
  ),
  Proverb(
    id: '31',
    tajikCyrillic: 'Меҳнат фаровон мекунад, танбалӣ вайрон мекунад.',
    persianText: 'محنت فراوان می‌کند، تنبلی ویران می‌کند.',
    simpleExplanationTj:
        'Меҳнат рӯзгорро обод мекунад, вале танбалӣ онро ақиб мебарад.',
    meaningTj:
        'Пешрафт аз кори пайваста меояд; бекорӣ ва танбалӣ боиси камбудӣ мешаванд.',
    exampleSentenceTj:
        'Хонавода бо меҳнати якҷоя хоҷагиро беҳтар кард; меҳнат фаровон мекунад, танбалӣ вайрон мекунад.',
    categoryId: 'mehnat',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '32',
    tajikCyrillic: 'Меҳнати ҳалол — нони бемалол.',
    persianText: 'محنت حلال — نان بی‌ملال.',
    simpleExplanationTj:
        'Ноне, ки аз меҳнати ҳалол ба даст меояд, бо виҷдони ором хӯрда мешавад.',
    meaningTj:
        'Рӯзии ҳалол оромишу обрӯ меорад ва аз даромади нопок беҳтар аст.',
    exampleSentenceTj:
        'Ӯ маоши камтарро интихоб кард, вале роҳи нодурустро напазируфт: «Меҳнати ҳалол — нони бемалол».',
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
        pdfPage: 47,
        printedPage: 47,
        printedText: 'Меҳнати ҳалол — нони бемалол.',
        note: 'section «Ҳаракату баракат»',
      ),
    ],
  ),
  Proverb(
    id: '33',
    tajikCyrillic: 'Бе ранҷ наояд ганҷ.',
    persianText: 'بی رنج نیاید گنج.',
    simpleExplanationTj:
        'Барои ба даст овардани ганҷ ё натиҷаи арзишманд ранҷу меҳнат лозим аст.',
    meaningTj: 'Муваффақияти ҳақиқӣ бе заҳмат ба даст намеояд.',
    exampleSentenceTj:
        'Омодагӣ ба имтиҳон душвор буд, аммо ӯ таслим нашуд; бе ранҷ наояд ганҷ.',
    categoryId: 'mehnat',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '34',
    tajikCyrillic: 'Аз бад — касофат, аз нек — шарофат.',
    persianText: 'از بد — کثافت، از نیک — شرافت.',
    simpleExplanationTj: 'Кори бад оқибати бад ва кори нек обрӯву хайр меорад.',
    meaningTj: 'Рафтори инсон натиҷа ва обрӯи мувофиқи худро ба вуҷуд меорад.',
    exampleSentenceTj:
        'Ӯ ба мардум кумак мекард ва ҳама эҳтиромаш мекарданд; аз нек — шарофат.',
    categoryId: 'hikmat',
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
        pdfPage: 29,
        printedPage: 32,
        printedText: 'Аз бад—касофат, аз нек—шарофат.',
      ),
      SourceRef(
        bookTitle:
            'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
        authorEditor: 'Муллоҷон Фозилов',
        year: 1975,
        publisher: 'Ирфон',
        city: 'Душанбе',
        pdfPage: 57,
        printedPage: 56,
        printedText: 'АЗ БАД КАСОФАТ, АЗ НЕК ШАРОФАТ.',
        note: 'cross-reference entry',
      ),
    ],
  ),
  Proverb(
    id: '35',
    tajikCyrillic: 'Салом аз хурду калом аз калон.',
    persianText: 'سلام از خرد و کلام از کلان.',
    simpleExplanationTj:
        'Дар одоби анъанавӣ хурдтар аввал салом мекунад ва калонтар суханро оғоз мекунад.',
    meaningTj: 'Ҳар синну мақом дар муошират одобу навбати худро дорад.',
    exampleSentenceTj:
        'Ҷавон ба устод аввал салом дод ва баъд ба сухани ӯ гӯш кард: «Салом аз хурду калом аз калон».',
    categoryId: 'odob',
    level: 2,
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
        pdfPage: 68,
        printedPage: 71,
        printedText: 'Салом аз хурду калом аз калон.',
      ),
    ],
  ),
  Proverb(
    id: '36',
    tajikCyrillic: 'Як китоби хуб беҳтар аз як хазинаи бузург.',
    persianText: 'یک کتاب خوب بهتر از یک خزینهٔ بزرگ.',
    simpleExplanationTj:
        'Китоби хуб метавонад аз сарвати зиёди моддӣ арзишмандтар бошад.',
    meaningTj: 'Донишу андешае, ки аз китоб мегирӣ, сарвати дарозмуддат аст.',
    exampleSentenceTj:
        'Ӯ барои тӯҳфа китоби хубро интихоб кард, зеро як китоби хуб беҳтар аз як хазинаи бузург аст.',
    categoryId: 'ilm',
    level: 2,
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
        pdfPage: 78,
        printedPage: 81,
        printedText: 'Як китоби хуб беҳтар аз як хазинаи бузург.',
      ),
    ],
  ),
  Proverb(
    id: '37',
    tajikCyrillic:
        'Ҳунар аз нуқраю тиллою зар беҳ, Ҳунар аз мулку мероси падар беҳ.',
    persianText: 'هنر از نقره و طلا و زر به، هنر از ملک و میراث پدر به.',
    simpleExplanationTj:
        'Ҳунари шахсӣ аз молу мулке, ки ба мерос мерасад, пойдортар аст.',
    meaningTj:
        'Малака ва касб сарватест, ки инсон бо худ дорад ва метавонад аз он рӯзӣ ёбад.',
    exampleSentenceTj:
        'Падар ба писараш касб омӯзонд: «Ҳунар аз мулку мероси падар беҳ».',
    categoryId: 'omuzish',
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
        pdfPage: 45,
        printedPage: 45,
        printedText:
            'Ҳунар аз нуқраю тиллою зар беҳ, / Ҳунар аз мулку мероси падар беҳ.',
        note: 'our text was the second line only',
      ),
      SourceRef(
        bookTitle: 'Фолклори Роғун',
        authorEditor:
            'Рӯзии Аҳмад, Салоҳиддин Фатҳуллоев (гирдоварӣ ва тадвин)',
        year: 2017,
        publisher: 'ЭР-граф',
        city: 'Душанбе',
        pdfPage: 296,
        printedPage: 296,
        printedText:
            'Ҳунар аз нуқраву тиллову зар беҳ, / Ҳунар аз молу мероси падар беҳ.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '38',
    tajikCyrillic: 'Дониш омӯхтан — бо сӯзан чоҳ кандан.',
    persianText: 'دانش آموختن — با سوزن چاه کندن.',
    simpleExplanationTj: 'Омӯхтани дониш кори оҳиста, душвор ва пуртоқат аст.',
    meaningTj: 'Дониш бо кӯшиши пайваста ва сабри зиёд ҷамъ мешавад.',
    exampleSentenceTj:
        'Ӯ ҳар рӯз кам-кам пеш мерафт; дониш омӯхтан — бо сӯзан чоҳ кандан.',
    categoryId: 'ilm',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '39',
    tajikCyrillic: 'Тилло дар оташ, одам дар меҳнат маълум мешавад.',
    persianText: 'طلا در آتش، آدم در محنت معلوم می‌شود.',
    simpleExplanationTj:
        'Тилло дар оташ санҷида мешавад ва инсон дар вақти меҳнату масъулият.',
    meaningTj:
        'Қобилияту хислати воқеии одам дар кори душвор ва озмоиш маълум мешавад.',
    exampleSentenceTj:
        'Ҳангоми кори сахти гурӯҳӣ ӯ масъулиятро ба дӯш гирифт; тилло дар оташ, одам дар меҳнат маълум мешавад.',
    categoryId: 'mehnat',
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
        pdfPage: 71,
        printedPage: 74,
        printedText: 'Тилло дар оташ, одам дар меҳнат маълум мешавад.',
      ),
    ],
  ),
  Proverb(
    id: '40',
    tajikCyrillic: 'Кам гӯю дониста гӯй.',
    persianText: 'کم گوی و دانسته گوی.',
    simpleExplanationTj:
        'Камтар сухан гӯ, вале ҳар суханатро бо дониш ва андеша бигӯ.',
    meaningTj: 'Сифати сухан аз зиёдии он муҳимтар аст.',
    exampleSentenceTj:
        'Ӯ дар маҷлис танҳо вақте сухан гуфт, ки далел дошт: «Кам гӯю дониста гӯй».',
    categoryId: 'odob',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '41',
    tajikCyrillic: 'Нури ақл — дониш аст.',
    persianText: 'نور عقل — دانش است.',
    simpleExplanationTj:
        'Дониш ақлро равшан карда, барои фаҳмидани ҷаҳон ёрӣ медиҳад.',
    meaningTj: 'Ақл бо омӯзиш ва дониш қавӣ ва равшан мешавад.',
    exampleSentenceTj:
        'Пас аз хондани китоб масъала барои ӯ равшан шуд; нури ақл — дониш аст.',
    categoryId: 'ilm',
    level: 2,
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
        printedText: 'Нури ақл—дониш аст.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 44,
        printedPage: 44,
        printedText: 'Нури ақл дониш аст.',
        note: 'section «Ақл»',
      ),
    ],
  ),
  Proverb(
    id: '42',
    tajikCyrillic: 'Аввал андеша, баъд гуфтор.',
    persianText: 'اول اندیشه، بعد گفتار.',
    simpleExplanationTj: 'Пеш аз он ки сухан гӯӣ, аввал фикр кун.',
    meaningTj:
        '1. Пеш аз гуфтани сухане фикр бояд кард, 2. сухан аз андеша карда гуфтан пуртаъсиру судмандтар мегардад.',
    exampleSentenceTj:
        '— Дар омади гап гуфтам-дия, раис, мебахшед,— узрхоҳӣ кард Улфатов.\n— «Аввал андеша, баъд гуфтор»,— гӯён раис дар сари дураҳа аз Улфатов ҷудо шуд...',
    categoryId: 'hikmat',
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
        pdfPage: 28,
        printedPage: 31,
        printedText: 'Аввал андеша, баъд гуфтор.',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 38,
        printedPage: 38,
        printedText: '«Аввал – андеша, баъд – гуфтор»',
        note: 'cited as a мақол',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 38,
        printedPage: 38,
        printedText: 'Аввал андеша в-он гаҳ гуфтор.',
        note: 'variant',
      ),
      SourceRef(
        bookTitle:
            'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
        authorEditor: 'Муллоҷон Фозилов',
        year: 1975,
        publisher: 'Ирфон',
        city: 'Душанбе',
        pdfPage: 26,
        printedPage: 25,
        printedText: 'АВВАЛ АНДЕША В-ОН ГАҲЕ (БАЪД) ГУФТОР.',
        note: 'variant, main entry',
      ),
    ],
    meaningSource: SourceRef(
      bookTitle:
          'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
      authorEditor: 'Муллоҷон Фозилов',
      year: 1975,
      publisher: 'Ирфон',
      city: 'Душанбе',
      pdfPage: 26,
      printedPage: 25,
    ),
    exampleSource: SourceRef(
      bookTitle:
          'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
      authorEditor: 'Муллоҷон Фозилов',
      year: 1975,
      publisher: 'Ирфон',
      city: 'Душанбе',
      pdfPage: 26,
      printedPage: 25,
      note: 'continues on p. 26',
    ),
    exampleAttribution: 'Фотеҳ Ниёзӣ',
  ),
  Proverb(
    id: '43',
    tajikCyrillic: 'Забони сурх сари сабз медиҳад барбод.',
    persianText: 'زبان سرخ سر سبز می‌دهد برباد.',
    simpleExplanationTj:
        'Сухани беэҳтиёт метавонад ба худи гӯянда зарари ҷиддӣ расонад.',
    meaningTj:
        'Забонро бояд нигоҳ дошт, зеро сухани нодуруст метавонад обрӯ, амният ё ҳатто ҷони инсонро зери хатар гузорад.',
    exampleSentenceTj:
        'Ӯ фаҳмид, ки дар бораи сирри дигарон беэҳтиёт сухан гуфтан хатарнок аст; забони сурх сари сабз медиҳад барбод.',
    categoryId: 'odob',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ (1956)',
    variants: ['44'],
    sources: [
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 51,
        printedPage: 54,
        printedText: 'Забони сурх сари сабз медиҳад барбод.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 51,
        printedPage: 51,
        printedText:
            'Забони сурх сари сабз медиҳад бар бод, / Киро забон на ба банд аст, пой дар банд аст. (Рӯдакӣ)',
        note: 'couplet signed Рӯдакӣ',
      ),
    ],
  ),
];
