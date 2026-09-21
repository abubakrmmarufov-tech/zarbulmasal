import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/history/domain/history_book.dart';

void main() {
  const validBook = HistoryBook(
    id: 'history-5',
    grade: '5',
    title: 'Valid source',
    author: 'Test author',
    year: '2026',
    description: 'Test fixture',
    sourceUrl: 'https://maorif.tj/libraries?category=27',
  );

  test('exposes only absolute HTTPS history source links', () {
    expect(validBook.externalSourceUri, isNotNull);
    expect(validBook.externalSourceUri!.host, 'maorif.tj');
  });

  for (final sourceUrl in [
    'javascript:alert(1)',
    'file:///etc/passwd',
    'zarbulmasal://open',
    'http://maorif.tj/libraries?category=27',
    'not a URI',
    'https://example.test/history',
    'https://user:pass@maorif.tj/history',
    'https://maorif.tj:8443/history',
  ]) {
    test('does not expose $sourceUrl as an external source link', () {
      final book = HistoryBook(
        id: 'invalid-source',
        grade: '5',
        title: 'Invalid source',
        author: 'Test author',
        year: '2026',
        description: 'Test fixture',
        sourceUrl: sourceUrl,
      );

      expect(book.externalSourceUri, isNull);
    });
  }
}
