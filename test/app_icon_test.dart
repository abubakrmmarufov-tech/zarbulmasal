// The launcher icon, launch screens and web icons come from one master
// (docs/design/icon final.png) through tool/design/build_icons.py.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';
const _densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

String? _color(String file, String name) => RegExp(
  '<color name="$name">(#[0-9A-Fa-f]{6})</color>',
).firstMatch(File(file).readAsStringSync())?.group(1);

void main() {
  test('the adaptive icon has a background, foreground and monochrome', () {
    final xml = File(
      '$_res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    expect(xml, contains('@color/ic_launcher_background'));
    expect(xml, contains('<foreground android:drawable="@mipmap/'));
    expect(xml, contains('<monochrome android:drawable="@mipmap/'));
  });

  test('every density has WebP layers and a legacy icon, no PNG left', () {
    for (final density in _densities) {
      for (final name in [
        'ic_launcher',
        'ic_launcher_foreground',
        'ic_launcher_monochrome',
      ]) {
        final file = File('$_res/mipmap-$density/$name.webp');
        expect(file.existsSync(), isTrue, reason: file.path);
        // RIFF....WEBP
        final head = file.openSync().readSync(12);
        expect(ascii.decode(head.sublist(8, 12)), 'WEBP', reason: file.path);
      }
      expect(
        File('$_res/mipmap-$density/ic_launcher.png').existsSync(),
        isFalse,
      );
      expect(
        File('$_res/drawable-$density/ic_launcher_foreground.png').existsSync(),
        isFalse,
      );
    }
  });

  test('launch screens use the icon background, light and dark', () {
    final icon = _color('$_res/values/colors.xml', 'ic_launcher_background');
    expect(icon, isNotNull);
    expect(_color('$_res/values/colors.xml', 'launch_background'), icon);
    expect(_color('$_res/values-night/colors.xml', 'launch_background'), icon);
    for (final folder in ['drawable', 'drawable-v21']) {
      expect(
        File('$_res/$folder/launch_background.xml').readAsStringSync(),
        contains('@color/launch_background'),
      );
    }
    for (final folder in ['values-v31', 'values-night-v31']) {
      expect(
        File('$_res/$folder/styles.xml').readAsStringSync(),
        contains(
          '<item name="android:windowSplashScreenBackground">'
          '@color/launch_background</item>',
        ),
      );
    }
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(manifest['background_color'], icon);
  });

  test('the master and the Play Store icon are in the repository', () {
    expect(File('docs/design/icon final.png').existsSync(), isTrue);
    final play = File('docs/store/play_icon_512.png').readAsBytesSync();
    // PNG width and height, big-endian at bytes 16..23.
    int word(int at) =>
        (play[at] << 24) |
        (play[at + 1] << 16) |
        (play[at + 2] << 8) |
        play[at + 3];
    expect([word(16), word(20)], [512, 512]);
  });
}
