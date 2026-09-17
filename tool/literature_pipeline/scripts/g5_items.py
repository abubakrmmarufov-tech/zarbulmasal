import json, pymupdf
from generate_extracted_poems import extract_poem_from_doc

doc = pymupdf.open("docs/literature/pdfs/adabiet sinfi 5.pdf")

items = [
    {
        "id": "g5_rudaki_01",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Гар бар сари нафси худ амирӣ, мардӣ",
        "incipit": "Гар бар сари нафси худ амирӣ, мардӣ,",
        "genre": "рубоӣ",
        "completeness": "complete",
        "hint": (50, 50),
        "start": "Гар бар сари нафси худ амирӣ, мардӣ,",
        "end": "Гар дасти фитодае бигирӣ, мардӣ.",
        "notes": "Панд оид ба мардӣ ва ҷавонмардӣ"
    },
    {
        "id": "g5_rudaki_02",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Бирав зи таҷрибаи рӯзгор баҳра бигир",
        "incipit": "Бирав зи таҷрибаи рӯзгор баҳра бигир,",
        "genre": "байт",
        "completeness": "fragment",
        "hint": (50, 50),
        "start": "Бирав зи таҷрибаи рӯзгор баҳра бигир,",
        "end": "туро ба кор ояд.",
        "notes": "Панд оид ба омӯхтани таҷрибаи ҳаёт"
    },
    {
        "id": "g5_rudaki_03",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Ҳар кӣ н-омӯхт аз гузашти рӯзгор",
        "incipit": "Ҳар кӣ н-омӯхт аз гузашти рӯзгор,",
        "genre": "байт",
        "completeness": "fragment",
        "hint": (50, 50),
        "start": "Ҳар кӣ н-омӯхт аз гузашти рӯзгор,",
        "end": "Ҳеч н-омӯзад зи ҳеч омӯзгор",
        "notes": "Панд оид ба таҷрибаи рӯзгор"
    },
    {
        "id": "g5_rudaki_04",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Ин ҷаҳонро нигар ба чашми хирад",
        "incipit": "Ин ҷаҳонро нигар ба чашми хирад,",
        "genre": "қитъа",
        "completeness": "complete",
        "hint": (50, 50),
        "start": "Ин ҷаҳонро нигар ба чашми хирад",
        "end": "Киштие соз, то бад-он гузарӣ.",
        "notes": "Қитъа дар шинохти ҷаҳон"
    },
    {
        "id": "g5_rudaki_05",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "То ҷаҳон буд аз сари одам фароз",
        "incipit": "То ҷаҳон буд аз сари одам фароз,",
        "genre": "маснавӣ",
        "completeness": "excerpt",
        "hint": (50, 50),
        "start": "То ҷаҳон буд аз сари одам фароз",
        "end": "В-аз ҳама бад бар тани ту ҷавшан",
        "notes": "Порча аз «Калила ва Димна» дар бораи дониш"
    },
    {
        "id": "g5_rudaki_06",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Ба чашми дилат дид бояд ҷаҳон",
        "incipit": "Ба чашми дилат дид бояд ҷаҳон,",
        "genre": "байт",
        "completeness": "fragment",
        "hint": (50, 50),
        "start": "Ба чашми дилат",
        "end": "Ки чашми сари ту набинад ниҳон.",
        "notes": "Байт дар бораи чашми дил ва хирад"
    },
    {
        "id": "g5_rudaki_07",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Ой дареғо, ки хирадмандро",
        "incipit": "Ой дареғо, ки хирадмандро,",
        "genre": "қитъа",
        "completeness": "excerpt",
        "hint": (50, 50),
        "start": "Ой дареғо, ки хирадмандро,",
        "end": "Ҳосили мерос ба фарзанд не.",
        "notes": "Қитъа дар бораи тарбияи фарзанд"
    },
    {
        "id": "g5_rudaki_08",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Ёди диёр",
        "incipit": "Ҳар бод, ки аз сӯйи Бухоро ба ман ояд,",
        "genre": "ғазал",
        "completeness": "excerpt",
        "hint": (51, 52),
        "start": "Ҳар бод, ки аз сӯйи Бухоро ба ман ояд,",
        "end": "К-он бод ҳаме аз бари маъшуқи ман ояд.",
        "notes": "Ғазал дар васфи ёди диёр ва Бухоро"
    },
    {
        "id": "g5_rudaki_09",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Хандаи лола",
        "incipit": "Бихандад лола дар саҳро,",
        "genre": "қасида",
        "completeness": "excerpt",
        "hint": (52, 52),
        "start": "Бихандад лола дар саҳро",
        "end": "Нигори ман рухи гулгун.",
        "notes": "Порча аз қасидаи баҳория"
    },
    {
        "id": "g5_rudaki_10",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Баҳори хуррам",
        "incipit": "Омад баҳори хуррам бо рангу бӯйи тиб,",
        "genre": "қасида",
        "completeness": "excerpt",
        "hint": (52, 52),
        "start": "Омад баҳори хуррам бо рангу бӯйи тиб",
        "end": "Сор аз дарахти сарв мар-ӯро шуда муҷиб...",
        "notes": "Қасидаи машҳури баҳория"
    },
    {
        "id": "g5_rudaki_11",
        "author": "Абӯабдуллоҳи Рӯдакӣ",
        "authorId": "rudaki",
        "title": "Бӯйи Ҷӯйи Мулиён",
        "incipit": "Бӯйи Ҷӯйи Мулиён ояд ҳаме,",
        "genre": "қасида",
        "completeness": "excerpt",
        "hint": (54, 54),
        "start": "Бӯйи Ҷӯйи Мулиён ояд ҳаме,",
        "end": "Сарв сӯйи бӯстон ояд ҳаме.",
        "notes": "Суруд / қасида дар ёди Бухоро аз «Чаҳор мақола»"
    },
    {
        "id": "g5_shahidi_balkhi_01",
        "author": "Шаҳиди Балхӣ",
        "authorId": "01df7214-28b7-44ab-a1f4-898bb7e83950",
        "title": "Дар мадҳи устод Рӯдакӣ",
        "incipit": "Ба сухан монад шеъри шуаро,",
        "genre": "қитъа",
        "completeness": "complete",
        "hint": (55, 56),
        "start": "Ба сухан монад шеъри шуаро,",
        "end": "Рӯдакиро хаву аҳсант ҳиҷост",
        "notes": "Қитъа дар ситоиши Рӯдакӣ"
    },
    {
        "id": "g5_daqiqi_01",
        "author": "Дақиқӣ",
        "authorId": "b0133115-7ead-4ec8-bc6d-115f4540bdb2",
        "title": "Дар васфи Рӯдакӣ",
        "incipit": "Киро Рӯдакӣ гуфта бошад мадеҳ,",
        "genre": "қитъа",
        "completeness": "complete",
        "hint": (56, 56),
        "start": "Киро Рӯдакӣ гуфта бошад мадеҳ,",
        "end": "Чу хурмо ба пеши Хаҷевар",
        "notes": "Қитъа дар бузургии шоирии Рӯдакӣ"
    },
    {
        "id": "g5_unsuri_01",
        "author": "Унсурӣ",
        "authorId": "unsuri",
        "title": "Дар ситоиши ғазали Рӯдакӣ",
        "incipit": "Ғазал Рӯдакивор неку бувад,",
        "genre": "байт",
        "completeness": "fragment",
        "hint": (56, 56),
        "start": "Ғазал Рӯдакивор неку бувад,",
        "end": "Ғазалҳои ман Рӯдакивор нест.",
        "notes": "Байт дар ситоиши ғазали Рӯдакӣ"
    },
    {
        "id": "g5_rashidi_01",
        "author": "Рашидии Самарқандӣ",
        "authorId": "rashidii_samarqandi",
        "title": "Дар мадҳи Рӯдакӣ",
        "incipit": "Гар сарӣ ёбад ба олам кас ба некӯшоирӣ,",
        "genre": "қитъа",
        "completeness": "complete",
        "hint": (56, 56),
        "start": "Гар сарӣ ёбад ба олам кас ба некӯшоирӣ,",
        "end": "Ҳам фузун ояд, агар чандон, ки бояд бишмарӣ.",
        "notes": "Қитъа дар васфи азамати шеъри Рӯдакӣ"
    }
]

for it in items:
    text, p_s, p_e = extract_poem_from_doc(doc, it["hint"][0], it["hint"][1], it["start"], it["end"])
    print(f"[{it['id']}] pages {p_s}-{p_e} lines={len(text.splitlines())}")

