import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/utils/trusted_url_policy.dart';

void main() {
  test('allows approved HTTPS hosts and the explicit cover CDN', () {
    expect(
      TrustedUrlPolicy.parseExternal('https://kitobkhon.net/book'),
      isNotNull,
    );
    expect(
      TrustedUrlPolicy.parseExternal('https://cdn.kitobkhon.net/cover.jpg'),
      isNotNull,
    );
    expect(
      TrustedUrlPolicy.parseExternal('https://maorif.tj/libraries'),
      isNotNull,
    );
    expect(
      TrustedUrlPolicy.parseExternal('https://khirad.tj/books/read/muntahabot'),
      isNotNull,
    );
    expect(
      TrustedUrlPolicy.parseExternal(
        'https://khirad.tj/books/navodiru-l-vaqoea',
      ),
      isNotNull,
    );
  });

  test(
    'rejects untrusted hosts, arbitrary subdomains, and unsafe URI authority',
    () {
      for (final value in [
        'https://example.test/book',
        'https://kitobkhon.net.evil.test/book',
        'https://evil.kitobkhon.net/book',
        'https://evil.khirad.tj/book',
        'https://khirad.tj.evil.test/book',
        'https://cdn.maorif.tj/book',
        'https://user:pass@kitobkhon.net/book',
        'https://kitobkhon.net:8443/book',
        'http://kitobkhon.net/book',
        'javascript:alert(1)',
      ]) {
        expect(
          TrustedUrlPolicy.parseExternal(value),
          isNull,
          reason: 'Unexpectedly allowed $value',
        );
      }
    },
  );
}
