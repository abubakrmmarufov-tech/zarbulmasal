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
}
