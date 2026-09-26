import 'package:flutter/widgets.dart';

final _firstLetter = RegExp(r'[A-Za-zЀ-ӿ؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]');
final _arabicScript = RegExp(r'[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]');

/// The direction [text] reads in, from the script of its first letter:
/// Persian script right to left; Tajik Cyrillic (and Latin) left to right,
/// also inside the Persian interface, so its punctuation stays at its end.
TextDirection scriptDirection(String text) {
  final letter = _firstLetter.firstMatch(text)?.group(0);
  return letter != null && _arabicScript.hasMatch(letter)
      ? TextDirection.rtl
      : TextDirection.ltr;
}
