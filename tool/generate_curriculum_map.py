import json

curriculum_data = {
    "version": "1.0.0",
    "description": "Authoritative Tajik Literature School Curriculum Mapping (Grades 5-11)",
    "officialSources": {
        "5": {
            "sourceId": "tj_literature_grade_5_2017",
            "title": "Адабиёти тоҷик",
            "authors": "Т. Мирзод, Р. Ҳамидов, М. Пирзод",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2017",
            "isbn": "978-999-47-1-436-0",
            "sourceReference": "docs/literature/pdfs/adabiet sinfi 5.pdf",
            "maorifId": 212
        },
        "6": {
            "sourceId": "tj_literature_grade_6_2014",
            "title": "Адабиёти тоҷик",
            "authors": "Қурбон Хоҷаев, Аҳмад Абдувалиев, Нуриддин Шарафиддинов, Баҳодур Раҳматов",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2014",
            "isbn": "978-99947-1-263-2",
            "sourceReference": "docs/literature/pdfs/adabiet sinfi 6.pdf",
            "maorifId": 229
        },
        "7": {
            "sourceId": "tj_literature_grade_7_2018",
            "title": "Адабиёти тоҷик",
            "authors": "У. Тоиров, М. Солеҳов, Н. Ширинов",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2018",
            "isbn": "978-99947-1-515-2",
            "sourceReference": "docs/literature/pdfs/adabiyot sinfi 7.pdf",
            "maorifId": 242
        },
        "8": {
            "sourceId": "tj_literature_grade_8_2026",
            "title": "Адабиёти тоҷик",
            "authors": "Абдунабӣ Сатторзода",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2026",
            "isbn": "978-99985-61-78-6",
            "sourceReference": "docs/literature/pdfs/adabiyet sinfi 8.pdf",
            "maorifId": 663
        },
        "9": {
            "sourceId": "tj_literature_grade_9_2026",
            "title": "Адабиёти тоҷик",
            "authors": "Т. Мирзод, С. Давлатзода, Ф. Мирзода",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2026",
            "isbn": "978-99985-39-75-4",
            "sourceReference": "docs/literature/pdfs/adabiyet sinfi 9.pdf",
            "maorifId": 704
        },
        "10": {
            "sourceId": "tj_literature_grade_10_2026",
            "title": "Адабиёти тоҷик",
            "authors": "У. Тоир, М. Солеҳ, Н. Ширинзода",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2026",
            "isbn": "978-99985-61-84-7",
            "sourceReference": "docs/literature/pdfs/adabiet sinfi 10.pdf",
            "maorifId": 728
        },
        "11": {
            "sourceId": "tj_literature_grade_11_2018",
            "title": "Адабиёти тоҷик (давраи нав)",
            "authors": "Х. Асозода, А. Кӯчаров",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2018",
            "isbn": "978-99947-1-536-7",
            "sourceReference": "docs/literature/pdfs/adabiyet sinfi 11.pdf",
            "maorifId": 741
        }
    },
    "grades": {
        "5": [
            {"authorName": "Абӯабдуллоҳи Рӯдакӣ", "authorSlug": "rudaki", "pageStart": 49, "pageEnd": 56, "works": ["Шикоят аз пирӣ (порча)", "Рубоиёт", "Дар бораи мардӣ ва одамгарӣ", "Дар бораи дониш"]},
            {"authorName": "Робиаи Балхӣ", "authorSlug": "robia_balkhi", "pageStart": 60, "pageEnd": 61, "works": ["Зи ишқи ӯ шудам ғофил", "Ишқи бепоён"]},
            {"authorName": "Абӯалӣ ибни Сино", "authorSlug": "ibn_sina", "pageStart": 62, "pageEnd": 72, "works": ["Рубоиёт (Аз қаъри гили сиёҳ...)", "Куфри чу мане", "Май душмани масту дӯст бо ҳушёр аст"]},
            {"authorName": "Абдуллоҳи Ансорӣ", "authorSlug": "ansori", "pageStart": 73, "pageEnd": 79, "works": ["Пандҳо аз «Муноҷотнома»", "Хислатҳои инсони комил"]},
            {"authorName": "Низомулмулк", "authorSlug": "nizomulmulk", "pageStart": 80, "pageEnd": 88, "works": ["Ҳикоятҳо аз «Сиёсатнома»", "Дар адлу инсоф"]},
            {"authorName": "Аҳмади Ҷомӣ", "authorSlug": "ahmadi_jomi", "pageStart": 89, "pageEnd": 91, "works": ["Дар ситоиши адаб ва дониш"]},
            {"authorName": "Фаридуддини Аттори Нишопурӣ", "authorSlug": "attor", "pageStart": 92, "pageEnd": 99, "works": ["Ҳикоятҳо аз «Мантиқ-ут-тайр»", "Булбул ва боғбон"]},
            {"authorName": "Саъдии Шерозӣ", "authorSlug": "saadi", "pageStart": 100, "pageEnd": 128, "works": ["Ҳикоятҳо аз «Гулистон»", "Пандҳо аз «Бӯстон»", "Бани Одам аъзои якдигаранд", "Ғазалиёт"]},
            {"authorName": "Камолиддин Биноӣ", "authorSlug": "binoi", "pageStart": 129, "pageEnd": 145, "works": ["Ҳикоятҳо аз «Беҳрӯзу Баҳром»", "Панди падар"]},
            {"authorName": "Бадриддин Ҳилолӣ", "authorSlug": "hiloli", "pageStart": 146, "pageEnd": 152, "works": ["Порчаҳо аз «Шоҳ ва Дарвеш»", "Ғазалиёт"]},
            {"authorName": "Садриддин Айнӣ", "authorSlug": "ayni", "pageStart": 153, "pageEnd": 176, "works": ["Пораҳо аз «Ёддоштҳо»", "Биёед, эй рафиқон, дарс хонем", "Темурмалик (порча)"]},
            {"authorName": "Абулқосим Лоҳутӣ", "authorSlug": "lohuti", "pageStart": 177, "pageEnd": 194, "works": ["Ба раҳзан", "Ба бачаҳои тоҷик", "Кова (порча)"]},
            {"authorName": "Мирзо Турсунзода", "authorSlug": "tursunzoda", "pageStart": 195, "pageEnd": 209, "works": ["Офтоби сарзамин", "Дӯстии халқҳо", "Баҳори диёр"]},
            {"authorName": "Мирсаид Миршакар", "authorSlug": "mirshakar", "pageStart": 210, "pageEnd": 227, "works": ["Қишлоқи тиллоӣ (порча)", "Мо аз Помир омадем"]},
            {"authorName": "Ғаффор Мирзо", "authorSlug": "ghaffor_mirzo", "pageStart": 228, "pageEnd": 237, "works": ["Асрор (достонча)", "Гулдаста"]},
            {"authorName": "Лоиқ Шералӣ", "authorSlug": "loiq_sherali", "pageStart": 238, "pageEnd": 247, "works": ["Модар", "Забони модарӣ", "Ватан"]},
            {"authorName": "Гулчеҳра Сулаймонӣ", "authorSlug": "gulchehra_sulaymoni", "pageStart": 248, "pageEnd": 255, "works": ["Ситораҳои умедбахш", "Гулҳои баҳор"]},
            {"authorName": "Гулназар Келдӣ", "authorSlug": "gulnazar_keldi", "pageStart": 256, "pageEnd": 263, "works": ["Суруди миллӣ", "Фасли гулҳо", "Маърифат"]}
        ],
        "6": [
            {"authorName": "Унсурулмаолии Кайковус", "authorSlug": "kaykovus", "pageStart": 23, "pageEnd": 38, "works": ["Бобҳо аз «Қобуснома»", "Андар шинохтани ҳаққи падар ва модар", "Андар фурӯтанӣ ва афзунии ҳунар"]},
            {"authorName": "Фаррухии Систонӣ", "authorSlug": "farrukhi", "pageStart": 39, "pageEnd": 43, "works": ["Қасидаи Доғгоҳ (порча)", "Боз тавлид шуд баҳори хуррам"]},
            {"authorName": "Низомии Ганҷавӣ", "authorSlug": "nizomi_ganjavi", "pageStart": 44, "pageEnd": 68, "works": ["Подшоҳи золим ва ҷавони саховатпеша", "Достони «Хайр ва Шар»", "Султон Санҷар ва пиразан"]},
            {"authorName": "Муҳаммад Ғазолӣ", "authorSlug": "ghazoli", "pageStart": 69, "pageEnd": 78, "works": ["Ҳикоятҳо аз «Насиҳат-ул-мулук»", "Дар одоби суҳбат"]},
            {"authorName": "Муҳаммад Авфии Бухороӣ", "authorSlug": "avfi", "pageStart": 79, "pageEnd": 89, "works": ["Ҳикоятҳо аз «Ҷомеъ-ул-ҳикоёт»", "Саховати Ҳотами Той"]},
            {"authorName": "Зиёуддини Нахшабӣ", "authorSlug": "nakhshabi", "pageStart": 90, "pageEnd": 100, "works": ["Ҳикоятҳо аз «Тӯтинома»", "Дар ситоиши вафодорӣ"]},
            {"authorName": "Бадриддини Ҳилолӣ", "authorSlug": "hiloli", "pageStart": 120, "pageEnd": 137, "works": ["Достони «Сифотулошиқин»", "Ғазалиёт"]},
            {"authorName": "Шамсуддини Шоҳин", "authorSlug": "shohin", "pageStart": 138, "pageEnd": 146, "works": ["Достони «Лайлӣ ва Маҷнун» (порчаҳо)", "Ғазалиёт"]},
            {"authorName": "Садриддин Айнӣ", "authorSlug": "ayni", "pageStart": 147, "pageEnd": 158, "works": ["Қаҳрамони халқи тоҷик Темурмалик", "Мубориза дар Хуҷанд"]},
            {"authorName": "Мирзо Турсунзода", "authorSlug": "tursunzoda", "pageStart": 159, "pageEnd": 176, "works": ["Достони «Писари Ватан»", "Садои Осиё (порчаҳо)"]},
            {"authorName": "Аминҷон Шукӯҳӣ", "authorSlug": "shukuhi", "pageStart": 177, "pageEnd": 188, "works": ["Порае аз қиссаи «Шаҳло»", "Барги сабз"]}
        ],
        "7": [
            {"authorName": "Абулқосими Фирдавсӣ", "authorSlug": "firdawsi", "pageStart": 30, "pageEnd": 50, "works": ["Достони «Кова ва Заҳҳок»", "Расидани Суҳроб ба Дижи сафед", "Разми Суҳроб бо Гурдофарид", "Панду андарзҳо"]},
            {"authorName": "Заҳирии Самарқандӣ", "authorSlug": "zahiri", "pageStart": 51, "pageEnd": 57, "works": ["Ҳикояти «Калимоти кохи Афредун» аз «Синдбоднома»"]},
            {"authorName": "Низомии Арӯзии Самарқандӣ", "authorSlug": "nizomii_aruzi", "pageStart": 58, "pageEnd": 61, "works": ["Ҳикояти рӯзгори Масъуди Саъди Салмон аз «Чаҳор мақола»"]},
            {"authorName": "Масъуди Саъди Салмон", "authorSlug": "masudi_sad", "pageStart": 62, "pageEnd": 67, "works": ["Қасидаи ҳабсия «Тиру теғ аст бар дилу ҷагарам»", "Қитъаи «То тавонӣ, макаш зи мардӣ даст»"]},
            {"authorName": "Ҷалолуддини Балхӣ", "authorSlug": "rumi", "pageStart": 68, "pageEnd": 97, "works": ["Ҳикояти «Бозаргон ва тӯтӣ»", "Ҳикояти «Марди аблаҳ ва хирс»", "Ҳикояти «Табиб ва бемор»", "Андарзҳои Мавлавӣ"]},
            {"authorName": "Убайди Зоконӣ", "authorSlug": "zokonii", "pageStart": 98, "pageEnd": 103, "works": ["Ҳикоятҳо аз «Рисолаи дилкушо»", "Ҳикоятҳо аз «Ахлоқ-ул-ашроф»"]},
            {"authorName": "Камоли Хуҷандӣ", "authorSlug": "kamol_khujandi", "pageStart": 104, "pageEnd": 108, "works": ["Ғарибӣ", "Гуфтам ба чашм", "Ошӯби ҷонӣ", "Дӯст медорад дилам ҷавру ҷафои дӯстро"]},
            {"authorName": "Абдурраҳмони Ҷомӣ", "authorSlug": "jami", "pageStart": 109, "pageEnd": 120, "works": ["Ҳикоятҳо аз «Баҳористон»", "Ҳикоятҳо аз «Силсилат-уз-заҳаб»", "Қиссаи он хирс, ки обаш мебурд", "Ҳикояти пирзоле, ки роҳ бар Санҷар гирифт"]},
            {"authorName": "Ҳусайн Воизи Кошифӣ", "authorSlug": "koshifi", "pageStart": 126, "pageEnd": 140, "works": ["Ҳикоятҳо аз «Анвори Суҳайлӣ»", "Ҳикояти «Гунҷишк ва сусмор»", "Ҳикояти «Моҳихор»", "Ҳикояти «Тадбири бӯзинагон»"]},
            {"authorName": "Самандархоҷаи Тирмизӣ", "authorSlug": "samandar", "pageStart": 141, "pageEnd": 150, "works": ["Ҳикоятҳо аз «Дастур-ул-мулук»", "Дар ҳоли вазирон", "Дар санҷида гуфтан"]},
            {"authorName": "Саййидои Насафӣ", "authorSlug": "sayyido", "pageStart": 151, "pageEnd": 164, "works": ["Ҳикоятҳо аз «Баҳориёт» («Ҳайвонотнома»)", "Ғазалиёт"]},
            {"authorName": "Соиби Табрезӣ", "authorSlug": "soib", "pageStart": 165, "pageEnd": 176, "works": ["Ғазалиёт (Ҳамвор кардани роҳи рӯзгор)", "Андарзҳо"]},
            {"authorName": "Ҳофизи Шерозӣ", "authorSlug": "hafiz", "pageStart": 177, "pageEnd": 190, "works": ["Агар он турки шерозӣ ба даст орад дили моро", "Саҳар бо бод мегуфтам ҳадиси орзумандӣ", "Мазид аз лутфи шоҳӣ"]}
        ],
        "8": [
            {"authorName": "Бузургмеҳри Ҳаким", "authorSlug": "buzurgmehr", "pageStart": 19, "pageEnd": 21, "works": ["«Андарзнома»-и Бузургмеҳр"]},
            {"authorName": "Абӯабдуллоҳи Рӯдакӣ", "authorSlug": "rudaki", "pageStart": 43, "pageEnd": 64, "works": ["Қасидаи «Шикоят аз пирӣ»", "Қасидаи «Модари май»", "«Бӯи ҷӯи Мӯлиён»", "Андарзҳои манзум"]},
            {"authorName": "Дақиқӣ", "authorSlug": "daqiqi", "pageStart": 65, "pageEnd": 76, "works": ["Гуштоспнома (порчаҳо)", "Ғазалиёт ва қасоид"]},
            {"authorName": "Абулқосими Фирдавсӣ", "authorSlug": "firdawsi", "pageStart": 77, "pageEnd": 126, "works": ["«Шоҳнома»", "Достони Суҳроб", "Достони разми Исфандиёр бо Рустам", "Ҳунари шоирӣ дар «Шоҳнома»"]},
            {"authorName": "Абӯалӣ ибни Сино", "authorSlug": "ibn_sina", "pageStart": 127, "pageEnd": 142, "works": ["«Қасидаи айния»", "Рубоиёт", "Аз қаъри гили сиёҳ то авҷи Зуҳал", "Ҳикматҳо"]},
            {"authorName": "Боботоҳири Урён", "authorSlug": "bobotohir", "pageStart": 150, "pageEnd": 154, "works": ["Дубайтиҳои Боботоҳир"]},
            {"authorName": "Асадии Тӯсӣ", "authorSlug": "asadii_tusi", "pageStart": 159, "pageEnd": 167, "works": ["«Гаршоспнома» (порчаҳо)", "Мунозираи «Шаб ва Рӯз»"]},
            {"authorName": "Амир Унсурулмаолии Кайковус", "authorSlug": "kaykovus", "pageStart": 168, "pageEnd": 178, "works": ["«Қобуснома»", "Дар одоби муошират ва ҳунаромӯзӣ"]},
            {"authorName": "Носири Хусрав", "authorSlug": "nasir_khusraw", "pageStart": 179, "pageEnd": 200, "works": ["Қасидаи «Донишу дин»", "«Сафарнома» (порчаҳо)", "«Рӯшноинома»", "«Саодатнома»"]},
            {"authorName": "Умари Хайём", "authorSlug": "khayyam", "pageStart": 201, "pageEnd": 211, "works": ["Рубоиёти фалсафӣ", "Дар моҳияти ҳастӣ ва кайҳон"]},
            {"authorName": "Саноии Ғазнавӣ", "authorSlug": "sanoi", "pageStart": 212, "pageEnd": 219, "works": ["«Ҳадиқат-ул-ҳақиқа» (порчаҳо)", "Ғазалиёти ирфонӣ"]},
            {"authorName": "Абулмаолии Насруллоҳ", "authorSlug": "nasrulloh", "pageStart": 220, "pageEnd": 225, "works": ["«Калила ва Димна» (тарҷума)", "Боби «Шер ва Гов»"]},
            {"authorName": "Фаромуз ибни Худодод", "authorSlug": "faromuz", "pageStart": 226, "pageEnd": 232, "works": ["«Самаки Айёр» (насри ривоятӣ)"]},
            {"authorName": "Анварии Абевардӣ", "authorSlug": "anvari", "pageStart": 234, "pageEnd": 243, "works": ["Қасидаи «Ашки Хуросон»", "Ғазалиёт ва қитъаҳо"]},
            {"authorName": "Фаридуддини Аттори Нишопурӣ", "authorSlug": "attor", "pageStart": 244, "pageEnd": 250, "works": ["«Мантиқ-ут-тайр»", "«Тазкират-ул-авлиё» (порчаҳо)"]},
            {"authorName": "Хоқонии Шарвонӣ", "authorSlug": "khoqoni", "pageStart": 251, "pageEnd": 260, "works": ["Қасидаи «Айвони Мадоин»", "Қасоиди мутафаккирона"]},
            {"authorName": "Низомии Ганҷавӣ", "authorSlug": "nizomi_ganjavi", "pageStart": 262, "pageEnd": 296, "works": ["«Хамса»", "«Махзан-ул-асрор»", "«Хусрав ва Ширин»", "«Лайлӣ ва Маҷнун»", "«Ҳафт пайкар»", "«Искандарнома»"]}
        ],
        "9": [
            {"authorName": "Саъдии Шерозӣ", "authorSlug": "saadi", "pageStart": 14, "pageEnd": 58, "works": ["«Гулистон» (бобҳои 1-8)", "«Бӯстон» (достонҳо)", "Ғазалиёти ошиқона ва орифона", "Қасоид"]},
            {"authorName": "Ҷалолиддини Балхӣ", "authorSlug": "rumi", "pageStart": 59, "pageEnd": 86, "works": ["«Девони кабир» («Девони Шамс»)", "«Маснавии маънавӣ»", "Ҳикояти «Марди баққол ва тӯтӣ»", "Ҳикояти «Ҷуҳӣ»", "Ғазалиёт"]},
            {"authorName": "Амир Хусрави Деҳлавӣ", "authorSlug": "khusrav_dehlavi", "pageStart": 87, "pageEnd": 106, "works": ["«Хамса»", "Достони «Дувалронӣ ва Хизрхон»", "Ғазалиёти латиф", "Қасоид"]},
            {"authorName": "Сайфи Фарғонӣ", "authorSlug": "sayfi_farghoni", "pageStart": 107, "pageEnd": 115, "works": ["Қасидаи иҷтимоӣ", "Ғазалиёт ва қитъаҳо"]},
            {"authorName": "Муҳаммад Авфии Бухороӣ", "authorSlug": "avfi", "pageStart": 116, "pageEnd": 126, "works": ["«Лубоб-ул-албоб» (нахустин тазкира)", "«Ҷомеъ-ул-ҳикоёт ва лавомеъ-ур-ривоёт»"]},
            {"authorName": "Зиёуддини Нахшабӣ", "authorSlug": "nakhshabi", "pageStart": 127, "pageEnd": 138, "works": ["«Тӯтинома» (42 ҳикоят)", "«Гулрез»", "«Силк-ус-сулук»"]},
            {"authorName": "Ибни Ямин", "authorSlug": "ibni_yamin", "pageStart": 139, "pageEnd": 149, "works": ["Қитъаоти пандуахлоқӣ ва иҷтимоӣ", "Ғазалиёт"]},
            {"authorName": "Убайди Зоконӣ", "authorSlug": "zokonii", "pageStart": 150, "pageEnd": 161, "works": ["«Муш ва Гурба»", "«Рисолаи дилкушо»", "«Сад панд»", "«Ахлоқ-ул-ашроф»"]},
            {"authorName": "Ҳофизи Шерозӣ", "authorSlug": "hafiz", "pageStart": 162, "pageEnd": 194, "works": ["«Девони ашъор»", "Ғазалиёти безавол", "Тасвири табиат ва инсон", "Санъатҳои бадеӣ дар шеъри Ҳофиз"]},
            {"authorName": "Камоли Хуҷандӣ", "authorSlug": "kamol_khujandi", "pageStart": 195, "pageEnd": 206, "works": ["Ғазалиёти латиф ва ошиқона", "Ашъор дар ситоиши Хуҷанд", "«Девони Камол»"]},
            {"authorName": "Абдурраҳмони Ҷомӣ", "authorSlug": "jami", "pageStart": 219, "pageEnd": 270, "works": ["«Ҳафт авранг»", "«Юсуф ва Зулайхо»", "«Саломон ва Абсол»", "«Баҳористон»", "Ғазалиёт"]},
            {"authorName": "Алишери Навоӣ", "authorSlug": "navoi", "pageStart": 271, "pageEnd": 278, "works": ["«Девони Фонӣ» (ба забони тоҷикӣ)", "«Туҳфат-ул-афкор»", "Дӯстию ҳамкории Ҷомию Навоӣ"]},
            {"authorName": "Ҳусайн Воизи Кошифӣ", "authorSlug": "koshifi", "pageStart": 279, "pageEnd": 293, "works": ["«Анвори Суҳайлӣ»", "«Ахлоқи Муҳсинӣ»", "«Футувватномаи султонӣ»"]},
            {"authorName": "Камолиддини Биноӣ", "authorSlug": "binoi", "pageStart": 294, "pageEnd": 305, "works": ["Достони «Беҳрӯзу Баҳром»", "«Шайбонинома»", "Ғазалиёт"]},
            {"authorName": "Бадриддини Ҳилолӣ", "authorSlug": "hiloli", "pageStart": 306, "pageEnd": 331, "works": ["Достони «Шоҳ ва Дарвеш»", "Достони «Сифотулошиқин»", "Ғазалиёт"]},
            {"authorName": "Зайниддин Восифӣ", "authorSlug": "vosifi", "pageStart": 332, "pageEnd": 345, "works": ["«Бадоеъ-ул-вақоеъ» (насри хотиравӣ ва таърихӣ)"]}
        ],
        "10": [
            {"authorName": "Абдурраҳмони Мушфиқӣ", "authorSlug": "mushfiqi", "pageStart": 26, "pageEnd": 49, "works": ["Маснавии «Гулзори Ирам»", "Девони мутоибот", "Ҳаҷвиёт ва қасоид"]},
            {"authorName": "Шавкати Бухороӣ", "authorSlug": "shavkati_bukhoroi", "pageStart": 50, "pageEnd": 69, "works": ["«Девони ашъор»", "Сабки ҳиндӣ дар ашъори Шавкат", "Ғазалиёт"]},
            {"authorName": "Саййидои Насафӣ", "authorSlug": "sayyido", "pageStart": 70, "pageEnd": 95, "works": ["«Шаҳрошӯб» (ситоиши ҳунармандон)", "«Баҳориёт» («Ҳайвонотнома»)", "Мусамматҳо ва ғазалиёт"]},
            {"authorName": "Соиби Табрезӣ", "authorSlug": "soib", "pageStart": 96, "pageEnd": 116, "works": ["Ғазалиёти тасвирӣ ва маърифатӣ", "Тамсил ва услуби сабки ҳиндӣ"]},
            {"authorName": "Мирзо Абдулқодири Бедил", "authorSlug": "bedil", "pageStart": 117, "pageEnd": 160, "works": ["«Куллиёт»", "«Ирфон»", "«Тилисми ҳайрат»", "«Тӯри маърифат»", "«Нукот» ва «Чаҳорунсур»", "Ғазалиёти фалсафӣ"]},
            {"authorName": "Мирзосодиқи Муншӣ", "authorSlug": "mirzosodiq", "pageStart": 173, "pageEnd": 184, "works": ["«Дахмаи шоҳон»", "Ғазалиёт"]},
            {"authorName": "Ҷунайдуллоҳи Ҳозиқ", "authorSlug": "hoziq", "pageStart": 185, "pageEnd": 206, "works": ["Достони «Юсуф ва Зулайхо»", "Ғазалиёт"]},
            {"authorName": "Гулханӣ", "authorSlug": "gulkhani", "pageStart": 207, "pageEnd": 215, "works": ["«Зарбулмасал» (маснавӣ ва наср)", "Ҳикояти «Зоғ ва кабк»"]},
            {"authorName": "Қоонӣ", "authorSlug": "qooni", "pageStart": 216, "pageEnd": 225, "works": ["Қасоиди мутанаввеъ", "«Парешон»"]},
            {"authorName": "Аҳмади Дониш", "authorSlug": "ahmad_donish", "pageStart": 238, "pageEnd": 269, "works": ["«Наводир-ул-вақоеъ»", "«Рисола ё мухтасаре аз таърихи салтанати хонадони манғития»"]},
            {"authorName": "Савдо", "authorSlug": "savdo", "pageStart": 270, "pageEnd": 281, "works": ["Мутоибот ва ҳаҷвиёт", "Ғазалиёт"]},
            {"authorName": "Шамсуддини Шоҳин", "authorSlug": "shohin", "pageStart": 282, "pageEnd": 311, "works": ["«Бадоеъ-ус-саноеъ»", "«Туҳфаи дӯстон»", "«Лайлӣ ва Маҷнун»", "Ғазалиёт"]},
            {"authorName": "Муҳаммадсиддиқи Ҳайрат", "authorSlug": "hayrat", "pageStart": 312, "pageEnd": 318, "works": ["«Девони ашъор»", "Ғазалиёт"]},
            {"authorName": "Қорӣ Раҳматуллоҳи Возеҳ", "authorSlug": "vozeh", "pageStart": 319, "pageEnd": 331, "works": ["«Савонеҳ-ул-масолик ва фаросих-ул-мамолик»", "«Кони лаззат ва хони неъмат»", "«Ақоид-ун-нисо»"]}
        ],
        "11": [
            {"authorName": "Тошхӯҷаи Асирӣ", "authorSlug": "asiri", "pageStart": 31, "pageEnd": 39, "works": ["Маснавии «Ҷӯйи Бекобод»", "Ашъори маорифпарварӣ"]},
            {"authorName": "Ҳоҷӣ Ҳусайни Кангуртӣ", "authorSlug": "kangurti", "pageStart": 40, "pageEnd": 47, "works": ["«Девони ашъор»", "Ғазалиёт ва мусаддасот"]},
            {"authorName": "Садриддин Айнӣ", "authorSlug": "ayni", "pageStart": 61, "pageEnd": 106, "works": ["Романи «Ғуломон»", "Қиссаи «Марги судхӯр»", "«Ёддоштҳо» (ҷилдҳои 1-4)", "«Таърихи инқилоби Бухоро»", "«Намунаи адабиёти тоҷик»", "Шеърҳои даврони нав"]},
            {"authorName": "Абулқосим Лоҳутӣ", "authorSlug": "lohuti", "pageStart": 107, "pageEnd": 131, "works": ["«Суруди зафар»", "«Ба чӯпон»", "«Мо музаффар хоҳем шуд»", "Достони «Тоҷ ва байрақ»", "Тарҷумаи осори классикони ҷаҳон"]},
            {"authorName": "Пайрав Сулаймонӣ", "authorSlug": "payrav_sulaymoni", "pageStart": 132, "pageEnd": 143, "works": ["«Қалами ман»", "«Шукуфаи инқилоб»", "Ғазалиёт ва марсияҳо"]},
            {"authorName": "Ҳабиб Юсуфӣ", "authorSlug": "habib_yusufi", "pageStart": 144, "pageEnd": 151, "works": ["«Таронаи ватан»", "«Ба ҷанговари тоҷик»", "Ғазалиёт"]},
            {"authorName": "Мирзо Турсунзода", "authorSlug": "tursunzoda", "pageStart": 152, "pageEnd": 198, "works": ["Достони «Ҳасани аробакаш»", "Достони «Чароғи абадӣ»", "Достони «Ҷони ширин»", "Силсилаи «Ман аз Шарқи озод»", "«Қиссаи Ҳиндустон»"]},
            {"authorName": "Ҷалол Икромӣ", "authorSlug": "ikromi", "pageStart": 207, "pageEnd": 239, "works": ["Романи «Духтари оташ»", "Романи «Дувоздаҳ дарвозаи Бухоро»", "Қиссаи «Тирмоҳ»"]},
            {"authorName": "Мирсаид Миршакар", "authorSlug": "mirshakar", "pageStart": 240, "pageEnd": 252, "works": ["Достони «Ливои зафар»", "Достони «Панҷакенти шӯрбахт»", "«Қишлоқи тиллоӣ»"]},
            {"authorName": "Фазлиддин Муҳаммадиев", "authorSlug": "muhammadiev", "pageStart": 253, "pageEnd": 269, "works": ["Қиссаи «Шоҳи тирдон»", "«Одамони сари роҳ»", "Ҳикояҳо"]},
            {"authorName": "Муъмин Қаноат", "authorSlug": "qanoat", "pageStart": 270, "pageEnd": 287, "works": ["Достони «Сурӯши Сталинград»", "Достони «Модарнома»", "Достони «Тоҷикистон – исми ман»", "«Ситораи Сино»"]},
            {"authorName": "Лоиқ Шералӣ", "authorSlug": "loiq_sherali", "pageStart": 288, "pageEnd": 316, "works": ["«Модарнома»", "«Хонаи чашм»", "«Дасти дуои модар»", "«Шеъру шоирӣ»", "Ғазалиёт ва дубайтӣ"]},
            {"authorName": "Сайф Раҳимзоди Афардӣ", "authorSlug": "sayf_rahimzod", "pageStart": 317, "pageEnd": 325, "works": ["Қиссаи «Ситораҳои сари танӯр»", "Ҳикояи «Аз мо буд, ки бар мо шуд»"]},
            {"authorName": "Саттор Турсун", "authorSlug": "sattor_tursun", "pageStart": 326, "pageEnd": 333, "works": ["Романи «Се рӯзи як баҳор»", "Қиссаи «Камони Рустам»"]},
            {"authorName": "Бозор Собир", "authorSlug": "bozor_sobir", "pageStart": 334, "pageEnd": 349, "works": ["«Забони модарӣ»", "«Аз гули хор»", "«Офтобсавор»", "Шеъри нави тоҷикӣ"]},
            {"authorName": "Меҳмон Бахтӣ", "authorSlug": "mehmon_bakhti", "pageStart": 355, "pageEnd": 365, "works": ["Драмаи «Фирдавсӣ»", "Драмаи «Шоҳ Исмоили Сомонӣ»"]},
            {"authorName": "Гулназар Келдӣ", "authorSlug": "gulnazar_keldi", "pageStart": 366, "pageEnd": 380, "works": ["«Суруди миллӣ»", "Шеърҳои васфи Модар", "«Оғӯши саршор»"]},
            {"authorName": "Абдулҳамид Самад", "authorSlug": "abdulhamid_samad", "pageStart": 381, "pageEnd": 389, "works": ["Қиссаи «Шарораи хотира»", "«Аспи бобом»", "Ҳикояҳо"]},
            {"authorName": "Кароматуллоҳи Мирзо", "authorSlug": "karomatullohi_mirzo", "pageStart": 390, "pageEnd": 396, "works": ["Романи «Дар орзуи падар»", "«Нишони зиндагӣ»"]}
        ]
    }
}

with open('docs/literature/CURRICULUM_MAPPING.json', 'w', encoding='utf-8') as f:
    json.dump(curriculum_data, f, ensure_ascii=False, indent=2)

print('Successfully generated docs/literature/CURRICULUM_MAPPING.json')
