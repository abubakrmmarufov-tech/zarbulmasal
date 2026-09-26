import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/atlas_cover.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/books/presentation/book_cover.dart';

Book _uncovered({
  String id = 'b',
  String title = 'Девони ашъор',
  String? author = 'Абдураҳмони Ҷомӣ',
  List<String> categoryIds = const ['nazm'],
}) => Book(
  id: id,
  canonicalTitle: title,
  titleTj: title,
  authorNameTj: author,
  descriptionTj: '',
  language: 'Тоҷикӣ',
  categoryIds: categoryIds,
  editions: const [],
);

/// Where the laid-out glyphs of [text] end, which may be below the
/// paragraph's own box when the text does not fit it.
double _glyphBottom(WidgetTester tester, String text) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: find.text(text), matching: find.byType(RichText)),
  );
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: text.length),
  );
  final bottom = boxes.map((box) => box.bottom).reduce(math.max);
  return paragraph.localToGlobal(Offset(0, bottom)).dy;
}

Future<void> _pump(WidgetTester tester, Widget cover, {double scale = 1}) =>
    tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Center(child: cover),
        ),
      ),
    );

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

  group('typographic cover', () {
    testWidgets('shows the title, the author and the category\'s ikat band', (
      tester,
    ) async {
      await _pump(
        tester,
        BookCover(
          book: _uncovered(),
          width: 116,
          height: 170,
          placeholderAuthor: 'Абдураҳмони Ҷомӣ',
        ),
      );
      expect(find.text('Девони ашъор'), findsOneWidget);
      expect(find.text('Абдураҳмони Ҷомӣ'), findsOneWidget);
      final band = tester.widget<AtlasCover>(find.byType(AtlasCover));
      expect(band.seed, 'book-category-nazm');
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('books of one category share a band; others differ', (
      tester,
    ) async {
      String seedOf(Book book) => BookCover.bandSeed(book);
      expect(
        seedOf(_uncovered(id: 'a')),
        seedOf(_uncovered(id: 'b', title: 'Дигар')),
      );
      expect(
        seedOf(_uncovered(categoryIds: const ['nasr'])),
        isNot(seedOf(_uncovered())),
      );
      expect(seedOf(_uncovered(categoryIds: const [])), 'book-category-books');
    });

    testWidgets('the small poet-page slot shows the title only', (
      tester,
    ) async {
      await _pump(tester, BookCover(book: _uncovered(), width: 48, height: 68));
      expect(find.text('Девони ашъор'), findsOneWidget);
      expect(find.text('Абдураҳмони Ҷомӣ'), findsNothing);
    });

    testWidgets('a book with no author shows just its title', (tester) async {
      await _pump(tester, BookCover(book: _uncovered(author: null)));
      expect(find.text('Девони ашъор'), findsOneWidget);
    });

    testWidgets('fits every slot at large text sizes', (tester) async {
      final long = _uncovered(
        title: 'Зинда бод ханда (Гулчин барои кӯдакон ва наврасон)',
        author: 'Абдусалом Деҳотӣ ва дигарон',
      );
      for (final (width, height) in [
        (48.0, 68.0),
        (72.0, 104.0),
        (116.0, 170.0),
      ]) {
        for (final scale in [1.0, 1.3, 2.0]) {
          await _pump(
            tester,
            BookCover(
              book: long,
              width: width,
              height: height,
              placeholderAuthor: long.authorNameTj,
            ),
            scale: scale,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '$width x $height at $scale',
          );
          expect(tester.getSize(find.byType(BookCover)), Size(width, height));
        }
      }
    });

    testWidgets('the title never runs into the author', (tester) async {
      final long = _uncovered(
        title:
            'Осори мунтахаб. Адиб Собири Тирмизӣ ва шоирони дигари '
            'даври Салҷуқиён',
      );
      for (final (width, height) in [(72.0, 104.0), (116.0, 170.0)]) {
        await _pump(
          tester,
          BookCover(
            book: long,
            width: width,
            height: height,
            placeholderAuthor: 'Адиб Собири Тирмизӣ',
          ),
        );
        final author = tester.getRect(find.text('Адиб Собири Тирмизӣ'));
        final cover = tester.getRect(find.byType(BookCover));
        expect(
          _glyphBottom(tester, long.titleTj),
          lessThanOrEqualTo(author.top),
          reason: '$width',
        );
        expect(
          _glyphBottom(tester, 'Адиб Собири Тирмизӣ'),
          lessThanOrEqualTo(cover.bottom),
          reason: '$width',
        );
      }
    });

    testWidgets('the cover is decoration; its title is read beside it', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, BookCover(book: _uncovered()));
      expect(find.bySemanticsLabel('Девони ашъор'), findsNothing);
      semantics.dispose();
    });
  });
}
