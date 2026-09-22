import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/data/models/learning_mastery.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/quiz/quiz_engine.dart';
import 'package:zarbulmasal/shared/providers/recent_activity_provider.dart';
import 'helpers/test_helper.dart';

void main() {
  group('Failure Resilience & Defensive Handling Tests', () {
    testWidgets(
      'missing proverb ID displays clean empty state without crashing',
      (tester) async {
        await openApp(tester, route: '/proverb/non-existent-99999');
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Ҳоло мақол дастрас нест'), findsOneWidget);
      },
    );

    testWidgets('missing poet ID displays clean empty state without crashing', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/literature/poet/non-existent-poet-99999',
        overrides: [
          authorByIdProvider.overrideWith((ref, id) => Future.value(null)),
          worksByAuthorProvider.overrideWith((ref, id) => Future.value([])),
          worksUnderReviewByAuthorProvider.overrideWith(
            (ref, id) => Future.value([]),
          ),
          schoolCanonByAuthorProvider.overrideWith(
            (ref, id) => Future.value([]),
          ),
        ],
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Шоир ёфт нашуд'), findsOneWidget);
    });

    testWidgets('missing work ID displays clean empty state without crashing', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/literature/work/non-existent-work-99999',
        overrides: [
          approvedWorksProvider.overrideWith((ref) => Future.value([])),
          literaryWorksProvider.overrideWith((ref) => Future.value([])),
        ],
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Асар ёфт нашуд'), findsOneWidget);
    });

    testWidgets(
      'missing history ID displays clean empty state without crashing',
      (tester) async {
        await openApp(
          tester,
          route: '/history/non-existent-entry-99999',
          overrides: [
            historyEntryByIdProvider.overrideWith(
              (ref, id) => Future.value(null),
            ),
            historyBooksProvider.overrideWith((ref) => Future.value([])),
          ],
        );
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Сабти таърихӣ ёфт нашуд'), findsOneWidget);
      },
    );

    testWidgets('missing book ID displays clean empty state without crashing', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/books/non-existent-book-99999',
        overrides: [
          bookByIdProvider.overrideWith((ref, id) => Future.value(null)),
        ],
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Китобе ёфт нашуд'), findsOneWidget);
    });

    testWidgets('arbitrary unknown route renders route error page', (
      tester,
    ) async {
      await openApp(tester, route: '/completely/broken/path/123');
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Саҳифа ёфт нашуд'), findsOneWidget);
    });

    test('corrupted ProverbMastery JSON falls back to safe unseen state', () {
      final corruptedJson = <String, dynamic>{
        'proverbId': 'corrupted-1',
        'level': 'UNKNOWN_LEVEL_NAME',
        'reviewCount': 'not-a-number',
        'lastReviewedAt': 'invalid-date-string',
      };

      final mastery = ProverbMastery.fromJson(corruptedJson);
      expect(mastery.proverbId, 'corrupted-1');
      expect(mastery.level, MasteryLevel.unseen);
      expect(mastery.reviewCount, 0);
      expect(mastery.lastReviewedAt.millisecondsSinceEpoch, 0);
    });

    test(
      'corrupted RecentActivity JSON handles malformed input gracefully',
      () {
        final validJson = <String, dynamic>{
          'id': 'rec-1',
          'type': 'proverb',
          'title': 'Паррандаро ба парвозаш',
          'subtitle': 'Зарбулмасал',
          'timestamp': '2026-09-20T12:00:00.000Z',
          'route': '/proverb/22',
        };

        final activity = RecentActivity.fromJson(validJson);
        expect(activity.id, 'rec-1');
        expect(activity.type, RecentActivityType.proverb);
      },
    );

    test(
      'corrupted persisted activity records are discarded individually',
      () async {
        SharedPreferences.setMockInitialValues({
          'recent_activities': [
            jsonEncode({
              'id': 'valid-1',
              'type': 'proverb',
              'title': 'Мақоли дуруст',
              'subtitle': 'Зарбулмасал',
              'timestamp': '2026-09-20T12:00:00.000Z',
              'route': '/proverb/22',
            }),
            '{not valid json',
            jsonEncode({
              'id': 'external-1',
              'type': 'history',
              'title': 'External route',
              'timestamp': '2026-09-20T12:00:00.000Z',
              'route': 'https://example.com',
            }),
          ],
        });
        final prefs = await SharedPreferences.getInstance();

        final notifier = RecentActivityNotifier(prefs);

        expect(notifier.state, hasLength(1));
        expect(notifier.state.single.id, 'valid-1');
        expect(
          RecentActivity.tryFromJson({
            'id': 'external-2',
            'type': 'history',
            'title': 'External route',
            'timestamp': '2026-09-20T12:00:00.000Z',
            'route': '//example.com',
          }),
          isNull,
        );
      },
    );

    test(
      'insecure or malformed URLs in BookEdition are rejected by safe URI getters',
      () {
        const edition = BookEdition(
          id: 'ed-1',
          bookId: 'b-1',
          providerId: 'p-1',
          sourceUrl: 'http://insecure-http-site.com/book',
          readUrl: 'javascript:alert(1)',
          downloadUrl: 'file:///etc/passwd',
          coverUrl: '   ',
          language: 'Тоҷикӣ',
          format: BookFormat.pdf,
          availability: BookAvailability.downloadAvailable,
          rightsStatus: BookRightsStatus.rightsUnclear,
          metadataNote: 'test',
        );

        expect(edition.sourceUri, isNull);
        expect(edition.readUri, isNull);
        expect(edition.downloadUri, isNull);
        expect(edition.coverUri, isNull);
        expect(edition.hasCover, isFalse);
        expect(edition.canRead, isFalse);
      },
    );

    test(
      'QuizEngine handles zero eligible proverbs gracefully without crashing',
      () {
        final emptyQuiz = QuizEngine.generateQuiz(catalog: const []);
        expect(emptyQuiz, isEmpty);

        // Only unverified proverbs in catalog
        const unverifiedCatalog = [
          Proverb(
            id: 'unver-1',
            tajikCyrillic: 'Сухан гуфтан ҳунар аст.',
            persianText: 'سخن گفتن هنر است.',
            simpleExplanationTj: 'Сухан бояд боандеша бошад.',
            meaningTj: 'Сухан гуфтан маърифат мехоҳад.',
            exampleSentenceTj: 'Ба ӯ гуфтанд: сухан гуфтан ҳунар аст.',
            categoryId: 'odob',
            level: 1,
            type: ProverbType.traditional,
            sourceStatus: SourceStatus.unverified,
            sourceNote: '',
          ),
        ];

        final unverifiedQuiz = QuizEngine.generateQuiz(
          catalog: unverifiedCatalog,
        );
        expect(unverifiedQuiz, isEmpty);
      },
    );

    testWidgets(
      'renders key screens at 200% font scale without fatal crash or overflow',
      (tester) async {
        await openApp(tester, route: '/', width: 360, height: 800, scale: 2.0);
        expect(find.byType(Scaffold), findsWidgets);

        await openApp(
          tester,
          route: '/explore',
          width: 360,
          height: 800,
          scale: 2.0,
        );
        expect(find.byType(Scaffold), findsWidgets);

        await openApp(
          tester,
          route: '/settings',
          width: 360,
          height: 800,
          scale: 2.0,
        );
        expect(find.byType(Scaffold), findsWidgets);
      },
    );
  });
}
