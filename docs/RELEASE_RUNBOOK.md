# Zarbulmasal Release Runbook

This runbook is the release and recovery boundary for the Android and GitHub
Pages builds. Never publish a temporary-QA-signed artifact as a public release.

## Preconditions

1. Work from a clean source branch and record the commit being released.
2. Run the local quality gate:

   ```sh
   flutter pub get --enforce-lockfile
   flutter analyze
   flutter test --coverage
   python3 tool/check_coverage.py coverage/lcov.info --minimum 80
   dart run tool/validate_literature_json.dart
   dart run tool/validate_literary_content.dart
   python3 tool/provenance_linter.py
   python3 tool/provenance_repair_loop5_adversarial.py
   ```

3. Confirm the current browser audit and privacy URL are green.
4. On the protected release runner, configure `KEYSTORE_BASE64`,
   `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`, and the matching
   `EXPECTED_RELEASE_CERT_SHA256` GitHub secrets. The CI workflow must reject
   a missing, debug, or mismatched certificate before building public files.

## Release

1. Merge the audited source through the protected default branch.
2. Let the main-branch workflow build the obfuscated split APKs and signed
   App Bundle, verify package `com.zarbulmasal.zarbulmasal`, version, signing
   identity, 16 KB alignment, bundletool page alignment, mapping, and symbols.
3. Publish Android downloads only from the verified APK artifact. Keep the AAB,
   mapping, native symbols, and Dart symbols in the separate evidence artifact.
4. Verify the live Pages root and `/privacy.html`, then run the full browser
   audit against the deployed URL. Record the Pages commit, cache ID, artifact
   checksums, signing certificate digest, and test/coverage results in the QA
   audit.

## Recovery

### Web or content regression

Stop the publication workflow and preserve its logs. Revert the offending
source commit with `git revert` on a reviewed branch, rerun the quality gate,
and publish the corrected Pages build. Do not use `git reset --hard` or rewrite
the published branch. Verify the root, privacy URL, route audit, and cache ID
after redeployment.

### Android regression

Halt a staged rollout in Google Play immediately. Google Play does not support
an in-place downgrade to a lower `versionCode`; after the incident is
contained, ship a reviewed hotfix with a higher versionCode using the same
protected production signing identity. Preserve the failing AAB, mapping,
symbols, Play release ID, crash/device evidence, and the remediation commit.

### Data and provenance regression

Keep affected records withheld by the displayability gate. Revert or correct
the source data, rerun duplicate, false-candidate, provenance, and content
validators, and only promote a record after its page evidence, attribution,
rights state, and source relationship are rechecked.

## Current limitation

The repository currently has a technically verified temporary-QA AAB, but no
protected production keystore or signed-release device-upgrade evidence. Public
Android downloads therefore remain withheld until the secret-gated main build
is completed.
