# Zarbulmasal — Current Production Readiness Report

## Fresh continuation audit — 2026-09-22

This block supersedes older build, test, deployment, and working-tree
statements below where they differ.

### Source-attested content continuation

The user-approved publication rule now accepts one exact page from an uploaded
project PDF or `maorif.tj`; a second witness is optional. Under that rule, 28
works have restored, verified Tajik text and an explicitly labeled generated
Persian-script representation. Three other page-checked records remain without
text because no exact recoverable transcription was available; they are not
guessed or displayed. The catalog totals remain 5,501 works: 31 primary-page
checked, 5,215 awaiting review, and 255 rejected extraction/prose candidates.

The current local gates are **437/437 Flutter tests passing**, **84.41% line
coverage (8,195/9,708)**, **60/60 Python tool tests passing**, clean static
analysis, passing provenance/content validators, and a successful web build.
This continuation has not been pushed or deployed. The historical blocked
release assessment below still applies to portrait and repository page-scan
redistribution, but its statement that zero poems are locally displayable is
superseded by the 28 source-attested works above.

**Fresh production-audit score: 44/100 — BLOCKED.** This qualitative score is
for the Literature/Books release scope: 0 approved/displayable poems, unknown
redistribution rights for every bundled portrait, and 66 textbook page scans
still tracked in the public GitHub repository outweigh the passing local UI and
test gates. The older 84/100 checkpoint score is superseded.

- Local branch: `provenance-repair-2026-09-19`; this worktree has uncommitted,
  scoped Persian-display fixes. Nothing from this continuation has been pushed
  or deployed.
- `flutter test --coverage --no-pub`: **433/433 passed**; coverage is
  **84.37% (8,131/9,637 lines)**. Formatting check: **154 files, no changes**;
  `flutter analyze --no-pub`: **no issues**.
- `python3 -m unittest discover -s tool -p 'test_*.py' -q`: **36/36 passed**;
  the provenance linter and adversarial re-audit also pass.
- Fresh `flutter build web --no-pub --base-href /` and
  `flutter build apk --debug --no-pub` both pass. The current local web preview
  is `http://127.0.0.1:8772/`; the debug APK is
  `build/app/outputs/flutter-apk/app-debug.apk`.
- Five viewport smoke checks pass at 320×568, 375×667, 390×844, 430×932, and
  568×320 with no document-level horizontal overflow, browser errors, or failed
  requests. Real search, quiz-feedback, and flashcard-reveal interactions pass
  at 320px and 390px. Literature hub, poet list/detail, works, Books list/detail,
  and global search were screenshot-checked at both 320px and 390px, with no
  horizontal document overflow. The compact poet dossier layout now keeps long
  names intact and moves the full literary-period context below the biography.
- Accessibility widget regressions measure contrast and key semantics, but this
  is not a complete WCAG 2.2 sign-off: the referenced audit checklists/render
  gates were unavailable, and native screen-reader/device QA was not performed.
- Fresh browser review verified Persian RTL Books list/detail, the localized
  source-note fallback, category filtering, and explicit Tajik-original
  title/author disclosures where reviewed Persian fields are unavailable. All
  18 catalog books still lack reviewed Persian title and author-name fields;
  the original fields are labeled as Tajik, not presented as translations.
- The 7 literature PDFs (grades 5–11) are registered in the source inventory;
  the copies under `pdf books/` and `docs/literature/pdfs/` have matching
  SHA-256 digests. The separate Grade 5 history PDF is not counted as a
  literature textbook. The inventory regeneration produced no content change.
- Fresh data validators: **159 authors**, **5,501 works**, **0 approved**,
  **31 primary-page-checked**, **5,215 pending review**, and **255 rejected**;
  no Tajik or Persian poem text is shipped. Provenance lint passes. The 67
  source-backed portraits remain, with placeholders for authors lacking a
-  reliable image. All **67 portraits have `rightsStatus: unknown`**; source
  attribution establishes identity/provenance, not redistribution permission.
- The repository is confirmed **public**. **66 page-scan PNGs are Git-tracked**
  as audit evidence (not Flutter assets), so excluding them from the app bundle
  does not prevent public GitHub distribution. The issue is recorded in
  `docs/QA_ISSUE_REGISTER.md`; do not publish another release until rights are
  established or the evidence is moved out of the public repository.
- GitHub run [35664585090](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/runs/35664585090)
  (#86) is for older commit `e1199c2` on `audit-publish-2026-09-22`, not this
  dirty worktree. It reports 393 passed and 3 failed in the Android job; the
  current local suite passes. The latest Pages workflow [35667658617](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/runs/35667658617)
  succeeds at `gh-pages` commit `d2ae804`, but this is still the older build.
  The live app and `/privacy.html` both return HTTP 200; neither includes these
  unpushed changes.
- Android devices are unavailable in this session, and no production signing
  material was supplied; release signing and physical-device QA remain open.

**Status: NOT READY FOR PUBLIC LITERATURE/BOOKS RELEASE OR GOOGLE PLAY**

**Historical checkpoint score at `2313edd`: 84/100 — superseded by the fresh
44/100 blocked audit above; do not use for the current release decision.**

The details below record the earlier evidence snapshot, not a release sign-off.
At that checkpoint the repository working tree was clean; the current dirty
worktree is described in the fresh continuation audit above. The earlier local
source checkpoint was `2313edd`; the review branch `audit-publish-2026-09-22`
included that source at `644051d`. Its workflow file remained at the previous
published revision because the connected GitHub OAuth credential did not have
the `workflow` scope.

Prior published content-repair evidence (2026-09-22): the rebuilt web artifact uses
cache ID `537219cd1f6ef81793f6`; the web-only Pages deployment is `gh-pages`
commit `d2ae804`; and the live app root and
`privacy.html` return HTTP 200.
The live browser sweep covers 8 viewports and 209 route/mode visits with zero
errors, overflows, console errors, page errors, or request failures. Android
download publication remains withheld pending production signing.

## Current source and content state

Current content-loop override (2026-09-22): the validator reports **31
primary-page-checked works, 25 secondary-witness collations, 6 checked works
without a second witness, 5,215 pending works, 255 rejected extraction/prose
or duplicate candidates, and 0 pending review records without a printed page**.
The final three page gaps were verified against Grade 11 pages 290 and 298 and
Grade 6 page 12, with the exact held-edition metadata recorded in `works.json`.
This loop also added image-backed Grade 7 2025 second witnesses for Firdausi
(p. 46, minor typographic variant) and Kamol (p. 272, exact).
New page proofs and attribution/title corrections are retained in the source
data; rights remain unknown, so all checked works stay withheld.

- Package: `com.zarbulmasal.zarbulmasal`
- Source version: `2.0.0+2004`
- Literary authors: 159 catalog records (145 public; 6 rejected extraction/non-author artifacts; 8 pending review)
- Literary works: 5,501
- Books catalogue: 18 canonical books and 18 editions; 8 editions have
  source-backed covers bundled from their exact provider cover URLs, while
  the remaining 10 retain the consistent no-cover placeholder because their
  provider pages expose no dedicated matching cover.
- Book detail renders verified related-poet links separately from the source
  author, including Persian labels/names; the live Ahmadi Donish → Ahmad Donish
  route was tapped through to the poet dossier after the final deployment.
- Source-backed portraits: 67 of 159 authors; the remaining authors use the
  consistent no-invented-face placeholder until another reliable source is
  verified
- Poem page imagery is optional: works without a verified book-page image stay
  image-free, with no image affordance or substitute artwork. No portrait,
  cover, or page image is invented to fill a missing source.
- Inspected book-page scans remain outside the public app asset bundle, but 66
  are still Git-tracked in the public repository. A regression guard prevents
  bundling them; it does not prevent GitHub from distributing the source files.
- Tajik biographies with non-unsupported provenance: 145 of 159 authors
  (76 marked `SOURCE_BACKED`, 69 declared editorial summaries); 14
  biographies remain quarantined
- The latest conservative evidence pass promoted two previously review-only
  reference records: Ҳасанбеки Рафеъ (Grade 7, p. 150) and Абӯсаиди
  Абулхайр (Grade 7, p. 159). Neither record invents dates, places, or a
  broader bibliography beyond the cited textbook attribution.
- A later Ministry-textbook sweep added exact page leads for seven review-only
  references—Фарҳат, Бадри Чочӣ, Пушкин, Лермонтов, Маршак, Виктор Гюго,
  and Рафаэл Патканян—without promoting any record or assigning a portrait;
  the pages mention the names or works but do not establish complete identity
  and biography evidence.
- Editorially approved works: 0
- Primary-page-checked works: 31, all still rights-unknown and non-displayable
- Secondary-witness collations: 25 (Sayyido p. 161 (minor spelling variant), Hafez, Tursunzoda, Bozor Sobir, Rabi’a Balkhi, Sadriddin Ayni (minor variant),
  Kamol Khujandi (two works, one current Maorif exact witness), Qanoat (three
  works, one minor variant), Rudaki (two works, one minor variant), Saadi, and
  two Ibn Sina works, plus exact Ministry-hosted witnesses for Bedil p. 146,
  Hafez p. 93, Lоҳутӣ p. 113, and Loiq Sherali p. 288); 6 of the 31
  page-checked works still lack a second witness
- Provenance correction: the Grade 7 2025 pp. 102–103 witness is attached only
  to Kamol Khujandi’s «Дӯст медорад дилам ҷавру ҷафои дӯстро»; it was removed
  from the distinct «Ошӯби ҷонӣ» record, whose held Grade 7 2018 primary page
  is printed p. 106. Both remain review-only.
- A fresh cross-book sweep added complete Ministry-hosted witnesses for Hafez’s
  16-line ghazal (Grade 9 p. 173, 2023; exact), Qanoat’s «Мавҷ дар саҳро»
  (Grade 6 p. 148, 2022; minor variant), Sadriddin Ayni’s four-line poem
  (Grade 5 p. 132, 2022; minor variant), and Rabi’a Balkhi’s qasida (Grade 5
  pp. 61–62, 2022), Tursunzoda’s four-line excerpt (Grade 11 p. 160, 2022;
  exact), Bozor Sobir’s eight-line excerpt (Grade 11 p. 313, 2022; exact),
  and Qanoat’s «Мавҷи одам» (Grade 6 pp. 149–150, 2022; exact) and «Мавҷи
  бародарӣ» (Grade 6 pp. 150–151, 2022; exact), and Rudaki’s «Бӯйи Ҷӯйи
  Мулиён» (Grade 5 p. 56, 2025; minor orthographic variant).
  The remaining Hafez and Qanoat occurrences are retained as additional source
  citations.
- The uploaded Grade 9 textbook also supplies a visually inspected six-line
  Hiloli occurrence on printed p. 316. It is retained as `sourceOccurrences`
  only because the complete 12-line primary poem is not reproduced there; the
  six-record missing-secondary-witness count is unchanged.
- A further read-only sweep of current Maorif library editions for Grades 5, 6,
  7, 9, 10, and 11 found complete witnesses for the two Qanoat sections above
  and Rudaki’s «Бӯйи Ҷӯйи Мулиён». A phrase-level negative sweep of the current
  Grade 7 and Grade 11 PDFs found no complete distinct witness for the two
  remaining page-checked records. The Grade 11 2022 edition does preserve
  Lo(iq)’s title and identifying couplet in a test question on printed p. 304;
  it is recorded as a source occurrence with inspected page evidence, not
  promoted to a secondary witness.
- Quarantined `needsReview` works: 5,215
- Current pending gaps: 5,215 records remain under review with line/script and
  editorial gates incomplete; 6 of the 31 primary-page-checked records still
  lack a second witness, while **0 pending records lack a printed primary
  page**. All remain withheld from display.
- Rejected false-positive or duplicate extraction records: 255 (classroom
  questions, biographical/explanatory prose fragments, or duplicate candidates;
  retained in the audit ledger)
- Duplicate canonical work records: 0; 31 duplicate extraction records were
  merged while preserving 38 distinct source occurrences, and 6 additional
  duplicate candidates are explicitly linked to their canonical records and
  quarantined.
- Runtime assets ship **zero full-text fields and zero incipits** for the
  rights-unknown catalog. The 31 page-checked records remain `primaryChecked`
  only; rights and editorial approval are still absent.
- Textbook page scans remain audit evidence only: they are not bundled in the
  Flutter asset manifest or shown until publication rights are cleared.
- Generated Persian-script title fields are labeled as representations, not
  semantic translations or Persian source witnesses; full-text Persian
  representations are not shipped for the rights-unknown records. The Persian
  zero-leak regression also rejects Latin or Cyrillic artifacts inside Persian
  titles; two corrupted generated candidate titles were withheld rather than
  guessed and the full suite passes.
- Oral heritage retains 14 rights-unknown metadata records, but ships zero
  Tajik or Persian oral-text fields until verification and publication rights
  are cleared; the runtime provider therefore exposes none of them.

The active catalog is deliberately fail-closed. An unreviewed 2,243-record
candidate extraction was quarantined outside the checkout after it failed
author-reference and rights-consistency validation; it is not shipped data.

## Automated evidence

The latest local checks on this worktree report:

- `flutter test --coverage --no-pub`: **428/428 passed**
- Coverage: **8,119/9,626 lines (84.34%)**
- `python3 tool/check_coverage.py coverage/lcov.info --minimum 80`: **pass**;
  the CI gate enforces the documented 80% minimum.
- Accessibility regression: the Home and Explore search entries plus the
  verified SourcePanel page-facsimile action expose localized labels, tap
  actions, and button roles; the Literary Heritage and Daily Verse cards plus
  the SourcePanel review badge now meet measured 4.5:1 normal-text contrast;
  source-backed portraits expose one citation-aware image semantics node; the
  full suite includes these semantics/contrast checks alongside quiz-feedback
  announcements. SourcePanel secondary witnesses and additional source
  occurrences now expose their full human-readable citations and exact pages;
  the focused regression and dark-mode/Persian RTL browser checks pass.
- `flutter analyze`: **no issues**
- `dart run tool/validate_literature_json.dart`: **pass**
- `dart run tool/validate_literary_content.dart`: **pass**
- Literary validator report: **31 primary-checked; 6 still lack a second witness**, surfaced explicitly by the `PRIMARY CHECKED MISSING SECOND SOURCE` metric
- `python3 tool/provenance_linter.py`: **pass; 0 errors**
- CI-equivalent Python literature/provenance/portrait/duplicate guards and
  release-shell syntax checks: **pass**; duplicate, portrait, and false-candidate
  tests pass in both direct-script and module invocation modes.
- `python3 tool/provenance_repair_loop5_adversarial.py`: **pass**; the raw
  fake-page, generated-source, and unreviewed-verifier sweep now runs in CI.
- Provenance source-image/bibliography guard: **pass**; page-checked records
  require verified primary-page imagery, declared image paths must resolve
  beneath the local page-image evidence directory, and checked/secondary
  witnesses must carry complete bibliographic identity, inspected local page
  imagery, plus an uploaded-PDF or `maorif.tj` source reference
- Standard security scan (`d53aabe8-cda0-4b0c-80be-6d983557a2ad`, 21 September
  2026): **0 reportable findings in reviewed surfaces**; coverage remains
  partial because the 739-file target was not closed file-by-file, and
  production-signed/native/live deployment evidence is unavailable
- Final working-tree diff scan (`e449b572-260e-4399-9a7d-820d12f4f212`, 21
  September 2026): **0 reportable findings across 111 review items**, with no
  scan warnings; coverage remains partial across the broader 740-file target
- The sealed diff review does not replace production-signed, live-host, or
  physical-device evidence
- Provider catalogue metadata now fails closed at the repository boundary when
  its identifier or external URL is invalid; direct model access exposes only
  URLs accepted by the central HTTPS host policy
- Rights-distribution scrub: **pass**; no rights-unknown work or oral record
  ships text or an excerpt, and the candidate builder plus validators enforce
  the same rule.
- `python3 -m unittest tool.test_legacy_literature_guards -v`: **pass**; legacy
  catalog writers fail closed before they can modify active assets
- `python3 -m unittest discover -s tool -p 'test_*.py' -q`: **36/36 passed**;
  provenance, source-register, and Android bundle-alignment guards are covered
  in CI; the Android alignment test also passes through its direct executable
  path (`python3 tool/test_android_bundle_alignment.py -q`)
- Release helper syntax gate: **pass**; CI now runs `bash -n` over the Android
  signing, bundle, alignment, artifact, download, web-release, Pages-deploy,
  and local-server scripts before the release path.
- Source-register evidence boundary: **pass**; unsupported bibliographic
  candidates are explicitly marked legacy/unverified and cannot be mistaken
  for checked witnesses or active release provenance
- Dependency audit: no current package is reported as affected by an advisory,
  retracted, or discontinued; nine compatible transitive patch updates are
  locked, while major Riverpod/GoRouter upgrades remain intentionally deferred
  pending a dedicated migration and regression pass. CI now uses
  `flutter pub get --enforce-lockfile` in both quality and web jobs.
- `flutter build apk --debug --target-platform android-arm64`: **pass** after
  the dependency refresh; produced `build/app/outputs/flutter-apk/app-debug.apk`.
  This confirms the Android compile path only and does not close production
  signing, signed-upgrade, or physical-device gates.
- Android manifest regression: **pass**; release configuration disables
  cleartext traffic, requests no runtime Internet permission, and only queries
  HTTPS VIEW handlers plus Flutter text processing.
- `flutter build appbundle --release --no-pub`: **pass** with a temporary QA
  certificate for technical release-pipeline verification; the current 59.7 MB
  AAB is not a publication artifact because its certificate is not the protected
  Play identity.
- Fresh current-data AAB evidence (2026-09-22): QA certificate SHA-256
  `e6c4a6a69ad368c6cea3e485f25de825b5d2437f6c4ef33dd10cc7a567b82c9d`, AAB
  SHA-256 `4d6c9c64c2ae3dd8bd206913777624b48ce454e78769ed3c16fad7c23dd7af13`,
  size 63,332,434 bytes, and source/embedded `works.json` SHA-256 match
  (`84832ddc565ab61a8ed37b4fd7d7e96a602ea27f95cd05516eb3519424d33a8d`).
  Mapping SHA-256 is `e88f938cedcbefc5e0a1a6a4d479a158d5d1764fa525d124b128c7e736e8f1f2`;
  native-symbol SHA-256 is `d52af33b2d5414431bedd175daa9d9b5a1b2f473579088daaed85053a1ef993e`;
  3 Dart-symbol and 6 native-symbol files were retained. This is a diagnostic QA
  identity only, not a Play signing identity.
- `python3 tool/verify_android_bundle_alignment.py build/app/outputs/bundle/release/app-release.aab`: **pass**; all 9 native libraries meet 16 KB ELF alignment
- `bash tool/verify_android_signing_material.sh`: **expected fail-closed** without production signing variables; the CI preflight validates the decoded keystore, private-key alias, protected `EXPECTED_RELEASE_CERT_SHA256`, and rejects `CN=Android Debug` before release compilation
- `bash tool/verify_android_bundle.sh build/app/outputs/bundle/release/app-release.aab`: **pass** for the temporary QA certificate after case-insensitive certificate-digest normalization; package/version, signature, and 16 KB alignment checks pass
- `bash tool/verify_android_bundletool_alignment.sh build/app/outputs/bundle/release/app-release.aab <bundletool-1.18.3.jar>`: **pass** for the temporary QA certificate; the checksum-pinned official bundletool 1.18.3 reports `PAGE_ALIGNMENT_16K`
- `bash tool/verify_android_release_artifacts.sh build/app/outputs/bundle/release/app-release.aab`: **pass** for the temporary QA certificate; mapping, native debug symbols, Dart symbols, ZIP integrity, and 16 KB alignment all pass
- `flutter build apk --release --split-per-abi` plus universal release APK: **pass** with a temporary QA certificate; `tool/prepare_android_downloads.sh` passed package/version/ABI/certificate, zipalign, and SHA-256 staging checks. These APKs were diagnostic only and not published.
- CI release archival now separates the APK-rooted public-download artifact from the retained AAB/mapping/native-symbol/Dart-symbol evidence artifact, preventing unrelated `build/` paths from changing the APK archive root consumed by the Pages job.
- `flutter build web --release`: **pass**, including the static privacy-policy
  artifact check
- The CI web job now installs pinned Playwright 1.62.0, serves the prepared
  release artifact under `/zarbulmasal/`, and runs the full browser audit before
  publishing. The latest local reproduction on 21 September 2026 covered 8
  viewports and 209 route/mode visits, including all 159 poet routes and all 18
  book routes, with 0 errors, overflows, console errors,
  page errors, or request failures.
- `git diff --check`: **pass**
- The 9 MB literary works catalog is decoded off the UI isolate where Flutter
  supports background computation and is memoized after a successful load;
  failed loads are evicted so retry remains functional. A repository regression
  test covers both behaviors.

## Local browser smoke evidence

The fresh local release web artifact was served under its deployed base path
`/zarbulmasal/` and visually exercised through onboarding, the Literature hub,
an actual pending work, its source panel, and an invalid work ID. The pending
record displayed its page citation and review state without poem text; the
source panel displayed the page-image withheld notice rather than exposing the
audit scan; and the invalid ID rendered the localized safe error state. After
enabling Flutter's web accessibility bridge, semantic labels for the pending
record, source button, dialog, and withheld notice were exposed. This remains
web evidence—not a substitute for native TalkBack, font-scale, and
signed-device verification.

A post-scrub spot check of the rebuilt artifact also confirmed that the Works
route renders the review-only empty state rather than distributed snippets, and
the known pending record still shows its printed citation without poem text.

The rebuilt artifact then passed the local Playwright sweep across 8 viewports
and 209 route/mode visits, including all 159 poet routes, all 18 book routes,
Persian/RTL, and dark-mode passes: no page
errors, route errors, failed requests, console errors, or layout overflows were
recorded. Four Chromium GPU-stall warnings occurred only during the
smallest-viewport screenshots; no app or network errors accompanied them. The
audit harness now exits nonzero when a real diagnostic or overflow is found.

A fresh corrected-data web rebuild on 21 September 2026 repeated the same
8-viewport, Tajik, Persian/RTL, dark-mode, and major-route sweep after fixing
the Ibn Sina attribution, adding three Qanoat records, admitting two
additional source-backed portrait records, and recording a Grade 10 source
occurrence for the Hafez ghazal, adding the exact Grade 8 secondary collation
for the Ibn Sina rubai, and promoting eleven page-backed biographies
(including Ozarbod Mehraspandon, Masudi Marvazi, Abu Hafs Sugdi, Muhammad bin
Vasif as-Sijzi, Abulmuayad Balkhi, Abuabdulloh Jayhani, Abuali Balami,
Masudi Saadi Salman, Zahiri Samarqandi, Mavlono Nahvi Herati, and Qozizoda). It
again recorded zero page errors,
route errors, failed requests, console errors, or horizontal overflows across
29 route/mode visits. The subsequent semantic author-dedup pass removed three
duplicate canonical author records (Sanai, Jami, and Shahid Balkhi) and
redirected their works, book, canon, and evidence references. After the final
eleven-biography upgrade, the release rebuild passed the same 8-viewport,
29-route/mode sweep with zero diagnostics; its prepared web cache is
`703859aab2d66fd9c0c8`.

After that sweep, a further source-backed biography pass added Zahir Faryabi,
Salmani Savaji, Amir Shahi Sabzvari, Rashidi Vatvat, Shams Tabrizi, and Ghani
Kashmiri, Juma Odina, Abulmaoli Nasrulloh, Faromuz ibn Khododod,
Mirzosodiqi Munshi, Gulkhani, Qaani, Savdo, Karomatullohi Mirzo, Sayf
Rahimzodi Afardi, Buzurgmehr Hakim, Junaydullohi Hoziq, Qori Rahmatullohi
Vozeh, Haji Husayni Kangurti, Sattor Tursun, Mehmon Bakhti, and Abdulhamid
Samad with page citations; the conservative candidate audit also
quarantined 33 additional unmistakable exercise/prose false positives.

The current rebuild after adding the Maorif Grade 11 source occurrence for
Lo(iq)’s «Қасидаи модар» passed the same 8-viewport browser audit across 34
route/mode visits with zero page errors, route errors, failed requests, console
errors, or horizontal overflows. Its prepared web cache is
`308a2dd2e0809dbadbad`.

The latest rebuild after hardening the page-image guard against a verified flag
without a concrete local asset path passed the same 8-viewport, 34-route/mode
audit with zero page errors, route errors, failed requests, console errors, or
horizontal overflows. Its prepared web cache is
`ecd70a48071cedadf530`.

The current rebuild after recording the official Maorif Grade 11 2025 edition
as a reviewed source lead passed the same 8-viewport, 34-route/mode audit with
zero page errors, route errors, failed requests, console errors, or horizontal
overflows. The edition’s Lo(iq) section does not contain a complete «Қасидаи
модар» witness, so it was recorded for audit provenance only and no poem was
promoted. Its prepared web cache is `377081a64096ed3b15da`.

The subsequent review-list integrity pass keeps quarantined records in the
audit dataset but only names pending works on poet profiles when both a source
reference and printed page are present. Unlinked extraction leads are counted
and explicitly withheld from the public review-title list; focused UI tests,
 the full 387-test suite, and the rebuilt browser sweep passed after this change.

Literature search now uses the stricter page-checked review set for work
discovery. Pending results are visibly labeled and open to a source-citation
state with text withheld; raw extraction candidates remain undiscoverable until
editorial review.

The current privacy-metadata refresh rebuilt the web artifact with the policy
date synchronized to 21 September 2026 in English, Tajik, and Persian. Its
8-viewport, 34-route/mode browser audit again recorded zero page errors, route
errors, failed requests, console errors, or horizontal overflows. Prepared web
cache: `fd20d4d7a6260e599704`.

The latest content-quarantine rebuild added one verified uploaded-PDF page
citation and quarantined four prose/quoted-verse extraction false positives.
Its fresh browser audit covered 8 viewports and 209 route/mode visits with
zero page errors, route errors, failed requests, console errors, or horizontal
overflows. Prepared web cache: `953279a53f804958ccf5`.

A read-only reachability check on 21 September 2026 returned HTTP 200 for all
18 catalog read links and all 18 catalog source links. Eight provider-declared
cover URLs also returned valid JPEG images matching their canonical book pages;
those exact responses are bundled under `assets/data/books/covers/` while
their original URLs remain in the edition metadata. The other 10 cover entries
remain intentionally unfilled after the provider pages exposed only a generic
placeholder or covers belonging to different books. This verifies current
availability only; it does not grant redistribution rights or replace the
trusted-host and provenance checks.

The same current web artifact was then swept with the Books list and
`Баъди борон` detail routes included, plus Persian Books detail with an
explicit `Kitobkhon · kitobkhon.net` marker assertion and dark-mode Books: 8
viewport configurations and 34 route/mode visits recorded 0 page errors,
route errors, failed requests, console errors, or horizontal overflows.

After the Persian-title integrity fix, the rebuilt path-aware web artifact
again passed 8 viewport configurations and 34 route/mode visits with zero page
errors, route errors, failed requests, console errors, or horizontal overflows;
the Persian and dark Literature screenshots were visually spot-checked.

The Persian result was independently corrected on 20 September 2026 after
review found that the earlier harness wrote Flutter Web preferences in the wrong
storage format and did not verify CanvasKit's localized semantics tree. The
current harness JSON-encodes those preferences, enables Flutter semantics,
requires Persian markers on seven route visits, and rejects the Tajik home
marker. The corrected sweep passed all 29 visits; the saved Persian Home and
Literature captures show Persian labels and RTL layout.

The native environment check for this audit found no connected Android device
(`flutter devices`: no devices; `adb devices -l`: no authorized devices) and no
available emulator images (`flutter emulators`). This run therefore adds no
fresh native install, upgrade, offline, TalkBack, font-scale, or 16 KB-device
evidence; the signed-device gates below remain open.

The latest sealed Standard security scan
(`1cbcd37a-d3ad-4874-b6a1-261499b52de9`) found **0 reportable findings** across
the inspected runtime/state, URL, Android release, web/cache, GitHub
publication, provenance, and dependency surfaces. The 761-file worktree
inventory was available, but coverage is explicitly **partial** because
protected GitHub controls, production signing, live Pages publication,
physical-device upgrade, and a fresh advisory database were not observable;
this is not a repository-wide clean sign-off.
The previous sealed Standard security scan
(`d53aabe8-cda0-4b0c-80be-6d983557a2ad`) found **0 reportable findings** across
its inspected Android identity/signing, CI secret, external-URL, provenance,
persistence, privacy, web-shell, and source-inventory surfaces. Coverage is
explicitly **partial**: no delegated-worker runtime was available, the target
contains 739 files, and the remaining independent repository review,
production-signed artifact, Play Console configuration, live HTTPS deployment,
and physical 16 KB-device evidence still require follow-up.
The final sealed working-tree diff scan
(`e449b572-260e-4399-9a7d-820d12f4f212`) also found **0 reportable findings**
across 111 review items with no warnings. The later source-inventory synchronization is covered by the rerun Python
guards and validators, not retroactively by earlier scans.

## Android release gate

The current debug manifest reports package
`com.zarbulmasal.zarbulmasal`, version `2.0.0` / code `2004`, compile SDK 36,
target SDK 36, and min SDK 24. The target meets the Android 16/API 36 Google
Play submission requirement effective 31 August 2026 ([official target API
policy](https://developer.android.com/google/play/requirements/target-sdk)). The local diagnostic
release bundle was also inspected for the Android 16 16 KB-page transition:
its native ELF load segments were all aligned to at least 16 KB, its generated
APK passed `zipalign -c -P 16 -v 4`, and checksum-pinned bundletool 1.18.3
reported `PAGE_ALIGNMENT_16K`. This is diagnostic evidence only; the final
signed bundle still needs the production-signing and Play-side bundle
verification path. Google’s current guidance requires 16 KB support for apps
targeting Android 15/API 35 and higher, with unsupported updates blocked from
release beginning 1 February 2027 ([official 16 KB guidance](https://developer.android.com/guide/practices/page-sizes));
physical-device evidence is still missing.

`flutter build appbundle --release` was run against the current tree and fails
closed at `android/app/build.gradle.kts:61` with:

```text
Release signing config missing
```

No production keystore or trusted public signing certificate is available in
this environment. The connected Xiaomi phone currently runs a debug-signed
`2.0.0+2004` APK; a temporary-key/debug diagnostic artifact is not a Play
release artifact and must not be used for publication or upgrade evidence. The current Flutter
toolchain resolves to AGP 9.0.1 and NDK 28.2. The temporary QA bundle passes
the repository alignment verifier and bundletool `PAGE_ALIGNMENT_16K` check;
the production-signed bundle and physical 16 KB-device run remain open before
that compatibility claim can be closed.

## Remaining release blockers

1. Supply the production keystore, credentials, and its SHA-256 digest through
   the protected CI secret path; build and verify the signed AAB with the
   configured production certificate.
2. Verify a signed upgrade from the published version on a physical Android
   device, including data preservation and the critical Persian/RTL/offline
   flows.
3. Keep the verified web deployment and post-publish browser/privacy checks in
   CI; Android download publication remains withheld until production signing.
4. Complete page-level editorial collation and rights review before promoting
   any literary record from review-only to displayable content.
5. Complete native accessibility verification (TalkBack/semantics, enlarged
   text, focus order, and touch targets) on a signed Android build.

Until those items are evidenced, the app should not be described as
production-ready or submitted to Google Play.
