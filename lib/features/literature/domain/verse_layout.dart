import 'literary_work.dart';

/// Forms whose lines are written in bayts (couplets of two hemistiches).
const Set<WorkType> baytForms = {
  WorkType.ghazal,
  WorkType.qasida,
  WorkType.rubai,
  WorkType.fragment,
  WorkType.epic,
};

/// One stanza of a text: an ordered list of units.
///
/// A unit is either a bayt (two hemistiches) or a single line. Grouping is
/// presentation only — every line keeps its exact characters and order.
class VerseStanza {
  const VerseStanza({required this.units, required this.unitsAreBayts});

  final List<List<String>> units;
  final bool unitsAreBayts;
}

/// The laid-out verse of a text plus a flat index over its units, used for
/// "bayt 4 of 6" resume anchors.
class VerseLayout {
  const VerseLayout(this.stanzas);

  final List<VerseStanza> stanzas;

  int get unitCount =>
      stanzas.fold(0, (total, stanza) => total + stanza.units.length);

  /// Whether every unit is a bayt (so anchors can be called "bayt").
  bool get isBaytText =>
      stanzas.isNotEmpty && stanzas.every((stanza) => stanza.unitsAreBayts);

  /// Groups [text] for display.
  ///
  /// - Blank lines in the source separate stanzas, exactly as recorded.
  /// - A stanza of a bayt form ([baytForms]) with an even number of lines is
  ///   shown as bayts.
  /// - Anything else keeps its lines one by one: the layout never guesses a
  ///   couplet structure the data does not state.
  factory VerseLayout.of(String text, WorkType type) {
    final blocks = <List<String>>[];
    var current = <String>[];
    for (final raw in text.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        if (current.isNotEmpty) blocks.add(current);
        current = <String>[];
      } else {
        current.add(line);
      }
    }
    if (current.isNotEmpty) blocks.add(current);

    final stanzas = [
      for (final block in blocks)
        if (baytForms.contains(type) && block.length.isEven)
          VerseStanza(
            unitsAreBayts: true,
            units: List.unmodifiable([
              for (var i = 0; i < block.length; i += 2)
                List<String>.unmodifiable([block[i], block[i + 1]]),
            ]),
          )
        else
          VerseStanza(
            unitsAreBayts: false,
            units: List.unmodifiable([
              for (final line in block) List<String>.unmodifiable([line]),
            ]),
          ),
    ];
    return VerseLayout(List.unmodifiable(stanzas));
  }
}
