import 'history_entry.dart';

/// Canonical chronological epochs of the Tajik people as taught in the
/// historical and educational curriculum of Tajikistan.
enum HistoryEpoch {
  ancient,
  samanid,
  medieval,
  enlightenment,
  soviet,
  independence;

  String get labelTajik {
    switch (this) {
      case HistoryEpoch.ancient:
        return 'Бостон ва ориёӣ';
      case HistoryEpoch.samanid:
        return 'Сомониён ва эҳё';
      case HistoryEpoch.medieval:
        return 'Асрҳои миёна';
      case HistoryEpoch.enlightenment:
        return 'Маорифпарварӣ';
      case HistoryEpoch.soviet:
        return 'Давраи Шӯравӣ';
      case HistoryEpoch.independence:
        return 'Истиқлолият';
    }
  }

  String get labelPersian {
    switch (this) {
      case HistoryEpoch.ancient:
        return 'باستان و آریایی';
      case HistoryEpoch.samanid:
        return 'سامانیان و رنسانس';
      case HistoryEpoch.medieval:
        return 'قرون وسطی';
      case HistoryEpoch.enlightenment:
        return 'معارف‌پروری و جدیدیه';
      case HistoryEpoch.soviet:
        return 'دوران شوروی';
      case HistoryEpoch.independence:
        return 'استقلال دولتی';
    }
  }

  String get periodTajik {
    switch (this) {
      case HistoryEpoch.ancient:
        return 'То асри VIII милодӣ';
      case HistoryEpoch.samanid:
        return 'Асрҳои IX–X';
      case HistoryEpoch.medieval:
        return 'Асрҳои XI–XIX';
      case HistoryEpoch.enlightenment:
        return 'Нимаи дуюми асри XIX – 1917';
      case HistoryEpoch.soviet:
        return '1917–1991';
      case HistoryEpoch.independence:
        return 'Аз соли 1991 то имрӯз';
    }
  }

  String get periodPersian {
    switch (this) {
      case HistoryEpoch.ancient:
        return 'تا قرن ۸ میلادی';
      case HistoryEpoch.samanid:
        return 'قرن‌های ۹–۱۰';
      case HistoryEpoch.medieval:
        return 'قرن‌های ۱۱–۱۹';
      case HistoryEpoch.enlightenment:
        return 'نیمه دوم قرن ۱۹ تا ۱۹۱۷';
      case HistoryEpoch.soviet:
        return '۱۹۱۷–۱۹۹۱';
      case HistoryEpoch.independence:
        return 'از ۱۹۹۱ تا امروز';
    }
  }

  /// Classifies a [HistoryEntry] into its canonical chronological epoch.
  static HistoryEpoch fromEntry(HistoryEntry entry) {
    final haystack =
        '${entry.period} ${entry.id} ${entry.keywords.join(' ')} ${entry.title}'
            .toLowerCase();

    if (haystack.contains('истиқлол') ||
        haystack.contains('1991') ||
        haystack.contains('муосир')) {
      return HistoryEpoch.independence;
    }
    if (haystack.contains('шӯравӣ') ||
        haystack.contains('1917') ||
        haystack.contains('1918') ||
        haystack.contains('1920') ||
        haystack.contains('1923') ||
        haystack.contains('1929') ||
        haystack.contains('1930') ||
        haystack.contains('1938') ||
        haystack.contains('1945') ||
        haystack.contains('ҷанги дуюм') ||
        haystack.contains('ссср')) {
      return HistoryEpoch.soviet;
    }
    if (haystack.contains('маорифпарвар') ||
        haystack.contains('ҷадид') ||
        haystack.contains('дониш') ||
        haystack.contains('айнӣ') ||
        haystack.contains('аморати бухоро') ||
        haystack.contains('нимаи дуюми асри xix') ||
        haystack.contains('асри xix – 1917') ||
        haystack.contains('асри xix милодӣ')) {
      return HistoryEpoch.enlightenment;
    }
    if (haystack.contains('сомониён') ||
        haystack.contains('тоҳириён') ||
        haystack.contains('саффориён') ||
        haystack.contains('рӯдакӣ') ||
        haystack.contains('асри ix') ||
        haystack.contains('асри x') ||
        haystack.contains('асрҳои ix–x')) {
      return HistoryEpoch.samanid;
    }
    if (haystack.contains('ғазнавиён') ||
        haystack.contains('ғуриён') ||
        haystack.contains('хоразмшоҳ') ||
        haystack.contains('муғул') ||
        haystack.contains('темур') ||
        haystack.contains('темуриён') ||
        haystack.contains('асри xi') ||
        haystack.contains('асри xii') ||
        haystack.contains('асри xiii') ||
        haystack.contains('асри xiv') ||
        haystack.contains('асри xv') ||
        haystack.contains('асрҳои xi') ||
        haystack.contains('асрҳои xii') ||
        haystack.contains('асрҳои xiii') ||
        haystack.contains('асрҳои xiv') ||
        haystack.contains('асрҳои x–xii') ||
        haystack.contains('асрҳои xi–xii') ||
        haystack.contains('асрҳои xi–xiii')) {
      return HistoryEpoch.medieval;
    }
    return HistoryEpoch.ancient;
  }
}
