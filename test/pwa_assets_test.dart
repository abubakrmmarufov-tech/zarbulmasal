import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';

void main() {
  test('web manifest is installable and scoped to the deployed app', () {
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(manifest['name'], 'Зарбулмасал');
    expect(manifest['short_name'], 'Зарбулмасал');
    expect(manifest['start_url'], '.');
    expect(manifest['scope'], '.');
    expect(manifest['display'], 'standalone');
    expect(manifest['orientation'], 'portrait-primary');
    expect(
      manifest['icons'],
      isA<List<dynamic>>().having((icons) => icons.length, 'icon count', 4),
    );
  });

  test('web shell carries iPhone and controlled font fallback metadata', () {
    final index = File('web/index.html').readAsStringSync();

    expect(index, contains('viewport-fit=cover'));
    expect(index, contains('apple-mobile-web-app-capable'));
    expect(index, contains('black-translucent'));
    expect(index, contains("connect-src 'self' https://fonts.gstatic.com"));
    expect(index, contains("font-src 'self' data: https://fonts.gstatic.com"));
    expect(index, isNot(contains('fonts.googleapis.com')));
    expect(index, isNot(contains('user-scalable=no')));
  });

  test(
    'public privacy policy is source-controlled and matches app behavior',
    () {
      final policy = File('web/privacy.html');

      expect(policy.existsSync(), isTrue);
      final content = policy.readAsStringSync();
      expect(content, contains('Zarbulmasal Privacy Policy'));
      expect(content, contains('Last updated: 21 September 2026'));
      expect(content, contains('Навсозии охирин: 21 сентябри 2026'));
      expect(content, contains('آخرین به‌روزرسانی: ۲۱ سپتامبر ۲۰۲۶'));
      expect(
        content,
        contains('does not collect, sell, or share personal information'),
      );
      expect(content, contains('stores ordinary app state locally'));
      expect(
        content,
        contains('no advertising, analytics, tracking, or cloud-sync service'),
      );
      expect(content, contains('Сиёсати махфияти «Зарбулмасал»'));
      expect(content, contains('سیاست حفظ حریم خصوصی «ضرب‌المثل»'));
      expect(content, contains(AppConstants.privacyPolicyUrl));
      expect(
        AppTranslations.tj['settings_privacy_text'],
        contains(AppConstants.privacyPolicyUrl),
      );
      expect(
        AppTranslations.fa['settings_privacy_text'],
        contains(AppConstants.privacyPolicyUrl),
      );
    },
  );

  test(
    'web release preparation refuses to package without a valid privacy artifact',
    () {
      final script = File('tool/prepare_web_release.sh').readAsStringSync();

      expect(script, contains('privacy.html'));
      expect(script, contains('Zarbulmasal Privacy Policy'));
      expect(
        script,
        contains(r'test -s "$web_dir/privacy.html"'),
        reason:
            'Prepared web releases must contain a non-empty privacy policy.',
      );
      expect(
        script,
        contains(r'! -path "$web_dir/.git/*"'),
        reason: 'Release cache IDs must not depend on local Git metadata.',
      );
      expect(
        script,
        contains(r'! -path "$web_dir/.git"'),
        reason: 'Release cache IDs must also ignore Git worktree files.',
      );
      expect(script, contains('Invalid deployed base href'));
      expect(script, contains('<base href="/zarbulmasal/">'));
    },
  );

  test('all application fonts and licenses are bundled locally', () {
    const bundledFonts = ['NotoSans', 'NotoSerif', 'NotoNaskhArabic'];
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final family in bundledFonts) {
      expect(pubspec, contains('family: $family'));
      expect(File('assets/fonts/$family.ttf').existsSync(), isTrue);
      expect(File('assets/fonts/$family-OFL.txt').existsSync(), isTrue);
    }
  });

  test('book-page evidence remains audit-only unless explicitly approved', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(
      pubspec,
      isNot(contains('assets/data/literature/page_images/')),
      reason:
          'Inspected book pages must not enter a public bundle without a deliberate rights and asset review.',
    );
  });

  test('main branch CI verifies and deploys the prepared web release', () {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();
    final webJob = workflow.split('  web:').last.split('  publish:').first;
    final publishJob = workflow.split('  publish:').last;

    expect(workflow, contains('branches: [main]'));
    expect(workflow, contains('flutter analyze'));
    expect(workflow, contains('flutter test --coverage'));
    expect(workflow, contains('flutter build web --release'));
    expect(workflow, contains('--base-href /zarbulmasal/'));
    expect(workflow, contains('bash tool/prepare_web_release.sh'));
    expect(workflow, contains('Remove unavailable Android downloads portal'));
    expect(workflow, contains('rm -rf build/web/android build/web/downloads'));
    expect(webJob, contains('persist-credentials: false'));
    expect(
      publishJob,
      contains('persist-credentials: false'),
      reason:
          'Pages publication must not leave the checkout token in local git config.',
    );
    expect(webJob, isNot(contains('contents: write')));
    expect(publishJob, contains('contents: write'));
    expect(publishJob, contains('GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}'));
    expect(
      publishJob,
      contains(
        'git remote set-url origin '
        '"https://x-access-token:\${GITHUB_TOKEN}@github.com/\${GITHUB_REPOSITORY}.git"',
      ),
    );
    expect(workflow, contains('git worktree add --detach'));
    expect(publishJob, contains('pages_base_sha='));
    expect(
      publishJob,
      contains(
        'git push --force-with-lease="refs/heads/gh-pages:\${pages_base_sha}" '
        'origin HEAD:gh-pages',
      ),
    );
    expect(publishJob, contains('Verify published privacy policy'));
    expect(
      publishJob,
      contains(
        'https://abubakrmmarufov-tech.github.io/zarbulmasal/privacy.html',
      ),
    );
    expect(publishJob, contains('Zarbulmasal Privacy Policy'));
  });

  test('offline worker uses build-isolated caches and bounded navigation', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();
    final worker = File('web/qalam_service_worker.js').readAsStringSync();

    expect(bootstrap, contains('__ZARBULMASAL_BUILD_ID__'));
    expect(bootstrap, contains('usesChromiumCanvasKit'));
    expect(bootstrap, isNot(contains('.last_build_id')));
    expect(worker, contains("WORKER_URL.searchParams.get('build')"));
    expect(worker, contains('CANVASKIT_VARIANT'));
    expect(worker, contains('LEGACY_CACHE_NAMESPACE'));
    expect(worker, contains(':\${CANVASKIT_VARIANT}\${SCOPE_SUFFIX}'));
    expect(worker, contains('caches.delete'));
    expect(worker, contains('isShellNavigation'));
    expect(worker, contains("includes('text/html')"));
    expect(
      worker,
      contains("const shellRequest = new Request(resolve('index.html'))"),
    );
    expect(worker, contains('cache.put(shellRequest, response.clone())'));
  });

  test('release cache ID changes when a non-Dart asset changes', () {
    String prepareWithAsset(String asset) {
      final directory = Directory.systemTemp.createTempSync(
        'zarbulmasal-release-',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      File('${directory.path}/main.dart.js').writeAsStringSync('same app');
      File(
        '${directory.path}/index.html',
      ).writeAsStringSync('<base href="/zarbulmasal/">');
      File('${directory.path}/flutter_bootstrap.js').writeAsStringSync(
        'const worker = "qalam_service_worker.js?build='
        '__ZARBULMASAL_BUILD_ID__&variant=full";',
      );
      File('${directory.path}/qalam_service_worker.js').writeAsStringSync(
        "const BUILD_ID = WORKER_URL.searchParams.get('build') || "
        "'__ZARBULMASAL_BUILD_ID__';",
      );
      File(
        '${directory.path}/privacy.html',
      ).writeAsStringSync('<title>Zarbulmasal Privacy Policy</title>');
      File('${directory.path}/manifest.json').writeAsStringSync(asset);

      final result = Process.runSync('bash', [
        'tool/prepare_web_release.sh',
        directory.path,
      ]);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      return RegExp(
        r'[a-f0-9]{20}',
      ).firstMatch(result.stdout.toString())!.group(0)!;
    }

    expect(
      prepareWithAsset('version one'),
      isNot(prepareWithAsset('version two')),
    );
  });

  test('rerunning release preparation rewrites an injected cache ID', () {
    final directory = Directory.systemTemp.createTempSync(
      'zarbulmasal-release-rerun-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final bootstrap = File('${directory.path}/flutter_bootstrap.js')
      ..writeAsStringSync(
        'const worker = "qalam_service_worker.js?build='
        '__ZARBULMASAL_BUILD_ID__&variant=full";',
      );
    final worker = File('${directory.path}/qalam_service_worker.js')
      ..writeAsStringSync(
        "const BUILD_ID = WORKER_URL.searchParams.get('build') || "
        "'__ZARBULMASAL_BUILD_ID__';",
      );
    File('${directory.path}/main.dart.js').writeAsStringSync('same app');
    File(
      '${directory.path}/index.html',
    ).writeAsStringSync('<base href="/zarbulmasal/">');
    File(
      '${directory.path}/privacy.html',
    ).writeAsStringSync('<title>Zarbulmasal Privacy Policy</title>');
    final manifest = File('${directory.path}/manifest.json')
      ..writeAsStringSync('version one');

    String prepare() {
      final result = Process.runSync('bash', [
        'tool/prepare_web_release.sh',
        directory.path,
      ]);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      return RegExp(
        r'[a-f0-9]{20}',
      ).firstMatch(result.stdout.toString())!.group(0)!;
    }

    final firstId = prepare();
    manifest.writeAsStringSync('version two');
    final secondId = prepare();

    expect(secondId, isNot(firstId));
    expect(bootstrap.readAsStringSync(), contains(secondId));
    expect(worker.readAsStringSync(), contains(secondId));
    expect(bootstrap.readAsStringSync(), isNot(contains(firstId)));
    expect(worker.readAsStringSync(), isNot(contains(firstId)));
  });
}
