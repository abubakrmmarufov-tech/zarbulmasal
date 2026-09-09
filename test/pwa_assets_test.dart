import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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

  test('web shell carries iPhone and same-origin privacy metadata', () {
    final index = File('web/index.html').readAsStringSync();

    expect(index, contains('viewport-fit=cover'));
    expect(index, contains('apple-mobile-web-app-capable'));
    expect(index, contains('black-translucent'));
    expect(index, contains("connect-src 'self'"));
    expect(index, isNot(contains('user-scalable=no')));
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
      File('${directory.path}/flutter_bootstrap.js').writeAsStringSync(
        'const worker = "qalam_service_worker.js?build='
        '__ZARBULMASAL_BUILD_ID__&variant=full";',
      );
      File('${directory.path}/qalam_service_worker.js').writeAsStringSync(
        "const BUILD_ID = WORKER_URL.searchParams.get('build') || "
        "'__ZARBULMASAL_BUILD_ID__';",
      );
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
