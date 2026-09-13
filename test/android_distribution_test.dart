import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release can upgrade the public v1.0.1 package', () {
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
  });

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

    expect(workflow, contains('app-armeabi-v7a-release.apk'));
    expect(workflow, contains('name: zarbulmasal-public-apks'));
    expect(workflow, contains('actions/download-artifact@'));
    expect(workflow, contains('bash tool/prepare_android_downloads.sh'));
    expect(workflow, contains('Missing required Android release secret'));
    final pullRequestBuild = workflow.substring(
      workflow.indexOf('- name: Build Android APK for CI'),
      workflow.indexOf('- name: Build signed public Android APKs'),
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
      stagingScript,
      contains('com.zarbulmasal.zarbulmasal'),
      reason: 'Public downloads must verify the stable Android package ID.',
    );
    expect(
      stagingScript,
      contains(
        '93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e',
      ),
      reason: 'Public downloads must retain the v1.0.1 signing identity.',
    );
  });
}
