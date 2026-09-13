# Proverb Content Audit — September 2026

## Scope

The production proverb corpus was reviewed entry by entry for:

- Tajik wording where an obvious textual error was present
- Persian-script translation
- simple Tajik explanation
- intended figurative meaning
- natural contextual example
- production source status

The original seed contained 170 entries. IDs 1–20 were explicitly marked with an unknown source and several contained wording that could not be treated safely as established Tajik proverbs. They were quarantined rather than rewritten or presented as authentic. The current catalog contains 149 book-attested traditional entries plus one needs-review modern entry (IDs 21–170).

## Editorial principles

1. Preserve the proverb itself unless there is strong evidence of an obvious typo or malformed variant.
2. Do not translate word-for-word when that destroys the idiomatic meaning.
3. Keep `simpleExplanationTj` literal and easy to understand.
4. Keep `meaningTj` focused on the figurative lesson actually conveyed by the proverb.
5. Make `exampleSentenceTj` a realistic situation that demonstrates usage instead of merely repeating the proverb.
6. Treat historically specific sayings as historical/cultural material rather than universal modern rules.
7. Do not promote an entry to production if its source is explicitly unknown.

## Notable corrections

Examples of major semantic corrections include:

- `Аз пашша фил масоз`: corrected to “do not exaggerate a small issue.”
- `Об аз сар лой мешавад`: corrected to the leadership/source metaphor: disorder or corruption often begins at the top.
- `Кор кори кордон аст`: corrected to “specialized work should be done by a competent person.”
- `Сарро деҳу сирро не`: corrected to the duty of keeping an entrusted secret.
- `Даҳони пӯшида сад тилло`: corrected to the value of silence when speech would be useless or harmful.
- `Сари хамро шамшер намебурад`: corrected to the protective value of humility/de-escalation.
- `Як дари баста, сад дари кушода`: corrected from the reversed form and explained as continuing opportunity after one setback.
- `Саги аккосак газанда нест`: spelling corrected and meaning restored: loud threats do not always correspond to real danger.
- `Моҳӣ аз сар бадбӯй мешавад`: corrected to the “problems begin with leadership” metaphor.
- `Дарахти пурмева сар хам мекунад`: corrected to humility associated with real accomplishment or knowledge.

## Historical / culturally specific material

Some traditional sayings encode older social assumptions. Their explanations now identify that context instead of presenting the assumption as a universal fact. Examples include sayings about marriage, mothers-in-law, and family roles.

## Source limitations

Current production records preserve the book/source names already present in the repository, including works such as:

- «Зарбулмасал ва мақолҳои тоҷикӣ»
- «Баёзи фолклори тоҷик. Ҷилди 2»
- «Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I»
- «Фолклори тоҷик»
- «Фолклори Роғун»
- «Фарҳанги мардуми диёри Турсунзода»

The current data model does not store edition, publisher, year, or page number for each proverb. Therefore this audit must **not** be described as page-level bibliographic verification. A future provenance upgrade should add edition/page metadata per entry.

## September 2026 provenance follow-up

The only `needsReview` record is ID 28, `Инсон бо забонаш не, бояд бо
амалаш сухан гӯяд.` Exact-phrase searches in both scripts found no book or
folklore attestation, so it remains a `needsReview` `modernCustom` entry. It is
excluded from quiz questions but remains visible in the browsable catalog.

Digitized primary-source scans produced 19 strong candidates for later
`pageVerified` promotion. Statuses remain unchanged until the model can record
edition metadata and distinguish printed pages from PDF scan pages:

- [Воҳид Асрорӣ, *Зарбулмасал ва мақолҳои тоҷикӣ*](https://zarowadk.com/dnld/folklor/zarbulmasal_va_maqolho.php) (Сталинобод:
  Нашрдавтоҷик, 1956): IDs 24 (25/24), 34 (32/29), 36 (81/78), 39
  (74/71), 41 (65/62), 67 (74/71), 74 (54/51), 80 (51/48), 87
  (53/50), 100 (42/39), 117 (45/42), 118 (45/42), 144 (35/32),
  147 (68/65), 150 (43/40), and 164 (67/64).
- [Б. Тилавов et al., *Баёзи фолклори тоҷик*, ҷ. 2](https://zarowadk.com/dnld/folklor/bayozi_ft_2.php) (Душанбе: Адиб,
  1990): ID 45 (31/31).
- [Муллоҷон Фозилов, *Фарҳанги зарбулмасал, мақол ва афоризмҳои
  тоҷикию форсӣ*, ҷ. I](https://zarowadk.com/dnld/folklor/fozilov_farh_zarbulmasal_1.php) (Душанбе: Ирфон, 1975): IDs 98 (69/70) and
  116 (101/102).

Each pair above is `printed page/PDF page`. The scans contain unnumbered leaves,
so those numbers are not interchangeable. Other matches were absent, uncertain,
or lexical variants and therefore do not justify changing authentic wording or
provenance status.

## Production guardrail

Automated tests now require every production proverb to have:

- a unique ID
- both Tajik Cyrillic and Persian-script text
- a non-empty meaning
- a non-empty simple explanation
- a non-empty example
- a recognized catalog provenance state (`bookAttested`, `pageVerified`, or
  the explicitly quiz-excluded `needsReview`)
- a non-unknown source note

Unverified legacy sayings must not be reintroduced without a book-level source.
