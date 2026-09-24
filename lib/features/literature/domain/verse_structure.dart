/// Shared heuristics for deciding whether a text is a coherent verse work.
///
/// Used both by [LiteraryWork.hasCoherentVerseStructure] and by the
/// `tool/validate_literary_content.dart` data-audit script so the two can
/// never drift apart. Kept deliberately narrow: it only recognises appended
/// editorial noise that no real hemistich can produce, so legitimate short
/// forms and parenthetical text inside a genuine hemistich are unaffected.
library;

/// A line that is entirely one parenthesized note — typically an appended
/// author attribution such as «(Лоиқ Шералӣ)». Verse hemistiches are never
/// wrapped in parentheses, so this cannot match real poetry.
final RegExp _pureParenthesisLine = RegExp(r'^\s*\([^()]*\)\s*$');

/// Trailing punctuation that may follow the final word of a hemistich.
final RegExp _trailingPunctuation = RegExp(r'[.,;:!?»…«()"“”—–،؛؟-]+$');

/// Bare prepositions/conjunctions that a coherent Tajik/Persian hemistich
/// never ends with. A line whose final word is one of these is an obvious
/// truncated prose-gloss line, not verse.
const Set<String> _danglingLineEnders = {'дар', 'ба', 'аз', 'бо', 'бар', 'то'};

/// Whether [line] is appended editorial noise that must not count as a
/// hemistich: a pure-parenthesis attribution or an obvious truncated
/// prose-gloss line.
bool isAppendedNoiseLine(String line) {
  if (_pureParenthesisLine.hasMatch(line)) return true;
  final trimmedEnd = line.replaceAll(_trailingPunctuation, '');
  final words = trimmedEnd.split(RegExp(r'\s+'));
  if (words.isEmpty) return false;
  return _danglingLineEnders.contains(words.last);
}

/// Returns the lines of [text] that can count as verse hemistiches.
///
/// Empty lines and appended editorial noise ([isAppendedNoiseLine]) are
/// dropped. A real hemistich that merely contains a parenthetical gloss
/// (e.g. «қазо (тақдир, сарнавишт)») is preserved.
List<String> coherentVerseLines(String text) {
  return text
      .split(RegExp(r'[\n|]'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !isAppendedNoiseLine(line))
      .toList(growable: false);
}
