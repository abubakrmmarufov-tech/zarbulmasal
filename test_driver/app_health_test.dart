// Host side of the device health check (see test_driver/app_health.dart).
//
// Times the poem list, the longest poem, the Lexicon and search, then opens
// 100 poems and 30 poet pages in a row. Writes one timeline summary per
// screen to build/<screen>.timeline_summary.json and the memory readings
// to build/app_health_memory.json.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

const _pause = Duration(seconds: 5);

Future<void> main() async {
  final driver = await FlutterDriver.connect();
  await driver.waitUntilFirstFrameRasterized();

  Future<void> timed(String screen, Future<void> Function() action) async {
    final timeline = await driver.traceAction(action);
    await TimelineSummary.summarize(
      timeline,
    ).writeTimelineToFile(screen, pretty: true, includeSummary: true);
  }

  Future<int> rss() async => int.parse(await driver.requestData('rss'));

  final longest =
      jsonDecode(await driver.requestData('longest')) as Map<String, dynamic>;

  await timed('poem_list', () async {
    await driver.requestData('go:/literature/works');
    await driver.requestData('scroll:12');
  });
  await timed('long_poem', () async {
    await driver.requestData('go:/literature/work/${longest['id']}');
    await driver.requestData('scroll:20');
  });
  await timed('lexicon', () async {
    await driver.requestData('go:/vocabulary');
    await driver.requestData('scroll:12');
  });
  await timed('search', () async {
    await driver.requestData('go:/search');
    for (final query in ['д', 'ди', 'дил', 'дили ман']) {
      await driver.requestData('type:$query');
    }
  });

  await driver.requestData('go:/');
  await Future<void>.delayed(_pause);
  final before = await rss();
  await timed('soak', () => driver.requestData('soak:100:30'));
  final after = await rss();
  await driver.requestData('go:/');
  await Future<void>.delayed(_pause * 2);
  final settled = await rss();

  const mb = 1 << 20;
  await File('build/app_health_memory.json').writeAsString(
    const JsonEncoder.withIndent(' ').convert({
      'longestPoem': longest,
      'poemsOpened': 100,
      'poetPagesOpened': 30,
      'rssBeforeMb': before / mb,
      'rssAfterSoakMb': after / mb,
      'rssSettledMb': settled / mb,
    }),
  );
  await driver.close();
}
