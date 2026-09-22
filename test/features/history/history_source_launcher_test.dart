import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/history/presentation/history_source_launcher.dart';

void main() {
  final source = Uri.parse('https://maorif.tj/libraries?category=27');

  test(
    'does not launch when the platform cannot open a History source',
    () async {
      var launchCalls = 0;

      final launched = await launchHistorySource(
        source,
        canOpen: (_) async => false,
        open: (_) async {
          launchCalls += 1;
          return true;
        },
      );

      expect(launched, isFalse);
      expect(launchCalls, 0);
    },
  );

  test('reports platform launch failures without throwing', () async {
    final launched = await launchHistorySource(
      source,
      canOpen: (_) async => true,
      open: (_) async => false,
    );

    expect(launched, isFalse);
  });

  test('rejects untrusted URIs before probing or launching', () async {
    var probeCalls = 0;
    var launchCalls = 0;

    final launched = await launchHistorySource(
      Uri.parse('https://example.test/history'),
      canOpen: (_) async {
        probeCalls += 1;
        return true;
      },
      open: (_) async {
        launchCalls += 1;
        return true;
      },
    );

    expect(launched, isFalse);
    expect(probeCalls, 0);
    expect(launchCalls, 0);
  });

  test('contains probe and launcher exceptions', () async {
    final probeFailure = await launchHistorySource(
      source,
      canOpen: (_) async => throw StateError('no handler'),
    );
    final launchFailure = await launchHistorySource(
      source,
      canOpen: (_) async => true,
      open: (_) async => throw StateError('launch failed'),
    );

    expect(probeFailure, isFalse);
    expect(launchFailure, isFalse);
  });
}
