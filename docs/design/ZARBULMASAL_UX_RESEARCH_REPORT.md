# Зарбулмасал — UX + Visual Design Research Report

Research date: 24 September 2026 · **v2**: premium reference set and bold directions (§5–§8, §12)
Subject: the web build in the current workspace (`build/web`, version 2.0.0+2004, branch `provenance-repair-2026-09-19`, HEAD `259d17f`), served read-only from a scratchpad symlink.
Scope: research and design planning only. No project files were changed.

Evidence images are in `evidence/`. Labels such as **[A1]** refer to panels inside those images.

Labels used throughout:
- **OBSERVED**: seen directly in the rendered app, the project docs, or an external product.
- **INFERRED**: an interpretation of observed evidence.
- **UNKNOWN**: the available evidence does not settle it.
- **CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED**: something in the source content may be wrong. I have not corrected it.

---

## EXECUTIVE RECOMMENDATION

Зарбулмасал should feel like **a private gallery of the Tajik word**: an unmistakably premium, calm place to read Tajik poems, proverbs, and history, where the source behind every text is visible but never noisy. The team has already done the hard part. Every visible poem, proverb, and history section carries a citation. Sources are compared against second copies ("witnesses"), and unapproved material is held back. The interface does not yet match that standard. The poem reader doesn't group lines into couplets (bayts), and lines wrap mid-hemistich on phones. When a poem ends, there is nowhere to go next. Resuming reading sends people to the wrong place. On desktop, the app is a phone layout stretched to a column of about 730 px.

**The highest-impact problem is trust, not decoration.** One poem shows a green "Матн санҷида шудааст" (text verified) badge. Its own source panel lists three unchecked steps: line-by-line collation, orthography, and copyright **[D3]**. A page-scan tile with a check mark says "tap to view and enlarge", then opens "page image not available". The provenance panel also shows raw English enum values ("Tier A", "minor-variant", "exact"), an English policy sentence, a reviewer hash, and an internal repository file path (`docs/literature/pdfs/adabiet sinfi 5.pdf`). A related problem is the reading-script control. On a proverb page it silently switches the **whole interface** to Persian script and right-to-left layout. In the poem reader, the same kind of control changes only the poem text **[E1–E3]**. Readers can't tell what has been verified, or which script mode they are in.

**Recommended direction (v2): «Муҳр / The Seal» — a private gallery of the word.** The base is ivory paper, monumental type, and one vermilion seal pressed beside every verified text. The seal is where the product's credibility becomes its identity, and it directly fixes the contradictory "verified" signals. Night mode («Шаб») becomes **lapis-black**. Collections, eras, and grades wear **procedurally generated ikat covers** («Атлас»), which no literary product I found uses. Saved becomes **«Баёзи ман»**, a personal anthology (Баёз). References are now chosen for taste rather than category: Letterform Archive, MUBI, Lapham's Quarterly, Rijksmuseum, Assouline, Taschen, and Are.na (§5). The functional fixes still come first: provenance truthfulness, verse layout, the script model, one clear information architecture, and resume. The premium layer is how those fixes should *look and feel*.

---

## 1. PRODUCT UNDERSTANDING

### What it is (OBSERVED)
A Flutter web app and installable PWA (Android distribution is currently withheld, per README) with no account. It bundles a Tajik cultural corpus for reading and learning:

| Area | What the rendered app shows |
|---|---|
| Proverbs (Зарбулмасалҳо) | 150 proverbs in Settings, the flashcard filter, and the proverb list header ("Дар ганҷина / 150"). The README says 149. Each detail page has meaning, a simple explanation, an example, and a source, plus the Persian-script form. 20 categories ("Гурӯҳҳо"), 6 levels, and a daily proverb. |
| Literature (Мероси адабӣ) | A hub with a "bayt of the day", selected poems, and a numbered index. A poets list (the hub says 145 poets), poet dossiers (portrait, biography, source citation, era, links to history, verified works plus a collapsed count of records under review), a works list (hub: 28 works), a poem reader, and a source panel. |
| School canon (Барномаи мактабӣ) | Works and authors by grade (5–11), each with a textbook citation (hub: 77 works). |
| Oral heritage (Мероси шифоҳӣ) | Filter chips over an **empty** list. The hub marks this section as "coming". |
| History (Таърихи халқи тоҷик) | Textbook carousel (grades 5–11), mode tabs (timeline / textbooks / topics), era chips, and entry cards. Each entry opens a bottom sheet, then a full long-form page with printed page numbers per section. |
| Library (Китобхона) | 28 external books from two providers (Kitobkhon; Khirad shows "— китоб · — муаллиф"). The detail page links out to read and shows a rights warning. |
| Lexicon (Луғатнома) | 379 term entries with category filters. |
| Learning | Levels, a 5-question multiple-choice quiz with explanations, and flashcards (sessions of 15) with "Again / Learning / Mastered" rating. |
| Personal | Saved items plus a "Recent activity" list on the Saved tab, and a "Continue reading" card on Home. |
| Settings | Theme (system/light/dark), app text size with a live sample, poem text size, line spacing, reading mode (standard / parallel), interface language (Tajik Cyrillic / Persian script), clear history, replay the tour, about, about sources, and feedback via Telegram. |

### Apparent audience (INFERRED)
1. **Tajik school students (grades 5–11) and their teachers.** Strong signals: textbook-grade carousels in History and School canon, citations to Ministry of Education textbooks, and a learning tab.
2. **Adult Tajik readers and the diaspora** looking for poems, proverbs, and national history offline.
3. **Persian-script readers** (Iran and Afghanistan, or Tajiks learning the Perso-Arabic script). There is a full Persian-script interface, and Persian forms of proverbs are shown by default.
4. **Researchers and editors** are a secondary audience. The dense provenance layer (witnesses, collation, rights) seems aimed at scholarly credibility.

UNKNOWN: real usage mix, device mix, literacy in each script, and whether students use it in class or at home. There are no analytics in the workspace.

### Main user needs (INFERRED from the content and features)
- Read a poem or proverb comfortably, in the right script, and understand it.
- Look up a specific poet, poem, proverb, historical period, or term.
- Study for class by grade and textbook.
- Trust that a text is authentic and correctly attributed.
- Come back to something they were reading or saved.
- Practise and remember proverbs without pressure.

### Key assumptions
- The workspace build is the product under review. The live GitHub Pages site is an older deployment (per `docs/QA_AUDIT.md`), and its `main.dart.js` differs in size from the local build. I did not do a full walkthrough of the live site.
- Tajik Cyrillic is the primary interface language. It is the default, and Persian is opt-in.

### Unknowns
- Whether the Persian-script text of poems and proverbs is meant as a *reading text* or a *script-learning aid*. The data notes call the poem renderings "mechanical Tajik Cyrillic to Persian-script representation; not a Persian source". See the content flag in §3.
- Whether all 67 portraits may be displayed (the audit says rights are "unknown" for all of them).
- The release timeline for Oral heritage.
- Whether accounts or sync are planned. Nothing suggests they are.

---

## 2. EXPERIENCE INVENTORY

### Screens and routes inspected in the rendered app
Home `/` · first-run tour (4 steps) · Explore `/explore` · Learn `/learn` · Saved `/saved` (empty and populated) · Global search `/search` (idle, results, no results) · Daily proverb `/daily` · Proverbs list `/proverbs` (level chips, search, category filter, no-results state) · Proverb detail `/proverb/:id` (Tajik and Persian script) · Categories `/categories` · Levels `/levels` · Quiz `/quiz` (question and answered feedback) · Flashcards `/flashcards` (front and back) · Literature hub `/literature` (loading and loaded) · Poets list `/literature/poets` · Poet dossier `/literature/poet/rudaki` · Works list `/literature/works` · Poem reader `/literature/work/:id` (100% and 120% text, Tajik and Persian interface, dark and light) · Source panel (Rudaki and Saadi works) · Page-image viewer (not-available state) · Literature search `/literature/search` (idle suggestions) · School canon `/literature/school` · Oral heritage `/literature/oral` (empty) · History `/history` · History entry sheet and full page `/history/empire-med` · Library `/books` · Book detail `/books/badi-boron` · Lexicon `/vocabulary` · Settings `/settings` (Tajik and Persian) · Route-not-found page · Cold-start splash.

### Major flows followed (by tapping through, not by URL)
See §4.

### Mobile coverage
375×812 (in-app browser pane, dark theme following the pane) and 390×844 @2x (Playwright, light and dark). Every screen above was seen at phone width.

### Desktop coverage
1440×900 for Home, Explore, Learn, Saved, Poets, Poet dossier, Works, Reader, History, History entry, Library, Book detail, Proverbs, Proverb detail, School canon, Settings, and the others in the capture set. All were captured headless. I also inspected Home interactively in the pane at 1440.

### Not seen or not accessible
- **Vocabulary detail** `/vocabulary/:id`: entries in `words.json` have no `id` field, so I couldn't construct the route. I didn't tap into an entry.
- **Book category and author routes** (`/books/category/:id`, `/books/author/:id`): not visited.
- **Favorites** `/favorites` (a legacy route alongside Saved) and **Literature search results**: only the idle state was seen.
- **Parallel reading mode with a Persian-source text**: no displayable work showed a parallel layout in my session (see §3).
- **Offline/PWA install, native Android, screen readers, 200% text scaling**: not tested.
- **Quiz results screen**: I answered one question and didn't finish a run.
- **Live production site**: only its version file and bundle headers were checked.

---

## 3. CURRENT EXPERIENCE AUDIT

### 3.1 Strengths to preserve

| # | Strength | Evidence (OBSERVED) |
|---|---|---|
| S1 | **Provenance is real, not cosmetic.** Textbook title, authors, publisher, year, page, ISBN, second-witness collation, and variant notes. History long-form sections end with "Саҳифаи чопӣ 124 (PDF 124)". | [D2], history full page (pane) |
| S2 | **Editorial proverb page.** Large serif proverb, a short rule, the Persian-script line, and numbered sections ("01 / Маъно", "02 / Шарҳи оддӣ", "03 / Мисол"), then the source. | [E1] |
| S3 | **The Literature hub already reads like a journal.** Eyebrow labels, a "bayt of the day", and a numbered index of sections with counts. | [B3], pane |
| S4 | **Search tolerates missing diacritics.** "рудаки" finds "Рӯдакӣ" and results are grouped by type (poets, works, proverbs, history). | pane |
| S5 | **Calm learning.** No streaks, points, or pressure. The quiz explains the answer, and flashcards use honest three-way rating. | [G2], pane |
| S6 | **Links between areas.** A poet's "Ҷаҳони ӯро бишносед" chips link to history entries (Samanids, Nasr II, Ismail Somoni). Book detail links to the author's dossier. | pane, [H2] |
| S7 | **Complete app shell.** Branded 404 with a way home, empty states for Saved and Recent, skippable 4-step tour, dark theme with good contrast, and correctly mirrored chevrons in the Persian interface. | [I1], [G3], pane |
| S8 | **Honest external-book handling.** "Read on Kitobkhon" goes out to the provider, with "Republication rights unclear" stated plainly. | [H2] |
| S9 | **Live preview in Settings.** The text-size control shows a sample proverb. | pane |

### 3.2 Key friction (ranked by user impact)

**F1. The verification status contradicts itself, and internal data leaks into the provenance panel.** (Critical: it undermines the product's main differentiator.)
- OBSERVED: The Saadi work header shows a green "✓ Матн санҷида шудааст" (Text verified). Its source panel's "Editorial checks" section is marked "Дар баррасӣ" (Under review), with three unchecked items: line-by-line collation, orthography/script, and copyright **[D3]**.
- OBSERVED: The "Тасвири аслии саҳифаи китоб" tile shows a green check and "tap to view and enlarge". Tapping it opens a black viewer that says "Тасвири саҳифа дастрас нест" (Page image not available) **[D2]**, pane. The header chip "Тасвири саҳифа" looks disabled (low-contrast green on dark).
- OBSERVED: Untranslated tokens in a Tajik interface: "(Tier A)", "minor-variant", "exact"; an English sentence "Zarbulmasal source-attested publication policy: exact text attributed in the checked source at page 111."; legal basis shown as `docs/literature/pdfs/adabiet sinfi 5.pdf`; reviewer shown as `f81cb8fdce2d1797`.
- IMPLICATION: A reader can't tell what "verified" means. The panel looks like debug output, and the mismatches invite doubt about the very thing the product does best.

**F2. Poetry is set as prose lines, not verse.** (High: this is the core reading task.)
- OBSERVED: Hemistichs are stacked with equal leading and no gap between bayts. At 375 px, lines such as "Оби Ҷайҳун аз нишоти рӯйи / дӯст" wrap mid-hemistich with no hanging indent. At 120% text, almost every hemistich wraps and the couplet structure disappears (pane). On desktop the poem sits in the left half of a column about 730 px wide with empty space around it **[D4]**.
- OBSERVED: After the last line there is no next or previous poem, no "more by Rudaki", and no "back to the collection" link. The page just ends.
- REFERENCE: Ganjoor groups each bayt with a divider, stacks hemistichs on mobile, places them side by side at 1440 px, and ends with previous/next poem titles.

**F3. One word, "script", means two different things.** (High for Persian-script readers, and confusing for everyone.)
- OBSERVED: On a proverb page, the "Хатти хониш" chips (Tajik Cyrillic / Persian) switch the **entire app** to the Persian-script interface in right-to-left layout. The tab bar, settings, and Home all change **[E1→E2]**. The explanations stay in Cyrillic and are labelled "توضیح تاجیکی (خط سیریلیک)", left-aligned inside a right-to-left page.
- OBSERVED: In the poem reader, script chips only appear when the interface is already Persian, and they change only the poem text **[E3]**.
- OBSERVED: I set Settings → "Reading mode: Parallel (two-script)". The Khayyam and Saadi poems I then opened in the Tajik interface still showed only Cyrillic, with no explanation.
- IMPLICATION: Users can get stuck in an interface they didn't choose, and can't predict what a control will do.

**F4. The information architecture overlaps and has dead ends.** (High.)
- OBSERVED: The same destinations appear through three different visual languages. Home has 4 tiles. Explore has 10 bordered rows. The Literature hub has a numbered 00–06 index. Learn also repeats "School literature" and "Lexicon" **[B1–B3]**.
- OBSERVED: Explore contains "Маркази мероси адабӣ" (Literary heritage centre) as a sibling of the literature subsections it contains.
- OBSERVED: "Мероси шифоҳӣ" (Oral heritage) is active in Explore and opens an empty page reading "Oral heritage not found — no items for this filter" **[G1]**. The hub shows the same item as disabled with an hourglass.
- OBSERVED: "Луғатнома" sits under no section heading in Explore.
- OBSERVED: Numbered eyebrows collide. School canon, Oral heritage, and Levels are all "03 / …". History is "04". The number carries no meaning for users.

**F5. Resuming sends people to the wrong place.** (High for returning readers.)
- OBSERVED: I read Rudaki's poem, went back to his dossier, then opened Home. "Идомаи хондан" (Continue reading) showed **Rudaki (the poet page)**, not the poem, because visiting the dossier via Back was logged as the most recent activity.
- OBSERVED: The first-run tour promises "Continue reading" on Home before anything has been read, and the card is missing on first launch.
- OBSERVED: Recent activity rows show long raw era strings as subtitles (for example "Асрҳои IX–X (Даврае тиллоии тамаддуни форсу тоҷик) | Давлати Сомониён (аҳди амирон Исмоили Сомонӣ, …)").
- OBSERVED: The Continue card is a saturated burgundy block, the loudest element on Home (pane session, mobile and desktop).

**F6. The desktop layout is a stretched phone.** (Medium–High for teachers and classroom projection.)
- OBSERVED: All screens are a single centred column about 730 px wide. The mobile bottom tab bar is still used at 1440 px **[A2]**. Pushed screens (poet, reader, history…) **drop the tab bar** entirely, leaving only a back arrow.
- OBSERVED: Type is *smaller* on desktop than on mobile. The Home proverb is about 24 px at 1440 compared with about 28 px at 390.
- OBSERVED: Horizontal carousels (history textbooks, era chips, selected poems) are cut off at the column edge. Mouse users get no scroll cue **[F2]**.

**F7. Search is capable but hard to scan, and field chrome leaks.** (Medium.)
- OBSERVED: Every inline search field shows a character counter "0/256" under it (poets, proverbs, books, history, global search). On the poets list it sits where a result count would be and reads like "0 of 256" **[C1]**. On global search the counter is clipped under the field.
- OBSERVED: Poet results use the raw era text as a subtitle, up to four lines each ("бухоро" returned 17 poets, many matched only through era text). Matched terms are not highlighted.
- OBSERVED: "бухоро" returned poets and history but no poems, although Rudaki's displayed poem contains "Бухоро" several times. Searching "мулиён" found the poem by its title or first line. INFERRED: poem body text isn't searched.
- OBSERVED: The no-results state shows only "No content found for «…»", with no suggestions, spelling help, or scope switch.

**F8. History puts heavy controls before any content.** (Medium.)
- OBSERVED: On mobile, the first entry begins about 85% down the first screen, below the title, a search field with "0/256", a textbook carousel, three mode tabs, and era chips **[F1]**.
- OBSERVED: An entry opens first as a full-height sheet, then "Саҳифаи пурраи таърихӣ" opens a full page that repeats the same header block. There is no previous or next period at the end of either.
- REFERENCE: Met Heilbrunn period pages end with "Primary chronology" links to the adjacent periods, and separate "Overview / Key Events / Citation".

**F9. Small interaction breaks in Learn and Proverbs.** (Medium–Low.)
- OBSERVED: After answering a quiz question on mobile, "Correct. Well done!", the explanation, and "Next question" are all below the fold. The user has to scroll to see feedback.
- OBSERVED: The flashcard back cuts off the explanation inside the fixed card height.
- OBSERVED: "All (150)" sits next to "Card 1 of 15" with no explanation of the session size.
- OBSERVED: On proverb and daily pages, tag chips ("Сабр", "Саводи 4", "Анъанавӣ") look tappable but do nothing.
- OBSERVED: Levels 01, 02, and 03 contain 1, 22, and 50 proverbs. Every level row shows the same "Оғоз" (Start) label.
- OBSERVED: The level filter on the proverb list is "Ҳама 01 02 03 04 05 06". Nothing names the levels.

**F10. Too many cards.** (Medium, visual.)
- OBSERVED: `DESIGN.md` says "No Card Soup: avoid nested rounded containers". The rendered app still uses bordered rounded boxes for Explore rows, Home tiles, Learn tiles, History entries, book metadata (5 separate tiles), the Saved empty state, and the history long-form (a text section inside a bordered card inside the page). Only the Literature hub and proverb pages use rules and whitespace.
- INFERRED: The card use is the main reason the app reads as "generic Material" rather than the "literary journal" described in its own design doc.

### 3.3 Missed opportunities
- **Meaning of a line**: Poems have no glosses and no link to the 379-entry Lexicon, even though the Lexicon cites the same textbooks.
- **Couplet-level actions**: Copy, share, and save apply to a whole poem or proverb. Quran.com and Ganjoor both act per verse or bayt.
- **A daily ritual without pressure**: Home has a proverb of the day and the hub has a bayt of the day, but neither has "previous days". Poetry Foundation lists earlier Poems of the Day under today's.
- **Period context**: History entries and poet eras use the same periods but don't link to each other symmetrically. A period page could list its poets.
- **Teacher use**: Nothing is built for projection or printing.

### 3.4 CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED
1. **Persian-script poem text.** In the Persian interface, Saadi's "بنی‌آدم اعضای یکدیگرند" has a title in conventional Persian spelling. The body shows forms that look like machine transliteration of the Cyrillic, for example "یاکدیگرند", "اوزوی", "اوزوهارا", and "تو ک-از می‌هنتی" **[E3]**. Rudaki's "گر بر سر نفس خود امیری، مردی" shows a similar pattern ("نوکته", "فیتادرا"). `runtime_works.json` notes say "Mechanical Tajik Cyrillic to Persian-script representation; not a Persian source". I saw no label on the reading surface that says so. *UX consequence*: Persian-script readers may take a generated rendering for an authoritative text. I have not assessed or corrected the spellings.
2. **Proverb count**: README says 149, while the app shows 150 in several places.
3. **Proverb source lines** such as "Баёзи фолклори тоҷик. Ҷилди 2" appear without page numbers, while poems and history carry pages. This may be deliberate. Please verify.
4. **Poet counts**: the hub says "145 poets", README says 159 catalogued (145 public). The poets list shows no count at all (only "0/256").
5. **Status wording**: "Text verified" vs "Editorial checks: under review" on the same work. Is that a content state or a display rule? See F1.

---

## 4. KEY USER JOURNEYS (actually walked)

1. **First visit → orientation**: Load → 4-step tour (Home → Explore → Learn → Saved) → "Ok!" → Home. *Verified.* The tour highlights tabs without opening them. Step 1 promises "Continue reading", which doesn't exist yet.
2. **Daily proverb**: Home → "Бихонед" on the proverb of the day → daily page (meaning, explanation, example, source) → tap tag "Сабр" (nothing happens) → Back. *Verified dead end.*
3. **Poet → poem → source → save**: Explore → Poets → Rudaki → scroll biography, source, era, history chips → "Бӯйи Ҷӯйи Мулиён" → read → A+ ×2 (verse breaks up) → "Манбаъ" → tap page-scan tile ("not available") → close → bookmark. *Verified.*
4. **Return**: Back ×2 → Saved (poem listed under Saved and Recent) → Home ("Continue reading" = Rudaki **poet page**, not the poem). *Verified.*
5. **Learn**: Learn → Quiz → pick answer (feedback below the fold) → scroll → explanation. Flashcards → tap to reveal (text clipped) → rating buttons visible. *Verified to the first answer only.*
6. **Proverb finding**: Explore → Browse all → type "модар" (8 results, counter "5/256") → type gibberish (empty state, "Clear") → Categories → "Сабр" (4 results, filter chip) → proverb detail. *Verified.*
7. **Global search**: Home search field → /search → "рудаки" (poets + history) → "бухоро" (17 poets + 6 history, no poems) → "мулиён" (1 work) → "меҳмон" (1 poet + 3 proverbs) → nonsense string (no-results state). *Verified.*
8. **Script switch**: Proverb detail → tap "فارسی (عربی)" → whole app becomes Persian and right-to-left → Home in Persian → Settings → pick Tajik to return. *Verified.*
9. **History**: /history → era card "Давлати Мод" → sheet → "Full page" → long-form with printed pages → end (no next era). *Verified.*
10. **Library**: /books → "Баъди борон" → detail (external read CTA, rights note, author link). *Verified. I didn't follow the external link.*

---

## 5. REFERENCE GALLERY (v2 — premium and design-led)

> **Revision note (v2).** The first reference set (Ganjoor, Sefaria, Quran.com, Wikisource, Poetry Foundation, the Met timeline, Standard Ebooks) was functionally relevant but visually conventional. It is now kept only as a *functional benchmark* in the appendix, for interaction patterns such as bayt layout and prev/next. The references below were chosen for **taste**: products where arriving *feels* expensive, deliberate, and unlike anything else in the category. None of them is a literature app, and that is deliberate. The aim is a Tajik heritage product that feels like a private gallery or a luxury publisher, not like another reading app.
>
> Moodboard of my own captures: `evidence/11_premium_references.png`.

### P1. Letterform Archive — Online Archive
- **Examined:** `https://oa.letterformarchive.org/`: index at 390 px (pane) and 1440 px (headless). One object page: "Funeral and Ancestral Offerings, Ceremonies, and Rituals Manuscript", opened from the index in the pane.
- **Observed:** The search field **is the page headline**. At 1440, "Enter Your Search" is set in very large grey type across the whole width, with facets underneath (People, Firms, Disciplines, Decades, Countries, Formats). A masonry wall of objects photographed on white fills the rest. Within the wall, **one solid signal-red block** carries a curated collection title ("Graffiti Zines of 1990s") in white. Object page: the object shown very large, a **filmstrip of pages** with a thin red progress rule, then a plain fact block ("7 images available. Size: 31 x 22 cm. **Date: Unknown**"). Every metadata value (creator, discipline, format, country, language) is a **red link into the archive**. Rights take one sentence: "Public domain. No restrictions on use." The page ends in a solid red footer.
- **Transferable lesson:** A single **signature colour** used with discipline. **Unknowns stated with calm confidence.** Every fact is a door. Search is the monument, not a small field.
- **What not to copy:** The graphic-design, punk-flyer energy of its collection and its Latin-only type. Tajik content needs a quieter voice.

### P2. MUBI — film page and collections
- **Examined:** `https://mubi.com/en/us/films/the-color-of-pomegranates` in the pane (≈800 px, scrolled) and at 1440 headless. I declined non-essential cookies.
- **Observed:** A full-bleed still is the entire page. The title is in huge uppercase grotesque, then **"SERGEI PARAJANOV SOVIET UNION, 1969"** as a single pedigree line, then a four-line lyrical synopsis. Lower down, **collections are split tiles**: a black panel with the collection name in white caps (e.g. "1960S MASTERPIECES") beside a still, with a small count ("18"). "Awards & Festivals" is laid out as a **prestige list**: festival mark, festival name, year ("Show all (26)").
- **Transferable lesson:** (a) **Curation is the luxury.** A small set, framed with conviction, beats a big catalogue. (b) **Pedigree reads as prestige, not as metadata.** A text's printed witnesses ("Маориф, 2017, с. 54 · Маориф, 2025, с. 56") can be shown the way MUBI shows festivals: named, dated, proud.
- **Art-direction note:** The film itself (Parajanov's frontal, folkloric *tableaux* about a poet) is a strong mood reference for this region's poetic imagery. It is **not** a UI reference.
- **What not to copy:** The subscription funnel, email capture, and cookie wall.

### P3. Lapham's Quarterly — "Memory" issue page
- **Examined:** `https://www.laphamsquarterly.org/memory` at 1440 and 390 (headless). In the pane, the page loaded but screenshots would not paint.
- **Observed:** A full-bleed historical artwork (a 17th-century Japanese folding screen) with a **museum credit caption** in small serif ("…The Metropolitan Museum of Art, Mary Griggs Burke Collection…"). The issue title "MEMORY" is set in large crimson roman capitals, above "VOLUME XIII, NUMBER 1 | WINTER 2020". **"Voices in Time" cards** open with a **dateline of year and place**, such as "c. 1832 | Middlemarch" and "1890 | London", then a big serif title and a one-line teaser. Pale rose card fields, crimson accents.
- **Transferable lesson:** **Datelines.** Every proverb, bayt, and history excerpt should be anchored as *"асри X | Бухоро"* or *"1911 | Қаратоғ"*, using only dates and places the sources support. **Themed "issues"** (Memory, Patience, Friendship) as the discovery unit instead of plain category lists. **Image credit as craft**: a caption that names the source is itself a trust signal.
- **What not to copy:** Magazine commerce (Purchase, Donate) and its Western classical canon framing.

### P4. Rijksmuseum — object page (*The Night Watch*)
- **Examined:** `https://www.rijksmuseum.nl/en/collection/SK-C-5` at 1440 and 390 (headless). A cookie banner covered part of the lower-left in the screenshot.
- **Observed:** A near-black immersive gallery surface with the artwork filling the screen. Two quiet tabs, **"ABOUT | DATA"**, separate the story from the catalogue record. Feature tiles: "ULTRA HIGH RESOLUTION PHOTO — Zoom in to miniscule pigment particles", a short film, and a talk by the head of science. Then "DISCOVER MORE".
- **Transferable lesson:** **About vs Data** is the cleanest possible answer to F1. The poem or proverb page tells its story, and a second tab holds the full provenance record. **Extreme zoom as reverence**: when page scans exist, the scan viewer should feel like a pigment-level zoom, not a placeholder.
- **What not to copy:** Heavy video and marketing tiles. A totally dark default for long reading.

### P5. Assouline — luxury publisher home
- **Examined:** `https://www.assouline.com/` at 1440 (headless). A country-selection modal was open and was not dismissed.
- **Observed:** A **commissioned, painterly illustrated world** fills the hero: Mediterranean villages, a boat, a heron, an octopus, and olive branches, wrapped around a notebook still-life. Headlines are set in **high-contrast didone capitals** ("NEW ARRIVAL: TRAVEL FROM HOME NOTEBOOKS", "CURATED FOR YOU"). Links are **italic serif with an arrow** ("*Shop Now* →"). The copy talks about ritual: "…the room where reading becomes ritual."
- **Transferable lesson:** **Commission a world, don't decorate a UI.** One illustrator's hand, used on covers and empty states, makes the product unmistakable. Treat reading as ritual in the language. Italic serif links are a small, costly-feeling detail.
- **What not to copy:** Retail modals, gifting, and an explicitly luxury-consumer tone. This is cultural heritage, not a boutique.

### P6. Taschen — Art books index
- **Examined:** `https://www.taschen.com/en/books/art/` at 1440 (headless).
- **Observed:** Books are shown as **physical objects**: covers photographed with spine edge, depth, and soft shadow on pure white, in generous four-column spacing. Size markers ("XL") and one line of title and subtitle. The breadcrumb carries the count: "Art (261 Items)".
- **Transferable lesson:** The Library (28 external books) and the textbooks behind the provenance should look like **objects you could hold**: spine, weight, and edition, not flat thumbnails in bordered cards.
- **What not to copy:** Price-led listing.

### P7. Are.na — Explore channels
- **Examined:** `https://www.are.na/explore` at 1440 (headless, second scroll position; the first screen was still loading).
- **Observed:** A strict grid where **user-made "channels"** appear as white tiles set only in type ("DESIGN — by BELLA GOMEZ — 148 blocks — about 1 month ago") among the saved "blocks" (images, links, PDFs) with small captions. Minimal grey UI and a single navy button.
- **Transferable lesson:** **Saving becomes authorship.** A person's saved poems and proverbs can become their own **Баёз** — the Persianate tradition of the personal anthology notebook — with a title, an owner, and a count, shown as typeset "covers".
- **What not to copy:** The social network and the anonymous-looking grey palette.

**Not accessible (CAPTCHA or bot wall, deliberately not bypassed):** Hermès (only the hero was glimpsed: an editorial full-bleed photograph with an italic serif line about silk scarves; not used as evidence), Aesop, MasterClass, Louvre Abu Dhabi, Cooper Hewitt. **Timed out:** Museum of Islamic Art, Doha. **Reviewed and rejected:** Aga Khan Museum (a conventional museum website, not a taste reference), Cosmos (landing page only), The Pudding (distinctive but pop and data-driven, the wrong register).

---

## 6. DESIGN PRINCIPLES (v2)

1. **Exhibit, don't list.** One object per view at the moments that matter: the proverb of the day, a bayt, a poet. The rest of the app earns its density. *(P1, P2, P4)*
2. **Trust is the signature.** Verification should be the most beautiful thing in the product, not a debug panel. It appears as one mark (the seal), one sentence, and a full record one tab away. *(F1; P2 pedigree, P4 About|Data, P1 honest unknowns)*
3. **Every text has a dateline.** Time and place first, drawn only from the sources, never invented. *(P3; §3.4 integrity)*
4. **Commission a world.** A small set of owned visual assets makes the product unmistakable: seal, pattern, monograms, and possibly one illustrator. These replace generic icons in tiles. *(P5, P1)*
5. **The bayt is the atom.** Verse layout, actions, and saving work on couplets. *(F2; functional benchmark Ganjoor)*
6. **Your anthology, not your bookmarks.** Saving builds a personal Баёз. *(P7, F5)*
7. **One colour speaks.** A single vermilion for the seal and for action. Everything else is ink, paper, and (at night) lapis. *(P1)*

---

## 7. THREE VISUAL DIRECTIONS (v2 — bold)

All three are rooted in **Tajik and Persianate material culture**: manuscript seals, Badakhshan lapis lazuli, and atlas/adras ikat silk. These are *design motifs*, not content claims. Validate the choices with Tajik cultural advisors and designers before committing.

### Direction A — «Муҳр / The Seal»: a private gallery of the word
**Thesis:** Every proverb and bayt is exhibited like a masterpiece on an ivory wall, and trust is a vermilion seal pressed into the page.

- **The "wow" moment:** On opening the app, a single proverb fills the screen in monumental type, and nothing else competes. After a beat, a small **vermilion seal** (muhr) *presses* into the corner beside it: a 240 ms ink-impression (slight overshoot, then settle), once per session. The seal means *this text is verified against printed sources*. It's where the product's credibility becomes its identity.
- **Mood:** Hushed, after-hours museum. Luxury through restraint. Confident silence.
- **Layout:**
  - *Home* is an exhibit, not a dashboard. Above the fold there's a tiny wordmark, the catalogue line "№ 079 · Сабр", the proverb set at 44–64 px on mobile and up to about 120 px on desktop, the Persian line beneath, and the seal. Swiping up reveals the **wall label**: dateline, meaning, source. A second swipe moves to the bayt of the day.
  - *Lists* are **numbered catalogues** in the style of an auction catalogue: small-caps numbers, serif titles, hairlines, no boxes.
  - *Detail pages* have two quiet tabs, **"Дар бора | Сабт"** (About | Record), following P4.
  - *Desktop* is a gallery: the object centred, the wall label in a fixed right column, and a left rail for navigation.
- **Colour:** Ivory paper (warm, slightly deeper than today's). Lamp-black ink. **One cinnabar vermilion**, used only for the seal, active states, and links. No green, gold, or burgundy blocks. Dark mode is "gallery at night": warm near-black, ivory text, and the vermilion seal unchanged.
- **Typography:** A high-contrast display serif for exhibits, a calm text serif for reading, and a precise grotesque for UI. Persian verse uses **Nastaliq** for exhibits (the traditional Persian poetry hand) and Naskh for reading. See §12 for candidates with glyph checks.
- **Imagery:** Default is **none**. The text is the artwork. Poets without cleared portraits get a **seal-monogram plate**: the poet's initial in Cyrillic and Persian, cut like a seal. Cleared portraits are hung like prints, with a credit caption (P3).
- **Components:** Hairline rules, catalogue numbers, italic serif text links ("*Бихонед* →", from P5), and the seal in three states: *pressed* = verified; *outline* = partially verified; *absent* = under review, shown only with a plain sentence. Buttons are rare. Chips are used only for real filters.
- **Interaction:** Slow fades (250–320 ms). Swipe between exhibits like walking to the next wall. Long-press a bayt to "collect" it into your Баёз. Tap the seal to flip to the **Сабт** (record) tab.
- **Strengths:** It turns the biggest weakness (F1) into the signature. It needs no image rights, is the most readable of the three, scales to classroom projection, and looks unlike any Persian-poetry app.
- **Risks:** Austerity can feel cold, or like a luxury brand costume. Monumental type needs careful Cyrillic line-breaking (Tajik words are long). The seal is only premium if it's drawn by a real designer or calligrapher, since a clip-art stamp would cheapen everything.

### Direction B — «Лоҷвард / Lapis Night»: cinematic tableaux
**Thesis:** Heritage as cinema. Deep Badakhshan lapis, flat gold, and frontal tableaux, where every poem opens like a film title card (P2 plus the Parajanov mood).

- **The "wow" moment:** Opening a poem, the screen goes lapis. The title appears in huge condensed capitals with a pedigree line ("РӮДАКӢ · САМАРҚАНД · АСРИ X", only as the sources support it). Then each bayt arrives as its own title card, gold hemistich markers glinting as you scroll. There is an optional **Recital mode** that advances bayt by bayt, but only on the user's command.
- **Mood:** Nocturnal, ceremonial, enchanted.
- **Layout:** Full-screen vertical tableaux on mobile. Home is a sequence of three: *Tonight's bayt*, *Proverb*, *Continue*. Collections are MUBI-style **split tiles** (a solid lapis title panel beside an ornament or image panel, with a count). Desktop is a letterboxed stage.
- **Colour:** Lapis ultramarine as the ground, **flat** ochre-gold (never gradients, as DESIGN.md warns), pomegranate red as the accent, and ivory text. Day mode inverts to ivory with lapis ink.
- **Typography:** Condensed uppercase grotesque for titles (Cyrillic). Nastaliq for Persian lines. A text serif for reading.
- **Imagery:** Commissioned tableaux or miniature-*inspired* illustration and pattern plates (not pastiche). Manuscript details only where rights allow.
- **Interaction:** Title-card sequencing, cross-dissolves, parallax-free (motion stays on the text layer). Reduced motion gives a static page.
- **Strengths:** The biggest emotional impact and the most memorable first impression. Superb share cards. A strong night-reading ritual.
- **Risks:** Long reading on saturated blue is tiring. Gold can slide into kitsch. Miniature pastiche is a cultural cliché. It needs commissioned art and a lot of motion-accessibility care. It is the hardest to keep usable in Learn, Search, and History.

### Direction C — «Атлас / Ikat Silk»: the house print
**Thesis:** Tajik atlas/adras ikat, the blurred-edge silk, becomes a generative identity. Every collection wears its own print, like a fashion house's seasonal scarves (the P5 commissioned-world lesson, pushed into contemporary colour).

- **The "wow" moment:** The collection index is a rack of **ikat covers**: Ҳикмат, Сабр, Дӯстӣ, Модар, and so on, each a unique print generated from the collection's identity, with the title set large on the silk. Opening one, the print slides up to become a narrow band at the top, and the proverbs sit on clean white beneath.
- **Mood:** Proud, vivid, contemporary Dushanbe. Young.
- **Layout:** Bold cover grid for collections, eras, and grades (each era and grade gets a print). The interiors are clean editorial white with big numbers. Home is "this week's print" plus today's proverb.
- **Colour:** Saturated ikat palettes (magenta, saffron, emerald, indigo), one per collection, on a neutral white interior.
- **Typography:** A heavy contemporary Cyrillic grotesque for headlines, a serif for texts, and Naskh for Persian.
- **Imagery:** **Procedural ikat patterns** (seeded from the collection ID, rendered as vector art), so there are no image-rights dependencies and every collection is unique. The motif grammar must be designed with a textile specialist.
- **Interaction:** Covers lift on tap. The print band compresses on scroll. Share cards carry the collection's print.
- **Strengths:** Genuinely **unique** (I found no literary product using ikat as a system). Appeals to students. No rights risk. A strong national identity.
- **Risks:** Loud. It competes with long reading. Text on pattern has contrast problems. Without expert design it becomes souvenir pastiche.

---

## 8. RECOMMENDED DIRECTION: «Муҳр» by day, «Лоҷвард» by night, «Атлас» as the house print

**Base system: Direction A, «Муҳр / The Seal».** It's the only direction that is premium *and* readable, *and* that fixes the product's most serious problem (contradictory, leaky provenance, F1) by making verification its signature. It needs no image rights (portrait rights are unknown for all 67), and it gives a luxury feel through type and space rather than decoration. That matches P1, P3, and P4.

**Borrowed signature moments (these make it "wow" rather than merely tasteful):**
1. **From Лоҷвард, the night.** Dark mode isn't grey-green. It's **lapis-black** ("Шаб"), with ivory text and the vermilion seal. The poem reader's first screen can use a **title card** (condensed caps plus pedigree line) before the verse begins.
2. **From Атлас, the house print.** Ikat appears in exactly three places: **collection covers** (proverb themes, history eras, grades), **share cards**, and the **launch/splash**. It never appears behind reading text.
3. **From P7, the personal anthology.** Saved becomes **«Баёзи ман»** (My Bayoz). Users can name their anthologies, each shown as a typeset cover with a count, and it holds collected bayts and proverbs.
4. **From P2, pedigree.** The **Сабт** (Record) tab lists printed witnesses the way MUBI lists festivals: named, dated, and proud.

**What stays from v1:** Everything functional in §9–§13: bayt layout, the script/language split, one collection index, correct resume, end-of-text navigation, and the desktop reading room. v2 changes *how it looks and feels*, not *what it must fix*.

### Signature screen sketches (v2)

```
MOBILE — Home «Экспозиция» (exhibit)       MOBILE — Home, swipe up: wall label
┌─────────────────────────────┐            ┌─────────────────────────────┐
│ зарбулмасал          ⌕   ⚙  │            │ № 079 · САБР                 │
│                             │            │ Шитоб кори шайтон аст.       │
│ № 079 · САБР                │            │ ─────────────────────────── │
│                             │            │ АНЪАНАВӢ | <place if sourced>│  ← dateline
│ Шитоб                       │            │                             │
│ кори                        │            │ Маъно                       │
│ шайтон                      │            │ Пеш аз амал кардан фикр …   │
│ аст.            (≈56px serif)│            │                             │
│                             │            │ Дар бора  |  Сабт           │  ← About | Record
│ شتاب کار شیطان است.  (Nastaliq)│         │ Баёзи фолклори тоҷик, ҷ. 2 › │
│                       ┌──┐  │            │                             │
│                       │М│  │ ← seal     │ ♡ Ба Баёзи ман   ⧉   ↗      │
│                       └──┘  │            ├─────────────────────────────┤
│        ︿ байти рӯз          │            │ ИДОМА · Бӯйи Ҷӯйи Мулиён,    │
└─────────────────────────────┘            │ байти 4 аз 7            ›   │
                                           └─────────────────────────────┘

MOBILE — Collections «Ганҷина» (ikat covers)  MOBILE — Saved «Баёзи ман»
┌─────────────────────────────┐            ┌─────────────────────────────┐
│ ГАНҶИНА                      │            │ БАЁЗИ МАН                    │
│ ┌─────────────┐┌───────────┐│            │ ┌───────────┐ ┌───────────┐ │
│ │▒▓ ikat ▓▒▓▒ ││▓▒ ikat ▒▓ ││            │ │ Барои     │ │ Бухоро    │ │
│ │ ҲИКМАТ      ││ САБР      ││            │ │ модарам   │ │           │ │
│ │ 37          ││ 4         ││            │ │ 12 байт   │ │ 5 матн    │ │
│ └─────────────┘└───────────┘│            │ └───────────┘ └───────────┘ │
│ ┌─────────────┐┌───────────┐│            │  (typeset covers, P7)        │
│ │ ДӮСТӢ 12    ││ МЕҲНАТ 27 ││            │ + Баёзи нав                  │
│ └─────────────┘└───────────┘│            │ ─────────────────────────── │
│ ДАВРАҲО (era prints) ›       │            │ Ҳамаи нигоҳдоштаҳо (18)   › │
│ СИНФҲО 5·6·7·8·9·10·11       │            │ Таърихи хониш             › │
└─────────────────────────────┘            └─────────────────────────────┘

DESKTOP — Poem, night «Шаб» (lapis-black)
┌────┬────────────────────────────────────────────┬───────────────────────┐
│rail│   БӮЙИ ҶӮЙИ МУЛИЁН                          │ Дар бора | Сабт        │
│    │   РӮДАКӢ · 858–941 · ҚАСИДА          ┌──┐   │ ─────────────────────  │
│    │                                      │М│   │ Маориф, 2017 · с. 54   │
│    │   Бӯйи Ҷӯйи Мулиён     Ёди ёри меҳрбон└──┘  │ Маориф, 2025 · с. 56   │
│    │   ояд ҳаме,            ояд ҳаме.            │ (pedigree list, P2)    │
│    │                                             │ Фарқият: ночиз         │
│    │   Реги Омуву …         Зери поям …          │                        │
│    │          ─ ─ ─ ─ ─                          │ Пайвандҳо: Сомониён ›  │
│    │   ← Асари қаблӣ            Асари баъдӣ →    │                        │
└────┴────────────────────────────────────────────┴───────────────────────┘
```
*(Tajik strings are layout placeholders. Datelines and places must come only from the sources. The seal glyph "М" in the sketches is a placeholder and must be replaced by an original Tajik/Persian seal design.)*

---

## 9. SCREEN-BY-SCREEN REDESIGN

Priority screens have wireframes. "PROPOSED" marks anything that doesn't exist today.

### 9.1 Poem reader (`/literature/work/:id`) — priority 1
- **Purpose:** Read one poem. Check its source. Save or copy it.
- **Observed issues:** F2 (no bayt structure, mid-hemistich wraps, dead end), F1 (contradictory status, dead scan tile), F3 (script chips only in the Persian interface; Parallel mode shows no visible change), the title set in sans while the verse is serif, and three chips in two rows above the title.
- **Keep:** The serif verse face. The author link with dates. The bottom toolbar idea (save, copy, size). The source panel content.
- **Hierarchy:** Title → poet → **status line** → verse → colophon → "continue exploring".
- **Layout:** The title is serif. Genre moves into the meta line ("Қасида · Абӯабдуллоҳи Рӯдакӣ · 858–941"). Below it, **one status line**: "✓ Бо китоби дарсӣ муқобала шудааст · 2 нусха" or "◐ Матн дар баррасӣ" (final wording is up to the editors). Verse is set as bayts: each bayt is a block, hemistichs are separate lines, a hanging indent of about 1.5 em applies to wraps, and bayts are separated by space, not rules. The colophon follows the poem. "More by this poet", "Same period" (history link), and "Next poem in this collection" come last.
- **Responsive:** Mobile hemistichs stack. At a text measure of 900 px or more, hemistichs sit side by side (in RTL order for Persian script). Desktop adds a right context pane that holds the colophon, so it isn't a sheet.
- **Interactions:** Tap or long-press a bayt to open a bayt menu (copy bayt, share, save bayt). The toolbar holds save, copy poem, and "Aa" (reading settings sheet: size, spacing, script, live preview). A script chip appears **only when a second script exists**, and its label says what it is ("Хатти форсӣ — табдили механикӣ" if generated, pending the editors' decision). The source panel on mobile becomes a scrollable "Сарчашма" section at the end of the poem, and the toolbar button scrolls to it.

```
MOBILE — Poem reader                    DESKTOP ≥1200 — Poem reader
┌─────────────────────────────┐        ┌────┬─────────────────────────────┬──────────────────┐
│ ←  Шеърҳо            Aa  ⋯  │        │nav │  Бӯйи Ҷӯйи Мулиён            │ САРЧАШМА          │
├─────────────────────────────┤        │rail│  Қасида · Рӯдакӣ · 858–941   │ Адабиёти тоҷик,  │
│ Бӯйи Ҷӯйи Мулиён  (serif)   │        │    │  ✓ Муқобала бо 2 нусха       │ синфи 5 (2017),  │
│ Қасида · Рӯдакӣ › · 858–941 │        │    │ ───────────────────────────  │ с. 54            │
│ ✓ Бо 2 нусхаи чопӣ муқобала │        │    │  Бӯйи Ҷӯйи   │ Ёди ёри       │ Нусхаи дуввум…   │
├─────────────────────────────┤        │    │  Мулиён ояд  │ меҳрбон ояд   │ Фарқият: ночиз   │
│ Бӯйи Ҷӯйи Мулиён ояд ҳаме,  │        │    │  ҳаме,       │ ҳаме.         │ Скан: дастрас    │
│ Ёди ёри меҳрбон ояд ҳаме.   │        │    │              │               │  нест            │
│                             │        │    │  Реги Омуву  │ Зери поям …   │──────────────────│
│ Оби Ҷайҳун аз нишоти рӯйи   │        │    │  …           │               │ ПАЙВАНДҲО         │
│     дӯст                    │ ← hang │    │                              │ Рӯдакӣ: 2 асар   │
│ Хинги моро то миён ояд ҳаме.│        │    │ ───────────────────────────  │ Сомониён (таърих)│
│  …                          │        │    │  ← Асари қаблӣ  Асари баъдӣ → │ Луғат: 3 вожа    │
├─────────────────────────────┤        └────┴─────────────────────────────┴──────────────────┘
│ САРЧАШМА (colophon)         │
│ Адабиёти тоҷик, синфи 5 …   │
│ Муқобала: нусхаи 2025, с.56 │
│ Ҳуқуқ: … (plain sentence)   │
├─────────────────────────────┤
│ Боз аз Рӯдакӣ  ›            │
│ Давраи Сомониён  ›          │
│ ← Қаблӣ          Баъдӣ →    │
├─────────────────────────────┤
│ [♡ Нигоҳ доштан] [⧉] [Aa]   │  sticky toolbar
└─────────────────────────────┘
```
*(All Tajik strings in wireframes are placeholders for layout. Final copy belongs to the team.)*

### 9.2 Source and verification ("Сарчашма ва санҷиш") — priority 1
- **Purpose:** Explain where the text comes from and how far it has been checked.
- **Observed issues:** F1 in full. Also, the checklist's "reviewer" is a hash, and there are "Full text ✓ / Citation ✓" chips in low-contrast disabled styling.
- **Keep:** Primary source, second witness, variant note, and the checklist concept.
- **Proposed hierarchy:** (1) **One status sentence** from a fixed set of 3–4 states defined with the editors (e.g. *Verified against two printed witnesses* / *Verified against one printed witness* / *Under editorial review*). The header badge must use the same state. (2) The primary source as a formatted citation. (3) The second witness and what differs, in plain Tajik. (4) Checks as a short list, with unchecked items shown as "pending", not faint circles. (5) Rights in one plain sentence, with **no file paths**. (6) "Report a problem with this text" (opens the existing Telegram feedback, or a PROPOSED form).
- **Scan tile:** Render it **only if a scan exists**. Otherwise show a single line: "Скани саҳифа ҳанӯз илова нашудааст" (wording TBD).
- **Localisation:** Map every enum ("Tier A", "minor-variant", "exact") to reviewed Tajik and Persian labels. Show an editor's name or role, never a hash.

```
MOBILE — colophon block (end of reader)
┌─────────────────────────────┐
│ САРЧАШМА                    │
│ ✓ Бо ду нусхаи чопӣ муқобала│  ← same wording as header status
│ шудааст.                    │
│                             │
│ Т. Мирзод ва дигарон.       │
│ Адабиёти тоҷик, синфи 5.    │
│ Душанбе: Маориф, 2017, с.54.│
│                             │
│ Нусхаи дуввум: … 2025, с.56 │
│ Фарқият: имлои як мисраъ    │
│                             │
│ Санҷишҳо                    │
│ ✓ Сарчашма  ✓ Муаллиф       │
│ … Имло — дар навбат          │
│ … Ҳуқуқ — дар навбат         │
│                             │
│ Ҳуқуқ: <one plain sentence> │
│ Хато ёфтед? Хабар диҳед  ›  │
└─────────────────────────────┘
```

### 9.3 Home (`/`) — priority 2
- **Purpose:** A daily entry point plus a way back into reading.
- **Observed issues:** Four generic tiles duplicate Explore. The burgundy Continue block dominates. Below the proverb card the page is empty. It resumes the wrong target (F5). On desktop it's a narrow column with a bottom bar (F6).
- **Keep:** The proverb-of-the-day card (dark folio in light mode, a strong typographic moment), the search field, and the settings access.
- **Hierarchy:** Continue reading (only when something exists) → Today (proverb **and** bayt of the day, with "earlier days") → Collection index (typographic list: Literature, Proverbs, History, Lexicon, Library, each with a one-line description and count) → Grade lens (PROPOSED: "Синфи 5…11" chips).
- **Responsive:** On desktop, "Today" becomes two columns (proverb | bayt), and the collection index sits beside them in a third column.

```
MOBILE — Home                           DESKTOP — Home
┌─────────────────────────────┐        ┌────┬──────────────────────────────────────────────┐
│ ЗАРБУЛМАСАЛ            ⚙    │        │ ⌂  │ [ Ҷустуҷӯ … ]                                │
│ [ Ҷустуҷӯ …              ]  │        │ ◎  ├──────────────────────┬───────────────────────┤
├─────────────────────────────┤        │ ▤  │ ИДОМАИ ХОНДАН         │ ИМРӮЗ                 │
│ ИДОМАИ ХОНДАН               │        │ ♡  │ Бӯйи Ҷӯйи Мулиён      │ Мақоли рӯз (folio)    │
│ Бӯйи Ҷӯйи Мулиён — байти 4  │        │    │ байти 4 аз 7  ›       │ Шитоб кори шайтон аст.│
│ Рӯдакӣ · 2 рӯз пеш       ›  │        │    ├──────────────────────┤ ─────                  │
├─────────────────────────────┤        │    │ ГАНҶИНА               │ Байти рӯз             │
│ ИМРӮЗ                       │        │    │ Адабиёт — 145 шоир  › │ «Дар шеър се тан…»    │
│ ┌ dark folio ─────────────┐ │        │    │ Зарбулмасал — 150   › │ Саъдӣ ›               │
│ │ Мақоли рӯз              │ │        │    │ Таърих — 85 мавзӯъ  › │ Рӯзҳои пешин ›        │
│ │ Шитоб кори шайтон аст.  │ │        │    │ Луғатнома — 379     › │                       │
│ │ شتاب کار شیطان است.     │ │        │    │ Китобхона — 28      › │ СИНФИ ШУМО            │
│ └─────────────── Бихонед ›┘ │        │    │                       │ 5 6 7 8 9 10 11       │
│ Байти рӯз: «…» Саъдӣ     ›  │        └────┴──────────────────────┴───────────────────────┘
│ Рӯзҳои пешин ›              │
├─────────────────────────────┤
│ ГАНҶИНА  (typographic list) │
│ Адабиёт                     │
│ Шоирон, шеърҳо, мактаб   ›  │
│ ─────────────────────────── │
│ Зарбулмасалҳо …          ›  │
│ Таърих …                 ›  │
│ Луғатнома …              ›  │
├─────────────────────────────┤
│ Синфи шумо: 5 6 7 8 9 10 11 │  PROPOSED grade lens
└─────────────────────────────┘
│ Асосӣ  Ганҷина  Омӯзиш  Маҳфуз │
```

### 9.4 Explore → "Ганҷина" (collection index; the tab name "Ганҷина" is a PROPOSED rename) — priority 2
- **Purpose:** The complete map of the collection.
- **Observed issues:** F4: 10 boxed rows, a "centre" row that duplicates its siblings, an unlabeled Lexicon row, and an empty Oral heritage entry.
- **Keep:** Grouping by domain. Short descriptions.
- **Proposed:** **Merge Explore and the Literature hub into one structure.** The Explore tab shows the domain index (Literature, Proverbs, History, Lexicon, Library). The Literature hub becomes the Literature section page (keeping bayt of the day, selected poems, and sub-index). Remove "Маркази мероси адабӣ" as a separate row. Oral heritage appears only when it has items, or as a clearly labelled "Ба зудӣ" line that isn't tappable, the same way in every place it appears. Remove meaningless running numbers ("03 / …"). Use numbers only where order means something (levels, grades).
- **Visual:** Typographic list with hairlines (Sefaria's "Browse the Library" pattern, R2). No boxes.

### 9.5 Poet dossier (`/literature/poet/:id`) — priority 2
- **Purpose:** Who the poet was, what can be read, and context.
- **Observed issues:** The biography is a single 16 px sans block about 40 lines long on mobile. The "under review: 96" pill sits in the header with the same weight as "verified: 2". Epithet chips (Одамушшуаро, Устод…) look like filters. On desktop the portrait sits small in a wide column.
- **Keep:** The Persian-script name under the Cyrillic name, the portrait frame, the biography citation box, the "Explore their world" links, and verified works first with the under-review list collapsed.
- **Hierarchy:** Name (both scripts) → dates · place · era (one line) → **Works to read (2)** → Biography (first paragraph, then "Read more") → Epithets as inline text ("Also known as: …") → Period and world (links) → Records under review (collapsed, explained in one line) → Source.
- **Responsive:** On desktop, a two-column layout: left has the portrait and facts, right has works and biography.
- **Imagery:** Use the portrait only if rights allow. Otherwise use the PROPOSED monogram plate.

### 9.6 Proverb detail and daily proverb — priority 3
- **Keep:** Almost everything (S2).
- **Change:** Remove the "Reading script" chips from this page. Script is set in reading settings (Aa), and it **never** changes the interface language (F3). Make tags real links (category and level lists), or style them as plain meta text. Add a source page where one exists (content check §3.4). End with "Same theme ›", "Previous/Next proverb", and on the daily page "Earlier days ›".

### 9.7 Global search (`/search`) — priority 3
- **Change:** Remove the character counter. Keep the field full-height and unclipped. Results: one-line subtitles (poet: dates · era *short name*; history: date range), highlighted match, group headers with counts and "Show all". No-results: suggest spelling variants (the diacritic-folding logic already exists), offer "Search inside poem texts" (PROPOSED, if the team adds full-text search), and link to the collection index. Idle state: recent searches (local) plus the existing suggestion chips from Literature search.

```
MOBILE — Search results
┌─────────────────────────────┐
│ ← [ бухоро              ✕ ] │
├─────────────────────────────┤
│ ШОИРОН · 17        Ҳама ›   │
│ Садриддин Айнӣ              │
│ 1878–1954 · Аморати Бухоро  │  ← one line, match bold
│ Шокири **Бухор**ой          │
│ асри X · Сомониён           │
├─────────────────────────────┤
│ ТАЪРИХ · 6         Ҳама ›   │
│ Аморати **Бухоро** 1753–1920│
├─────────────────────────────┤
│ ШЕЪРҲО · 0                  │
│ Ҷустуҷӯ дар матни шеърҳо ›  │  PROPOSED
└─────────────────────────────┘
```

### 9.8 History list and entry — priority 3
- **List:** Content first. Title, then **era navigator** (a single horizontal list of periods with dates, sticky). The textbook carousel moves behind a "By textbook" view switch. Search is folded into the global search or into a search icon. Entries become typographic rows (title, date range, one-line summary, grade) instead of boxed cards.
- **Entry:** Remove the intermediate sheet and go straight to the page. Header: title, dates, capital, rulers as a compact fact list. Overview. Long-form sections with printed page numbers (keep S1). The end shows "← Previous period | Next period →" plus "Poets of this period" (PROPOSED link from existing poet-era data).
- **Desktop:** Era navigator as a left sub-rail, and facts in the right context pane.

### 9.9 Saved (`/saved`) — priority 3
- **Change:** Drop the duplicate title ("Маҳфуз" + "Маҳфузҳо"). Sections: "Continue" (last reading position per text), "Saved" (grouped by type with counts: Poems, Bayts [PROPOSED], Proverbs, Books), "History" (recent, one-line subtitles, "Clear" kept). Bayt-level saves show the bayt itself.

### 9.10 Learn, Quiz, Flashcards, Levels — priority 4
- **Learn:** Remove "School literature" and "Lexicon" duplicates, or present them via the grade lens. Keep "Practice": Quiz and Flashcards with equal-height tiles.
- **Quiz:** After answering, auto-scroll so feedback and "Next" are visible, or pin feedback in a bottom sheet.
- **Flashcards:** Let the back grow (scroll the page, not the card). Explain "15 per session" next to the counter.
- **Levels:** Show level names in the proverb filter chips. Drop the repeated "Оғоз" label in favour of the count only. CONTENT: the level distribution (1 / 22 / 50…) is for the team to review.

### 9.11 Library and book detail — priority 4
- **Keep:** The rights sentence, the external read CTA, and the author link.
- **Change:** Merge the five metadata tiles into one definition list. Remove the provider row showing "— китоб · — муаллиф" until data exists. Use a consistent cover fallback (spine style) where scans are missing.

### 9.12 School canon — priority 4
- **Change:** Group by textbook (edition heading once), then list authors and works with page ranges. Currently the same book, authors, and citation repeat on every row. Make the status labels ("Хатм", "Истинод дар санҷиш") match the unified status vocabulary.

### 9.13 Settings — priority 4
- **Split:** "Interface" (language: Tajik Cyrillic / Persian script; theme; app text size) and "Reading" (poem size, spacing, reading mode, script for texts), each with a live preview (R3). Make "Parallel" clearly dependent on content ("Only for texts that have both scripts").

### 9.14 First-run tour — priority 4
- **Change:** Remove the "continue reading" promise, or show that step only after first reading. Consider replacing the tab tour with a one-screen welcome that asks for **reading script** and optionally **grade** (both can be changed later).

---

## 10. INTERACTION DESIGN

**Browsing.** Use one collection index with typographic lists, counts, and one-line descriptions. Filters are real chips with visible result counts, and a clear "Reset". Horizontal carousels on desktop get arrow buttons and edge fades, or become wrapping lists. Don't use infinite scroll. Lists show their total ("145 шоир") and are paginated or sectioned (by era for poets, by grade for school canon).

**Reading.** Bayt layout with hanging indents. Reading settings (Aa) are scoped to texts and preview live. The sticky toolbar hides on scroll-down and shows on scroll-up. Each text has a thin progress indicator in the app bar. The end of a text offers neighbours and context. Colophon at the end, and the status line near the top. No pop-ups while reading.

**Searching.** A single global search reachable from every screen (top of Home and Explore on mobile, rail on desktop). Tolerant matching (already present). Grouped results with counts and highlighted matches. No-results offers alternatives. Returning from a result restores the query and scroll position. Per-section searches (poets, proverbs, books) keep their filters and drop character counters.

**Saving.** One save affordance per unit (text, bayt, proverb, book) with a brief confirmation toast that has "Undo". Saved items are grouped by type. No account and no sync (unchanged). Saved state also shows on list rows as a filled bookmark.

**Returning.** "Continue reading" stores **text ID plus bayt or section anchor**. It updates only on content screens (reader, proverb, history entry), not on hubs or back navigation. Show "bayt 4 of 7" or "section 2 of 5". History (recent) stays in Saved with a clear control. The flashcard "Again" pile is offered on the Learn tab when it isn't empty.

**Discovery.** Contextual and user-controlled. At the end of texts: more by the poet, the same period, the same theme, related lexicon terms. On Home: today's proverb and bayt, plus an archive of earlier days. A grade lens for students. No streaks, no push notifications, no "trending", no autoplay.

---

## 11. RESPONSIVE STRATEGY

| Concern | Mobile (360–430) | Tablet (≈768–1024) | Desktop (≥1200) |
|---|---|---|---|
| Navigation | Bottom bar (4 tabs), **kept on pushed screens** or replaced by a clear back and "home" | Bottom bar or rail | **Left rail, always visible** |
| Reading measure | Full width minus 20–24 px gutters | 36 em centred | 36–40 em column plus a **context pane** (colophon, connections) |
| Verse | Stacked hemistichs, hanging indent | Stacked | Hemistichs side by side when measure allows |
| Lists | Single column, typographic rows | Two columns for indexes | Index plus detail two-pane (e.g. poets list \| dossier) |
| Type scale | Base 16–17, verse 19–20 | Same | **Same or larger**, never smaller (fixes F6) |
| Carousels | Swipe | Swipe plus fade edge | Arrows or wrap into a grid |
| Source panel | Colophon section at end of text | Same | Right pane, always visible |

The difference should be intentional. Mobile is for one thing at a time, and desktop is a reading room with context beside the text (a teacher can project a poem with its source visible).

---

## 12. DESIGN SYSTEM DIRECTION (conceptual)

- **Typography (v2):** Replace the Noto trio. It is safe but generic, and that's a big part of why the app feels ordinary. Candidates, from Google Fonts metadata checked on 24 Sep 2026 (all list the `cyrillic-ext` subset, which should cover Tajik Ҷ Ҳ Қ Ғ Ӣ Ӯ). **Every candidate must pass a Tajik glyph proof sheet before adoption**, because a subset listing is not proof of full coverage:
  - *Exhibit/display serif (Cyrillic):* Cormorant Garamond (high contrast, luxurious at 48 px and above), or Brygada 1918 (sturdier).
  - *Reading serif (Cyrillic):* Literata or EB Garamond (both with `cyrillic-ext`), or PT Serif (designed with extended Cyrillic in mind).
  - *UI grotesque:* Onest or Golos Text (contemporary, Cyrillic-first), or Manrope. *Condensed title caps for the night title card:* test Unbounded sparingly, or source a licensed condensed grotesque.
  - *Persian:* **Nastaliq for exhibited verse** (Noto Nastaliq Urdu is available but tuned for Urdu, so a native Persian reader must review its Persian shaping, or license a Persian Nastaliq). **Markazi Text or Noto Naskh Arabic** for Persian reading and UI. Vazirmatn for Persian-UI sans.
  - Roles stay as in v1 (literary / reading / interface). Scale up exhibits (44–64 px on mobile, up to about 120 px on desktop). Never shrink on desktop.
- **Colour roles (v2 simplifies to ivory, ink, vermilion, plus lapis at night; the v1 list below remains the functional mapping):** *Paper* surfaces (3 steps), *Ink* text (3 steps), *Action* (burgundy: links, selected, primary button, never large fills), *Verified* (forest: only for the verified status), *Pending* (warm neutral, **not** red), *Warning* (only for rights and caution copy), *Ornament* (gold: eyebrows and bayt markers, sparingly). Each status pairs with an icon and words.
- **Spacing:** A 4-pt base. Section spacing of 32 on mobile and 48 on desktop. Bayt gap of 1.2× line height. List rows with 16 px vertical padding and hairline separators.
- **Surfaces:** Flat paper, hairlines, and tone shifts. One raised surface type (sheet or menu). Remove bordered cards from lists. Keep the **dark folio** for the proverb of the day as the single "hero" surface.
- **Imagery:** Rights-checked portraits only. Monogram plates as fallback. One restrained ornament family (rule-plus-rosette) for section starts and bayt markers. No faux parchment.
- **Iconography:** One outline set at a consistent stroke. Icons only where they add meaning (type markers in search results, status). Remove decorative icons from list rows.
- **Motion:** 150–200 ms fades and cross-fades. Sheet slides only. No parallax or bounce. Respect reduced motion.
- **Accessibility:** Status never by colour alone. Touch targets ≥48 dp (keep). Ensure the disabled-looking but active controls (scan chip, "Full text ✓" chips) either work or aren't shown. Contrast-check gold-on-paper eyebrows and low-contrast meta in dark mode. Semantic headings for verse and colophon so screen readers read bayts in order (Flutter semantics: UNKNOWN, not tested). RTL: text alignment follows **content script**, not only interface language (fixes the left-aligned Cyrillic inside RTL pages).

---

## 13. PRIORITIZED ROADMAP

### NOW (foundation: trust, reading, clarity)

| # | Recommendation | Evidence | User benefit | Effort | Dependencies | Success signal |
|---|---|---|---|---|---|---|
| N1 | Unify verification status: one vocabulary, header badge = panel state; hide the scan tile when no scan exists | F1, [D2][D3] | Readers can trust what "verified" means | Medium | Editors define 3–4 states and wording | No screen shows "verified" with unchecked items; no "not available" viewer reachable |
| N2 | Remove internal data from the UI: translate enums, replace file paths and hashes with plain sentences and names or roles | F1 | Professional, credible provenance | Low–Medium | Editor-approved Tajik/Persian labels | Zero Latin enums or paths on Tajik and Persian screens (QA sweep) |
| N3 | Bayt layout in the reader: couplet blocks, hanging indent, bayt spacing | F2 | Poems read as poems on phones and at large sizes | Medium | Work text must mark bayt boundaries (UNKNOWN whether the data does) | Hemistich structure is preserved at 375 px and at 120% text |
| N4 | Separate interface language from reading script; remove the script chips from the proverb page | F3, [E1–E3] | No accidental switch to RTL; predictable controls | Medium | Settings restructure, see §9.13 | Script changes never alter navigation language; fewer "language" support messages |
| N5 | Label generated Persian-script renderings (or hide them) pending editorial decision | §3.4 | Persian readers aren't misled | Low | **Team decision** (Open Q1) | Every Persian-script text states its origin |
| N6 | Fix resume: store text plus anchor, update only on content screens | F5 | Returning readers land where they stopped | Medium | Local persistence (exists for recent activity) | "Continue" opens the last-read text at the right bayt or section |
| N7 | Remove "0/256" counters; fix clipped global-search field | F7, [C1] | Less confusion, cleaner lists | Low | None | No counters visible |
| N8 | Hide or clearly disable empty Oral heritage everywhere | F4, [G1] | No dead ends | Low | Team decision (Open Q3) | No path leads to an empty collection |

### NEXT (structure and discovery)

| # | Recommendation | Evidence | User benefit | Effort | Dependencies | Success signal |
|---|---|---|---|---|---|---|
| X1 | Merge Explore and the Literature hub into one collection index; remove duplicate rows and meaningless numbering | F4, [B1–B3] | One mental map | Medium | N-series done | Each destination has one entry point per level; fewer back-and-forth navigations in testing |
| X2 | End-of-text navigation (prev/next, more by poet, same period, same theme) for poems, proverbs, history | F2, F8, R1, R5, R6 | Continuous reading without hunting | Medium | Collection ordering rules | More texts read per session without returning to lists (if measured locally or in testing) |
| X3 | Colophon pattern replaces the source sheet on mobile; right pane on desktop | F1, R5, R7 | Provenance is readable, not buried | Medium | N1, N2 | Testers can explain a text's source in their own words |
| X4 | Desktop reading room: left rail, persistent nav, context pane, no type shrink, carousel arrows | F6, [A2][D4][F2] | Usable on laptops and projectors | High | Layout breakpoints | Desktop screens keep navigation; type ≥ mobile |
| X5 | History redesign: content-first list, era navigator, direct entry page, prev/next period | F8, R6 | Faster to reach and move through periods | Medium | Era ordering data | First entry visible above the fold on mobile |
| X6 | Search quality: one-line subtitles, highlights, counts, helpful no-results | F7 | Faster scanning and recovery | Medium | Short era labels in data | Fewer zero-result dead ends in testing |
| X7 | Replace boxed lists with typographic lists across Explore, Learn, History, Library | F10 | A calmer, more literary identity matching DESIGN.md | Medium | X1 | Visual audit: cards only for true objects (the folio) |

### LATER (enrichment)

| # | Recommendation | Evidence | User benefit | Effort | Dependencies | Success signal |
|---|---|---|---|---|---|---|
| L1 | Bayt-level actions (copy, share, save a bayt) | R1, R3 | Quote and keep exactly what matters | Medium | N3 | Bayt saves appear in Saved |
| L2 | Grade lens across Literature, History, and Lexicon | Audience signal (v1 study-notebook idea) | Students find their curriculum quickly | Medium | Curriculum mapping per edition | Students in testing reach grade content in ≤2 taps |
| L3 | Inline glossary: link verse words to Lexicon entries | §3.3 | Understand difficult words in place | High | Editorial linking; Lexicon IDs | Glossary use in reading sessions |
| L4 | "Earlier days" archive for proverb and bayt of the day | R5 | Daily ritual without pressure | Low | Deterministic daily selection | Archive visits |
| L5 | Monogram plates and cover fallbacks; rights-cleared portraits | Imagery risk | Consistent visuals without rights risk | Medium | Rights review (Open Q2) | No uncleared portrait displayed |
| L6 | Print or projection view for poems and history | Teacher use (inferred) | Classroom use | Low–Medium | X4 | Teacher feedback |
| L7 | "Report a problem with this text" flow | R5, R7 | Community corrections feed provenance | Low | Feedback channel | Reports received per month |

---

## 14. OPEN QUESTIONS (only decisions the team must make)

1. **Persian-script renderings.** Should mechanically generated Persian-script versions of poems and proverbs be shown to readers at all? If yes, how must they be labelled? This decides whether the "script" control in the reader and proverb pages exists, and how Persian-interface users experience texts.
2. **Portrait rights.** Rights are "unknown" for all 67 bundled portraits. May the redesign keep showing them, or should it plan for monogram plates by default until rights are cleared?
3. **Unfinished sections.** For Oral heritage (and any future empty area), do you prefer "hidden until populated" or "visible but marked as coming soon"?
4. **Primary audience emphasis.** Should Home lead with the *daily reading ritual* (general readers) or with the *grade lens* (students)? Both are in the plan. This only sets their order and prominence.

---

## 15. RESEARCH APPENDIX

### APP SCREENS ACTUALLY INSPECTED
Home (first-run with tour, returning with Continue card; light, dark, Persian) · First-run tour steps 1–4 · Cold-start splash · Explore · Learn · Saved (empty; populated with 1 saved poem plus 3 recent) · Global search (idle; "рудаки"; "бухоро" scrolled to end; "мулиён"; "меҳмон"; nonsense no-results) · Daily proverb (Tajik) · Proverbs list (default; "модар" search; nonsense no-results; category filter "Сабр") · Proverb detail #21 and the "Сабр" proverb (Tajik; Persian after script tap) · Categories · Levels · Quiz (question 1 before and after answer) · Flashcards (front and back) · Literature hub (loading "…", loaded, scrolled to end) · Poets list (top; scrolled with portraits) · Poet dossier: Rudaki (header, biography, source, era, "Explore their world", works, under-review toggle) · Works list · Poem reader: Rudaki "Бӯйи Ҷӯйи Мулиён" (100%, 120%, 80%; dark; light; desktop), Saadi "Банӣ Одам…" (Tajik; Persian interface with script chips), Khayyam rubai (parallel mode set), Rudaki "Гар бар сари…" (Persian interface) · Source panel (Rudaki; Saadi, scrolled through checks and rights) · Page-image viewer (not-available state) · Literature search (idle suggestions) · School canon · Oral heritage (empty) · History (list, scrolled) · History entry "Давлати Мод" (sheet; full page top, middle, end) · Library · Book detail "Баъди борон" · Lexicon list · Settings (Tajik and Persian, full scroll) · Route-not-found page.

### USER JOURNEYS ACTUALLY WALKED
The 10 journeys in §4. Each was walked by tapping in the in-app browser pane, except the evidence re-captures, which were scripted with Playwright.

### VIEWPORTS / DEVICES INSPECTED
- In-app browser pane: 375×812 mobile emulation (Android Chrome UA, touch) in the dark theme. 1440×900 emulation (scaled) for Home, Ganjoor, and Wikisource.
- Headless Chromium via system Python Playwright: 390×844 @2x (light and dark, Tajik and Persian) and 1440×900 @1x (light), 27 routes each.
- Not inspected: tablet widths, 320 px, real iOS or Android devices, 200% OS text scaling, screen readers, offline mode.

### EXTERNAL REFERENCES ACTUALLY REVIEWED
**v2 premium set (§5):**
- Letterform Archive — index (390 pane, 1440 headless) and a manuscript object page (pane) — https://oa.letterformarchive.org/
- MUBI — film page and collections (pane ≈800 px; 1440 headless) — https://mubi.com/en/us/films/the-color-of-pomegranates
- Lapham's Quarterly — "Memory" issue page (1440 and 390 headless) — https://www.laphamsquarterly.org/memory
- Rijksmuseum — The Night Watch object page (1440 and 390 headless; cookie banner partly covering) — https://www.rijksmuseum.nl/en/collection/SK-C-5
- Assouline — home (1440 headless; country modal open) — https://www.assouline.com/
- Taschen — Art books index (1440 headless) — https://www.taschen.com/en/books/art/
- Are.na — Explore (1440 headless) — https://www.are.na/explore
- Reviewed and rejected: Aga Khan Museum https://agakhanmuseum.org/ · Cosmos https://www.cosmos.so/ · The Pudding https://pudding.cool/
- Blocked by CAPTCHA or bot wall (not bypassed): Hermès https://www.hermes.com/us/en/ · Aesop https://www.aesop.com/us/r/the-fabulist · MasterClass https://www.masterclass.com/ · Louvre Abu Dhabi https://www.louvreabudhabi.ae/en · Cooper Hewitt https://collection.cooperhewitt.org/objects/18704235/ · Sefaria web. Timed out: Museum of Islamic Art https://mia.org.qa/en/
- Typeface subset metadata: https://fonts.google.com/metadata/fonts

**v1 functional benchmarks (appendix below):**
- Ganjoor — https://ganjoor.net/roodaki · https://ganjoor.net/roodaki/baghimande/sh121
- Sefaria (store listings) — https://apps.apple.com/us/app/sefaria/id1163273965 · https://play.google.com/store/apps/details?id=org.sefaria.sefaria
- Quran.com — https://quran.com/1
- Wikisource — https://en.wikisource.org/wiki/Index:Rubaiyat_of_Omar_Khayyam_-_Fitzgerald's_translation.djvu · https://en.wikisource.org/wiki/Page:Rubaiyat_of_Omar_Khayyam_-_Fitzgerald%27s_translation.djvu/13
- Poetry Foundation — https://www.poetryfoundation.org/poems/poem-of-the-day · https://www.poetryfoundation.org/poems/45502/the-red-wheelbarrow
- The Met Heilbrunn Timeline — https://www.metmuseum.org/toah/chronology/ · https://www.metmuseum.org/toah/ht/06/nc.html
- Standard Ebooks — https://standardebooks.org/ebooks/omar-khayyam/the-rubaiyat-of-omar-khayyam/edward-fitzgerald

### MATERIALS / PROJECT DOCUMENTATION CONSULTED (read-only)
`README.md` · `DESIGN.md` · `pubspec.yaml` · `PROVENANCE_PAGE_AUDIT.md` (summary) · `docs/QA_AUDIT.md` (current-state note) · `lib/router/app_router.dart` (route inventory only) · `lib/core/constants/app_constants.dart` and `lib/shared/providers/app_providers.dart` (preference keys, to skip the tour and set the interface language in scripted captures) · `lib/core/l10n/app_translations.dart` (key names only) · `assets/data/**` (IDs for detail routes; the editorial note on Persian-script renderings) · `build/web/version.json`.

### COULD NOT ACCESS
- Sefaria web reader (Cloudflare CAPTCHA, deliberately not completed).
- Vocabulary detail route (no IDs in data). Book category and author routes, the `/favorites` legacy screen, and Literature-search results were not visited.
- A full walkthrough of the live production site (it is an older deployment; only its version and bundle headers were checked).
- Native Android build, offline and PWA behaviour, and screen-reader semantics.

### RESEARCH LIMITATIONS
- Flutter renders to canvas, so text was read from screenshots rather than the DOM. Small text readings could contain transcription slips in this report. Tajik copy in wireframes is placeholder only.
- The in-app pane followed a dark theme, while scripted captures used both themes. Some observations (verse wrapping at 120%, Continue-reading target, quiz feedback position) come from the pane session and were not re-captured as images.
- My preference changes in the pane (parallel mode, text size, language) were in that browser's local storage only, not in the project.
- No real users, analytics, or interviews: audience and needs are inferred.
- External references were reviewed at one moment in time. Sefaria's reader behaviour is inferred from store screenshots only.
- No project files were modified. A static server and the Playwright scripts ran from the session scratchpad and have been stopped.

---

## APPENDIX B — Functional benchmarks (v1 references, retained for interaction patterns only)

I didn't embed external screenshots, to avoid redistributing third-party imagery. Each entry gives the exact URL and what I inspected.

#### R1. Ganjoor (close analogue: Persian poetry archive)
- **Examined**: poet page `https://ganjoor.net/roodaki`; poem page `https://ganjoor.net/roodaki/baghimande/sh121` at about 800 px and at 1440 px (DOM geometry checked).
- **Observed**: Each bayt is a unit separated by a hairline. Hemistichs stack and centre on narrow screens and sit **side by side** at 1440 (first hemistich right, second left, each about 338 px wide). The action row under the title has previous/next poem, share, copy, link, and search within the poem. After the poem: previous and next poem **titles**, then tabs (Info, Vocabulary, Recitations, Images, Practice, Similar rhymes, Marginalia…) and a metadata table (meter, form, **original source**, number of bayts). The poet page has a biography and section links (qasidas, rubaiyat, scattered verses, masnavis, statistics, vocabulary, portraits, **paper sources**).
- **Transferable lesson**: Treat the **bayt as the unit** of layout, action, and navigation. Use responsive hemistich placement. End every poem by leading to the next one.
- **Limitation**: The page is dense, community-driven, and ornamented (dark brown and gold frames). Its tabbed extras are far more than this corpus supports. Don't copy the ornament or the feature count.

#### R2. Sefaria (bilingual religious text library with connections)
- **Examined**: The web reader was **blocked by a CAPTCHA** (`https://www.sefaria.org/Pirkei_Avot.1?lang=bi`), which I didn't bypass. Instead I reviewed official store screenshots: App Store `https://apps.apple.com/us/app/sefaria/id1163273965` ("Browse the Library", "Explore by Topic", Talmud index) and Google Play `https://play.google.com/store/apps/details?id=org.sefaria.sefaria` (Genesis 1 reader screenshot).
- **Observed**: The library index is a list of collections, each with a serif title, a two-line description, and a thin coloured rule per category. The Talmud index has a short intro paragraph, then sections with one-line descriptions. The reader stacks each Hebrew (RTL) verse over its English (LTR) translation, with a single "Aא" language toggle in the header. A "Resources" panel under the text lists connection types **with counts** (Commentary 458, Targum 5, Tanakh 8…), each with a coloured rule. The bottom nav is Texts · Topics · Search · Saved · Account.
- **Transferable lesson**: (a) A browse index made of **titles plus one-line descriptions**, with no boxes. (b) Bilingual text stacked **per unit** (per verse, so per bayt here), with one clearly scoped toggle. (c) A "connections" panel with counts after the text: other works by the poet, history for the period, lexicon terms.
- **Limitation**: Seen only through marketing screenshots, so I have not verified behaviour. Sefaria's connection depth depends on huge cross-references, which this corpus lacks. Show a connection category only when it has items.

#### R3. Quran.com (RTL scripture reading with scoped reading settings)
- **Examined**: `https://quran.com/1`, "Verse by Verse" view and the settings drawer (mobile width).
- **Observed**: Top tabs switch between "Verse by Verse" and "Reading". Each verse has a compact action row (play, bookmark, copy, share, note). The settings drawer has Arabic / Translation / Word-by-word tabs, a **live preview** of the verse, script style choices, a font size stepper, and Reset/Done. An email newsletter pop-up appeared on first visit.
- **Transferable lesson**: Keep **reading settings scoped to the text** (script, size, layout) and separate from app-wide settings, with a live preview. Put actions on the unit (verse or bayt).
- **Limitation**: The sacred-text context and audio recitation don't transfer directly. **Don't copy the newsletter interruption.**

#### R4. Wikisource (page-scan-backed transcription with public proofreading status)
- **Examined**: Index page `https://en.wikisource.org/wiki/Index:Rubaiyat_of_Omar_Khayyam_-_Fitzgerald's_translation.djvu` and Page view `https://en.wikisource.org/wiki/Page:Rubaiyat_of_Omar_Khayyam_-_Fitzgerald%27s_translation.djvu/13` at 1440.
- **Observed**: The index shows the cover scan, bibliographic fields, and a page list where each page number carries a quality class (`quality1` = not proofread, `quality3` = proofread, and so on). Each transcribed page opens with a **plain-language, colour-coded status line**: "This page has been proofread, but needs to be validated." The scan is available from an "Image" tab.
- **Transferable lesson**: **One sentence of status, in plain language, at the top of the text**, with a small fixed vocabulary of states. Show a scan link only when a scan actually exists.
- **Limitation**: The utilitarian wiki look and editing chrome aren't appropriate here.

#### R5. Poetry Foundation (editorial poem page and poem of the day)
- **Examined**: `https://www.poetryfoundation.org/poems/poem-of-the-day` and `https://www.poetryfoundation.org/poems/45502/the-red-wheelbarrow`.
- **Observed**: Title, "BY [POET]", and the poem with preserved stanza spacing. Directly after the poem, in small type, a **Copyright Credit** line and a **Source** line. Then an optional poem guide, Related collections, and audio. The page footer asks "See a problem on this page?". The Poem of the Day page lists **previous days' poems** below today's.
- **Transferable lesson**: Provenance as a **quiet colophon right after the text**, not a badge above it. Put "related" after the reading, not before. Give readers a way to report a problem. Let the daily item have a short archive.
- **Limitation**: The US editorial magazine voice and newsletter prompts don't transfer.

#### R6. The Met — Heilbrunn Timeline of Art History (period navigation)
- **Examined**: `https://www.metmuseum.org/toah/chronology/` (291 region-period entries) and `https://www.metmuseum.org/toah/ht/06/nc.html` (Central and North Asia, 500–1000 A.D.). The site ran an automatic, non-interactive browser check first.
- **Observed**: Each period page has an object strip, an **Overview** paragraph, **Key Events** and **Citation** tabs, a region note listing present-day countries (including Tajikistan), and **Primary chronology** links to the previous and next periods, plus lists of rulers and "See also".
- **Transferable lesson**: History entries should open to an overview and **always offer previous and next period**. Keep citation one tab away, not inline chrome.
- **Limitation**: This is object-driven art history with abundant licensed imagery. Zarbulmasal doesn't have cleared imagery (portrait rights unknown), so a typographic version is needed.

#### R7. Standard Ebooks (trust through transparent production notes)
- **Examined**: `https://standardebooks.org/ebooks/omar-khayyam/the-rubaiyat-of-omar-khayyam/edward-fitzgerald`.
- **Observed**: Word count, reading time, and difficulty. A short editorial note on which edition the text follows. A **plain-language rights statement** ("thought to be free of copyright restrictions in the United States…"). "Read online". "A brief history of this ebook" (dated change log). **Sources** with links to transcriptions and page scans. "Improve this ebook" (how to report errors).
- **Transferable lesson**: Readers trust a text more when they can see **which edition it follows, what changed, and where the scans are**, written in plain sentences. That is the model for replacing leaked field names and file paths.
- **Limitation**: Download formats and reading-ease scores are irrelevant here, and the minimal house style is too spare to carry cultural character on its own.

---


*§9 wireframes and §13 cite these as R1–R7.*
