# Google Play: what is still needed

Written 25 Sep 2026, after the `1.0.0-preview.1` preview. The preview is **debug-signed and for testers only**. Nothing below has been done yet.

## 1. The preview cannot become the Play app

- The preview APKs are signed with the Android **debug key** (`CN=Android Debug`, SHA-256 `93287a41…57f91e`). Android only updates an app with one signed by the same key, so the Play version **cannot install over the preview**.
- **Testers must uninstall the preview** before installing from Play. Uninstalling clears their bookmarks and settings.
- The preview was built with the switch `-P previewDebugSigning=true` (see `android/app/build.gradle.kts`). Without it, a release build still **fails** unless the real key is supplied. Never pass that switch for a Play build.

## 2. The upload key (you create it; never commit it)

1. **Create an upload key** on your own machine and keep it, with its passwords, in a password manager and one offline backup:

   ```
   keytool -genkeypair -v -keystore ~/zarbulmasal-upload.jks \
     -keyalg RSA -keysize 4096 -validity 10000 -alias upload
   ```

2. **Point the build at it.** The build reads `KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS` and `KEY_PASSWORD` from the environment or `-P` properties. It does not read `android/key.properties`. CI reads the same values from GitHub secrets, plus `EXPECTED_RELEASE_CERT_SHA256`, which `tool/verify_android_signing_material.sh` checks.
3. **No earlier key exists.** CI is already wired for `KEYSTORE_*` secrets, but the v1.0.1 APKs on GitHub Releases were signed with `CN=Android Debug` too. So the Play upload key is the first real key, and nobody with v1.0.1 or the preview can update to the Play version without uninstalling.

## 3. Play App Signing and the first upload

1. **Create the app** in Play Console with package `com.zarbulmasal.zarbulmasal`. This ID can never change after the first upload.
2. **Turn on Play App Signing.** Google keeps the app-signing key; you upload with your upload key.
3. **Build the bundle.** Do not pass `previewDebugSigning`:

   ```
   flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
   ```

   Keep `build/debug-info` for every release; crash stack traces cannot be read without it.
4. **Upload to Internal testing first.** Add testers by email and check install, update and a quick tour. Then move to Closed testing. New personal developer accounts must run a closed test before Production; the rule was 12 testers for 14 days, so check the current one in Play Console.

## 4. Version and SDK checks before each upload

- **versionCode** must be higher than every code uploaded before. `pubspec.yaml` is now `2.0.0+2007`.
  - The preview used versionName `1.0.0-preview.1` with code 2005 (4005 for the arm64 split APK); the Phase 10 phone check used `1.0.0-preview.2`, code 4006.
  - The first Play bundle (26 Sep 2026) is `2.0.0+2007`; its arm64 split APK is 4007.
- **Upload key:** kept outside the repository, never committed; the owner holds the location and must keep a backup. Build with its variables exported (`KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`, `EXPECTED_RELEASE_CERT_SHA256`); `tool/verify_android_bundle.sh` checks the signed bundle.
- **versionName** is only shown to users. Choose one line and keep it: `2.0.0` is in `pubspec.yaml`, while the preview said `1.0.0-preview.1`.
- **targetSdk** is 36 today (from Flutter). Play requires the current yearly level; check it in Play Console before each upload.
- **minSdk** is 24 (Android 7).
- **The app requests no permissions.** The only manifest entry is AndroidX's internal `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`; there is no INTERNET permission. Links to maorif.tj open in the phone's browser.

## 5. Store paperwork

- **Privacy policy on a public web page.** `web/privacy.html` exists and CI checks it is published at `https://abubakrmmarufov-tech.github.io/zarbulmasal/privacy.html`. Make sure it is live before submitting, and update its date if anything changes.
- **Data safety form:** no data is collected or shared. There are no accounts, analytics, ads or crash reporting. Bookmarks and settings stay on the device, and there is no network access.
- **Content rating:** fill in the IARC questionnaire (an educational reference; no violence, gambling or user content). Target audience: school students, so read the "Designed for Families"/children rules if you list under 13s.
- **Store listing:**
  - app name, short and full description (Tajik, and optionally Persian and English);
  - 512×512 icon and 1024×500 feature graphic;
  - at least 2 phone screenshots; `docs/design/phase7/` has candidates, but retake them without a status bar;
  - category Education or Books & Reference;
  - contact email.

## 6. Must decide before a public release

- **Portrait rights.** Poet portraits are shown from the school textbooks with rights recorded as "unknown". Get permission, or replace them with the seal-monogram plates.
- **Textbook text rights.** Poems, biographies, history excerpts and glossary meanings are copied from the textbooks and maorif.tj. Confirm the Ministry or publisher allows this in a published app.
- **Editorial approval.** **0 works are `editoriallyApproved`.** A native Tajik/Persian editor should review the poems, dates and the generated Persian-script text first. See «CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED» in `PHASE_7_REPORT.md`.
