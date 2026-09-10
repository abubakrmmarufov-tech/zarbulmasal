import '../models/proverb.dart';

const List<Proverb> seedProverbs = [
  // Legacy IDs 1-20 quarantined during the content audit.
  // Production corpus contains 150 verified Tajik proverbs (IDs 21-170).

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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '24',
    tajikCyrillic: 'Илм хоҳӣ, такрор кун; ҳосил хоҳӣ, шудгор кун.',
    persianText: 'علم خواهی، تکرار کن؛ حاصل خواهی، شیار کن.',
    simpleExplanationTj:
        'Барои омӯхтани илм такрор ва барои гирифтани ҳосил шудгору меҳнат лозим аст.',
    meaningTj:
        'Ҳар натиҷа роҳи худро дорад ва бе машқу меҳнати мувофиқ ба даст намеояд.',
    exampleSentenceTj:
        'Ӯ ҳар рӯз дарсҳоро аз нав мехонд, зеро медонист: «Илм хоҳӣ, такрор кун; ҳосил хоҳӣ, шудгор кун».',
    categoryId: 'ilm',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '26',
    tajikCyrillic: 'Дасти одамизод — гул.',
    persianText: 'دست آدمیزاد — گل.',
    simpleExplanationTj: 'Дасти инсон қодир аст чизҳои зебо ва фоиданок созад.',
    meaningTj:
        'Бо ҳунар ва меҳнат инсон метавонад чизҳоро обод, таъмир ё беҳтар кунад.',
    exampleSentenceTj:
        'Усто мизи кӯҳнаро чунон таъмир кард, ки нав барин шуд; дасти одамизод — гул.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '27',
    tajikCyrillic: 'Ба як ҷавон чил ҳунар кам.',
    persianText: 'به یک جوان چهل هنر کم.',
    simpleExplanationTj:
        'Ҷавон ҳар қадар ҳунару малака омӯзад, боз ҳам ба фоидаи ӯст.',
    meaningTj:
        'Давраи ҷавонӣ вақти муносиб барои омӯхтани ҳунарҳои гуногун аст.',
    exampleSentenceTj:
        'Ӯ ҳам барномасозӣ меомӯхт, ҳам забон ва ҳам ронандагӣ; ба як ҷавон чил ҳунар кам.',
    categoryId: 'omuzish',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '30',
    tajikCyrillic: 'Адаб беҳтарин ганҷ аст.',
    persianText: 'ادب بهترین گنج است.',
    simpleExplanationTj:
        'Одобу рафтори хуб аз сарвати моддӣ ҳам арзишмандтар аст.',
    meaningTj: 'Адаб обрӯе медиҳад, ки пулу мол ҷойи онро гирифта наметавонад.',
    exampleSentenceTj:
        'Ҳама ӯро барои муомилаи хубаш эҳтиром мекарданд; адаб беҳтарин ганҷ аст.',
    categoryId: 'odob',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '35',
    tajikCyrillic: 'Салом аз хурд, калом аз калон.',
    persianText: 'سلام از خرد، کلام از کلان.',
    simpleExplanationTj:
        'Дар одоби анъанавӣ хурдтар аввал салом мекунад ва калонтар суханро оғоз мекунад.',
    meaningTj: 'Ҳар синну мақом дар муошират одобу навбати худро дорад.',
    exampleSentenceTj:
        'Ҷавон ба устод аввал салом дод ва баъд ба сухани ӯ гӯш кард: «Салом аз хурд, калом аз калон».',
    categoryId: 'odob',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '37',
    tajikCyrillic: 'Ҳунар аз мулку мероси падар беҳ.',
    persianText: 'هنر از ملک و میراث پدر به.',
    simpleExplanationTj:
        'Ҳунари шахсӣ аз молу мулке, ки ба мерос мерасад, пойдортар аст.',
    meaningTj:
        'Малака ва касб сарватест, ки инсон бо худ дорад ва метавонад аз он рӯзӣ ёбад.',
    exampleSentenceTj:
        'Падар ба писараш касб омӯзонд: «Ҳунар аз мулку мероси падар беҳ».',
    categoryId: 'omuzish',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '41',
    tajikCyrillic: 'Нури ақл дониш аст.',
    persianText: 'نور عقل دانش است.',
    simpleExplanationTj:
        'Дониш ақлро равшан карда, барои фаҳмидани ҷаҳон ёрӣ медиҳад.',
    meaningTj: 'Ақл бо омӯзиш ва дониш қавӣ ва равшан мешавад.',
    exampleSentenceTj:
        'Пас аз хондани китоб масъала барои ӯ равшан шуд; нури ақл дониш аст.',
    categoryId: 'ilm',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '42',
    tajikCyrillic: 'Аввал андеша, баъд гуфтор.',
    persianText: 'اول اندیشه، بعد گفتار.',
    simpleExplanationTj: 'Пеш аз он ки сухан гӯӣ, аввал фикр кун.',
    meaningTj: 'Сухани боандеша аз пушаймонии баъдӣ пешгирӣ мекунад.',
    exampleSentenceTj:
        'Ӯ пеш аз ҷавоб додан чанд сония фикр кард: «Аввал андеша, баъд гуфтор».',
    categoryId: 'hikmat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '43',
    tajikCyrillic: 'Забони сурх сари сабзро медиҳад бар бод.',
    persianText: 'زبان سرخ سر سبز را می‌دهد بر باد.',
    simpleExplanationTj:
        'Сухани беэҳтиёт метавонад ба худи гӯянда зарари ҷиддӣ расонад.',
    meaningTj:
        'Забонро бояд нигоҳ дошт, зеро сухани нодуруст метавонад обрӯ, амният ё ҳатто ҷони инсонро зери хатар гузорад.',
    exampleSentenceTj:
        'Ӯ фаҳмид, ки дар бораи сирри дигарон беэҳтиёт сухан гуфтан хатарнок аст; забони сурх сари сабзро медиҳад бар бод.',
    categoryId: 'odob',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
    variants: ['Забони сурх сари сабзро мехӯрад.'],
  ),
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '49',
    tajikCyrillic: 'Сухани хуб морро аз хонааш мебарорад.',
    persianText: 'سخن خوب مار را از خانه‌اش برمی‌آرد.',
    simpleExplanationTj:
        'Сухани нарму хуб ҳатто мавҷуди тарснокро аз ҷояш берун меорад — ин тасвири маҷозӣ аст.',
    meaningTj:
        'Муомилаи хуб ва сухани ширин метавонад одамони душворро ҳам розӣ ё ором кунад.',
    exampleSentenceTj:
        'Ба ҷойи ҷанҷол ӯ оромона хоҳиш кард ва масъала ҳал шуд; сухани хуб морро аз хонааш мебарорад.',
    categoryId: 'dusti',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '62',
    tajikCyrillic: 'Ҳунар беҳ аз симу зар.',
    persianText: 'هنر به از سیم و زر.',
    simpleExplanationTj: 'Ҳунар аз нуқраю тилло арзишмандтар аст.',
    meaningTj:
        'Малака сарватест, ки метавонад ҳамеша ба инсон кору рӯзӣ диҳад.',
    exampleSentenceTj:
        'Ӯ ба ҷойи мероси пулӣ касб омӯхт; ҳунар беҳ аз симу зар.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '65',
    tajikCyrillic: 'Ҳар кӣ ранҷ бурд, ганҷ бурд.',
    persianText: 'هر که رنج برد، گنج برد.',
    simpleExplanationTj:
        'Касе, ки заҳмат мекашад, ба натиҷаи арзишманд мерасад.',
    meaningTj: 'Меҳнат ва сабр роҳи расидан ба комёбӣ ва фоидаанд.',
    exampleSentenceTj:
        'Солҳо машқ кард ва ниҳоят ғолиб шуд; ҳар кӣ ранҷ бурд, ганҷ бурд.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '68',
    tajikCyrillic: 'Бе меҳнат ганҷ муяссар намешавад.',
    persianText: 'بی محنت گنج میسر نمی‌شود.',
    simpleExplanationTj: 'Ганҷ ё натиҷаи калон бе меҳнат ба даст намеояд.',
    meaningTj: 'Барои комёбӣ кӯшиши воқеӣ лозим аст.',
    exampleSentenceTj:
        'Ӯ ҳар рӯз машқ мекард; бе меҳнат ганҷ муяссар намешавад.',
    categoryId: 'mehnat',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '70',
    tajikCyrillic: 'Кор кори кордон аст.',
    persianText: 'کار کار کاردان است.',
    simpleExplanationTj:
        'Ҳар корро касе беҳтар анҷом медиҳад, ки онро медонад ва таҷриба дорад.',
    meaningTj: 'Кори махсусро бояд ба шахси соҳибихтисос супорид.',
    exampleSentenceTj:
        'Барои таъмири барқ усто даъват карданд; кор кори кордон аст.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
    variants: ['Корро ба кордон супор.'],
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '75',
    tajikCyrillic: 'Об аз сар лой мешавад.',
    persianText: 'آب از سر لای می‌شود.',
    simpleExplanationTj:
        'Агар сарчашма лой бошад, об аз ҳамон ҷо ифлос мешавад.',
    meaningTj:
        'Бадкорӣ ё бесарусомонӣ аксар вақт аз роҳбарӣ ё қисми болоӣ оғоз мешавад.',
    exampleSentenceTj:
        'Вақте роҳбар қоидаҳоро риоя намекунад, дигарон ҳам беэътино мешаванд; об аз сар лой мешавад.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '76',
    tajikCyrillic: 'Қатра-қатра дарё шавад.',
    persianText: 'قطره‌قطره دریا شود.',
    simpleExplanationTj: 'Қатраҳои хурд ҷамъ шуда дарё месозанд.',
    meaningTj: 'Кӯшиш ё пасандози кам-кам бо вақт ба натиҷаи калон мерасад.',
    exampleSentenceTj:
        'Ӯ ҳар рӯз андаке пул ҷамъ мекард; қатра-қатра дарё шавад.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '77',
    tajikCyrillic: 'Сабр кунӣ, аз ғӯра ҳалво мешавад.',
    persianText: 'صبر کنی، از غوره حلوا می‌شود.',
    simpleExplanationTj:
        'Бо сабр ҳатто ғӯраи турш метавонад ба чизи ширин табдил ёбад — ба маънои маҷозӣ.',
    meaningTj:
        'Вақт ва сабр метавонанд ҳолати душвор ё нопухтаро ба натиҷаи хуб расонанд.',
    exampleSentenceTj:
        'Ниҳол солҳои аввал мева надод, вале ӯ нигоҳубинро давом дод; сабр кунӣ, аз ғӯра ҳалво мешавад.',
    categoryId: 'sabr',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '78',
    tajikCyrillic: 'Сабр талх аст, вале мевааш ширин.',
    persianText: 'صبر تلخ است، ولی میوه‌اش شیرین.',
    simpleExplanationTj:
        'Сабр кардан душвор аст, аммо натиҷаи он метавонад хуш бошад.',
    meaningTj: 'Таҳаммул ва интизорӣ аксар вақт ба натиҷаи хуб меоранд.',
    exampleSentenceTj:
        'Омӯзиш тӯл кашид, вале баъд кори хуб ёфт; сабр талх аст, вале мевааш ширин.',
    categoryId: 'sabr',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '81',
    tajikCyrillic: 'Ҳар кор вақти худро дорад.',
    persianText: 'هر کار وقت خود را دارد.',
    simpleExplanationTj: 'Барои ҳар кор вақти муносиб вуҷуд дорад.',
    meaningTj: 'Корро дар вақти дуруст анҷом додан натиҷаро беҳтар мекунад.',
    exampleSentenceTj:
        'Ҳоло вақти баҳс набуд, барои ҳамин суҳбатро ба баъд гузоштанд; ҳар кор вақти худро дорад.',
    categoryId: 'vaqt',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '82',
    tajikCyrillic: 'Имрӯзро ба фардо магузор.',
    persianText: 'امروز را به فردا مگذار.',
    simpleExplanationTj: 'Кори имрӯзро бе сабаб ба рӯзи дигар нагузор.',
    meaningTj:
        'Ба таъхир андохтани кор метавонад мушкилро зиёд кунад; вазифаи имрӯза беҳтараш имрӯз анҷом ёбад.',
    exampleSentenceTj:
        'Вазифаро ҳамон шаб тамом кард; имрӯзро ба фардо магузор.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '84',
    tajikCyrillic: 'Модарашро бину, духтарашро гир.',
    persianText: 'مادرش را بین و دخترش را گیر.',
    simpleExplanationTj:
        'Ин мақоли анъанавӣ монандии тарбия ва одатҳои духтарро ба муҳити модарӣ таъкид мекунад.',
    meaningTj:
        'Пеш аз интихоби ҳамсар ба муҳити оилавӣ ва тарбия низ аҳамият медиҳанд; ин қоидаи қатъӣ дар бораи ҳар шахс нест.',
    exampleSentenceTj:
        'Пирон ҳангоми шиносоии ду оила ба муҳити тарбия ҳам менигаристанд: «Модарашро бину, духтарашро гир».',
    categoryId: 'oila',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '86',
    tajikCyrillic: 'Ҳуши оча ба бача, ҳуши бача ба кӯча.',
    persianText: 'هوش اوچه به بچه، هوش بچه به کوچه.',
    simpleExplanationTj:
        'Модар ҳамеша дар фикри фарзанд аст, вале кӯдак бештар дар фикри бозӣ ва кӯча мешавад.',
    meaningTj:
        'Ғамхории волидайн нисбат ба фарзанд аксар вақт бештар аз он аст, ки кӯдак дарк мекунад.',
    exampleSentenceTj:
        'Модар дер омадани писарашро нигарон буд, аммо ӯ машғули бозӣ буд; ҳуши оча ба бача, ҳуши бача ба кӯча.',
    categoryId: 'padaru_modar',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '87',
    tajikCyrillic: 'Духтарам, ба ту мегӯям; келинам, ту шунав.',
    persianText: 'دخترم، به تو می‌گویم؛ کلینم، تو شنو.',
    simpleExplanationTj:
        'Ба як кас мегӯянд, вале мақсад ин аст, ки шахси дигар ҳам пандро бифаҳмад.',
    meaningTj: 'Ин тарзи ғайримустақими насиҳат ё танқид аст.',
    exampleSentenceTj:
        'Модар ба духтараш дар бораи тартиб гуфт, то келинаш ҳам ишораро фаҳмад: «Духтарам, ба ту мегӯям; келинам, ту шунав».',
    categoryId: 'oila',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '88',
    tajikCyrillic: 'Ба ҷанги зану шавҳар остона хандидааст.',
    persianText: 'به جنگ زن و شوهر آستانه خندیده است.',
    simpleExplanationTj:
        'Ҷанҷоли зану шавҳар бисёр вақт зуд мегузарад ва аз берун дахолат кардан метавонад беҳуда бошад.',
    meaningTj:
        'Муноқишаи оилавии кӯтоҳмуддатро набояд зуд ба душмании доимӣ баробар донист; ҳамсарон метавонанд зуд оштӣ кунанд.',
    exampleSentenceTj:
        'Дӯстонашон мехостанд тараф гиранд, вале онҳо худ зуд оштӣ карданд; ба ҷанги зану шавҳар остона хандидааст.',
    categoryId: 'oila',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Фолклори тоҷик',
  ),
  Proverb(
    id: '92',
    tajikCyrillic: 'Хоки Ватан аз тахти Сулаймон беҳ.',
    persianText: 'خاک وطن از تخت سلیمان به.',
    simpleExplanationTj:
        'Ҳатто хоки Ватан аз сарвати бузургу шоҳона азизтар дониста мешавад.',
    meaningTj: 'Муҳаббат ба зодгоҳ ва Ватан аз молу мақом болотар аст.',
    exampleSentenceTj:
        'Ӯ дар хориҷ имкони хуб дошт, вале ҳамеша зодгоҳашро ёд мекард; хоки Ватан аз тахти Сулаймон беҳ.',
    categoryId: 'zindagi',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Фолклори тоҷик',
  ),
  Proverb(
    id: '94',
    tajikCyrillic: 'Бе Ватан одам булбули бе чаман аст.',
    persianText: 'بی‌وطن آدم بلبل بی‌چمن است.',
    simpleExplanationTj: 'Одами бе Ватан мисли булбулест, ки чаман надорад.',
    meaningTj:
        'Инсон бе зодгоҳ ва ҳисси тааллуқ метавонад худро бегонаву бепаноҳ эҳсос кунад.',
    exampleSentenceTj:
        'Дар ғарибӣ ҳамеша зодгоҳашро ёд мекард; бе Ватан одам булбули бе чаман аст.',
    categoryId: 'zindagi',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
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
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
    variants: ['Дӯст дар рӯзи сахт маълум мешавад.'],
  ),
  Proverb(
    id: '97',
    tajikCyrillic: 'Дӯсти нодон аз душмани доно бадтар аст.',
    persianText: 'دوست نادان از دشمن دانا بدتر است.',
    simpleExplanationTj:
        'Дӯсти нодон метавонад аз рӯйи нодонӣ зарари бештар аз душман расонад.',
    meaningTj: 'Нияти хуб кофӣ нест; ақлу фаҳм ҳам муҳиманд.',
    exampleSentenceTj:
        'Дӯсташ барои ёрӣ коре кард, ки вазъро бадтар намуд; дӯсти нодон аз душмани доно бадтар аст.',
    categoryId: 'dusti',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '98',
    tajikCyrillic: 'Душмани доно беҳ аз дӯсти нодон.',
    persianText: 'دشمن دانا به از دوست نادان.',
    simpleExplanationTj:
        'Душмани оқил баъзан аз дӯсти нодон пешгӯишавандатар ва камзарартар аст.',
    meaningTj:
        'Ақлу фаҳм дар муносибат муҳиманд; дӯстии беақлона метавонад зарар расонад.',
    exampleSentenceTj:
        'Маслиҳати дӯсти беандеша ба ӯ зиён овард; душмани доно беҳ аз дӯсти нодон.',
    categoryId: 'dusti',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '99',
    tajikCyrillic: 'Дӯст оинаи дӯст аст.',
    persianText: 'دوست آیینهٔ دوست است.',
    simpleExplanationTj:
        'Дӯсти наздик мисли оина хислат ва рафтори туро нишон медиҳад.',
    meaningTj:
        'Аз дӯстони инсон бисёр вақт метавон дар бораи худи ӯ ва арзишҳояш чизе фаҳмид.',
    exampleSentenceTj:
        'Ҳарду ба ростгӯӣ аҳамият медоданд; дӯст оинаи дӯст аст.',
    categoryId: 'dusti',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '100',
    tajikCyrillic: 'Бо моҳ шинӣ, моҳ шавӣ; бо дег шинӣ, сиёҳ шавӣ.',
    persianText: 'با ماه شینی، ماه شوی؛ با دیگ شینی، سیاه شوی.',
    simpleExplanationTj:
        'Ҳамнишинӣ ба инсон таъсир мекунад: бо некон некӣ ва бо бадон бадӣ мегирад.',
    meaningTj:
        'Муҳит ва дӯстони наздик метавонанд хислат, одат ва рафтори инсонро тағйир диҳанд.',
    exampleSentenceTj:
        'Пас аз ҳамнишинӣ бо донишҷӯёни ҷиддӣ худаш ҳам бештар мехонд; бо моҳ шинӣ, моҳ шавӣ.',
    categoryId: 'dusti',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '101',
    tajikCyrillic: 'Ҳамнишинатро гӯй, то туро бишиносам.',
    persianText: 'همنشینت را گوی، تا تو را بشناسم.',
    simpleExplanationTj:
        'Аз ҳамнишинони шахс метавон дар бораи хислат ва завқи ӯ чизе фаҳмид.',
    meaningTj:
        'Инсон аксар вақт аз муҳити наздик ва дӯстонаш таъсир мегирад; ҳамнишинӣ нишонаи баъзе арзишҳои ӯст.',
    exampleSentenceTj:
        'Вақте дид, ки дӯстонаш ҳама китобхонанд, гуфт: «Ҳамнишинатро гӯй, то туро бишиносам».',
    categoryId: 'dusti',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '102',
    tajikCyrillic: 'Бо некон нишинӣ, нек шавӣ.',
    persianText: 'با نیکان نشینی، نیک شوی.',
    simpleExplanationTj:
        'Ҳамнишинӣ бо одамони нек ба рафтори хуб таъсир мекунад.',
    meaningTj:
        'Муҳити солим ва дӯстони хуб метавонанд инсонро ба одатҳои нек ҳидоят кунанд.',
    exampleSentenceTj:
        'Ӯ бо донишҷӯёни ҷиддӣ дӯст шуд ва худаш ҳам бештар мехонд; бо некон нишинӣ, нек шавӣ.',
    categoryId: 'dusti',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '103',
    tajikCyrillic: 'Бо бадон нишинӣ, бад шавӣ.',
    persianText: 'با بدان نشینی، بد شوی.',
    simpleExplanationTj:
        'Ҳамнишинӣ бо одамони бад метавонад ба одат ва рафтори инсон таъсири манфӣ расонад.',
    meaningTj: 'Муҳити носолим метавонад инсонро ба кори нодуруст одат диҳад.',
    exampleSentenceTj:
        'Баъд аз ҳамроҳӣ бо гурӯҳи бадрафтор мушкилҳояш зиёд шуданд; бо бадон нишинӣ, бад шавӣ.',
    categoryId: 'dusti',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '104',
    tajikCyrillic: 'Некӣ куну ба дарё андоз.',
    persianText: 'نیکی کن و به دریا انداز.',
    simpleExplanationTj:
        'Некӣ кун, ҳатто агар касе онро набинад ё ҷавоб надиҳад.',
    meaningTj:
        'Кори хайрро барои подошу таъриф не, балки барои худи некӣ анҷом деҳ.',
    exampleSentenceTj:
        'Ӯ пинҳонӣ ба оилаи ниёзманд кумак кард; некӣ куну ба дарё андоз.',
    categoryId: 'muhabbat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '105',
    tajikCyrillic: 'Некӣ бо некӣ ҷавоб дорад.',
    persianText: 'نیکی با نیکی جواب دارد.',
    simpleExplanationTj: 'Кори нек бисёр вақт бо некӣ ҷавоб мегирад.',
    meaningTj: 'Муносибати хуб боварӣ ва ҷавоби хубро ба вуҷуд меорад.',
    exampleSentenceTj:
        'Ӯ ҳамсояашро дар рӯзи сахт ёрӣ дод ва баъд ҳамсоя низ дастгирӣ кард; некӣ бо некӣ ҷавоб дорад.',
    categoryId: 'muhabbat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '106',
    tajikCyrillic: 'Бадӣ кунӣ, бадӣ мебинӣ.',
    persianText: 'بدی کنی، بدی بینی.',
    simpleExplanationTj: 'Кори бад оқибати бад оварда метавонад.',
    meaningTj: 'Зараре, ки ба дигарон мерасонӣ, метавонад ба худат баргардад.',
    exampleSentenceTj:
        'Ӯ дигаронро фиреб медод ва охир касе ба ӯ бовар накард; бадӣ кунӣ, бадӣ мебинӣ.',
    categoryId: 'hikmat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '107',
    tajikCyrillic: 'Одами нек аз суханаш маълум.',
    persianText: 'آدم نیک از سخنش معلوم.',
    simpleExplanationTj:
        'Аз тарзи сухан гуфтан одоб ва хислати инсон то андозае маълум мешавад.',
    meaningTj:
        'Сухани боэҳтиром, рост ва боандеша нишонаи тарбия ва хислати хуб аст.',
    exampleSentenceTj:
        'Ӯ ҳатто дар баҳс бо эҳтиром сухан гуфт; одами нек аз суханаш маълум.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '108',
    tajikCyrillic: 'Ҳеҷ кас айби худро намебинад.',
    persianText: 'هیچ کس عیب خود را نمی‌بیند.',
    simpleExplanationTj:
        'Одам одатан айби худро аз айби дигарон камтар мебинад.',
    meaningTj:
        'Худбаҳодиҳӣ метавонад яктарафа бошад; барои ислоҳ худтанқидӣ лозим аст.',
    exampleSentenceTj:
        'Ӯ ҳамаро танқид мекард, вале хатои худашро намедид; ҳеҷ кас айби худро намебинад.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '109',
    tajikCyrillic: 'Ҳеҷ кас думи харашро каҷ намегӯяд.',
    persianText: 'هیچ کس دم خرش را کج نمی‌گوید.',
    simpleExplanationTj:
        'Ҳар кас моли худ ё кори худро одатан беҳтар мешуморад ва айбашро кам мебинад.',
    meaningTj:
        'Инсон ба чизҳои вобаста ба худ бо чашми ҷонибдорона нигоҳ мекунад.',
    exampleSentenceTj:
        'Ҳар ду фурӯшанда моли худро беҳтарин мегуфтанд; ҳеҷ кас думи харашро каҷ намегӯяд.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '110',
    tajikCyrillic: 'Кал агар табиб будӣ, сари худ даво намудӣ.',
    persianText: 'کل اگر طبیب بودی، سر خود دوا نمودی.',
    simpleExplanationTj:
        'Агар кас воқеан роҳи ҳалли мушкилро медонист, пеш аз дигарон онро барои худ истифода мекард.',
    meaningTj:
        'Ба маслиҳат ё даъвои касе, ки мушкили худашро ҳал карда наметавонад, бояд бо андеша муносибат кард.',
    exampleSentenceTj:
        'Ӯ ба ҳама роҳи бой шуданро мефаҳмонд, вале худаш қарздор буд; кал агар табиб будӣ, сари худ даво намудӣ.',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '111',
    tajikCyrillic: 'Айби худ кӯр, айби мардум дурбин.',
    persianText: 'عیب خود کور، عیب مردم دوربین.',
    simpleExplanationTj:
        'Одам айби худро намебинад, вале айби дигаронро аз дур ҳам мебинад.',
    meaningTj: 'Пеш аз танқиди дигарон бояд камбудии худро низ дид.',
    exampleSentenceTj:
        'Ӯ хатои хурди ҳамкорашро калон кард, аммо хатои худашро нодида гирифт; айби худ кӯр, айби мардум дурбин.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '112',
    tajikCyrillic: 'Чоҳи дигаронро макан, ки худ меафтӣ.',
    persianText: 'چاه دیگران را مکن، که خود می‌افتی.',
    simpleExplanationTj:
        'Барои дигарон дом ё бадӣ омода накун, зеро оқибаташ метавонад ба худат расад.',
    meaningTj:
        'Нияти зарар расондан ба дигарон бисёр вақт ба худи инсон бармегардад.',
    exampleSentenceTj:
        'Ӯ мехост ҳамкорашро фиреб диҳад, вале худ ошкор шуд; чоҳи дигаронро макан, ки худ меафтӣ.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
    canonicalId: '168',
  ),
  Proverb(
    id: '113',
    tajikCyrillic: 'Дари касеро ба мушт назан, ки даратро бо лагад мезананд.',
    persianText: 'در کسی را با مشت نزن، که درت را با لگد می‌زنند.',
    simpleExplanationTj:
        'Ба дигарон озор нарасон, зеро ҷавоб метавонад аз кори худат сахттар бошад.',
    meaningTj:
        'Рафтори бад зиддият ва ҷавоби бадтарро ба вуҷуд оварда метавонад.',
    exampleSentenceTj:
        'Ӯ пеш аз таҳқири ҳамсоя худро нигоҳ дошт; дари касеро ба мушт назан, ки даратро бо лагад мезананд.',
    categoryId: 'odob',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '114',
    tajikCyrillic: 'Як дари баста, сад дари кушода.',
    persianText: 'یک در بسته، صد در کشاده.',
    simpleExplanationTj:
        'Агар як роҳ баста шавад, роҳу имкониятҳои дигар вуҷуд доранд.',
    meaningTj:
        'Аз як нокомӣ ноумед нашав; имконият танҳо ба як роҳ маҳдуд нест.',
    exampleSentenceTj:
        'Ба як донишгоҳ қабул нашуд, вале имкониятҳои дигарро ҷуст; як дари баста, сад дари кушода.',
    categoryId: 'odob',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '115',
    tajikCyrillic: 'Як гулу сад харидор.',
    persianText: 'یک گل و صد خریدار.',
    simpleExplanationTj:
        'Чизи хуб ё шахси писандида метавонад хоҳишмандони зиёд дошта бошад.',
    meaningTj:
        'Вақте чизе арзишманд ва камёб аст, рақобат барои он зиёд мешавад.',
    exampleSentenceTj:
        'Барои он ҷойи кор довталабони зиёд буданд; як гулу сад харидор.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '116',
    tajikCyrillic: 'Як гул баҳор намешавад.',
    persianText: 'یک گل بهار نمی‌شود.',
    simpleExplanationTj: 'Як гул барои ба вуҷуд омадани баҳор кофӣ нест.',
    meaningTj:
        'Аз як мисол хулосаи умумӣ баровардан дуруст нест ва кори калон одатан бо як нафар анҷом намешавад.',
    exampleSentenceTj:
        'Як натиҷаи хуб ҳанӯз маънои муваффақияти тамоми солро надорад; як гул баҳор намешавад.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '117',
    tajikCyrillic: 'Гул бе хор намешавад.',
    persianText: 'گل بی خار نمی‌شود.',
    simpleExplanationTj:
        'Гул одатан хор ҳам дорад; чизи хуб метавонад душворӣ ҳам дошта бошад.',
    meaningTj: 'Дар зиндагӣ кам чизе бе нуқсон, хавф ё заҳмат ба даст меояд.',
    exampleSentenceTj:
        'Кори нав маоши хуб дошт, аммо масъулияташ ҳам зиёд буд; гул бе хор намешавад.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '118',
    tajikCyrillic: 'Гул гулро дида мешукуфад.',
    persianText: 'گل گل را دیده می‌شکفد.',
    simpleExplanationTj:
        'Гул аз дидани гули дигар мешукуфад — тасвири рамзии таъсири мусбати ҳамнишинӣ.',
    meaningTj:
        'Одамон аз дидани пешрафт, зебоӣ ё некӣ дар дигарон рӯҳбаланд мешаванд.',
    exampleSentenceTj:
        'Баъд аз дидани муваффақияти дӯсташ ӯ ҳам ба омӯзиш ҷиддӣ шуд; гул гулро дида мешукуфад.',
    categoryId: 'muhabbat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '119',
    tajikCyrillic: 'Дарахтро аз мевааш мешиносанд.',
    persianText: 'درخت را از میوه‌اش می‌شناسند.',
    simpleExplanationTj:
        'Дарахтро аз мевааш ва инсонро аз натиҷаи кораш мешиносанд.',
    meaningTj:
        'Амалу натиҷа бештар аз даъво хислати воқеии шахсро нишон медиҳад.',
    exampleSentenceTj:
        'Ваъдаҳо зиёд буданд, вале ӯ натиҷаро дид: дарахтро аз мевааш мешиносанд.',
    categoryId: 'hikmat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '120',
    tajikCyrillic: 'Дарахти пурбор сар хам мекунад.',
    persianText: 'درخت پربار سر خم می‌کند.',
    simpleExplanationTj: 'Шохаи пурмева аз вазни мева хам мешавад.',
    meaningTj:
        'Одами воқеан донишманду соҳибкамол одатан фурӯтан аст, на худнамо.',
    exampleSentenceTj:
        'Бо вуҷуди дастовардҳои зиёд хеле хоксор буд; дарахти пурбор сар хам мекунад.',
    categoryId: 'ehtirom',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
    variants: ['Дарахти пурмева сар хам мекунад.'],
  ),
  Proverb(
    id: '121',
    tajikCyrillic: 'Бой аз фарбеҳӣ меноладу камбағал аз лоғарӣ.',
    persianText: 'بای از فربهی می‌نالد و کم‌بغل از لاغری.',
    simpleExplanationTj:
        'Ҳар кас аз мушкили вобаста ба ҳолати худ шикоят мекунад.',
    meaningTj:
        'Одамон дар шароити гуногун ғамҳои гуногун доранд; чизе, ки барои яке зиёд аст, барои дигаре кам аст.',
    exampleSentenceTj:
        'Яке аз серкорӣ менолид, дигаре аз бекорӣ; бой аз фарбеҳӣ меноладу камбағал аз лоғарӣ.',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '122',
    tajikCyrillic: 'Қарз гирӣ, ғам мехарӣ.',
    persianText: 'قرض گیری، غم می‌خری.',
    simpleExplanationTj:
        'Қарз гирифтан ҳамроҳ бо масъулияти баргардондан ташвиш меорад.',
    meaningTj:
        'Қарз метавонад озодии молиявиро кам карда, ғам ва фишор зиёд кунад.',
    exampleSentenceTj:
        'Пеш аз гирифтани қарзи нолозим фикр кард: «Қарз гирӣ, ғам мехарӣ».',
    categoryId: 'pul',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '123',
    tajikCyrillic: 'Қарздор — ғамдор.',
    persianText: 'قرضدار — غم‌دار.',
    simpleExplanationTj: 'Қарздор одатан дар фикри баргардондани қарз аст.',
    meaningTj: 'Уҳдадории молиявӣ метавонад ташвиши доимӣ оварад.',
    exampleSentenceTj: 'То қарзро напардохт, ором набуд; қарздор — ғамдор.',
    categoryId: 'pul',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '124',
    tajikCyrillic: 'Қаноат ганҷи бепоён аст.',
    persianText: 'قناعت گنج بی‌پایان است.',
    simpleExplanationTj:
        'Қаноат мисли ганҷест, ки ба инсон оромии доимӣ медиҳад.',
    meaningTj:
        'Касе, ки ҳадду ниёзи худро мешиносад, аз ҳирси беохир камтар азоб мекашад.',
    exampleSentenceTj:
        'Ӯ зиндагии сода дошт, вале ором буд; қаноат ганҷи бепоён аст.',
    categoryId: 'pul',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '125',
    tajikCyrillic: 'Нафси бад балои ҷон аст.',
    persianText: 'نفس بد بلای جان است.',
    simpleExplanationTj:
        'Ҳавасу хоҳиши носолим метавонад ба худи инсон зарар расонад.',
    meaningTj:
        'Ҳирс, шаҳват ё хоҳиши беандоза агар идора нашавад, зиндагиро вайрон карда метавонад.',
    exampleSentenceTj:
        'Ҳар чизеро мехост, ҳатто бо қарз мехарид; нафси бад балои ҷон аст.',
    categoryId: 'din',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '126',
    tajikCyrillic: 'Ош бе пиёз намешавад.',
    persianText: 'آش بی پیاز نمی‌شود.',
    simpleExplanationTj: 'Барои тайёр шудани ош як ҷузъи муҳим лозим аст.',
    meaningTj:
        'Ҳар кор унсур ё шарти асосии худро дорад; бе он кор нопурра мемонад.',
    exampleSentenceTj:
        'Лоиҳа бе маълумоти асосӣ пеш намерафт; ош бе пиёз намешавад.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '127',
    tajikCyrillic: 'Нон бошад, ҷон бошад.',
    persianText: 'نان باشد، جان باشد.',
    simpleExplanationTj: 'Нон рамзи рӯзӣ ва василаи зиндагист.',
    meaningTj: 'Ғизо ва рӯзии асосӣ барои идомаи зиндагӣ заруранд.',
    exampleSentenceTj:
        'Пирамард нонро қадр мекард ва мегуфт: «Нон бошад, ҷон бошад».',
    categoryId: 'mehnat',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Фолклори тоҷик',
  ),
  Proverb(
    id: '128',
    tajikCyrillic: 'Нонро хор макун.',
    persianText: 'نان را خوار مکن.',
    simpleExplanationTj: 'Нонро беқадр ва исроф накун.',
    meaningTj:
        'Дар фарҳанги тоҷик нон рамзи рӯзӣ ва меҳнат аст ва бояд бо эҳтиром муносибат шавад.',
    exampleSentenceTj:
        'Кӯдак нонро ба замин партофтанӣ шуд, модар гуфт: «Нонро хор макун».',
    categoryId: 'mehnat',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '129',
    tajikCyrillic: 'Нони меҳнат ширин аст.',
    persianText: 'نان محنت شیرین است.',
    simpleExplanationTj:
        'Ноне, ки бо меҳнати худ ба даст омадааст, ширинтар менамояд.',
    meaningTj: 'Рӯзии бо заҳмати ҳалол бадастомада қаноат ва ифтихор меорад.',
    exampleSentenceTj:
        'Аввалин маошашро гирифт ва хушҳол шуд; нони меҳнат ширин аст.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '130',
    tajikCyrillic: 'Меҳмон атои Худост.',
    persianText: 'مهمان عطای خداست.',
    simpleExplanationTj:
        'Меҳмон дар фарҳанги анъанавӣ баракат ва неъмат дониста мешавад.',
    meaningTj: 'Меҳмонро бояд бо эҳтиром ва меҳмондорӣ қабул кард.',
    exampleSentenceTj:
        'Онҳо мусофирро гарм пешвоз гирифтанд; меҳмон атои Худост.',
    categoryId: 'odob',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '131',
    tajikCyrillic: 'Меҳмон азиз, ҷойаш азизтар.',
    persianText: 'مهمان عزیز، جایش عزیزتر.',
    simpleExplanationTj:
        'Меҳмон азиз аст, аммо меҳмонӣ бояд ҳадду вақти худро дошта бошад.',
    meaningTj:
        'Меҳмонро эҳтиром мекунанд, вале меҳмони дарозмуддат набояд ба соҳибхона бори зиёдатӣ шавад.',
    exampleSentenceTj:
        'Пас аз чанд рӯзи меҳмонӣ ӯ бо сипос ба хонааш баргашт; меҳмон азиз, ҷойаш азизтар.',
    categoryId: 'odob',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '132',
    tajikCyrillic: 'Хонаи меҳмондор обод аст.',
    persianText: 'خانهٔ مهماندار آباد است.',
    simpleExplanationTj:
        'Хонае, ки меҳмонро қабул мекунад, пур аз рафтуомад ва баракат шумурда мешавад.',
    meaningTj: 'Меҳмондорӣ нишонаи кушодадилӣ ва ободии хона аст.',
    exampleSentenceTj:
        'Дар хонаи онҳо ҳамеша меҳмон буд ва дастархон кушода; хонаи меҳмондор обод аст.',
    categoryId: 'odob',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Фолклори Роғун',
  ),
  Proverb(
    id: '133',
    tajikCyrillic: 'Ҳар хона одати худро дорад.',
    persianText: 'هر خانه عادت خود را دارد.',
    simpleExplanationTj: 'Ҳар хона тартиб ва одатҳои хоси худро дорад.',
    meaningTj:
        'Ҳангоми ворид шудан ба муҳити дигар бояд ба қоидаҳои он эҳтиром гузошт.',
    exampleSentenceTj:
        'Дар хонаи дӯсташ пойафзолро назди дар гузошт, зеро ҳар хона одати худро дорад.',
    categoryId: 'odob',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Фарҳанги мардуми диёри Турсунзода',
  ),
  Proverb(
    id: '134',
    tajikCyrillic: 'Ҳар диёр расми худро дорад.',
    persianText: 'هر دیار رسم خود را دارد.',
    simpleExplanationTj: 'Ҳар минтақа расму одатҳои хоси худро дорад.',
    meaningTj:
        'Дар ҷойи дигар бояд фарқи фарҳанг ва анъанаҳоро ба назар гирифт.',
    exampleSentenceTj:
        'Дар сафар ба урфи маҳаллӣ эҳтиром кард; ҳар диёр расми худро дорад.',
    categoryId: 'odob',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Фарҳанги мардуми диёри Турсунзода',
  ),
  Proverb(
    id: '135',
    tajikCyrillic: 'Ба шаҳр рафтӣ, расми шаҳрро гир.',
    persianText: 'به شهر رفتی، رسم شهر را گیر.',
    simpleExplanationTj: 'Ба ҷойи нав рафтӣ, қоида ва расми он ҷоро риоя кун.',
    meaningTj:
        'Инсон бояд ба муҳити нав бо эҳтиром мутобиқ шавад, агар он ба ӯ зарар нарасонад.',
    exampleSentenceTj:
        'Дар кишвари дигар қоидаҳои маҳаллиро омӯхт; ба шаҳр рафтӣ, расми шаҳрро гир.',
    categoryId: 'odob',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '136',
    tajikCyrillic: 'Қарға ба қарға чашм намеканад.',
    persianText: 'قارغه به قارغه چشم نمی‌کند.',
    simpleExplanationTj:
        'Қарға ба қарғаи дигар зарар намерасонад — ин ташбеҳ ба ҳамдигарпуштибонии гурӯҳ аст.',
    meaningTj:
        'Одамони як гурӯҳ баъзан ҳатто ҳангоми хато ҳамдигарро ҳимоя мекунанд; мақол аксар вақт бо маънои танқидӣ истифода мешавад.',
    exampleSentenceTj:
        'Ду ҳамкор хатои якдигарро пинҳон карданд; қарға ба қарға чашм намеканад.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '137',
    tajikCyrillic: 'Гургзода оқибат гург шавад.',
    persianText: 'گرگزاده عاقبت گرگ شود.',
    simpleExplanationTj:
        'Мақол мегӯяд, ки табиати аслӣ дер ё зуд худро нишон медиҳад.',
    meaningTj:
        'Одат ё хислати решадорро танҳо бо намуди зоҳирӣ пинҳон кардан душвор аст; ин маънои маҷозӣ дорад, на ҳукми қатъӣ дар бораи ирс.',
    exampleSentenceTj:
        'Ӯ муддате худро ором нишон дод, вале боз ба рафтори пешина баргашт; гургзода оқибат гург шавад.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '138',
    tajikCyrillic: 'Саг аккос мезанад, корвон мегузарад.',
    persianText: 'سگ عقاس می‌زند، کاروان می‌گذرد.',
    simpleExplanationTj:
        'Саг аккос мезанад, вале корвон роҳи худро идома медиҳад.',
    meaningTj:
        'Ба ҳар танқид, овоза ё садои халалрасон таваққуф накун; кори муҳимро идома деҳ.',
    exampleSentenceTj:
        'Бо вуҷуди масхараи дигарон ӯ таҳсилро давом дод; саг аккос мезанад, корвон мегузарад.',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '139',
    tajikCyrillic: 'Саги аккосак газанда нест.',
    persianText: 'سگ عقاسک گزنده نیست.',
    simpleExplanationTj:
        'Саге, ки бисёр аккос мезанад, одатан камтар газиданӣ аст — маънои маҷозӣ.',
    meaningTj:
        'Касе, ки бисёр таҳдид мекунад, на ҳамеша хатарноктарин аст; сухани баланд ҳатман амали сахт нест.',
    exampleSentenceTj:
        'Ӯ бисёр таҳдид мекард, вале коре намекард; саги аккосак газанда нест.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '140',
    tajikCyrillic: 'Аз асп афтӣ, аз асл наафт.',
    persianText: 'از اسپ افتی، از اصل نیفت.',
    simpleExplanationTj:
        'Агар молу мақом ё муваффақиятро аз даст диҳӣ, асли инсонӣ ва иззати худро аз даст надеҳ.',
    meaningTj:
        'Нокомӣ набояд сабаб шавад, ки инсон арзишҳо, шараф ё худшиносиашро фаромӯш кунад.',
    exampleSentenceTj:
        'Корашро аз даст дод, вале ростқавлиашро не; аз асп афтӣ, аз асл наафт.',
    categoryId: 'jasorat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '141',
    tajikCyrillic: 'Харро бо зин асп намешавад.',
    persianText: 'خر را با زین اسپ نمی‌شود.',
    simpleExplanationTj: 'Зин бастан ба хар онро ба асп табдил намедиҳад.',
    meaningTj:
        'Ороиши зоҳирӣ моҳият, қобилият ё хислати аслиро худ аз худ дигар намекунад.',
    exampleSentenceTj:
        'Либоси гарон пӯшид, вале одобаш тағйир наёфт; харро бо зин асп намешавад.',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '142',
    tajikCyrillic: 'Қурбоққа шӯй дорад, обрӯ дорад.',
    persianText: 'قورباغه شوی دارد، آبرو دارد.',
    simpleExplanationTj:
        'Ин мақоли кӯҳна бо киноя мегӯяд, ки ҳатто қурбоққа бо шавҳардор будан «обрӯ» дорад.',
    meaningTj:
        'Мақол фишори анъанавии ҷомеаро инъикос мекунад, ки мақоми занро ба издивоҷ мепайваст; ин андеша арзёбии таърихию фарҳангӣ аст, на меъёри имрӯза.',
    exampleSentenceTj:
        'Дар суҳбат дар бораи фишори пешина ба духтарони бешавҳар ин мақоли қадимиро ёд карданд: «Қурбоққа шӯй дорад, обрӯ дорад».',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '143',
    tajikCyrillic: 'Моҳӣ аз сар бадбӯй мешавад.',
    persianText: 'ماهی از سر بدبوی می‌شود.',
    simpleExplanationTj:
        'Моҳӣ аз сар бадбӯй шуданро ба таври рамзӣ ба сарварӣ монанд мекунанд.',
    meaningTj:
        'Фасод, бесарусомонӣ ё рафтори бад аксар вақт аз боло ва роҳбарӣ оғоз мешавад.',
    exampleSentenceTj:
        'Вақте роҳбар қоидаҳоро вайрон мекард, кормандон ҳам пайравӣ мекарданд; моҳӣ аз сар бадбӯй мешавад.',
    categoryId: 'hikmat',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '144',
    tajikCyrillic: 'Аз як даст садо намебарояд.',
    persianText: 'از یک دست صدا برنمی‌آید.',
    simpleExplanationTj: 'Бо як даст каф задан ва садо баровардан намешавад.',
    meaningTj:
        'Бисёр корҳо ва муносибатҳо иштироки ду тараф ё ҳамкории чанд нафарро талаб мекунанд.',
    exampleSentenceTj:
        'Барои ҳал кардани баҳс ҳар ду тараф бояд суҳбат кунанд; аз як даст садо намебарояд.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '145',
    tajikCyrillic: 'Як даст гул намекунад.',
    persianText: 'یک دست گل نمی‌کند.',
    simpleExplanationTj:
        'Як даст танҳо барои анҷоми баъзе корҳои ҷамъӣ кофӣ нест.',
    meaningTj:
        'Кори калон бо ҳамкорӣ ва ёрии дигарон осонтар ва пурратар мешавад.',
    exampleSentenceTj:
        'Барои омода кардани чорабинӣ ҳама кумак карданд; як даст гул намекунад.',
    categoryId: 'mehnat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '146',
    tajikCyrillic: 'Як тан танҳо ҷанг намекунад.',
    persianText: 'یک تن تنها جنگ نمی‌کند.',
    simpleExplanationTj: 'Як нафар танҳо наметавонад ҷанги калонро пеш барад.',
    meaningTj:
        'Барои кори бузург қувва, ҳамкорӣ ва дастгирии дигарон лозим мешавад.',
    exampleSentenceTj:
        'Лоиҳаро як нафар танҳо анҷом дода наметавонист; як тан танҳо ҷанг намекунад.',
    categoryId: 'dusti',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '147',
    tajikCyrillic: 'Оҳанро дар гармиаш мекӯбанд.',
    persianText: 'آهن را در گرمی‌اش می‌کوبند.',
    simpleExplanationTj: 'Оҳанро ҳангоми гарм будан осонтар шакл медиҳанд.',
    meaningTj:
        'Имконияти мувофиқро бояд сари вақт истифода кард; баъдтар метавонад дер шавад.',
    exampleSentenceTj:
        'Пас аз пайдо шудани имкони хуб фавран ариза дод; оҳанро дар гармиаш мекӯбанд.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '148',
    tajikCyrillic: 'Кор аз кордон тарсад.',
    persianText: 'کار از کاردان ترسد.',
    simpleExplanationTj: 'Кори душвор дар дасти кордон осон менамояд.',
    meaningTj:
        'Мутахассиси моҳир аз кори вазнин наметарсад ва роҳи дурусти анҷом додани онро медонад.',
    exampleSentenceTj: 'Усто мушкили дастгоҳро зуд ёфт; кор аз кордон тарсад.',
    categoryId: 'mehnat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '149',
    tajikCyrillic: 'Корро ба кордон супор.',
    persianText: 'کار را به کاردان سپار.',
    simpleExplanationTj:
        'Корро ба касе супор, ки дониш ва таҷрибаи он корро дорад.',
    meaningTj:
        'Барои натиҷаи дуруст бояд аз мутахассиси мувофиқ истифода кард.',
    exampleSentenceTj:
        'Барои таъмири ноқилҳо барқчиро даъват карданд; корро ба кордон супор.',
    categoryId: 'mehnat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
    canonicalId: '70',
  ),
  Proverb(
    id: '150',
    tajikCyrillic: 'Бо як даст ду тарбуз бардошта намешавад.',
    persianText: 'با یک دست دو تربز برداشته نمی‌شود.',
    simpleExplanationTj:
        'Бо як даст ду тарбузи калонро якбора гирифтан душвор аст.',
    meaningTj:
        'Ҳамзамон ба дӯш гирифтани чанд кори вазнин метавонад боиси он шавад, ки ҳеҷ кадомаш дуруст анҷом наёбад.',
    exampleSentenceTj:
        'Ӯ мехост ҳамзамон ду кори пурравақт кунад, вале фаҳмид: бо як даст ду тарбуз бардошта намешавад.',
    categoryId: 'hikmat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '151',
    tajikCyrillic: 'Одат балои ҷон аст.',
    persianText: 'عادت بلای جان است.',
    simpleExplanationTj:
        'Одати бад агар реша давонад, халос шудан аз он душвор мешавад.',
    meaningTj:
        'Рафтори носолиме, ки ба одат табдил ёфтааст, метавонад ба зиндагӣ ва саломатии инсон зарар расонад.',
    exampleSentenceTj:
        'Ҳар шаб корро ба таъхир меандохт ва ин ба мушкил табдил шуд; одат балои ҷон аст.',
    categoryId: 'tanbali',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '152',
    tajikCyrillic: 'Одат табиати дуюм аст.',
    persianText: 'عادت طبیعت دوم است.',
    simpleExplanationTj:
        'Коре, ки бисёр такрор мешавад, гӯё қисми табиати инсон мегардад.',
    meaningTj:
        'Одати такроршаванда ба рафтори худкор табдил меёбад, бинобар ин одатҳои хубро бояд барвақт сохт.',
    exampleSentenceTj:
        'Ҳар саҳар китоб мехонд ва баъд дигар бе он рӯзашро оғоз намекард; одат табиати дуюм аст.',
    categoryId: 'tanbali',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '153',
    tajikCyrillic: 'Дарахтро дар навниҳолӣ рост мекунанд.',
    persianText: 'درخت را در نونهالی راست می‌کنند.',
    simpleExplanationTj:
        'Дарахтро ҳангоми навниҳол будан осонтар рост кардан мумкин аст.',
    meaningTj: 'Тарбия ва одатҳои асосӣ дар кӯдакӣ осонтар шакл мегиранд.',
    exampleSentenceTj:
        'Волидайн аз хурдӣ ба фарзанд ростгӯӣ меомӯзонданд; дарахтро дар навниҳолӣ рост мекунанд.',
    categoryId: 'padaru_modar',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Фолклори тоҷик',
  ),
  Proverb(
    id: '154',
    tajikCyrillic: 'Пири корро хор мадор.',
    persianText: 'پیر کار را خوار مدار.',
    simpleExplanationTj:
        'Каси солҳо таҷрибаандӯхтаро дар кори худ беқадр накун.',
    meaningTj:
        'Таҷрибаи устодон ва собиқадорони касб арзишманд аст ва сазовори эҳтиром мебошад.',
    exampleSentenceTj:
        'Ҷавон пеш аз қарор аз устои куҳансол маслиҳат пурсид; пири корро хор мадор.',
    categoryId: 'ehtirom',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '155',
    tajikCyrillic: 'Калонро ҳурмат кун, хурдро иззат.',
    persianText: 'کلان را حرمت کن، خرد را عزت.',
    simpleExplanationTj:
        'Ба калонсолон эҳтиром ва ба хурдсолон низ иззату меҳрубонӣ нишон деҳ.',
    meaningTj:
        'Одоб танҳо нисбат ба калон нест; ҳар инсон бояд мувофиқи ҷойгоҳаш бо эҳтиром муносибат бинад.',
    exampleSentenceTj:
        'Ӯ бо пирон боэҳтиром ва бо кӯдакон меҳрубон буд; калонро ҳурмат кун, хурдро иззат.',
    categoryId: 'ehtirom',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Баёзи фолклори тоҷик. Ҷилди 2',
  ),
  Proverb(
    id: '156',
    tajikCyrillic: 'Пандро аз душман ҳам шунав.',
    persianText: 'پند را از دشمن هم شنو.',
    simpleExplanationTj:
        'Ҳатто агар насиҳат аз душман бошад, аввал дурустии онро бисанҷ.',
    meaningTj:
        'Арзиши маслиҳат ба ҳақиқату фоидаи он вобаста аст, на танҳо ба он ки кӣ онро гуфтааст.',
    exampleSentenceTj:
        'Рақибаш як хатои воқеиро нишон дод ва ӯ онро ислоҳ кард; пандро аз душман ҳам шунав.',
    categoryId: 'hikmat',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '157',
    tajikCyrillic: 'Илм ганҷи бебаҳост.',
    persianText: 'علم گنج بی‌بهاست.',
    simpleExplanationTj:
        'Дониш ганҷест, ки арзиши онро бо пул пурра чен кардан мумкин нест.',
    meaningTj:
        'Илм сарвати пойдорест, ки ба инсон имкони фаҳмидан, рушд кардан ва кор кардан медиҳад.',
    exampleSentenceTj:
        'Ӯ маблағашро барои таҳсил сарф кард; илм ганҷи бебаҳост.',
    categoryId: 'ilm',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '158',
    tajikCyrillic: 'Илм бе амал — дарахти бе ҳосил.',
    persianText: 'علم بی عمل — درخت بی حاصل.',
    simpleExplanationTj:
        'Донише, ки истифода намешавад, мисли дарахте аст, ки мева намедиҳад.',
    meaningTj:
        'Илм вақте арзиши амалӣ пайдо мекунад, ки ба рафтор, кор ё фоидаи воқеӣ табдил ёбад.',
    exampleSentenceTj:
        'Ӯ қоидаҳоро медонист, вале иҷро намекард; илм бе амал — дарахти бе ҳосил.',
    categoryId: 'ilm',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '159',
    tajikCyrillic: 'Нодонро панд гуфтан — об дар ҳован кӯфтан.',
    persianText: 'نادان را پند گفتن — آب در هاون کوفتن.',
    simpleExplanationTj:
        'Обро дар ҳован кӯфтан натиҷа намедиҳад; панд ба касе, ки қабул кардан намехоҳад, низ беҳуда мешавад.',
    meaningTj:
        'Насиҳат танҳо вақте фоида дорад, ки шунаванда омодаи фаҳмидан ва қабул кардан бошад.',
    exampleSentenceTj:
        'Ҳар бор далел меоварданд, вале ӯ ҳатто гӯш намекард; нодонро панд гуфтан — об дар ҳован кӯфтан.',
    categoryId: 'ilm',
    level: 6,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '160',
    tajikCyrillic: 'Ба доно як ишора бас.',
    persianText: 'به دانا یک اشاره بس.',
    simpleExplanationTj: 'Одами доно аз як ишораи кӯтоҳ ҳам мақсадро мефаҳмад.',
    meaningTj:
        'Ба шахси фаҳмо шарҳи дароз лозим нест; ӯ маъниро аз аломати кам дарк мекунад.',
    exampleSentenceTj:
        'Устод танҳо ба хатогӣ ишора кард ва шогирд фавран фаҳмид; ба доно як ишора бас.',
    categoryId: 'ilm',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote:
        'Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I',
  ),
  Proverb(
    id: '161',
    tajikCyrillic: 'Кам гӯю бисёр шунав.',
    persianText: 'کم گوی و بسیار شنو.',
    simpleExplanationTj: 'Камтар сухан гӯ ва бештар ба дигарон гӯш деҳ.',
    meaningTj:
        'Гӯш кардан барои фаҳмидан ва омӯхтан муҳим аст; сухани зиёд ҳамеша нишонаи дониш нест.',
    exampleSentenceTj:
        'Дар вохӯрӣ аввал ба ҳама гӯш дод ва баъд ҷавоб гуфт; кам гӯю бисёр шунав.',
    categoryId: 'odob',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '162',
    tajikCyrillic: 'Ҳар сухан ҷое дорад.',
    persianText: 'هر سخن جایی دارد.',
    simpleExplanationTj: 'Ҳар сухан ҷой, вақт ва шароити муносиб дорад.',
    meaningTj:
        'Ҳатто сухани дуруст агар дар вақти номуносиб гуфта шавад, метавонад таъсири бад дошта бошад.',
    exampleSentenceTj:
        'Ӯ масъалаи шахсиро дар назди ҳама нагуфт; ҳар сухан ҷое дорад.',
    categoryId: 'odob',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '163',
    tajikCyrillic: 'Дурӯғ пой надорад.',
    persianText: 'دروغ پای ندارد.',
    simpleExplanationTj: 'Дурӯғ пой надорад, яъне роҳи дур рафта наметавонад.',
    meaningTj: 'Дурӯғ пойдор нест ва дер ё зуд ошкор мешавад.',
    exampleSentenceTj:
        'Ҳикояаш бо далелҳо мувофиқ наомад ва зуд фош шуд; дурӯғ пой надорад.',
    categoryId: 'rostqavli',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '164',
    tajikCyrillic: 'Офтобро бо доман пӯшида намешавад.',
    persianText: 'آفتاب را با دامن پوشیده نمی‌شود.',
    simpleExplanationTj: 'Офтобро бо доман пинҳон кардан ғайриимкон аст.',
    meaningTj:
        'Ҳақиқати равшан ё воқеаи ошкорро бо пинҳонкорӣ барои ҳамеша махфӣ кардан мумкин нест.',
    exampleSentenceTj:
        'Ҳама далелҳоро дида буданд, бинобар ин инкор кардан фоида надошт; офтобро бо доман пӯшида намешавад.',
    categoryId: 'rostqavli',
    level: 5,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '165',
    tajikCyrillic: 'Аввал худро бин, баъд дигаронро.',
    persianText: 'اول خود را بین، بعد دیگران را.',
    simpleExplanationTj: 'Пеш аз дидани айби дигарон ба рафтори худ нигоҳ кун.',
    meaningTj: 'Худтанқидӣ бояд пеш аз доварӣ ва танқиди дигарон бошад.',
    exampleSentenceTj:
        'Пеш аз сарзаниши ҳамкораш хатои худашро санҷид; аввал худро бин, баъд дигаронро.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '166',
    tajikCyrillic: 'Дарахти пурмева сар хам мекунад.',
    persianText: 'درخت پرمیوه سر خم می‌کند.',
    simpleExplanationTj: 'Шохаи пурмева аз вазни мева ба поён хам мешавад.',
    meaningTj: 'Одами воқеан донишманд ва соҳибдастовард одатан фурӯтан аст.',
    exampleSentenceTj:
        'Бо вуҷуди донишаш худро аз дигарон боло намегирифт; дарахти пурмева сар хам мекунад.',
    categoryId: 'ilm',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
    canonicalId: '120',
  ),
  Proverb(
    id: '167',
    tajikCyrillic: 'Некӣ кун, некӣ бин.',
    persianText: 'نیکی کن، نیکی بین.',
    simpleExplanationTj: 'Ба дигарон некӣ кун, то дар зиндагӣ некӣ бинӣ.',
    meaningTj:
        'Рафтори хайрхоҳона муҳити нек ва муносибати хубро зиёд мекунад.',
    exampleSentenceTj:
        'Ҳамсояашро ёрӣ дод ва баъд худ ҳам дастгирӣ ёфт; некӣ кун, некӣ бин.',
    categoryId: 'muhabbat',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
  ),
  Proverb(
    id: '168',
    tajikCyrillic: 'Чоҳи касро макан, ки худ меафтӣ.',
    persianText: 'چاه کس را مکن، که خود می‌افتی.',
    simpleExplanationTj:
        'Барои каси дигар чоҳ ё дом насоз, зеро худат гирифтор шуда метавонӣ.',
    meaningTj:
        'Бадие, ки барои дигарон тарҳрезӣ мешавад, метавонад ба худи шахс баргардад.',
    exampleSentenceTj:
        'Нақшаи фиребаш баръакс худи ӯро шарманда кард; чоҳи касро макан, ки худ меафтӣ.',
    categoryId: 'hikmat',
    level: 4,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
    variants: ['Чоҳи дигаронро макан, ки худ меафтӣ.'],
  ),
  Proverb(
    id: '169',
    tajikCyrillic: 'Ҳар чӣ киштӣ, ҳамон даравӣ.',
    persianText: 'هر چه کشتی، همان دروی.',
    simpleExplanationTj: 'Ҳар чизе, ки мекорӣ, аз ҳамон навъ ҳосил мегирӣ.',
    meaningTj: 'Кору рафтори имрӯз оқибати фардоро месозад.',
    exampleSentenceTj:
        'Солҳо ба мардум бо эҳтиром муносибат кард ва дар пирӣ ҳама эҳтиромаш карданд; ҳар чӣ киштӣ, ҳамон даравӣ.',
    categoryId: 'hikmat',
    level: 3,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
    variants: ['Ҳар чизе, ки коштӣ, ҳамонро медаравӣ.'],
  ),
  Proverb(
    id: '170',
    tajikCyrillic: 'Дӯст дар рӯзи сахт маълум мешавад.',
    persianText: 'دوست در روز سخت معلوم می‌شود.',
    simpleExplanationTj: 'Дӯсти воқеӣ дар вақти мушкилӣ маълум мешавад.',
    meaningTj:
        'Дӯстӣ бо амал санҷида мешавад: касе, ки дар рӯзҳои сахт паҳлӯят мемонад, боэътимодтар аст.',
    exampleSentenceTj:
        'Вақте ба кӯмак ниёз дошт, дӯсташ аввал расид; дӯст дар рӯзи сахт маълум мешавад.',
    categoryId: 'dusti',
    level: 2,
    type: ProverbType.traditional,
    sourceStatus: SourceStatus.bookAttested,
    sourceNote: 'Зарбулмасал ва мақолҳои тоҷикӣ',
    canonicalId: '96',
  ),
];
