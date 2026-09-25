import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Current Android release version can upgrade the public v1.0.1 package',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final versionMatch = RegExp(
        r'^version:\s+([^+\s]+)\+(\d+)\s*$',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(versionMatch, isNotNull);
      expect(versionMatch!.group(1), '2.0.0');
      expect(
        int.parse(versionMatch.group(2)!),
        greaterThan(2002),
        reason: 'The published v1.0.1 APK uses Android versionCode 2002.',
      );
    },
  );

  test('the shared website provides direct standalone Android downloads', () {
    final page = File('web/android/index.html');

    expect(page.existsSync(), isTrue);
    final html = page.readAsStringSync();
    expect(html, contains('../downloads/zarbulmasal-arm64-v8a.apk'));
    expect(html, contains('../downloads/zarbulmasal-armeabi-v7a.apk'));
    expect(html, contains('../downloads/zarbulmasal-universal.apk'));
    expect(html, contains('Android 7'));
  });

  test('Pages deployment carries only verified signed APKs', () {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();
    final stagingScript = File(
      'tool/prepare_android_downloads.sh',
    ).readAsStringSync();

    expect(
      'flutter pub get --enforce-lockfile'.allMatches(workflow).length,
      greaterThanOrEqualTo(2),
      reason:
          'Quality and web jobs must use the checked-in dependency resolution.',
    );
    expect(
      workflow,
      contains('path: build/app/outputs/flutter-apk'),
      reason: 'Public APK uploads must preserve the APK directory as root.',
    );
    expect(workflow, contains('name: zarbulmasal-public-apks'));
    expect(workflow, contains('name: zarbulmasal-android-release-evidence'));
    expect(workflow, contains('actions/download-artifact@'));
    expect(
      workflow,
      contains(
        'name: zarbulmasal-public-apks\n'
        '          path: build/app/outputs/flutter-apk',
      ),
      reason:
          'The Pages job must download an APK-only artifact rooted at the APK directory.',
    );
    expect(workflow, contains('bash tool/prepare_android_downloads.sh'));
    expect(workflow, contains('Missing required Android release secret'));
    expect(
      workflow,
      contains(
        'python3 -m unittest tool.test_provenance_detector '
        'tool.test_provenance_linter_sources '
        'tool.test_validate_literary_content_report -v',
      ),
      reason: 'CI must exercise the provenance detector regression guard.',
    );
    expect(
      workflow,
      contains('python3 tool/provenance_repair_loop5_adversarial.py'),
      reason: 'CI must run the raw adversarial provenance re-audit.',
    );
    expect(
      workflow,
      contains('tool.test_validate_literary_content_report'),
      reason: 'CI must exercise the provenance report regression guard.',
    );
    expect(
      workflow,
      contains('python3 -m unittest tool.test_android_bundle_alignment -v'),
      reason: 'CI must exercise the 16 KB bundle alignment guard.',
    );
    expect(
      workflow,
      contains('python3 tool/test_android_bundle_alignment.py -q'),
      reason:
          'CI must keep the alignment verifier test runnable as a direct local command.',
    );
    expect(
      workflow,
      contains('bash -n tool/verify_android_signing_material.sh'),
      reason:
          'CI must reject shell syntax regressions before release steps run.',
    );
    expect(
      workflow,
      contains('android_release_ready'),
      reason:
          'Web Pages must remain deployable when Android signing is unavailable.',
    );
    final pullRequestBuild = workflow.substring(
      workflow.indexOf('- name: Build Android APK for CI'),
      workflow.indexOf('- name: Build signed public Android APKs'),
    );
    expect(
      pullRequestBuild,
      contains('flutter build apk --debug'),
      reason:
          'Pull-request APK validation must not require production signing secrets.',
    );
    expect(
      pullRequestBuild,
      isNot(contains('KEYSTORE_')),
      reason: 'Pull-request code must never receive Android signing secrets.',
    );
    expect(
      workflow,
      contains(
        "if: github.ref == 'refs/heads/main' && github.event_name != 'pull_request'\n"
        '        env:\n'
        '          KEYSTORE_BASE64:',
      ),
    );
    expect(
      workflow,
      contains('EXPECTED_RELEASE_CERT_SHA256:'),
      reason:
          'Public Android releases must receive the trusted certificate from protected CI configuration.',
    );
    expect(
      stagingScript,
      contains('com.zarbulmasal.zarbulmasal'),
      reason: 'Public downloads must verify the stable Android package ID.',
    );
    expect(stagingScript, contains('EXPECTED_RELEASE_CERT_SHA256'));
    expect(
      stagingScript,
      contains('must be a 64-character SHA-256 certificate digest'),
    );
    expect(stagingScript, contains('expected_abi_version_code'));
    expect(stagingScript, contains('CN=Android Debug'));
    expect(
      stagingScript,
      contains(r'find "$download_root" -mindepth 1 -maxdepth 1'),
      reason:
          'Android staging must remove stale binaries before copying new ones.',
    );
    expect(
      stagingScript,
      contains('Refusing to clean symlinked Android download output'),
    );
    expect(
      File('tool/deploy_gh_pages.sh').readAsStringSync(),
      contains(
        r'rm -rf "$project_root/build/web/android" '
        r'"$project_root/build/web/downloads"',
      ),
      reason: 'Web-only deploys must not publish stale Android release files.',
    );
    expect(workflow, contains('test ! -e build/web/android'));
    expect(workflow, contains('test ! -e build/web/downloads'));
    final manualDeployScript = File(
      'tool/deploy_gh_pages.sh',
    ).readAsStringSync();
    expect(
      manualDeployScript,
      contains(r'find "$deployment_dir" -mindepth 1 -maxdepth 1'),
      reason:
          'Manual Pages deploys must remove stale visible and hidden files.',
    );
    expect(manualDeployScript, contains('! -name .git -exec rm -rf -- {} +'));
    expect(
      manualDeployScript,
      contains(r'! -name .git -exec cp -R {} . \;'),
      reason: 'Manual Pages deploys must not copy nested Git metadata.',
    );
    expect(manualDeployScript, contains('git checkout -B gh-pages'));
    expect(
      manualDeployScript,
      contains('git checkout --detach'),
      reason:
          'Manual Pages deploys must work when another local worktree owns gh-pages.',
    );
    expect(
      manualDeployScript,
      contains('git rev-parse --show-toplevel'),
      reason:
          'Manual Pages deploys must not accidentally operate on the parent source worktree.',
    );
    expect(manualDeployScript, contains('git remote set-url origin'));
    expect(manualDeployScript, contains('git fetch origin gh-pages'));
    expect(manualDeployScript, contains('git push --force-with-lease='));
    expect(manualDeployScript, isNot(contains('git push -f origin gh-pages')));
    expect(
      manualDeployScript,
      contains(r'find "$project_root/build/web" -mindepth 1 -maxdepth 1'),
      reason: 'Manual Pages deploys must copy hidden release files too.',
    );
    expect(
      manualDeployScript,
      contains('git diff --cached --quiet'),
      reason: 'A no-op manual Pages redeploy must exit cleanly.',
    );
    expect(
      manualDeployScript.indexOf('git fetch origin gh-pages'),
      lessThan(manualDeployScript.indexOf('git diff --cached --quiet')),
      reason:
          'Manual Pages deploys must refresh the remote before accepting a no-op.',
    );
    expect(
      manualDeployScript,
      contains('Refusing to overwrite a changed gh-pages branch'),
      reason:
          'A moved remote branch must not be silently treated as already deployed.',
    );
    expect(
      manualDeployScript,
      contains(
        'https://abubakrmmarufov-tech.github.io/zarbulmasal/privacy.html',
      ),
      reason: 'Manual Pages deploys must verify the public privacy URL.',
    );
    expect(
      manualDeployScript,
      contains('Zarbulmasal Privacy Policy'),
      reason: 'Manual Pages deploys must verify the privacy policy content.',
    );
    expect(
      manualDeployScript,
      contains(r'test -s "$project_root/build/web/privacy.html"'),
      reason:
          'Manual Pages deploys must validate the local privacy artifact before push.',
    );
    expect(
      manualDeployScript,
      contains(
        r'grep -Fq "Zarbulmasal Privacy Policy" "$project_root/build/web/privacy.html"',
      ),
      reason:
          'Manual Pages deploys must reject an invalid local privacy artifact.',
    );
  });

  test('main release builds and archives a signed Play App Bundle', () {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();
    final verifier = File('tool/verify_android_bundle.sh').readAsStringSync();
    final signingMaterialVerifier = File(
      'tool/verify_android_signing_material.sh',
    );
    final alignmentVerifier = File(
      'tool/verify_android_bundle_alignment.py',
    ).readAsStringSync();
    final bundletoolVerifier = File(
      'tool/verify_android_bundletool_alignment.sh',
    );
    final bundletoolVerifierScript = bundletoolVerifier.readAsStringSync();
    final signedBuild = workflow.substring(
      workflow.indexOf('- name: Build signed public Android APKs'),
      workflow.indexOf('- name: Verify public Android packages'),
    );

    expect(
      signingMaterialVerifier.existsSync(),
      isTrue,
      reason:
          'CI must validate the production keystore before building public artifacts.',
    );
    final signingMaterialScript = signingMaterialVerifier.readAsStringSync();
    expect(
      signingMaterialScript,
      contains('KEYSTORE_PATH'),
      reason: 'Signing preflight must read the decoded keystore path.',
    );
    expect(
      signingMaterialScript,
      contains('KEYSTORE_PASSWORD'),
      reason: 'Signing preflight must validate the keystore password.',
    );
    expect(
      signingMaterialScript,
      contains('KEY_ALIAS'),
      reason: 'Signing preflight must validate the configured key alias.',
    );
    expect(signingMaterialScript, contains('EXPECTED_RELEASE_CERT_SHA256'));
    expect(
      signingMaterialScript,
      contains('must be a 64-character SHA-256 certificate digest'),
    );
    expect(signingMaterialScript, contains('PrivateKeyEntry'));
    expect(
      signedBuild,
      contains('bash tool/verify_android_signing_material.sh'),
      reason:
          'CI must reject a wrong signing identity before building public artifacts.',
    );

    expect(
      signedBuild,
      contains('flutter build appbundle --release'),
      reason: 'A Play release must produce an App Bundle, not only APKs.',
    );
    expect(
      workflow,
      contains('build/app/outputs/bundle/release/app-release.aab'),
      reason: 'The signed App Bundle must be retained as CI evidence.',
    );
    expect(workflow, contains('build/app/outputs/mapping/release/mapping.txt'));
    expect(workflow, contains('build/symbols/android'));
    expect(
      workflow,
      contains(
        'bash tool/verify_android_bundle.sh '
        'build/app/outputs/bundle/release/app-release.aab',
      ),
      reason: 'The Play bundle must be verified before it is archived.',
    );
    expect(verifier, contains('EXPECTED_RELEASE_CERT_SHA256'));
    expect(
      verifier,
      contains('must be a 64-character SHA-256 certificate digest'),
    );
    final certificateDetailsStart = verifier.indexOf('certificate_details=');
    final certificateExtractionStart = verifier.indexOf(
      r'certificate="$(printf',
      certificateDetailsStart,
    );
    final certificateExtractionEnd = verifier.indexOf(
      r'if [[ -z "$certificate"',
      certificateExtractionStart,
    );
    expect(certificateExtractionStart, greaterThanOrEqualTo(0));
    expect(certificateExtractionEnd, greaterThan(certificateExtractionStart));
    expect(
      verifier.substring(certificateExtractionStart, certificateExtractionEnd),
      contains("tr '[:upper:]' '[:lower:]'"),
      reason:
          'Bundle verification must compare certificate digests case-insensitively.',
    );
    expect(
      verifier,
      contains('expected_package="com.zarbulmasal.zarbulmasal"'),
    );
    expect(verifier, contains('expected_version_code'));
    expect(
      verifier,
      contains('aapt2" dump xmltree'),
      reason: 'The verifier must inspect the bundle manifest identity.',
    );
    expect(verifier, contains('base/manifest/AndroidManifest.xml'));
    expect(verifier, contains('jarsigner -verify -certs'));
    expect(verifier, contains('CN=Android Debug'));
    expect(
      verifier,
      contains('verify_android_bundle_alignment.py'),
      reason: 'The Play bundle must prove native 16 KB page compatibility.',
    );
    expect(alignmentVerifier, contains('MIN_PAGE_ALIGNMENT = 0x4000'));
    expect(alignmentVerifier, contains('PT_LOAD'));
    expect(
      bundletoolVerifier.existsSync(),
      isTrue,
      reason:
          'Play release verification must include bundletool config evidence.',
    );
    expect(bundletoolVerifierScript, contains('bundletool_version="1.18.3"'));
    expect(
      bundletoolVerifierScript,
      contains(
        'a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29',
      ),
      reason: 'The bundletool release asset must be checksum-pinned.',
    );
    expect(bundletoolVerifierScript, contains('dump config --bundle='));
    expect(bundletoolVerifierScript, contains('PAGE_ALIGNMENT_16K'));
    expect(
      workflow,
      contains('Verify bundletool 16 KB configuration'),
      reason: 'CI must run bundletool against the signed Play bundle.',
    );
    expect(
      workflow,
      contains(r'bundletool-all-${bundletool_version}.jar'),
      reason: 'CI must download the pinned official bundletool release asset.',
    );
    expect(workflow, contains('sha256sum --check --status'));
    expect(
      workflow,
      contains('bash tool/verify_android_bundletool_alignment.sh'),
    );
    final releaseEvidenceVerifier = File(
      'tool/verify_android_release_artifacts.sh',
    );
    expect(
      releaseEvidenceVerifier.existsSync(),
      isTrue,
      reason:
          'A Play release must retain deobfuscation and symbol evidence with the bundle.',
    );
    final releaseEvidenceScript = releaseEvidenceVerifier.readAsStringSync();
    expect(
      releaseEvidenceScript,
      contains('build/app/outputs/mapping/release/mapping.txt'),
    );
    expect(
      releaseEvidenceScript,
      contains(
        'build/app/outputs/native-debug-symbols/release/native-debug-symbols.zip',
      ),
    );
    expect(releaseEvidenceScript, contains('build/symbols/android'));
    expect(releaseEvidenceScript, contains('unzip -t'));
    expect(
      workflow,
      contains(
        'bash tool/verify_android_release_artifacts.sh '
        'build/app/outputs/bundle/release/app-release.aab',
      ),
      reason:
          'CI must fail before archival when release diagnostics are missing.',
    );
    expect(
      workflow,
      contains('if-no-files-found: error'),
      reason: 'A missing App Bundle must fail the release artifact upload.',
    );
    final verificationMetadata = File(
      'android/gradle/verification-metadata.xml',
    );
    expect(
      verificationMetadata.existsSync(),
      isTrue,
      reason:
          'Gradle dependencies must be integrity-pinned for release builds.',
    );
    final verificationXml = verificationMetadata.readAsStringSync();
    expect(
      verificationXml,
      contains('aapt2-9.0.1-14304508-osx.jar'),
      reason: 'Local macOS Android builds must remain integrity-pinned.',
    );
    expect(
      verificationXml,
      contains('aapt2-9.0.1-14304508-linux.jar'),
      reason: 'Ubuntu CI Android builds must remain integrity-pinned.',
    );
    expect(
      File(
        'android/gradle/wrapper/gradle-wrapper.properties',
      ).readAsStringSync(),
      contains('distributionSha256Sum='),
    );
  });

  test('release Android manifest disables cleartext traffic', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(
      manifest,
      contains('android:allowBackup="true"'),
      reason:
          'Local learning state may follow the user through Android backup/transfer; the public privacy policy discloses this behavior.',
    );
    expect(manifest, isNot(contains('android.permission.INTERNET')));
  });

  test('release Android manifest only queries HTTPS handlers', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('<data android:scheme="https" />'));
    expect(
      manifest,
      isNot(contains('<data android:scheme="http" />')),
      reason:
          'The runtime only permits trusted HTTPS links; do not advertise HTTP handlers.',
    );
  });

  test(
    'release Android manifest does not advertise an unhandled custom scheme',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(
        manifest,
        isNot(contains('android:scheme="zarbulmasal"')),
        reason:
            'The app has no custom-scheme intent handler; do not expose an unhandled external entry point.',
      );
    },
  );

  test('Android builds fail closed on unverified dependencies', () {
    final gradleProperties = File(
      'android/gradle.properties',
    ).readAsStringSync();
    expect(
      gradleProperties,
      contains('org.gradle.dependency.verification=strict'),
      reason:
          'Android release builds must reject dependencies without approved checksums.',
    );
  });

  test('a release without the upload key fails unless it is a marked '
      'debug-signed preview', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final release = gradle.substring(gradle.indexOf('buildTypes {'));

    // The real key always wins; the preview switch is checked next; with
    // neither, a release build stops.
    final real = release.indexOf('if (releaseConfig != null)');
    final preview = release.indexOf('} else if (previewDebugSigning)');
    final fail = release.indexOf(
      'throw GradleException("Release signing '
      'config missing")',
    );
    expect(real, greaterThanOrEqualTo(0));
    expect(preview, greaterThan(real));
    expect(fail, greaterThan(preview));
    expect(release, contains('"previewDebugSigning"'));
    expect(release, contains('== "true"'));
    expect(release, contains('Not for Google Play'));
    // The preview is only ever signed with the debug key.
    expect(release, contains('signingConfigs.getByName("debug")'));
    expect(release, contains('isMinifyEnabled = true'));
    expect(release, contains('isShrinkResources = true'));
  });
}
