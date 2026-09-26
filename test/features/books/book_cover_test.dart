import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/books/presentation/book_cover.dart';

void main() {
  testWidgets('the placeholder cover fits the small poet-page slot', (
    tester,
  ) async {
    const book = Book(
      id: 'long',
      canonicalTitle: 'Зинда бод ханда (Гулчин барои кӯдакон ва наврасон)',
      titleTj: 'Зинда бод ханда (Гулчин барои кӯдакон ва наврасон)',
      descriptionTj: '',
      language: 'Тоҷикӣ',
      editions: [],
    );
    for (final scale in [1.0, 1.5, 2.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Center(
              child: BookCover(book: book, width: 48, height: 68),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'text scale $scale');
    }
  });

  testWidgets('a cover that is only a web link is never fetched', (
    tester,
  ) async {
    const book = Book(
      id: 'remote-only',
      canonicalTitle: 'Китоби бе муқова',
      titleTj: 'Китоби бе муқова',
      descriptionTj: '',
      language: 'Тоҷикӣ',
      editions: [
        BookEdition(
          id: 'remote-only-edition',
          bookId: 'remote-only',
          providerId: 'kitobkhon',
          sourceUrl: 'https://kitobkhon.net/book/remote-only',
          coverUrl: 'https://kitobkhon.net/storage/covers/remote-only.jpg',
          language: 'Тоҷикӣ',
          format: BookFormat.pdf,
          availability: BookAvailability.readableExternal,
          rightsStatus: BookRightsStatus.rightsUnclear,
          metadataNote: 'fixture',
        ),
      ],
    );
    expect(book.primaryEdition!.hasCover, isFalse);
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: BookCover(book: book)),
      ),
    );
    // The typographic placeholder, no image request.
    expect(find.byType(Image), findsNothing);
    expect(find.text('Китоби бе муқова'), findsOneWidget);
  });

  testWidgets('a bundled cover is drawn from the app assets', (tester) async {
    const book = Book(
      id: 'badi-boron',
      canonicalTitle: 'Баъди борон',
      titleTj: 'Баъди борон',
      descriptionTj: '',
      language: 'Тоҷикӣ',
      editions: [
        BookEdition(
          id: 'badi-boron-edition',
          bookId: 'badi-boron',
          providerId: 'kitobkhon',
          sourceUrl: 'https://kitobkhon.net/book/badi-boron',
          coverUrl: 'https://kitobkhon.net/storage/covers/badi-boron.jpg',
          coverAssetPath: 'assets/data/books/covers/badi-boron.jpg',
          language: 'Тоҷикӣ',
          format: BookFormat.pdf,
          availability: BookAvailability.readableExternal,
          rightsStatus: BookRightsStatus.rightsUnclear,
          metadataNote: 'fixture',
        ),
      ],
    );
    expect(book.primaryEdition!.hasCover, isTrue);
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: BookCover(book: book)),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as ResizeImage;
    expect(provider.imageProvider, isA<AssetImage>());
  });
}
