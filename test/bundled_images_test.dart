import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Every portrait and book cover the app draws is bundled as WebP, no larger
/// than twice the largest box it is shown in (poet page 112×144, book page
/// 116×170): it just covers that box, keeping its aspect ratio.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<String> paths(String json, List<String> keys) {
    final found = <String>[];
    void walk(Object? node) {
      if (node is Map) {
        for (final entry in node.entries) {
          if (keys.contains(entry.key) && entry.value is String) {
            found.add(entry.value as String);
          } else {
            walk(entry.value);
          }
        }
      } else if (node is List) {
        node.forEach(walk);
      }
    }

    walk(jsonDecode(File(json).readAsStringSync()));
    return found;
  }

  Future<void> expectBounded(List<String> assets, int boxW, int boxH) async {
    expect(assets, isNotEmpty);
    for (final asset in assets) {
      expect(asset, endsWith('.webp'), reason: asset);
      final file = File(asset);
      expect(file.existsSync(), isTrue, reason: asset);
      final buffer = await ui.ImmutableBuffer.fromUint8List(
        file.readAsBytesSync(),
      );
      final image = await ui.ImageDescriptor.encoded(buffer);
      // Covering the 2x box means one side is at most the box.
      final cover = [
        image.width / boxW,
        image.height / boxH,
      ].reduce((a, b) => a < b ? a : b);
      expect(cover, lessThanOrEqualTo(1.01), reason: asset);
      image.dispose();
      buffer.dispose();
    }
  }

  test('portraits are WebP at most 2× the poet page box', () async {
    await expectBounded(
      paths('assets/data/literature/poets.json', ['assetPath']),
      224,
      288,
    );
  });

  test('book covers are WebP at most 2× the book page box', () async {
    await expectBounded(
      paths('assets/data/books/books.json', ['coverAssetPath']),
      232,
      340,
    );
  });

  test('no image file is left that no record names', () {
    final named = {
      ...paths('assets/data/literature/poets.json', ['assetPath']),
      ...paths('assets/data/books/books.json', ['coverAssetPath']),
    };
    for (final dir in [
      'assets/data/literature/portraits',
      'assets/data/books/covers',
    ]) {
      for (final file in Directory(dir).listSync().whereType<File>()) {
        expect(named, contains(file.path), reason: file.path);
      }
    }
  });
}
