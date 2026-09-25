import 'package:flutter/material.dart';

import '../../domain/verse_layout.dart';
import 'lookup_text.dart';

/// A verse line as [Text], or as [LookupText] when words can be looked up.
Widget _line(
  String text, {
  required TextStyle style,
  required TextDirection textDirection,
  ValueChanged<String>? onWordTap,
  TextAlign? textAlign,
}) => onWordTap == null
    ? Text(
        text,
        style: style,
        textDirection: textDirection,
        textAlign: textAlign,
      )
    : LookupText(
        text,
        style: style,
        textDirection: textDirection,
        textAlign: textAlign,
        onWord: onWordTap,
      );

/// Renders a [VerseLayout]: bayts as couplet blocks separated by space,
/// stanzas separated by more space, and wrapped continuations set flush to
/// the end edge so a long hemistich never looks like the start of a new one.
///
/// When the column is wide enough for both hemistiches of every bayt to fit
/// on one line each, the bayt is set side by side (first hemistich at the
/// start edge, following the text direction), as in printed divans.
class VerseView extends StatelessWidget {
  const VerseView({
    super.key,
    required this.layout,
    required this.style,
    required this.textDirection,
    this.unitKeys = const [],
    this.onWordTap,
  });

  final VerseLayout layout;
  final TextStyle style;
  final TextDirection textDirection;

  /// Optional keys, one per unit in reading order, so a reader can scroll to
  /// or observe a specific bayt/line.
  final List<GlobalKey> unitKeys;

  /// Called with a word the reader taps, when words can be looked up.
  final ValueChanged<String>? onWordTap;

  static const double hangingIndentEm = 1.5;
  static const double sideBySideMinWidth = 600;
  static const double hemistichGap = 32;

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? 20;
    final baytGap = fontSize * 0.9;
    final stanzaGap = fontSize * 1.8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = _fitsSideBySide(context, constraints.maxWidth);
        var unitIndex = 0;
        final children = <Widget>[];
        for (var s = 0; s < layout.stanzas.length; s++) {
          final stanza = layout.stanzas[s];
          if (s > 0) children.add(SizedBox(height: stanzaGap));
          for (var u = 0; u < stanza.units.length; u++) {
            final unit = stanza.units[u];
            if (u > 0 && stanza.unitsAreBayts) {
              children.add(SizedBox(height: baytGap));
            }
            final key = unitIndex < unitKeys.length
                ? unitKeys[unitIndex]
                : null;
            unitIndex++;
            children.add(
              KeyedSubtree(
                key: key,
                child: stanza.unitsAreBayts && sideBySide
                    ? _SideBySideBayt(
                        unit: unit,
                        style: style,
                        textDirection: textDirection,
                        onWordTap: onWordTap,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final line in unit)
                            HangingIndentLine(
                              text: line,
                              style: style,
                              textDirection: textDirection,
                              indent: fontSize * hangingIndentEm,
                              onWordTap: onWordTap,
                            ),
                        ],
                      ),
              ),
            );
          }
        }
        return Directionality(
          textDirection: textDirection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }

  bool _fitsSideBySide(BuildContext context, double width) {
    if (width < sideBySideMinWidth || !layout.isBaytText) return false;
    final half = (width - hemistichGap) / 2;
    final scaler = MediaQuery.textScalerOf(context);
    for (final stanza in layout.stanzas) {
      for (final unit in stanza.units) {
        for (final line in unit) {
          final painter = TextPainter(
            text: TextSpan(text: line, style: style),
            textDirection: textDirection,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          final fits = painter.width <= half;
          painter.dispose();
          if (!fits) return false;
        }
      }
    }
    return true;
  }
}

class _SideBySideBayt extends StatelessWidget {
  const _SideBySideBayt({
    required this.unit,
    required this.style,
    required this.textDirection,
    this.onWordTap,
  });

  final List<String> unit;
  final TextStyle style;
  final TextDirection textDirection;
  final ValueChanged<String>? onWordTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: unit.join('\n'),
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _line(
                unit.first,
                style: style,
                textDirection: textDirection,
                textAlign: TextAlign.start,
                onWordTap: onWordTap,
              ),
            ),
            const SizedBox(width: VerseView.hemistichGap),
            Expanded(
              child: _line(
                unit.last,
                style: style,
                textDirection: textDirection,
                textAlign: TextAlign.end,
                onWordTap: onWordTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single line of verse whose wrapped continuation drops under it, set
/// flush to the end edge (right for Cyrillic, left for Persian script) and
/// never closer than [indent] to the start edge. The text itself is
/// untouched; only the position of the continuation changes.
class HangingIndentLine extends StatelessWidget {
  const HangingIndentLine({
    super.key,
    required this.text,
    required this.style,
    required this.textDirection,
    required this.indent,
    this.onWordTap,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;
  final double indent;

  /// Called with a word the reader taps, when words can be looked up.
  final ValueChanged<String>? onWordTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: textDirection,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final wraps = painter.computeLineMetrics().length > 1;
        final firstEnd = painter
            .getLineBoundary(const TextPosition(offset: 0))
            .end;
        painter.dispose();

        if (!wraps || firstEnd <= 0 || firstEnd >= text.length) {
          return _line(
            text,
            style: style,
            textDirection: textDirection,
            onWordTap: onWordTap,
          );
        }
        // Split without trimming so the two parts rejoin to the exact
        // original characters (e.g. when a selection is copied).
        final first = text.substring(0, firstEnd);
        final rest = text.substring(firstEnd);
        return Semantics(
          label: text,
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _line(
                  first,
                  style: style,
                  textDirection: textDirection,
                  onWordTap: onWordTap,
                ),
                // The overflow drops under the line, set flush to the end
                // edge (right in Cyrillic), as printed divans set it.
                Padding(
                  padding: EdgeInsetsDirectional.only(start: indent),
                  child: _line(
                    rest,
                    style: style,
                    textDirection: textDirection,
                    textAlign: TextAlign.end,
                    onWordTap: onWordTap,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
