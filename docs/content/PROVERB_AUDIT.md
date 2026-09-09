# Proverb Content Audit — September 2026

## Scope

The production proverb corpus was reviewed entry by entry for:

- Tajik wording where an obvious textual error was present
- Persian-script translation
- simple Tajik explanation
- intended figurative meaning
- natural contextual example
- production source status

The original seed contained 170 entries. IDs 1–20 were explicitly marked with an unknown source and several contained wording that could not be treated safely as established Tajik proverbs. They were quarantined rather than rewritten or presented as authentic. The production corpus now contains 150 sourced traditional entries (IDs 21–170).

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

## Production guardrail

Automated tests now require every production proverb to have:

- a unique ID
- both Tajik Cyrillic and Persian-script text
- a non-empty meaning
- a non-empty simple explanation
- a non-empty example
- `SourceStatus.verified`
- a non-unknown source note

Unverified legacy sayings must not be reintroduced without a book-level source.
