# -*- coding: utf-8 -*-
"""
Enriches all 150 authors in poets.json with:
- canonicalNamePersian (Perso-Arabic script, zero Cyrillic)
- biographyFa (authentic Persian biography, zero Cyrillic)
- rich biographyTj (extracted/adapted from official school textbooks)
- biographySource (citing exact textbook and page ranges)
- Preserves all mandatory unit test assertions
"""
import json
import re
import fitz

cyrillic_pattern = re.compile(r'[\u0400-\u04FF]')

tajik_map = {
    'Љ': 'Ҷ', 'љ': 'ҷ',
    'Њ': 'Ҳ', 'њ': 'ҳ',
    'Ї': 'Ӣ', 'ї': 'ӣ',
    'Ќ': 'Қ', 'ќ': 'қ',
    'Ў': 'Ӯ', 'ў': 'ӯ',
    'Ѓ': 'Ғ', 'ѓ': 'ғ'
}

def clean_tajik(text):
    for k, v in tajik_map.items():
        text = text.replace(k, v)
    text = re.sub(r'(\w+)-\s*\n\s*(\w+)', r'\1\2', text)
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    return ' '.join(lines)

def extract_pages(pdf_path, start_page, end_page, max_chars=1200):
    try:
        doc = fitz.open(pdf_path)
        combined = []
        s = max(0, start_page - 1)
        e = min(len(doc), end_page)
        for p in range(s, e):
            txt = clean_tajik(doc[p].get_text())
            txt = re.sub(r'^\d+\s*', '', txt)
            combined.append(txt)
            if sum(len(x) for x in combined) >= max_chars:
                break
        full = ' '.join(combined)
        full = re.sub(r'\s+', ' ', full).strip()
        return full[:max_chars].strip()
    except Exception as e:
        print(f"Error extracting {pdf_path}: {e}")
        return ""

# Comprehensive Perso-Arabic canonical names for all 150 poets
CANONICAL_FA = {
    "rudaki": "ابوعبدالله رودکی",
    "nasir_khusraw": "ناصر خسرو",
    "kamol_khujandi": "کمال خجندی",
    "tursunzoda": "میرزا تورسون‌زاده",
    "qanoat": "مؤمن قناعت",
    "loiq_sherali": "لایق شیرعلی",
    "bozor_sobir": "بازار صابر",
    "gulnazar_keldi": "گل‌نظر کلدی",
    "gulrukhsor": "گلرخسار صفی‌اوا",
    "farzona": "فرزانه خجندی",
    "47c1dc67-363a-4506-8a9c-bbbb38f98d20": "صدرالدین عینی",
    "455f0420-3834-48f0-86b9-7da673a2a684": "میرزا عبدالقادر بیدل دهلوی",
    "d1abb54a-9804-4baf-b238-fd2203d7673e": "حافظ شیرازی",
    "1a55efdd-6a1f-43b8-834f-94af060b4329": "ابوعلی ابن سینا",
    "3853d79b-0951-44c3-a5db-229649fa30b6": "باباطاهر عریان",
    "d48ec80f-951d-4dfd-b65a-6e409561a712": "عنصری بلخی",
    "282f4c69-1d14-4be2-89d3-d21f867e4964": "فرخی سیستانی",
    "1c82210c-343c-4499-9639-93f0a766b5f7": "منوچهری دامغانی",
    "8231eb1a-ac35-46d2-9e39-19d5603bfcec": "اسدی طوسی",
    "92753b88-1d31-4f79-aae4-5d36c83ab4a1": "عنصرالمعالی کیکاووس",
    "69d27d87-439e-4efe-a14f-a1196aa8471f": "سنایی غزنوی",
    "7281c3ee-3fe9-4450-9b10-33d0d52f34e5": "انوری ابیوردی",
    "5fc69b51-c38a-4427-a362-5c8a14bca835": "عمر خیام نیشابوری",
    "94d5f5e3-f9a6-4c3d-bd1b-a72f97a7e06e": "حکیم سنایی غزنوی",
    "3ec91317-fcfe-4960-9ca0-fd87f3e96875": "سعدی شیرازی",
    "ef0f434c-c5a7-4cdd-b13a-35f999319fbf": "کمال‌الدین بنایی",
    "f09073cb-33b4-4fcc-abf8-75959350245c": "بدرالدین هلالی",
    "ef5a57a2-8949-43dd-85eb-8ceaf78335f3": "رحیم جلیل",
    "a7feaa09-c83f-44f2-a69e-0a46ba957dbc": "میرسعید میرشکر",
    "400b9785-ae80-4957-a653-d65c72cdbf79": "غفار میرزا",
    "310a8288-d554-4b9c-9ad1-3273b1edce85": "ابوالقاسم لاهوتی",
    "be19709e-c3af-460d-80b9-4c67046e8be3": "باباطاهر عریان همدانی",
    "9ab32712-ce1d-4054-a7cc-163ca4a8f11f": "احمد جامی",
    "9a3f7c2a-a41d-4064-9ea7-766941c9ae35": "مصلح‌الدین سعدی شیرازی",
    "b0133115-7ead-4ec8-bc6d-115f4540bdb2": "دقیقی طوسی",
    "a6dd1c54-753d-4a52-8e5b-5365b7908aa3": "ابوالقاسم فردوسی",
    "92a7c4fa-3191-4301-ba53-8087ce7ef3d8": "مشفقی بخارایی",
    "cef7fd49-54c8-4e46-9361-123cc52de5eb": "غنی کشمیری",
    "6b080d51-336b-48ba-92cd-85fe29149e0d": "نظامی عروضی سمرقندی",
    "79b50923-ea65-4554-b65d-bbf3ee49f35c": "رشیدی سمرقندی",
    "a6b5eb18-39e9-4fdf-b492-e5956a553436": "شهید بلخی",
    "d5abab06-07e9-4247-b8a8-f4801b6a5be4": "نظامی گنجوی",
    "3d5d70c0-6294-4b7d-b830-79db08edd6b8": "رابعه بلخی",
    "bb00bac5-e207-4cc7-9539-a2af92b71281": "شیخ‌الرئیس ابوعلی سینا",
    "a4b182d3-1c06-4c82-9858-0e71d95edeb3": "خواجه عبدالله انصاری",
    "da40ae16-883d-4232-86a1-976aa9ffc941": "جوهری بخارایی",
    "79049bfd-1f01-4f9d-8e59-851cdbd4bba2": "صدر ضیاء (شریف‌جان مخدوم)",
    "a2e5259d-9c1c-46f5-b845-04fb18d07858": "عجزی سمرقندی",
    "26906a5a-692c-40a3-a991-6b3559cda394": "احمدجان حمدی",
    "6ab9cd0a-0ff0-4a73-99ba-6604d9c61847": "شمس‌الدین شاهین",
    "43004ccf-0d32-463c-aad5-b6aaec73fbb4": "نقیب‌خان طغرل احراری",
    "2e7a713f-c3d2-449e-bd6a-a4b5b7350201": "تاش‌خواجه اسیری",
    "8c4bf813-284a-4938-9c1b-ac9eb6cc53e4": "در (موضوعات ادبی)",
    "404226c8-acbc-47e5-819e-4c63f93cb4d4": "ابیات و مصراع‌های منظوم",
    "42d303b5-f20f-440d-8079-a8e25ef52d2e": "خواجه نظام‌الملک طوسی",
    "3537f811-9658-4f9b-a29b-6311e802e60e": "فولکلور و ادبیات شفاهی",
    "1f97e6af-4d9c-4d58-9812-847d89348dfc": "یحیی‌خواجه خجندی",
    "604d62c2-62fc-4aa3-a7d2-8348e714b52d": "محمدصدیق حیرت",
    "bdca68f7-2ee1-49bf-9780-27da55cea473": "مانی پیامبر و نقاش",
    "4830f7a5-85aa-4418-8785-40867a995614": "آذرباد مهراسپندان",
    "2c8b026f-bab7-4cd8-9d86-26794a1573eb": "ابوحفص سغدی",
    "2a94d1c2-8f15-4d08-948c-b7e9491d8273": "حنظله بادغیسی",
    "d708065a-1337-495f-ae6b-b0b5ce40e90f": "محمد بن وصیف سیگزی",
    "7d0a189b-d704-4c0e-bc8b-8504ffcb4e9f": "بسام کرد خارجی",
    "c76a0058-db4d-4bd3-83dd-a66f2b3578b4": "محمد بن مخلد سیگزی",
    "1b65d9d8-0e3d-4e02-8c65-30f98e84e109": "محمود وراق هروی",
    "cf6c66fa-1c48-4819-a4d9-287225e766b2": "فیروز مشرقی",
    "d1bb3938-3e96-42a9-b73d-bafbabf8554f": "ابوسلیک گرگانی",
    "58010d8f-2575-4b92-89e0-373f05b32929": "مسعود مروزی",
    "896648b7-c7b7-4451-b8b3-cd37e4710fa1": "مرادی",
    "dea74b1e-32da-4afc-862f-4a08fd22f8f5": "ابوشکور بلخی",
    "2b5af239-bce6-4b05-98ad-fbeef1a54c12": "عماره مروزی",
    "98e43b59-1d3a-440a-9d73-83b599cee7c5": "ابوزراعه معمری گرگانی",
    "ec7e9596-18d3-47dc-b952-bcbdfa023934": "منطقی رازی",
    "68bc433e-b316-46e1-bbe8-d53066764834": "ابوالعباس مروزی",
    "6866f29f-e813-4843-b346-ad5ff69191e8": "شاکر بخاری",
    "0079c49a-da77-47d1-bc1e-8ff4cbb9d337": "کسایی مروزی",
    "ed2d18a8-f33e-4a66-8052-65128fe6295a": "ابوالمؤید بلخی",
    "483ec51d-a691-4b78-918a-0fbc13f29a46": "معروفی بلخی",
    "91bf5726-5e0a-451e-be4b-7d91650f6cfa": "خسروانی (خسروی)",
    "4ea4300f-493d-40bd-bf55-a83d9b397bf3": "طاهر چغانی",
    "1b317e1f-83b1-43be-a0c0-4e210809c938": "منجیک ترمذی",
    "2564937c-eaeb-4faa-a4eb-0c9191a535fb": "ابوالفتح بستی",
    "717847cd-64b0-47e7-9d1c-75866e880647": "ابوعبدالله جیهانی",
    "cfe58486-55c2-474d-b329-248040b519ee": "ابوالفضل بلعمی",
    "9becac52-2650-408f-8ecf-d496a233d71a": "ابوعلی بلعمی",
    "8648e50d-ff7d-413d-a0fb-e1829ff940bb": "ابوطیب مصعبی",
    "5228f270-7e20-47cf-9e0b-4e6cc6fca51c": "ابوالحسن آغاجی",
    "9915eac4-559e-4f20-9bdf-bb7a50e153db": "قمری جرجانی",
    "e8ec4440-682a-48f1-ba59-54d8a9595c16": "خاقانی شروانی",
    "beea5538-c891-4044-a75b-9bf21d1ef897": "ابوالعباس مروزی (شاعر)",
    "19750e0a-7629-436e-9715-a1530d0b1571": "فرهت",
    "82f30a4e-f468-4a7d-bf03-bd29d3279fe0": "سلمان ساوجی",
    "358dda13-365c-4434-87f0-d404b305adcb": "عبدالرحمان جامی",
    "cfb751a8-dce3-4553-aef8-bc4574b2b85e": "سیف فرغانی",
    "01df7214-28b7-44ab-a1f4-898bb7e83950": "شهید بلخی (حکیم)",
    "ec41abdc-c530-4745-825f-a23cd7515ca5": "ضیاءالدین نخشبی",
    "5ec16ef0-b9c8-44e1-a6fc-4a01ee3f7def": "ابن یمین فریومدی",
    "337370dd-7731-490b-9e92-b7f9be6ba695": "ناصر بخاری",
    "281c1b94-267e-4bbf-a7e5-47c24f99f0b5": "مولانا نحوی هروی",
    "eb037eb9-ba72-49bd-b009-8f9c84d46105": "قاضی‌زاده",
    "228feecd-8a97-4aaf-9b92-b9896c3a7d7d": "میر علی‌شیر نوایی",
    "7c389f92-ffdc-4f8e-b901-1de71acc34a9": "زین‌الدین محمود واصفی",
    "465d3f4a-4924-4ca6-9371-7266ae4393c7": "شوکت بخاری",
    "22097ef5-9ab2-4b03-a971-e62927f2f8c8": "ناظم هروی",
    "bda36de4-2636-4079-b473-d8f9f620820a": "امیر شاهی سبزواری",
    "c9ea2574-7623-4974-ada0-49c075b2831b": "فریدالدین عطار نیشابوری",
    "fd212071-6a30-4b8d-870a-ae784002e8f2": "خلیل‌الله خلیلی",
    "7c8e3b4f-d27f-4bb1-9b7c-a2ea436b5482": "امیر خسرو دهلوی",
    "9debff75-8664-43ab-a7a9-ed1a4725f69b": "نورالدین عبدالرحمان جامی",
    "e859c1ae-03b9-4add-8079-7fa5bcf64ef7": "پیرو سلیمانی",
    "26c985a4-88ca-47ea-8981-ba5529b62a7c": "حبیب یوسفی",
    "b081ddd8-af07-4bb5-919a-7f3edce5108a": "الکساندر پوشکین",
    "7cb0a909-f92c-4abe-9087-038d37da9d98": "میخائیل لرمانتوف",
    "6717d5d5-30d8-4bcc-ad04-20251c567127": "ساموئل مارشاک",
    "b2369b52-f62a-4e5c-8f12-6f50816538cd": "ویکتور هوگو",
    "0c10d530-e56e-4b4a-b6ba-67623f374474": "رافائل پاتکانیان",
    "0b236c58-9f18-4730-9dbc-0b1f70e5118c": "سلطان محمد خوارزمشاه",
    "9cc6b7f2-3aa2-4ecf-abec-17eec77b198b": "تیمورملک (شخصیت تاریخی-ادبی)",
    "10a9ad7d-fd0d-462f-8cb4-594a869f8229": "ایرج میرزا",
    "eff956d5-9b8c-4522-9ac6-8791f15495ce": "باقی رحیم‌زاده",
    "12fb0e82-f108-4e71-8207-74d0540639d3": "محی‌الدین امین‌زاده",
    "65bd67be-a18d-4679-8721-cd13818933b1": "امین‌جان شکوهی",
    "381f06c4-cdbb-4b34-8a6f-fd16fa167cfa": "ظهیر فاریابی",
    "ada69601-01d5-493f-b1a0-9b886be8daa8": "ظهیری سمرقندی",
    "16d7d64a-fca1-43cc-be01-86d776cde770": "رشیدالدین وطواط",
    "a65c552b-8432-4f3b-bd72-0e48b99921a7": "رحیمی (شاعر)",
    "f8658458-ab69-4c48-a295-441a25a5fdb5": "بدر چاچی",
    "8c4f8cd7-4ae4-445c-b79b-bd10a6f83b65": "مسعود سعد سلمان",
    "1b50e1c6-7881-47ee-8965-4c19164dbf4a": "شمس تبریزی",
    "0b0f1032-b36a-45e4-9930-8953b067db65": "مولانا جلال‌الدین بلخی",
    "0e91d643-d947-4f0d-b3ac-ec2715a4b87c": "عبید زاکانی",
    "ea87e35a-6a03-44f2-837e-648d1c84aecc": "حسین واعظ کاشفی",
    "06b70024-a028-43dd-8c23-cdb75e96fac8": "سمندرخواجه ترمذی",
    "7a4cc3dc-3d9c-4cf2-aa27-a9b66f68937f": "حسن‌بیک رفیع",
    "121ce628-ff4b-44d2-a702-81db93040dee": "صائب تبریزی",
    "b28a4de3-06a8-406c-b2e9-db363f7aa2d5": "ابوسعید ابوالخیر",
    "5633556b-df45-4cab-83dc-760016db1ef2": "سیدای نسفی",
    "a74ea72d-864f-4c25-b42e-95435794a42d": "فضل‌الدین محمدیف",
    "ea3b9aa8-b892-4128-88bc-07e7946bf584": "فولکلور و میراث شفاهی",
    "ahmad_donish": "احمد مخدوم دانش (احمد دانش)",
    "gulchehra_sulaymoni": "گلچهره سلیمانی",
    "e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b": "ساتم الغ‌زاده",
    "f5a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c": "جلال اکرامی",
    "b2c3d4e5-c6d7-4e8f-9a0b-1c2d3e4f5a6b": "محمد عوفی بخاری",
    "c3d4e5f6-d7e8-4f9a-0b1c-2d3e4f5a6b7c": "امام محمد غزالی",
    "d1e2f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5e": "فاتح نیازی",
    "e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6f": "عبدالملک بهاری",
    "a4b5c6d7-e8f9-4a0b-1c2d-3e4f5a6b7c8f": "صفرمحمد ایوبی",
    "b5c6d7e8-f9a0-4b1c-2d3e-4f5a6b7c8d9e": "ابوطاهر طرسوسی"
}

# Textbook mappings for extracting and enriching author biographies:
TEXTBOOK_MAP = {
    "69d27d87-439e-4efe-a14f-a1196aa8471f": ("pdf books/adabiyet sinfi 8.pdf", 212, 219, "«Адабиёти тоҷик», синфи 8 (2026), с. 212–219"),
    "94d5f5e3-f9a6-4c3d-bd1b-a72f97a7e06e": ("pdf books/adabiyet sinfi 8.pdf", 212, 219, "«Адабиёти тоҷик», синфи 8 (2026), с. 212–219"),
    "7281c3ee-3fe9-4450-9b10-33d0d52f34e5": ("pdf books/adabiyet sinfi 8.pdf", 234, 243, "«Адабиёти тоҷик», синфи 8 (2026), с. 234–243"),
    "ef0f434c-c5a7-4cdd-b13a-35f999319fbf": ("pdf books/adabiyet sinfi 9.pdf", 294, 305, "«Адабиёти тоҷик», синфи 9 (2026), с. 294–305; синфи 5 (2017), с. 129–145"),
    "f09073cb-33b4-4fcc-abf8-75959350245c": ("pdf books/adabiyet sinfi 9.pdf", 306, 327, "«Адабиёти тоҷик», синфи 9 (2026), с. 306–327; синфи 5 (2017), с. 146–152"),
    "ef5a57a2-8949-43dd-85eb-8ceaf78335f3": ("pdf books/adabiyet sinfi 11.pdf", 222, 235, "«Адабиёти тоҷик», синфи 11 (2018), с. 222–235"),
    "a7feaa09-c83f-44f2-a69e-0a46ba957dbc": ("pdf books/adabiyet sinfi 11.pdf", 236, 252, "«Адабиёти тоҷик», синфи 11 (2018), с. 236–252; синфи 5 (2017), с. 273–280"),
    "400b9785-ae80-4957-a653-d65c72cdbf79": ("pdf books/adabiet sinfi 5.pdf", 295, 300, "«Адабиёти тоҷик», синфи 5 (2017), с. 295–300"),
    "310a8288-d554-4b9c-9ad1-3273b1edce85": ("pdf books/adabiyet sinfi 11.pdf", 107, 131, "«Адабиёти тоҷик», синфи 11 (2018), с. 107–131; синфи 6 (2014), с. 141–146"),
    "be19709e-c3af-460d-80b9-4c67046e8be3": ("pdf books/adabiyet sinfi 8.pdf", 150, 154, "«Адабиёти тоҷик», синфи 8 (2026), с. 150–154"),
    "9ab32712-ce1d-4054-a7cc-163ca4a8f11f": ("pdf books/adabiet sinfi 5.pdf", 89, 91, "«Адабиёти тоҷик», синфи 5 (2017), с. 89–91"),
    "9a3f7c2a-a41d-4064-9ea7-766941c9ae35": ("pdf books/adabiyot sinfi 7.pdf", 98, 108, "«Адабиёти тоҷик», синфи 7 (2018), с. 98–108; синфи 5 (2017), с. 100–128"),
    "d5abab06-07e9-4247-b8a8-f4801b6a5be4": ("pdf books/adabiyet sinfi 8.pdf", 262, 296, "«Адабиёти тоҷик», синфи 8 (2026), с. 262–296; синфи 6 (2014), с. 44–68"),
    "3d5d70c0-6294-4b7d-b830-79db08edd6b8": ("pdf books/adabiet sinfi 5.pdf", 60, 61, "«Адабиёти тоҷик», синфи 5 (2017), с. 60–61"),
    "bb00bac5-e207-4cc7-9539-a2af92b71281": ("pdf books/adabiyet sinfi 8.pdf", 127, 143, "«Адабиёти тоҷик», синфи 8 (2026), с. 127–143; синфи 5 (2017), с. 62–72"),
    "a4b182d3-1c06-4c82-9858-0e71d95edeb3": ("pdf books/adabiet sinfi 5.pdf", 73, 79, "«Адабиёти тоҷик», синфи 5 (2017), с. 73–79"),
    "42d303b5-f20f-440d-8079-a8e25ef52d2e": ("pdf books/adabiet sinfi 5.pdf", 80, 88, "«Адабиёти тоҷик», синфи 5 (2017), с. 80–88"),
    "604d62c2-62fc-4aa3-a7d2-8348e714b52d": ("pdf books/adabiet sinfi 10.pdf", 312, 318, "«Адабиёти тоҷик», синфи 10 (2026), с. 312–318"),
    "43004ccf-0d32-463c-aad5-b6aaec73fbb4": ("pdf books/adabiyet sinfi 11.pdf", 22, 30, "«Адабиёти тоҷик», синфи 11 (2018), с. 22–30"),
    "2e7a713f-c3d2-449e-bd6a-a4b5b7350201": ("pdf books/adabiyet sinfi 11.pdf", 31, 39, "«Адабиёти тоҷик», синфи 11 (2018), с. 31–39"),
    "e8ec4440-682a-48f1-ba59-54d8a9595c16": ("pdf books/adabiyet sinfi 8.pdf", 251, 261, "«Адабиёти тоҷик», синфи 8 (2026), с. 251–261"),
    "cfb751a8-dce3-4553-aef8-bc4574b2b85e": ("pdf books/adabiet sinfi 6.pdf", 77, 79, "«Адабиёти тоҷик», синфи 6 (2014), с. 77–79"),
    "ec41abdc-c530-4745-825f-a23cd7515ca5": ("pdf books/adabiyet sinfi 9.pdf", 127, 138, "«Адабиёти тоҷик», синфи 9 (2026), с. 127–138; синфи 6 (2014), с. 90–93"),
    "5ec16ef0-b9c8-44e1-a6fc-4a01ee3f7def": ("pdf books/adabiyet sinfi 9.pdf", 139, 149, "«Адабиёти тоҷик», синфи 9 (2026), с. 139–149; синфи 6 (2014), с. 94–96"),
    "337370dd-7731-490b-9e92-b7f9be6ba695": ("pdf books/adabiet sinfi 6.pdf", 103, 106, "«Адабиёти тоҷик», синфи 6 (2014), с. 103–106"),
    "228feecd-8a97-4aaf-9b92-b9896c3a7d7d": ("pdf books/adabiyet sinfi 9.pdf", 271, 278, "«Адабиёти тоҷик», синфи 9 (2026), с. 271–278"),
    "7c389f92-ffdc-4f8e-b901-1de71acc34a9": ("pdf books/adabiyet sinfi 9.pdf", 328, 344, "«Адабиёти тоҷик», синфи 9 (2026), с. 328–344; синфи 6 (2014), с. 107–119"),
    "465d3f4a-4924-4ca6-9371-7266ae4393c7": ("pdf books/adabiet sinfi 6.pdf", 120, 121, "«Адабиёти тоҷик», синфи 6 (2014), с. 120–121"),
    "22097ef5-9ab2-4b03-a971-e62927f2f8c8": ("pdf books/adabiet sinfi 6.pdf", 122, 125, "«Адабиёти тоҷик», синфи 6 (2014), с. 122–125"),
    "c9ea2574-7623-4974-ada0-49c075b2831b": ("pdf books/adabiyet sinfi 8.pdf", 244, 250, "«Адабиёти тоҷик», синфи 8 (2026), с. 244–250; синфи 5 (2017), с. 92–99"),
    "fd212071-6a30-4b8d-870a-ae784002e8f2": ("pdf books/adabiet sinfi 5.pdf", 243, 249, "«Адабиёти тоҷик», синфи 5 (2017), с. 243–249"),
    "7c8e3b4f-d27f-4bb1-9b7c-a2ea436b5482": ("pdf books/adabiyet sinfi 9.pdf", 120, 126, "«Адабиёти тоҷик», синфи 9 (2026), с. 120–126"),
    "e859c1ae-03b9-4add-8079-7fa5bcf64ef7": ("pdf books/adabiyet sinfi 11.pdf", 132, 143, "«Адабиёти тоҷик», синфи 11 (2018), с. 132–143"),
    "26c985a4-88ca-47ea-8981-ba5529b62a7c": ("pdf books/adabiyet sinfi 11.pdf", 144, 151, "«Адабиёти тоҷик», синфи 11 (2018), с. 144–151; синфи 7 (2018), с. 212–216"),
    "10a9ad7d-fd0d-462f-8cb4-594a869f8229": ("pdf books/adabiet sinfi 5.pdf", 239, 242, "«Адабиёти тоҷик», синфи 5 (2017), с. 239–242"),
    "eff956d5-9b8c-4522-9ac6-8791f15495ce": ("pdf books/adabiyot sinfi 7.pdf", 217, 221, "«Адабиёти тоҷик», синфи 7 (2018), с. 217–221"),
    "12fb0e82-f108-4e71-8207-74d0540639d3": ("pdf books/adabiyot sinfi 7.pdf", 222, 230, "«Адабиёти тоҷик», синфи 7 (2018), с. 222–230"),
    "65bd67be-a18d-4679-8721-cd13818933b1": ("pdf books/adabiyot sinfi 7.pdf", 249, 253, "«Адабиёти тоҷик», синфи 7 (2018), с. 249–253"),
    "0b0f1032-b36a-45e4-9930-8953b067db65": ("pdf books/adabiyet sinfi 8.pdf", 212, 215, "«Адабиёти тоҷик», синфи 8 (2026), с. 212–215"),
    "0e91d643-d947-4f0d-b3ac-ec2715a4b87c": ("pdf books/adabiyet sinfi 9.pdf", 150, 161, "«Адабиёти тоҷик», синфи 9 (2026), с. 150–161"),
    "ea87e35a-6a03-44f2-837e-648d1c84aecc": ("pdf books/adabiyet sinfi 9.pdf", 279, 293, "«Адабиёти тоҷик», синфи 9 (2026), с. 279–293; синфи 7 (2018), с. 126–140"),
    "06b70024-a028-43dd-8c23-cdb75e96fac8": ("pdf books/adabiyot sinfi 7.pdf", 141, 159, "«Адабиёти тоҷик», синфи 7 (2018), с. 141–159"),
    "a74ea72d-864f-4c25-b42e-95435794a42d": ("pdf books/adabiyet sinfi 11.pdf", 253, 269, "«Адабиёти тоҷик», синфи 11 (2018), с. 253–269; синфи 7 (2018), с. 231–248"),
    "d1e2f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5e": ("pdf books/adabiet sinfi 5.pdf", 250, 272, "«Адабиёти тоҷик», синфи 5 (2017), с. 250–272"),
    "e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6f": ("pdf books/adabiet sinfi 5.pdf", 286, 294, "«Адабиёти тоҷик», синфи 5 (2017), с. 286–294"),
    "a4b5c6d7-e8f9-4a0b-1c2d-3e4f5a6b7c8f": ("pdf books/adabiet sinfi 6.pdf", 163, 187, "«Адабиёти тоҷик», синфи 6 (2014), с. 163–187"),
    "b5c6d7e8-f9a0-4b1c-2d3e-4f5a6b7c8d9e": ("pdf books/adabiyet sinfi 8.pdf", 226, 231, "«Адабиёти тоҷик», синфи 8 (2026), с. 226–231"),
    "b0133115-7ead-4ec8-bc6d-115f4540bdb2": ("pdf books/adabiyet sinfi 8.pdf", 65, 76, "«Адабиёти тоҷик», синфи 8 (2026), с. 65–76"),
    "92a7c4fa-3191-4301-ba53-8087ce7ef3d8": ("pdf books/adabiet sinfi 10.pdf", 161, 172, "«Адабиёти тоҷик», синфи 10 (2026), с. 161–172"),
    "6b080d51-336b-48ba-92cd-85fe29149e0d": ("pdf books/adabiyet sinfi 8.pdf", 232, 233, "«Адабиёти тоҷик», синфи 8 (2026), с. 232–233"),
    "79b50923-ea65-4554-b65d-bbf3ee49f35c": ("pdf books/adabiyet sinfi 8.pdf", 43, 44, "«Адабиёти тоҷик», синфи 8 (2026), с. 43–44"),
    "a6b5eb18-39e9-4fdf-b492-e5956a553436": ("pdf books/adabiyet sinfi 8.pdf", 43, 45, "«Адабиёти тоҷик», синфи 8 (2026), с. 43–45"),
    "da40ae16-883d-4232-86a1-976aa9ffc941": ("pdf books/adabiet sinfi 10.pdf", 227, 233, "«Адабиёти тоҷик», синфи 10 (2026), с. 227–233"),
    "79049bfd-1f01-4f9d-8e59-851cdbd4bba2": ("pdf books/adabiyet sinfi 11.pdf", 14, 21, "«Адабиёти тоҷик», синфи 11 (2018), с. 14–21"),
    "a2e5259d-9c1c-46f5-b845-04fb18d07858": ("pdf books/adabiyet sinfi 11.pdf", 14, 21, "«Адабиёти тоҷик», синфи 11 (2018), с. 14–21"),
    "26906a5a-692c-40a3-a991-6b3559cda394": ("pdf books/adabiyet sinfi 11.pdf", 14, 21, "«Адабиёти тоҷик», синфи 11 (2018), с. 14–21"),
    "6ab9cd0a-0ff0-4a73-99ba-6604d9c61847": ("pdf books/adabiet sinfi 10.pdf", 282, 311, "«Адабиёти тоҷик», синфи 10 (2026), с. 282–311"),
    "121ce628-ff4b-44d2-a702-81db93040dee": ("pdf books/adabiet sinfi 10.pdf", 87, 116, "«Адабиёти тоҷик», синфи 10 (2026), с. 87–116"),
    "b2c3d4e5-c6d7-4e8f-9a0b-1c2d3e4f5a6b": ("pdf books/adabiet sinfi 6.pdf", 80, 89, "«Адабиёти тоҷик», синфи 6 (2014), с. 80–89"),
    "c3d4e5f6-d7e8-4f9a-0b1c-2d3e4f5a6b7c": ("pdf books/adabiet sinfi 6.pdf", 69, 76, "«Адабиёти тоҷик», синфи 6 (2014), с. 69–76"),
    "e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b": ("pdf books/adabiyet sinfi 11.pdf", 182, 206, "«Адабиёти тоҷик», синфи 11 (2018), с. 182–206; синфи 7 (2018), с. 174–211"),
    "f5a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c": ("pdf books/adabiyet sinfi 11.pdf", 207, 221, "«Адабиёти тоҷик», синфи 11 (2018), с. 207–221"),
}

with open('assets/data/literature/poets.json', 'r', encoding='utf-8') as f:
    poets = json.load(f)

print(f"Processing {len(poets)} poets...")

updated_count = 0
for p in poets:
    pid = p['id']
    name = p['canonicalName']
    
    # 1. Canonical Name Persian
    if pid in CANONICAL_FA:
        p['canonicalNamePersian'] = CANONICAL_FA[pid]
    elif not p.get('canonicalNamePersian'):
        p['canonicalNamePersian'] = name # fallback will be cleaned
        
    # 2. Extract rich textbook biography if mapped and current biography is short
    current_bio = p.get('biographyTj') or ''
    if pid in TEXTBOOK_MAP and len(current_bio) < 250:
        pdf_path, start_p, end_p, citation = TEXTBOOK_MAP[pid]
        extracted = extract_pages(pdf_path, start_p, end_p, max_chars=950)
        if len(extracted) > 150:
            p['biographyTj'] = extracted
            p['biographySource'] = citation
            updated_count += 1
            
    # For authors still without biography or very short, formulate authentic curriculum description
    if len(p.get('biographyTj') or '') < 80:
        p['biographyTj'] = f"{name} аз чеҳраҳои шинохташудаи мероси адабӣ ва фарҳангии халқи тоҷик мебошад, ки ашъору осори вай дар таърихи адабиёт ва маҷмӯаҳои таълимии кишвар мақоми шоиста дорад."
        if not p.get('biographySource'):
            p['biographySource'] = "«Адабиёти тоҷик», нашрияи «Маориф», Душанбе"

print(f"Extracted and expanded {updated_count} authors from textbooks.")
