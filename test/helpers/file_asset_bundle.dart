import 'dart:io';

import 'package:flutter/services.dart';

/// Reads assets straight from the repository files. `rootBundle` decodes
/// large JSON on a background isolate, which never finishes inside a
/// widget test's fake clock; this bundle answers synchronously instead.
class FileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      File(key).readAsStringSync();
}
