import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/features/books/domain/book.dart';
import 'package:zarbulmasal/features/books/presentation/book_display_text.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

const _book = Book(
  id: 'display-text-book',
  canonicalTitle: 'Китоби санҷишӣ',
  titleTj: 'Китоби аслӣ',
  authorNameTj: 'Муаллифи аслӣ',
  descriptionTj: 'Тавсифи тоҷикӣ',
  language: 'Тоҷикӣ',
);

const _translatedBook = Book(
  id: 'translated-display-text-book',
  canonicalTitle: 'Китоби санҷишӣ',
  titleTj: 'Китоби аслӣ',
  titleFa: 'کتاب اصلی',
  authorNameTj: 'Муаллифи аслӣ',
  authorNameFa: 'نویسندهٔ اصلی',
  descriptionTj: 'Тавсифи тоҷикӣ',
  descriptionFa: 'توضیح فارسی',
  language: 'Тоҷикӣ',
);

void main() {
  test('Persian book labels and Tajik original fields stay distinct', () {
    expect(
      BookDisplayText.title(_book, DisplayLanguage.persian),
      AppTranslations.get(
        'books_title_translation_pending',
        DisplayLanguage.persian,
      ),
    );
    expect(
      BookDisplayText.author(_book, DisplayLanguage.persian),
      AppTranslations.get(
        'books_author_translation_pending',
        DisplayLanguage.persian,
      ),
    );
    expect(
      BookDisplayText.originalTitle(_book, DisplayLanguage.persian),
      _book.titleTj,
    );
    expect(
      BookDisplayText.originalAuthor(_book, DisplayLanguage.persian),
      _book.authorNameTj,
    );
  });

  test('reviewed Persian fields do not also appear as Tajik originals', () {
    expect(
      BookDisplayText.title(_translatedBook, DisplayLanguage.persian),
      'کتاب اصلی',
    );
    expect(
      BookDisplayText.author(_translatedBook, DisplayLanguage.persian),
      'نویسندهٔ اصلی',
    );
    expect(
      BookDisplayText.originalTitle(_translatedBook, DisplayLanguage.persian),
      isNull,
    );
    expect(
      BookDisplayText.originalAuthor(_translatedBook, DisplayLanguage.persian),
      isNull,
    );
  });

  test(
    'Tajik display returns source metadata without Persian fallback labels',
    () {
      expect(
        BookDisplayText.title(_book, DisplayLanguage.tajik),
        'Китоби аслӣ',
      );
      expect(
        BookDisplayText.author(_book, DisplayLanguage.tajik),
        'Муаллифи аслӣ',
      );
      expect(
        BookDisplayText.originalTitle(_book, DisplayLanguage.tajik),
        isNull,
      );
    },
  );
}
