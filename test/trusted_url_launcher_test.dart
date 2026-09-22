import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/utils/trusted_url_launcher.dart';

void main() {
  final trustedUri = Uri.parse('https://kitobkhon.net/books/example');

  test('revalidates a trusted URL before probing and launching', () async {
    Uri? probed;
    Uri? launched;

    final didLaunch = await launchTrustedExternal(
      trustedUri,
      canOpen: (uri) async {
        probed = uri;
        return true;
      },
      open: (uri) async {
        launched = uri;
        return true;
      },
    );

    expect(didLaunch, isTrue);
    expect(probed, trustedUri);
    expect(launched, trustedUri);
  });

  test('rejects an untrusted URL before probing or launching', () async {
    var probeCalls = 0;
    var launchCalls = 0;

    final didLaunch = await launchTrustedExternal(
      Uri.parse('https://example.test/books/example'),
      canOpen: (_) async {
        probeCalls += 1;
        return true;
      },
      open: (_) async {
        launchCalls += 1;
        return true;
      },
    );

    expect(didLaunch, isFalse);
    expect(probeCalls, 0);
    expect(launchCalls, 0);
  });

  test('contains platform probe and launch failures', () async {
    final probeFailure = await launchTrustedExternal(
      trustedUri,
      canOpen: (_) async => throw StateError('no handler'),
    );
    final launchFailure = await launchTrustedExternal(
      trustedUri,
      canOpen: (_) async => true,
      open: (_) async => throw StateError('launch failed'),
    );

    expect(probeFailure, isFalse);
    expect(launchFailure, isFalse);
  });
}
