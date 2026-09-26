import '../models/proverb.dart';
import '../models/source_ref.dart';

/// Seed proverbs 44–72; see seed_proverbs.dart.
const List<Proverb> seedProverbsPart2 = [
  Proverb(
    id: '44',
    tajikCyrillic: 'Забони сурх сари сабзро мехӯрад.',
    persianText: 'زبان سرخ سر سبز را می‌خورد.',
    simpleExplanationTj: 'Забони беандеша метавонад ба сари инсон бало оварад.',
    meaningTj:
        'Сухани нодуруст баъзан аз худи амал ҳам бештар зарар мерасонад.',
    exampleSentenceTj:
        'Пеш аз паҳн кардани овоза ӯ худро нигоҳ дошт: «Забони сурх сари сабзро мехӯрад».',
    categoryId: 'odob',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
    canonicalId: '43',
  ),
  Proverb(
    id: '45',
    tajikCyrillic: 'Сари хамро шамшер намебурад.',
    persianText: 'سر خم را شمشیر نمی‌بُرد.',
    simpleExplanationTj:
        'Касе, ки сар хам мекунад, аз зарбаи шамшер эмин мемонад — ин тасвири рамзӣ аст.',
    meaningTj:
        'Фурӯтанӣ, нармӣ ва дурӣ аз ҷанҷоли беҳуда бисёр вақт инсонро аз зарар нигоҳ медорад.',
    exampleSentenceTj:
        'Ӯ ба таҳқир бо ҷанҷол ҷавоб надод ва вазъ ором шуд; сари хамро шамшер намебурад.',
    categoryId: 'hikmat',
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
        pdfPage: 31,
        printedPage: 31,
        printedText: 'Сари хамро (каҷро) шамшер намебурад (набуридааст).',
        note:
            'our text is the base reading; the book gives alternatives in brackets',
      ),
    ],
  ),
  Proverb(
    id: '46',
    tajikCyrillic: 'Даҳони пӯшида сад тилло.',
    persianText: 'دهان پوشیده صد طلا.',
    simpleExplanationTj:
        'Хомӯш мондан дар баъзе ҳолатҳо аз бисёр сухан гуфтан арзишмандтар аст.',
    meaningTj:
        'Вақте сухан фоида надорад ё метавонад зарар расонад, хомӯшӣ беҳтар аст.',
    exampleSentenceTj:
        'Дар баҳси беасос ӯ чизе нагуфт; даҳони пӯшида сад тилло.',
    categoryId: 'xomushhi',
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
        pdfPage: 35,
        printedPage: 35,
        printedText: 'Даҳони пӯшида сад тилло.',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 121,
        printedPage: 121,
        printedText: 'ДАҲОНИ ПӮШИДА ҲАЗОР ТИЛЛО',
        note: 'variant, heading of a «Гулистон» story',
      ),
    ],
  ),
  Proverb(
    id: '47',
    tajikCyrillic: 'Бо ҳалво гуфтан даҳон ширин намешавад.',
    persianText: 'با حلوا گفتن دهان شیرین نمی‌شود.',
    simpleExplanationTj:
        'Танҳо номи ҳалворо гуфтан даҳонро ширин намекунад; барои натиҷа амал лозим аст.',
    meaningTj: 'Бо гапу орзу танҳо кор пеш намеравад — бояд амал кард.',
    exampleSentenceTj:
        'Нақша бисёр буд, вале касе оғоз намекард; бо ҳалво гуфтан даҳон ширин намешавад.',
    categoryId: 'mehnat',
    level: 4,
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
        pdfPage: 246,
        printedPage: 243,
        printedText: 'БО ҲАЛВО ГУФТАН ДАҲОН ШИРИН НАМЕШАВАД.',
        note: 'cross-reference to «Ба ҳалво гуфтан…» (vol. II)',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 40,
        printedPage: 43,
        printedText: 'Бо „ҳалво, ҳалво“ гуфтан даҳон ширин намешавад.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '48',
    tajikCyrillic: 'Нонро калон гиру, гапро калон не.',
    persianText: 'نان را کلان گیر و گپ را کلان نی.',
    simpleExplanationTj:
        'Порчаи нон калон бошад ҳам майлаш, вале суханро калон карда муболиға накун.',
    meaningTj: 'Лоф назан ва чизҳоро аз ҳад зиёд бузург нишон надеҳ.',
    exampleSentenceTj:
        'Ӯ гуфт, ки корро як рӯзда тамом мекунад, аммо дӯсташ хандид: «Нонро калон гиру, гапро калон не».',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '49',
    tajikCyrillic: 'Гапи нағз морро аз хонааш мебарорад.',
    persianText: 'گپ نغز مار را از خانه‌اش برمی‌آرد.',
    simpleExplanationTj:
        'Сухани нарму хуб ҳатто мавҷуди тарснокро аз ҷояш берун меорад — ин тасвири маҷозӣ аст.',
    meaningTj:
        'Муомилаи хуб ва сухани ширин метавонад одамони душворро ҳам розӣ ё ором кунад.',
    exampleSentenceTj:
        'Ба ҷойи ҷанҷол ӯ оромона хоҳиш кард ва масъала ҳал шуд; гапи нағз морро аз хонааш мебарорад.',
    categoryId: 'dusti',
    level: 4,
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
        pdfPage: 272,
        printedPage: 269,
        printedText: 'ГАПИ НАҒЗ МОРРО АЗ ХОНААШ МЕБАРОРАД.',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 39,
        printedPage: 42,
        printedText: 'Бо сухани ширин мор аз хонааш мебарояд.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '50',
    tajikCyrillic: 'Аз пашша фил масоз.',
    persianText: 'از پشه فیل مساز.',
    simpleExplanationTj: 'Чизи хурдро мисли чизи азим нишон надиҳ.',
    meaningTj: 'Мушкили майдаро муболиға карда калон накун.',
    exampleSentenceTj: 'Ин танҳо як хатои хурд буд; аз пашша фил масоз.',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '51',
    tajikCyrillic: 'Сарро деҳу сирро не.',
    persianText: 'سر را ده و سرّ را نی.',
    simpleExplanationTj:
        'Ҳатто дар ҳолати сахт ҳам сирри ба ту боваркардаро фош накун.',
    meaningTj:
        'Нигоҳ доштани сирру амонат аз манфиати шахсӣ ҳам болотар дониста мешавад.',
    exampleSentenceTj:
        'Дӯсташ ба ӯ сирре гуфт ва ӯ онро ба касе нагуфт: «Сарро деҳу сирро не».',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '52',
    tajikCyrillic: 'Дар ҳар сар сиррест.',
    persianText: 'در هر سر سرّی‌ست.',
    simpleExplanationTj:
        'Ҳар инсон дар дилаш фикр ё сирре дорад, ки дигарон намедонанд.',
    meaningTj:
        'Одами дигарро пурра донистан душвор аст; ҳар кас ҷаҳони дарунӣ ва асрори худро дорад.',
    exampleSentenceTj:
        'Ӯ хомӯш буд, вале касе намедонист чӣ фикр дорад; дар ҳар сар сиррест.',
    categoryId: 'mehnat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '53',
    tajikCyrillic: 'Дарро гуфтам, девор шунав.',
    persianText: 'در را گفتم، دیوار شنو.',
    simpleExplanationTj:
        'Суханро ба як кас мегӯянд, то шахси дигар онро ғайримустақим бишнавад.',
    meaningTj:
        'Баъзан панд ё танқидро мустақим не, балки ба воситаи ишора ба шахси дигар мерасонанд.',
    exampleSentenceTj:
        'Модар ба духтараш гуфт, вале мақсадаш келин буд: «Дарро гуфтам, девор шунав».',
    categoryId: 'odob',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '54',
    tajikCyrillic: 'Гапи рост талх мешавад.',
    persianText: 'گپ راست تلخ می‌شود.',
    simpleExplanationTj: 'Ҳақиқат баъзан ба гӯш нохуш ё дарднок мерасад.',
    meaningTj:
        'Рост гуфтан ҳамеша хушоянд нест, вале ҳақиқат буданашро аз даст намедиҳад.',
    exampleSentenceTj: 'Дӯсташ хатояшро рӯирост гуфт; гапи рост талх мешавад.',
    categoryId: 'rostqavli',
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
        pdfPage: 26,
        printedPage: 26,
        printedText: 'Гапи рост талх мешавад.',
        note: 'section «Ростӣ»',
      ),
      SourceRef(
        bookTitle:
            'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
        authorEditor: 'Муллоҷон Фозилов',
        year: 1975,
        publisher: 'Ирфон',
        city: 'Душанбе',
        pdfPage: 272,
        printedPage: 269,
        printedText: 'ГАПИ РОСТ ТАЛХ МЕШАВАД.',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 70,
        printedPage: 73,
        printedText: 'Сухани рост талх мешавад.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '55',
    tajikCyrillic: 'Ростӣ — растӣ.',
    persianText: 'راستی — رستی.',
    simpleExplanationTj: 'Ростӣ инсонро ба роҳи дуруст мебарад.',
    meaningTj: 'Ростқавлӣ асоси обрӯ, боварӣ ва раҳоӣ аз мушкилоти дурӯғ аст.',
    exampleSentenceTj:
        'Ӯ ҳақиқатро пинҳон накард ва масъала ҳал шуд; ростӣ — растӣ.',
    categoryId: 'rostqavli',
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
        pdfPage: 91,
        printedPage: 90,
        printedText: 'мук. Ростӣ — растӣ.',
        note: 'cross-reference line',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 15,
        printedPage: 15,
        printedText: 'Ростӣ, растӣ.',
      ),
    ],
  ),
  Proverb(
    id: '56',
    tajikCyrillic: 'Дурӯғ умри кӯтоҳ дорад.',
    persianText: 'دروغ عمر کوتاه دارد.',
    simpleExplanationTj: 'Дурӯғ дер пинҳон намемонад ва зуд ошкор мешавад.',
    meaningTj:
        'Дурӯғро муддати дароз нигоҳ доштан душвор аст; ҳақиқат оқибат рӯйи об мебарояд.',
    exampleSentenceTj:
        'Ӯ аввал дурӯғ гуфт, вале далелҳо зуд пайдо шуданд; дурӯғ умри кӯтоҳ дорад.',
    categoryId: 'rostqavli',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '57',
    tajikCyrillic: 'Ҳақиқат талх аст.',
    persianText: 'حقیقت تلخ است.',
    simpleExplanationTj: 'Ҳақиқат баъзан шуниданаш душвор аст.',
    meaningTj:
        'Ҳақиқат метавонад нохуш бошад, аммо қабул кардани он барои ислоҳи вазъ муҳим аст.',
    exampleSentenceTj:
        'Натиҷаи имтиҳон ба ӯ писанд наомад, вале қабул кард: ҳақиқат талх аст.',
    categoryId: 'rostqavli',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '58',
    tajikCyrillic: 'Ҳақиқатро пинҳон карда намешавад.',
    persianText: 'حقیقت را پنهان کرده نمی‌شود.',
    simpleExplanationTj: 'Ҳақиқатро барои ҳамеша пинҳон кардан мумкин нест.',
    meaningTj:
        'Бо гузашти вақт далелҳо пайдо мешаванд ва воқеият ошкор мегардад.',
    exampleSentenceTj:
        'Ҳама чизро пинҳон карданд, аммо санадҳо пайдо шуданд; ҳақиқатро пинҳон карда намешавад.',
    categoryId: 'rostqavli',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '59',
    tajikCyrillic: 'Илм — чароғи ақл.',
    persianText: 'علم — چراغ عقل.',
    simpleExplanationTj: 'Илм мисли чароғ ақлро равшан мекунад.',
    meaningTj:
        'Дониш ба инсон кумак мекунад, ки дурусттар бифаҳмад, андеша кунад ва қарор гирад.',
    exampleSentenceTj:
        'Бо омӯхтани мавзӯъ масъала барояш равшан шуд; илм — чароғи ақл.',
    categoryId: 'ilm',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '60',
    tajikCyrillic: 'Дониш аз хондан, ҳунар аз кор.',
    persianText: 'دانش از خواندن، هنر از کار.',
    simpleExplanationTj:
        'Дониш бештар аз хондану омӯхтан, ҳунар аз машқ ва кор пайдо мешавад.',
    meaningTj: 'Барои дониш назария ва барои маҳорат таҷриба лозим аст.',
    exampleSentenceTj:
        'Ӯ китоб мехонд ва ҳамзамон машқ мекард; дониш аз хондан, ҳунар аз кор.',
    categoryId: 'omuzish',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '61',
    tajikCyrillic: 'Одам аз одам меомӯзад.',
    persianText: 'آدم از آدم می‌آموزد.',
    simpleExplanationTj:
        'Инсон аз таҷриба, сухан ва рафтори дигарон чиз меомӯзад.',
    meaningTj:
        'Омӯзиш танҳо аз китоб нест; одамон низ барои ҳамдигар устод мешаванд.',
    exampleSentenceTj:
        'Шогирд аз устои калонсол бисёр чиз ёд гирифт; одам аз одам меомӯзад.',
    categoryId: 'omuzish',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '62',
    tajikCyrillic: 'Ҳунар беҳ аз симу зар аст.',
    persianText: 'هنر به از سیم و زر است.',
    simpleExplanationTj: 'Ҳунар аз нуқраю тилло арзишмандтар аст.',
    meaningTj:
        'Малака сарватест, ки метавонад ҳамеша ба инсон кору рӯзӣ диҳад.',
    exampleSentenceTj:
        'Ӯ ба ҷойи мероси пулӣ касб омӯхт; ҳунар беҳ аз симу зар аст.',
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
        pdfPage: 41,
        printedPage: 41,
        printedText: 'Ҳунар беҳ аз симу зар аст.',
        note: 'lesson «Зарбулмасалу мақолҳо»',
      ),
    ],
  ),
  Proverb(
    id: '63',
    tajikCyrillic: 'Ҳунарманд ҳар ҷо азиз аст.',
    persianText: 'هنرمند هر جا عزیز است.',
    simpleExplanationTj: 'Одами ҳунарманд дар ҳар ҷо қадр мешавад.',
    meaningTj:
        'Маҳорат ва қобилияти фоиданок ба инсон обрӯ ва ҷойгоҳ медиҳанд.',
    exampleSentenceTj:
        'Усто ба шаҳри дигар рафт ва зуд кор ёфт; ҳунарманд ҳар ҷо азиз аст.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '64',
    tajikCyrillic: 'Ҳунар дошта бошӣ, хор намешавӣ.',
    persianText: 'هنر داشته باشی، خوار نمی‌شوی.',
    simpleExplanationTj:
        'Касе, ки ҳунар дорад, одатан муҳтоҷу бечора намемонад.',
    meaningTj: 'Ҳунар ба инсон истиқлол, рӯзӣ ва обрӯ медиҳад.',
    exampleSentenceTj:
        'Ҳарчанд корашро аз даст дод, бо ҳунараш боз кор ёфт; ҳунар дошта бошӣ, хор намешавӣ.',
    categoryId: 'muvaffaqiyat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
  Proverb(
    id: '65',
    tajikCyrillic: 'Ранҷ бурдӣ, ганҷ бурдӣ.',
    persianText: 'رنج بردی، گنج بردی.',
    simpleExplanationTj:
        'Касе, ки заҳмат мекашад, ба натиҷаи арзишманд мерасад.',
    meaningTj: 'Меҳнат ва сабр роҳи расидан ба комёбӣ ва фоидаанд.',
    exampleSentenceTj:
        'Солҳо машқ кард ва ниҳоят ғолиб шуд. Мураббӣ табрикаш кард: «Ранҷ бурдӣ, ганҷ бурдӣ».',
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
        printedText: 'Ранҷ бурдӣ, ганҷ бурдӣ.',
      ),
      SourceRef(
        bookTitle:
            'Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо',
        authorEditor:
            'Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон)',
        year: 1990,
        publisher: 'Адиб',
        city: 'Душанбе',
        pdfPage: 15,
        printedPage: 15,
        printedText: 'Ранҷ бурдӣ, / Ганҷ бурдӣ.',
      ),
    ],
  ),
  Proverb(
    id: '66',
    tajikCyrillic: 'То меҳнат накунӣ, роҳат набинӣ.',
    persianText: 'تا محنت نکنی، راحت نبینی.',
    simpleExplanationTj:
        'Бе меҳнат ба роҳат ва зиндагии беҳтар расидан душвор аст.',
    meaningTj: 'Осудагӣ натиҷаи кӯшиш ва кори пешина аст.',
    exampleSentenceTj:
        'Ӯ аввал кори сахтро анҷом дод, баъд истироҳат кард; то меҳнат накунӣ, роҳат набинӣ.',
    categoryId: 'mehnat',
    level: 2,
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
        printedText: '«То меҳнат накунӣ, роҳат набинӣ»',
        note: 'cited as a мақол',
      ),
    ],
  ),
  Proverb(
    id: '67',
    tajikCyrillic: 'То меҳнат накунӣ, санги сиёҳ лаъл нагардад.',
    persianText: 'تا محنت نکنی، سنگ سیاه لعل نگردد.',
    simpleExplanationTj:
        'Ҳатто чизи оддӣ танҳо бо заҳмат метавонад ба чизи арзишманд табдил ёбад.',
    meaningTj: 'Қобилияту натиҷаи баланд бе кор ва тарбия ба вуҷуд намеояд.',
    exampleSentenceTj:
        'Шогирд бо машқи зиёд усто шуд; то меҳнат накунӣ, санги сиёҳ лаъл нагардад.',
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
        printedText: 'То меҳнат накунӣ, санги сиёҳ лаъл нагардад.',
      ),
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 41,
        printedPage: 41,
        printedText: 'То меҳнат накунӣ, санги сиёҳ лаъл нагардад.',
      ),
    ],
  ),
  Proverb(
    id: '68',
    tajikCyrillic: 'Бе меҳнат роҳат муяссар намешавад.',
    persianText: 'بی محنت راحت میسر نمی‌شود.',
    simpleExplanationTj: 'Роҳат ва осудагӣ бе меҳнат ба даст намеояд.',
    meaningTj: 'Барои комёбӣ кӯшиши воқеӣ лозим аст.',
    exampleSentenceTj:
        'Ӯ аввал корашро тамом кард, баъд истироҳат; бе меҳнат роҳат муяссар намешавад.',
    categoryId: 'mehnat',
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
        pdfPage: 37,
        printedPage: 40,
        printedText: 'Бе меҳнат роҳат муяссар намешавад.',
      ),
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
        printedText: 'Нобурда ранҷ ганҷ муяссар намешавад.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '69',
    tajikCyrillic: 'Кор кунӣ, нон мехӯрӣ.',
    persianText: 'کار کنی، نان می‌خوری.',
    simpleExplanationTj: 'Бо кор кардан инсон рӯзии худро пайдо мекунад.',
    meaningTj: 'Меҳнат асоси таъмини зиндагӣ аст.',
    exampleSentenceTj:
        'Ӯ аз субҳ кор мекард ва бо пули ҳалол рӯзӣ меёфт; кор кунӣ, нон мехӯрӣ.',
    categoryId: 'mehnat',
    level: 1,
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
        printedText: 'Кор кунӣ, нон мехӯрӣ.',
      ),
    ],
  ),
  Proverb(
    id: '70',
    tajikCyrillic: 'Кор ба кордон осон аст.',
    persianText: 'کار به کاردان آسان است.',
    simpleExplanationTj:
        'Ҳар корро касе беҳтар анҷом медиҳад, ки онро медонад ва таҷриба дорад.',
    meaningTj: 'Кори махсусро бояд ба шахси соҳибихтисос супорид.',
    exampleSentenceTj:
        'Барои таъмири барқ усто даъват карданд; кор ба кордон осон аст.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.pageVerified,
    sourceNote: 'Адабиёти тоҷик, синфи 5 (2017)',
    variants: ['149'],
    sources: [
      SourceRef(
        bookTitle: 'Адабиёти тоҷик, синфи 5',
        authorEditor: 'Т. Мирзод, Р. Ҳамидов, М. Пирзод',
        year: 2017,
        publisher: 'Маориф',
        city: 'Душанбе',
        pdfPage: 72,
        printedPage: 72,
        printedText: '«Кор ба кордон осон аст»',
        note: 'listed as зарбулмасалу мақол',
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
        printedText: 'Кор пеши кордон осон.',
        note: 'variant',
      ),
      SourceRef(
        bookTitle: 'Зарбулмасал ва мақолҳои тоҷикӣ',
        authorEditor: 'В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда)',
        year: 1956,
        publisher: 'Нашриёти давлатии Тоҷикистон',
        city: 'Сталинобод',
        pdfPage: 35,
        printedPage: 38,
        printedText: 'Ба кордон кор осон.',
        note: 'variant',
      ),
    ],
  ),
  Proverb(
    id: '71',
    tajikCyrillic: 'Ҳар чизе, ки коштӣ, ҳамонро медаравӣ.',
    persianText: 'هر چیزی که کاشتی، همان را مدروی.',
    simpleExplanationTj: 'Ҳар тухме, ки мекорӣ, ҳамон навъи ҳосилро мегирӣ.',
    meaningTj: 'Оқибати рафтору кори инсон ба худи ӯ бармегардад.',
    exampleSentenceTj:
        'Ӯ ба ҳама некӣ мекард ва дар рӯзи сахт ҳама ёриаш карданд; ҳар чӣ коштӣ, ҳамонро медаравӣ.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
    canonicalId: '169',
  ),
  Proverb(
    id: '72',
    tajikCyrillic: 'Агар бод шинонӣ, тӯфон медаравӣ.',
    persianText: 'اگر باد نشانی، توفان مدروی.',
    simpleExplanationTj:
        'Кори бад метавонад оқибати аз худи он ҳам вазнинтар оварад.',
    meaningTj:
        'Кина, низоъ ё беадолатии хурд метавонад мушкили калонтар ба вуҷуд орад.',
    exampleSentenceTj:
        'Ӯ ҷанҷолро қасдан оғоз кард ва баъд вазъ аз назорат баромад; агар бод шинонӣ, тӯфон медаравӣ.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.needsReview,
    sourceNote: '',
  ),
];
