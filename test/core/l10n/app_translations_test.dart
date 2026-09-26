import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  group('AppTranslations.get arguments in Persian', () {
    test('numbers use Persian digits', () {
      expect(
        AppTranslations.get('lit_source_grade', DisplayLanguage.persian, [5]),
        'صنف ۵',
      );
      expect(
        AppTranslations.get('lit_source_grade', DisplayLanguage.persian, [
          '11',
        ]),
        'صنف ۱۱',
      );
    });

    test('text arguments keep their digits', () {
      final line = AppTranslations.get(
        'lit_source_line',
        DisplayLanguage.persian,
        ['Адабиёти тоҷик, синфи 5 (2017)'],
      );
      expect(line, contains('синфи 5 (2017)'));
      expect(line, isNot(contains('۵')));
    });

    test('Tajik never changes digits', () {
      expect(
        AppTranslations.get('lit_source_grade', DisplayLanguage.tajik, [5]),
        'синфи 5',
      );
    });
  });
}
