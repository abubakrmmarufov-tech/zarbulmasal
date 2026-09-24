import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every bundled family with its asset files, so layout is exercised with
/// production Cyrillic/Persian glyph metrics, not Ahem.
const bundledFontAssets = <String, List<String>>{
  'NotoSans': ['NotoSans.ttf'],
  'NotoSerif': ['NotoSerif.ttf'],
  'NotoNaskhArabic': ['NotoNaskhArabic.ttf'],
  'EBGaramond': [
    'EBGaramond-Medium.ttf',
    'EBGaramond-SemiBold.ttf',
    'EBGaramond-Italic.ttf',
  ],
  'PTSerif': ['PTSerif-Regular.ttf', 'PTSerif-Bold.ttf', 'PTSerif-Italic.ttf'],
  'GolosText': [
    'GolosText-Regular.ttf',
    'GolosText-Medium.ttf',
    'GolosText-SemiBold.ttf',
    'GolosText-Bold.ttf',
  ],
  'NotoNastaliqUrdu': ['NotoNastaliqUrdu-Regular.ttf'],
  'Vazirmatn': [
    'Vazirmatn-Regular.ttf',
    'Vazirmatn-Medium.ttf',
    'Vazirmatn-Bold.ttf',
  ],
};

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final MapEntry(key: family, value: files) in bundledFontAssets.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(rootBundle.load('assets/fonts/$file'));
    }
    await loader.load();
  }
  await testMain();
}
