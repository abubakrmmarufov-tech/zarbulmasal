import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `persian ? 'فارسی' : 'Тоҷикӣ'` written inside a widget: the text belongs
/// in lib/core/l10n, in all four string files.
final _inlineLanguagePair = RegExp(
  r"""(?:[iI]sPersian|persian|DisplayLanguage\.persian)\s*\)?\s*\?\s*'[^'\n]*[؀-ۿЀ-ӿ][^'\n]*'\s*:\s*'""",
);

void main() {
  test('widgets take Tajik and Persian text from lib/core/l10n', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.startsWith('lib/core/l10n/'))
        .where((file) => !file.path.startsWith('lib/data/seed/'));
    for (final file in files) {
      final text = file.readAsStringSync();
      for (final match in _inlineLanguagePair.allMatches(text)) {
        final line = '\n'.allMatches(text.substring(0, match.start)).length + 1;
        offenders.add('${file.path}:$line');
      }
    }
    expect(offenders, isEmpty);
  });
}
