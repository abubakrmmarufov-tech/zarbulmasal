import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import '../../../vocabulary/domain/lexicon_index.dart';

/// A line of verse whose words can be tapped to look them up.
///
/// It renders exactly like [Text]; a tap finds the glyph under the finger
/// through the laid-out paragraph and hands the word there (see
/// [LexiconIndex.wordAt]) to [onWord]. Taps on spaces and marks do nothing.
class LookupText extends StatefulWidget {
  const LookupText(
    this.text, {
    super.key,
    required this.style,
    required this.textDirection,
    required this.onWord,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;
  final TextAlign? textAlign;
  final ValueChanged<String> onWord;

  @override
  State<LookupText> createState() => _LookupTextState();
}

class _LookupTextState extends State<LookupText> {
  final _paragraph = GlobalKey();
  Offset? _down;
  Duration? _downAt;

  // The reader's text sits in a SelectionArea, whose gestures win the
  // arena; raw pointer events see the tap without taking it from them. A
  // tap is a press released close to where it began, before a long press
  // (which selects) and without a drag (which scrolls).
  void _onPointerDown(PointerDownEvent event) {
    _down = event.position;
    _downAt = event.timeStamp;
  }

  void _onPointerUp(PointerUpEvent event) {
    final down = _down;
    final downAt = _downAt;
    _down = null;
    if (down == null || downAt == null) return;
    if ((event.position - down).distance > kTouchSlop) return;
    if (event.timeStamp - downAt > kLongPressTimeout) return;
    final word = _wordAt(event.position);
    if (word != null) widget.onWord(word);
  }

  /// The word whose glyphs lie under the global [point], if any.
  String? _wordAt(Offset point) {
    final box = _findParagraph(_paragraph.currentContext?.findRenderObject());
    if (box == null) return null;
    final local = box.globalToLocal(point);
    final caret = box.getPositionForOffset(local).offset;
    for (final index in [caret, caret - 1]) {
      if (index < 0 || index >= widget.text.length) continue;
      final glyphs = box.getBoxesForSelection(
        TextSelection(baseOffset: index, extentOffset: index + 1),
      );
      if (glyphs.any((glyph) => glyph.toRect().inflate(1).contains(local))) {
        return LexiconIndex.wordAt(widget.text, index);
      }
    }
    return null;
  }

  /// The laid-out paragraph under [object] (in a SelectionArea, [Text]
  /// wraps it in a mouse region for the text cursor).
  static RenderParagraph? _findParagraph(RenderObject? object) {
    if (object == null || object is RenderParagraph) {
      return object as RenderParagraph?;
    }
    RenderParagraph? found;
    object.visitChildren((child) => found ??= _findParagraph(child));
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: (_) => _down = null,
      child: Text(
        widget.text,
        key: _paragraph,
        style: widget.style,
        textDirection: widget.textDirection,
        textAlign: widget.textAlign,
      ),
    );
  }
}
