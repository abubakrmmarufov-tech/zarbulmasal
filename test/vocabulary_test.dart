import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/proverbs/proverb_detail_screen.dart';
import 'package:zarbulmasal/features/vocabulary/data/vocabulary_aggregator.dart';
import 'package:zarbulmasal/features/vocabulary/data/vocabulary_providers.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/domain/vocabulary_entry.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/features/vocabulary/presentation/vocabulary_detail_screen.dart';

import 'helpers/test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('real-data aggregation', () {
    const aggregator = VocabularyAggregator();
    late List<HistoryEntry> history;
    late List<LiteraryAuthor> authors;

    setUpAll(() async {
      history = await _loadHistory();
      authors = await _loadAuthors();
    });

    List<VocabularyEntry> aggregate() => aggregator.aggregate(
      proverbs: seedProverbs,
      history: history,
      authors: authors,
    );

    test('aggregates every glossary record into one flat lexicon', () {
      final entries = aggregate();

      // Counts mirror the verified catalog at the time of writing: 186
      // proverbs, 85 history entries, and 144 active poet dossiers.
      expect(entries, hasLength(415));
      expect(
        entries.where((e) => e.kind == VocabularyKind.proverb),
        hasLength(186),
      );
      expect(
        entries.where((e) => e.kind == VocabularyKind.history),
        hasLength(85),
      );
      expect(
        entries.where((e) => e.kind == VocabularyKind.literaryAuthor),
        hasLength(144),
      );

      expect(entries.map((e) => e.id).toSet(), hasLength(entries.length));
      expect(entries.every((e) => e.term.trim().isNotEmpty), isTrue);
      expect(entries.every((e) => e.meaning.trim().isNotEmpty), isTrue);
      expect(entries.every((e) => e.sources.isNotEmpty), isTrue);
    });

    test('terms are whole source phrases and names, never fragments', () {
      final entries = aggregate();
      final proverbTerms = seedProverbs
          .map((p) => p.tajikCyrillic.trim())
          .toSet();
      final historyTitles = history.map((h) => h.title.trim()).toSet();
      final authorNames = authors
          .where((a) => a.hasCanonicalName)
          .map((a) => a.canonicalName.trim())
          .toSet();

      for (final entry in entries) {
        final isVerbatim =
            (entry.kind == VocabularyKind.proverb &&
                proverbTerms.contains(entry.term)) ||
            (entry.kind == VocabularyKind.history &&
                historyTitles.contains(entry.term)) ||
            (entry.kind == VocabularyKind.literaryAuthor &&
                authorNames.contains(entry.term));
        expect(
          isVerbatim,
          isTrue,
          reason: 'Term "${entry.term}" is not a verbatim source field',
        );
      }
    });

    test('every source meaning survives verbatim in the merged entry', () {
      final entries = aggregate();
      final proverbById = {for (final p in seedProverbs) p.id: p};
      final historyById = {for (final h in history) h.id: h};
      final authorById = {for (final a in authors) a.id: a};

      for (final entry in entries) {
        final meaningTexts = entry.distinctMeanings.map((m) => m.text);
        for (final source in entry.sources) {
          switch (source.kind) {
            case VocabularyKind.proverb:
              final proverb = proverbById[source.sourceId]!;
              final expected = proverb.meaningTj.trim().isNotEmpty
                  ? proverb.meaningTj.trim()
                  : proverb.simpleExplanationTj.trim();
              expect(
                meaningTexts,
                contains(expected),
                reason: '${entry.id} dropped a proverb meaning',
              );
            case VocabularyKind.history:
              final record = historyById[source.sourceId]!;
              expect(
                meaningTexts,
                contains(record.summary.trim()),
                reason: '${entry.id} dropped a history meaning',
              );
            case VocabularyKind.literaryAuthor:
              final author = authorById[source.sourceId]!;
              expect(
                meaningTexts,
                contains(author.biographyTj.trim()),
                reason: '${entry.id} dropped an author meaning',
              );
          }
        }
      }
    });

    test('deduplication preserves distinct meanings and both sources', () {
      final entries = aggregate();
      final merged = entries.where((e) => e.sources.length > 1).toList();

      // Exactly one record is shared between sources in the current catalog.
      expect(merged, hasLength(1));

      final ayni = merged.single;
      expect(ayni.id, 'vocab-history-person-ayni');
      expect(ayni.term, 'Садриддин Айнӣ');
      expect(ayni.sources, hasLength(2));
      expect(ayni.distinctMeanings, hasLength(2));

      final historySummary = history
          .firstWhere((h) => h.id == 'person-ayni')
          .summary
          .trim();
      final author = authors.firstWhere(
        (a) => a.id == '47c1dc67-363a-4506-8a9c-bbbb38f98d20',
      );

      expect(
        ayni.distinctMeanings.map((m) => m.text),
        containsAll([historySummary, author.biographyTj.trim()]),
      );

      // Both source routes remain reachable from the merged entry.
      expect(
        ayni.sources.map((s) => s.route),
        containsAll([
          '/history/person-ayni',
          '/literature/poet/47c1dc67-363a-4506-8a9c-bbbb38f98d20',
        ]),
      );

      // The poet biography meaning is still searchable even though it is not
      // the primary meaning: only the biography contains this full name.
      expect(ayni.matches('Сайидмуродхоҷа'), isTrue);
      // The history meaning is searchable through the primary meaning too.
      expect(ayni.matches('Манғития'), isTrue);
    });

    test('kind filters select only entries of that kind', () {
      final entries = aggregate();
      expect(
        entries.where((e) => e.kind == VocabularyKind.proverb),
        hasLength(186),
      );
      expect(
        entries.where((e) => e.kind == VocabularyKind.history),
        hasLength(85),
      );
      expect(
        entries.where((e) => e.kind == VocabularyKind.literaryAuthor),
        hasLength(144),
      );
    });

    test('queries match terms, meanings, and Latin/Persian forms', () {
      final entries = aggregate();
      expect(entries.where((e) => e.matches('Айнӣ')), isNotEmpty);
      expect(entries.where((e) => e.matches('Рӯдакӣ')), isNotEmpty);
      // Latin keyboard transliteration still finds the author.
      expect(entries.where((e) => e.matches('rumi')), isNotEmpty);
      // A Persian meaning phrase is searchable.
      expect(entries.where((e) => e.matches('ضرب المثل')), isNotEmpty);
    });

    test('every source route points to a real record of the same kind', () {
      final entries = aggregate();
      final proverbIds = seedProverbs.map((p) => p.id).toSet();
      final historyIds = history.map((h) => h.id).toSet();
      final authorIds = authors.map((a) => a.id).toSet();

      for (final entry in entries) {
        for (final source in entry.sources) {
          switch (source.kind) {
            case VocabularyKind.proverb:
              expect(source.route, '/proverb/${source.sourceId}');
              expect(proverbIds, contains(source.sourceId));
            case VocabularyKind.history:
              expect(source.route, '/history/${source.sourceId}');
              expect(historyIds, contains(source.sourceId));
            case VocabularyKind.literaryAuthor:
              expect(source.route, '/literature/poet/${source.sourceId}');
              expect(authorIds, contains(source.sourceId));
          }
        }
      }
    });
  });

  group('dedup merge', () {
    const aggregator = VocabularyAggregator();

    const sameText = 'Оби кам дар кӯза аст.';
    const samePersian = 'آب کم در کوزه است.';

    const Proverb proverbA = Proverb(
      id: 'synthetic-1',
      tajikCyrillic: sameText,
      persianText: samePersian,
      simpleExplanationTj: 'Маънии якум.',
      meaningTj: 'Маънии якум — миқдор кам аст.',
      exampleSentenceTj: 'Мисоли якум.',
      categoryId: 'mehnat',
      level: 1,
      type: ProverbType.traditional,
      sourceStatus: SourceStatus.bookAttested,
      sourceNote: 'Манбаъи якум',
    );

    const Proverb proverbB = Proverb(
      id: 'synthetic-2',
      tajikCyrillic: sameText,
      persianText: samePersian,
      simpleExplanationTj: 'Маънии дуюм.',
      meaningTj: 'Маънии дуюм — фарқ дорад.',
      exampleSentenceTj: 'Мисоли дуюм.',
      categoryId: 'padaru_modar',
      level: 2,
      type: ProverbType.traditional,
      sourceStatus: SourceStatus.bookAttested,
      sourceNote: 'Манбаъи дуюм',
    );

    test('same normalized term with different meanings keeps both', () {
      final entries = aggregator.aggregate(
        proverbs: const [proverbA, proverbB],
        history: const [],
        authors: const [],
      );

      expect(entries, hasLength(1));
      final entry = entries.single;
      expect(entry.sources, hasLength(2));
      expect(entry.distinctMeanings, hasLength(2));
      expect(
        entry.distinctMeanings.map((m) => m.text),
        containsAll([
          'Маънии якум — миқдор кам аст.',
          'Маънии дуюм — фарқ дорад.',
        ]),
      );
      expect(
        entry.sources.map((s) => s.route),
        containsAll(['/proverb/synthetic-1', '/proverb/synthetic-2']),
      );
    });

    test('identical meaning from two sources is kept once with both links', () {
      const sharedMeaning = 'Маънии муштарак.';
      final entries = aggregator.aggregate(
        proverbs: const [
          Proverb(
            id: 'synthetic-a',
            tajikCyrillic: sameText,
            persianText: samePersian,
            simpleExplanationTj: sharedMeaning,
            meaningTj: sharedMeaning,
            exampleSentenceTj: 'Мисоли якум.',
            categoryId: 'mehnat',
            level: 1,
            type: ProverbType.traditional,
            sourceStatus: SourceStatus.bookAttested,
            sourceNote: 'Манбаъи якум',
          ),
          Proverb(
            id: 'synthetic-b',
            tajikCyrillic: sameText,
            persianText: samePersian,
            simpleExplanationTj: sharedMeaning,
            meaningTj: sharedMeaning,
            exampleSentenceTj: 'Мисоли дуюм.',
            categoryId: 'padaru_modar',
            level: 2,
            type: ProverbType.traditional,
            sourceStatus: SourceStatus.bookAttested,
            sourceNote: 'Манбаъи дуюм',
          ),
        ],
        history: const [],
        authors: const [],
      );

      expect(entries, hasLength(1));
      expect(entries.single.distinctMeanings, hasLength(1));
      expect(entries.single.sources, hasLength(2));
    });
  });

  group('vocabulary screen', () {
    const lexicalEntries = <WordEntry>[
      WordEntry(
        term: 'Тилисм',
        definition: 'ҷоду.',
        sourceBook: 'adabiet sinfi 5.pdf',
        pdfPage: 17,
      ),
      WordEntry(
        term: 'Урду',
        definition: 'лашкар, сипоҳ.',
        sourceBook: 'adabiet sinfi 5.pdf',
        pdfPage: 17,
      ),
    ];

    testWidgets('renders lexical headwords and keeps navigation back', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/vocabulary',
        overrides: [
          wordsProvider.overrideWith((ref) => Future.value(lexicalEntries)),
        ],
      );

      // Each headword is its own card with its meaning below it.
      expect(find.text('Тилисм'), findsOneWidget);
      expect(find.text('ҷоду.'), findsOneWidget);
      expect(find.text('Урду'), findsOneWidget);
      expect(find.text('лашкар, сипоҳ.'), findsOneWidget);

      // The old aggregated lexicon rows are gone; a search box is back
      // (users asked to search the lexicon).
      expect(
        find.textContaining('Зарбулмасали санҷишӣ', findRichText: true),
        findsNothing,
      );
      expect(find.byType(TextField), findsOneWidget);

      // Navigation back remains.
      expect(find.byType(BackButton), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('vocabulary detail', () {
    const mergedEntry = VocabularyEntry(
      id: 'vocab-history-person-ayni',
      term: 'Садриддин Айнӣ',
      meaning: 'Маънии таърихӣ.',
      kind: VocabularyKind.history,
      meanings: [
        VocabularyMeaning(
          text: 'Маънии таърихӣ.',
          kind: VocabularyKind.history,
        ),
        VocabularyMeaning(
          text: 'Зиндагиномаи пурраи адиб.',
          kind: VocabularyKind.literaryAuthor,
        ),
      ],
      sources: [
        VocabularySource(
          kind: VocabularyKind.history,
          sourceId: 'person-ayni',
          route: '/history/person-ayni',
          contextTj: 'Охири асри XIX – асри XX',
        ),
        VocabularySource(
          kind: VocabularyKind.literaryAuthor,
          sourceId: '47c1dc67-363a-4506-8a9c-bbbb38f98d20',
          route: '/literature/poet/47c1dc67-363a-4506-8a9c-bbbb38f98d20',
          contextTj: 'Охири асри XIX ва нимаи аввали асри XX',
        ),
      ],
    );

    testWidgets('renders every distinct meaning of a merged entry', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/vocabulary/vocab-history-person-ayni',
        overrides: [
          vocabularyProvider.overrideWith((ref) => Future.value([mergedEntry])),
        ],
      );

      expect(find.byType(VocabularyDetailScreen), findsOneWidget);
      expect(find.text('Садриддин Айнӣ'), findsOneWidget);
      expect(find.text('Маънии таърихӣ.'), findsOneWidget);
      expect(find.text('Зиндагиномаи пурраи адиб.'), findsOneWidget);

      // Merged entries label each meaning with its source kind.
      expect(find.text('Таърих'), findsWidgets);
      expect(find.text('Адиб'), findsWidgets);

      // Both source tiles carry their real context strings.
      expect(find.text('Манбаъҳо'), findsOneWidget);
      expect(find.text('Охири асри XIX – асри XX'), findsOneWidget);
      expect(
        find.text('Охири асри XIX ва нимаи аввали асри XX'),
        findsOneWidget,
      );
    });

    testWidgets('source tile navigates to the underlying record', (
      tester,
    ) async {
      const proverbEntry = VocabularyEntry(
        id: 'vocab-proverb-21',
        term: 'Мисли модар ёру мисли Ватан диёре нест.',
        meaning:
            'Ҳеҷ меҳру паноҳе мисли меҳри модар ва ҳеҷ диёре мисли Ватан нест.',
        kind: VocabularyKind.proverb,
        meanings: [
          VocabularyMeaning(
            text:
                'Ҳеҷ меҳру паноҳе мисли меҳри модар ва ҳеҷ диёре мисли Ватан нест.',
            kind: VocabularyKind.proverb,
          ),
        ],
        sources: [
          VocabularySource(
            kind: VocabularyKind.proverb,
            sourceId: '21',
            route: '/proverb/21',
            contextTj: 'Зарбулмасал ва мақолҳои тоҷикӣ',
            categoryId: 'padaru_modar',
          ),
        ],
      );

      await openApp(
        tester,
        route: '/vocabulary/vocab-proverb-21',
        overrides: [
          vocabularyProvider.overrideWith(
            (ref) => Future.value([proverbEntry]),
          ),
        ],
      );

      // Single-meaning entry: the only "Зарбулмасал" label is the source tile.
      await tester.tap(find.text('Зарбулмасал'));
      await tester.pumpAndSettle();

      expect(find.byType(ProverbDetailScreen), findsOneWidget);
    });
  });
}

Future<List<HistoryEntry>> _loadHistory() async {
  final raw =
      jsonDecode(
            await rootBundle.loadString('assets/data/history/entries.json'),
          )
          as List<dynamic>;
  return raw
      .whereType<Map<String, dynamic>>()
      .map(HistoryEntry.fromJson)
      .toList(growable: false);
}

Future<List<LiteraryAuthor>> _loadAuthors() async {
  final raw =
      jsonDecode(
            await rootBundle.loadString('assets/data/literature/poets.json'),
          )
          as List<dynamic>;
  return raw
      .whereType<Map<String, dynamic>>()
      .map(LiteraryAuthor.fromJson)
      .toList(growable: false);
}
