import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Decodes bundled JSON, off the UI thread when it is large enough for the
/// parse to cost a frame (books, history, the Lexicon are hundreds of KB).
Future<Object?> decodeJsonOffThread(
  String source, {
  int threshold = 64 * 1024,
}) {
  if (source.length < threshold) return Future.value(jsonDecode(source));
  return compute(_decode, source);
}

Object? _decode(String source) => jsonDecode(source);
