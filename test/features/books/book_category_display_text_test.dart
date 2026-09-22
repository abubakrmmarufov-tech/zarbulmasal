import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/books/presentation/book_category_display_text.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  test('known provider category IDs are localized in Persian', () {
    expect(
      BookCategoryDisplayText.label('nasr', DisplayLanguage.persian),
      'نثر',
    );
    expect(
      BookCategoryDisplayText.label('zindaginoma', DisplayLanguage.persian),
      'زندگی‌نامه',
    );
    expect(
      BookCategoryDisplayText.label('ilmi', DisplayLanguage.persian),
      'علمی',
    );
  });

  test(
    'unknown Persian category values do not expose source-language text',
    () {
      expect(
        BookCategoryDisplayText.label('Категория', DisplayLanguage.persian),
        'ترجمهٔ بخش در دسترس نیست',
      );
    },
  );

  test('Tajik category values preserve provider language in Tajik UI', () {
    expect(
      BookCategoryDisplayText.label('Зиндагинома', DisplayLanguage.tajik),
      'Зиндагинома',
    );
  });
}
