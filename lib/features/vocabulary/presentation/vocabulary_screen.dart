import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/utils/search_field_limits.dart';
import '../../../core/utils/search_normalizer.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/words_provider.dart';
import '../domain/word_entry.dart';

/// The Луғатнома: every reviewed headword as its own card, grouped under
/// large letters in Tajik alphabetical order, with a search box and an
/// alphabet strip. Follows the app theme (day paper, lapis at night).
class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key, this.initialQuery});

  /// A word to open the Lexicon on (from `?word=`), set in the search field.
  final String? initialQuery;

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  late final _search = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery ?? '';
  String? _letter;

  // Sorting ~1,900 headwords by the Tajik alphabet is done once per word
  // list, not on every keystroke.
  List<WordEntry>? _sourceWords;
  List<WordEntry> _sorted = const [];
  List<String> _letters = const [];

  void _index(List<WordEntry> words) {
    if (identical(words, _sourceWords)) return;
    _sourceWords = words;
    _sorted = TajikAlphabet.sort(words);
    _letters = <String>{
      for (final word in _sorted) TajikAlphabet.initialOf(word.term),
    }.toList(growable: false);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final async = ref.watch(wordsProvider);
    String tr(String key) => AppTranslations.get(key, lang);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: tr('btn_back'),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          tr('vocab_title'),
          style: QalamTypography.monographTitle(
            color: colors.onSurface,
            fontSize: 24,
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: EmptyState(
            icon: Icons.translate,
            title: tr('vocab_load_error'),
            subtitle: tr('vocab_load_error_sub'),
            action: OutlinedButton(
              onPressed: () => ref.invalidate(wordsProvider),
              child: Text(tr('btn_retry')),
            ),
          ),
        ),
        data: (words) => _buildBook(context, words, lang),
      ),
    );
  }

  Widget _buildBook(
    BuildContext context,
    List<WordEntry> words,
    DisplayLanguage lang,
  ) {
    final colors = Theme.of(context).colorScheme;
    String tr(String key) => AppTranslations.get(key, lang);
    _index(words);
    final sorted = _sorted;
    final letters = _letters;
    final visible = sorted
        .where(
          (word) =>
              (_letter == null ||
                  TajikAlphabet.initialOf(word.term) == _letter) &&
              (_query.trim().isEmpty ||
                  SearchNormalizer.matchesAny([
                    word.term,
                    word.definition,
                  ], _query)),
        )
        .toList(growable: false);

    // Flatten into letter headings and word cards for one lazy list.
    final items = <Object>[];
    String? current;
    for (final word in visible) {
      final initial = TajikAlphabet.initialOf(word.term);
      if (initial != current) {
        items.add(initial);
        current = initial;
      }
      items.add(word);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppTranslations.get('home_col_lexicon_sub', lang, [
                    AppTranslations.formatNumber(words.length, lang),
                  ]),
                  style: QalamTypography.meta(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  inputFormatters: searchQueryFormatters,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: tr('vocab_search_hint'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: tr('btn_clear'),
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              itemCount: letters.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final letter = index == 0 ? null : letters[index - 1];
                return ChoiceChip(
                  // Single letters are the whole label: set them larger
                  // than the 12 px chip text so they read at a glance.
                  label: Text(
                    letter ?? tr('vocab_all'),
                    style: letter == null
                        ? null
                        : const TextStyle(fontSize: 16),
                  ),
                  selected: _letter == letter,
                  onSelected: (_) => setState(() => _letter = letter),
                );
              },
            ),
          ),
        ),
        if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off,
              title: tr('vocab_no_results'),
              subtitle: tr('vocab_no_results_sub'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is String) return _LetterHeading(letter: item);
                return _WordCard(entry: item as WordEntry, query: _query);
              },
            ),
          ),
      ],
    );
  }
}

/// Tajik Cyrillic alphabetical order, so the lexicon reads like a printed
/// dictionary (Ғ after Г, Ӣ after И, Қ after К, Ӯ after У, Ҳ after Х,
/// Ҷ after Ч).
abstract final class TajikAlphabet {
  static const String order = 'АБВГҒДЕЁЖЗИӢЙКҚЛМНОПРСТУӮФХҲЧҶШЪЭЮЯ';

  /// The headword's first letter, upper-cased ('#' when it is not a letter
  /// of the alphabet).
  static String initialOf(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return '#';
    final first = String.fromCharCode(trimmed.runes.first).toUpperCase();
    return order.contains(first) ? first : '#';
  }

  static int _rank(String char) {
    final index = order.indexOf(char.toUpperCase());
    return index < 0 ? order.length + char.codeUnitAt(0) : index;
  }

  /// Compares two words letter by letter in Tajik alphabetical order.
  static int compare(String a, String b) {
    final left = a.trim();
    final right = b.trim();
    final length = left.length < right.length ? left.length : right.length;
    for (var i = 0; i < length; i++) {
      final diff = _rank(left[i]) - _rank(right[i]);
      if (diff != 0) return diff;
    }
    return left.length - right.length;
  }

  /// A new list sorted by headword.
  static List<WordEntry> sort(List<WordEntry> words) =>
      [...words]..sort((a, b) => compare(a.term, b.term));
}

class _LetterHeading extends StatelessWidget {
  const _LetterHeading({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 20, 0, 8),
        child: Row(
          children: [
            Text(
              letter,
              style: QalamTypography.monographTitle(
                color: colors.primary,
                fontSize: 34,
                height: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: colors.outline, height: 1)),
          ],
        ),
      ),
    );
  }
}

/// One headword: the word large, its meaning below, in its own box so one
/// entry never runs into the next.
class _WordCard extends StatelessWidget {
  const _WordCard({required this.entry, required this.query});

  final WordEntry entry;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final paper = theme.brightness == Brightness.dark
        ? colors.surfaceContainer
        : colors.surfaceContainerLowest;
    final termStyle = QalamTypography.monographTitle(
      color: colors.onSurface,
      fontSize: 22,
    );
    final range = SearchNormalizer.matchRange(entry.term, query);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            range == null
                ? Text(entry.term, style: termStyle)
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: entry.term.substring(0, range.start)),
                        TextSpan(
                          text: entry.term.substring(range.start, range.end),
                          style: TextStyle(color: colors.primary),
                        ),
                        TextSpan(text: entry.term.substring(range.end)),
                      ],
                    ),
                    style: termStyle,
                  ),
            const SizedBox(height: 6),
            Text(
              entry.definition,
              style: QalamTypography.body(
                color: colors.onSurfaceVariant,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
