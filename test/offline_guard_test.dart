import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app is fully offline and carries no ads or analytics: every text,
/// cover and portrait is bundled, and external links open in the browser.
void main() {
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  test('no code in lib/ fetches the network', () {
    const networkApis = [
      'Image.network',
      'NetworkImage',
      'HttpClient',
      'package:http/',
      'package:dio/',
      'WebSocket',
      'RawSocket',
      'Socket.connect',
      'HttpRequest',
    ];
    final hits = <String>[];
    for (final file in sources) {
      final text = file.readAsStringSync();
      for (final api in networkApis) {
        if (text.contains(api)) hits.add('${file.path}: $api');
      }
    }
    expect(sources, isNotEmpty);
    expect(hits, isEmpty);
  });

  test('pubspec has no ad, analytics, tracking or HTTP package', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final dependencies = RegExp(
      r'^  ([a-z0-9_]+):',
      multiLine: true,
    ).allMatches(pubspec).map((m) => m.group(1)!).toSet();
    const banned = [
      'ads',
      'admob',
      'analytics',
      'firebase',
      'crashlytics',
      'sentry',
      'appsflyer',
      'adjust',
      'facebook',
      'amplitude',
      'mixpanel',
      'segment',
      'http',
      'dio',
      'webview',
      'cached_network_image',
    ];
    final found = dependencies
        .where((name) => banned.any((word) => name.contains(word)))
        .toList();
    expect(dependencies, contains('flutter'));
    expect(found, isEmpty);
  });

  test('Android declares no network or advertising permission', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, isNot(contains('android.permission.INTERNET')));
    expect(manifest, isNot(contains('ACCESS_NETWORK_STATE')));
    expect(manifest, isNot(contains('AD_ID')));
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, isNot(contains('play-services-ads')));
    expect(gradle, isNot(contains('firebase')));
  });
}
