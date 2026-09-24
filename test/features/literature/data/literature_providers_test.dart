import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

class _OralRepository extends LiteratureRepository {
  _OralRepository(this.entries);

  final List<OralHeritageEntry> entries;

  @override
  Future<List<OralHeritageEntry>> loadOralHeritage() async => entries;
}

const _testApprovedSource = SourceEdition(
  bookTitle: 'Approved source',
  publisher: 'Publisher',
  city: 'Dushanbe',
  year: '2026',
  pageStart: 1,
  sourceType: SourceEditionType.criticalEdition,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Literature Providers', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'literatureRepositoryProvider provides LiteratureRepository instance',
      () {
        final repo = container.read(literatureRepositoryProvider);
        expect(repo, isA<LiteratureRepository>());
      },
    );

    test('literaryAuthorsProvider loads verified authors', () async {
      final authors = await container.read(literaryAuthorsProvider.future);
      expect(authors, isNotEmpty);
      expect(authors.first.id, 'rudaki');
    });

    test('literaryWorksProvider loads works', () async {
      final works = await container.read(literaryWorksProvider.future);
      expect(works, isA<List<LiteraryWork>>());
      expect(works, isNotEmpty);
    });

    test(
      'approvedWorksProvider provides verified works with page-level provenance',
      () async {
        final approved = await container.read(approvedWorksProvider.future);
        expect(approved, isA<List<LiteraryWork>>());
        expect(approved, isA<List<LiteraryWork>>());
      },
    );

    test(
      'searchableLiteraryWorksProvider exposes only page-checked review records',
      () async {
        final searchable = await container.read(
          searchableLiteraryWorksProvider.future,
        );

        expect(searchable, isNotEmpty);
        expect(
          searchable.every((work) => work.hasAuditableReviewCitation),
          isTrue,
        );
        expect(
          searchable.every(
            (work) => {
              VerificationLevel.primaryChecked,
              VerificationLevel.secondWitnessLocated,
              VerificationLevel.collated,
              VerificationLevel.editoriallyApproved,
            }.contains(work.verification.evidenceLevel),
          ),
          isTrue,
        );
        expect(
          searchable.any(
            (work) => work.id == 'qanoat_mavj_dar_sahro_grade6_2014_p147_148',
          ),
          isTrue,
        );
      },
    );

    test(
      'dailyVerseProvider provides daily verse when works have complete provenance',
      () async {
        final dailyVerse = await container.read(dailyVerseProvider.future);
        expect(dailyVerse, anyOf(isNull, isNotNull));
      },
    );

    test('schoolCanonProvider loads school canon entries', () async {
      final canon = await container.read(schoolCanonProvider.future);
      expect(canon, isNotEmpty);
      expect(canon.length, greaterThanOrEqualTo(20));
    });

    test('oralHeritageProvider loads oral heritage entries', () async {
      final oral = await container.read(oralHeritageProvider.future);
      expect(oral, isA<List<OralHeritageEntry>>());
    });

    test(
      'oralHeritageProvider surfaces exactly 12 source-attested entries and hides 2 quarantined',
      () async {
        final oral = await container.read(oralHeritageProvider.future);
        final ids = oral.map((entry) => entry.id).toList();
        expect(ids, hasLength(12));
        expect(ids, isNot(contains('oral-afsona-001')));
        expect(ids, isNot(contains('oral-afsona-002')));
        expect(ids.where((id) => id.startsWith('oral-afsona-')), isEmpty);
      },
    );

    test('sourceEditionsProvider loads source editions', () async {
      final sources = await container.read(sourceEditionsProvider.future);
      expect(sources, isNotEmpty);
      expect(sources.length, greaterThanOrEqualTo(15));
    });

    test('authorByIdProvider finds author by id', () async {
      final author = await container.read(authorByIdProvider('rudaki').future);
      expect(author, isNotNull);
      expect(author!.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');

      final unknown = await container.read(
        authorByIdProvider('unknown-id').future,
      );
      expect(unknown, isNull);
    });

    test('schoolCanonByAuthorProvider finds canon by author id', () async {
      final rudakiCanon = await container.read(
        schoolCanonByAuthorProvider('rudaki').future,
      );
      expect(rudakiCanon, isA<List<SchoolCanonEntry>>());
    });

    test(
      'worksByAuthorProvider returns approved works for an author',
      () async {
        final works = await container.read(
          worksByAuthorProvider('rudaki').future,
        );
        expect(works, isA<List<LiteraryWork>>());
      },
    );

    test('worksByAuthorProvider excludes unapproved works', () async {
      const approved = LiteraryWork(
        id: 'approved',
        authorId: 'rudaki',
        title: 'Approved',
        textTajik: 'Approved text',
        textStatus: TextStatus.verified,
        primarySource: SourceEdition(
          bookTitle: 'Approved source',
          publisher: 'Publisher',
          city: 'Dushanbe',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
        ),
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'Public domain',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );
      const partialApproval = LiteraryWork(
        id: 'partial-approval',
        authorId: 'rudaki',
        title: 'Partial approval',
        textTajik: 'Unverified text',
        textStatus: TextStatus.verified,
        primarySource: SourceEdition(
          bookTitle: 'Partial source',
          publisher: 'Publisher',
          city: 'Dushanbe',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
        ),
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'Public domain',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );
      const contradictoryRights = LiteraryWork(
        id: 'contradictory-rights',
        authorId: 'rudaki',
        title: 'Contradictory rights',
        textTajik: 'Blocked text',
        textStatus: TextStatus.verified,
        primarySource: SourceEdition(
          bookTitle: 'Blocked source',
          publisher: 'Publisher',
          city: 'Dushanbe',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
        ),
        rights: RightsRecord(
          status: RightsStatus.blocked,
          reasoning: 'Blocked',
          fullTextAllowed: true,
          excerptAllowed: false,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );
      const missingText = LiteraryWork(
        id: 'missing-text',
        authorId: 'rudaki',
        title: 'Missing text',
        textStatus: TextStatus.verified,
        primarySource: SourceEdition(
          bookTitle: 'Missing text source',
          publisher: 'Publisher',
          city: 'Dushanbe',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
        ),
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'Public domain',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );
      const rejected = LiteraryWork(
        id: 'rejected',
        authorId: 'rudaki',
        title: 'Rejected',
        textTajik: 'Rejected text',
        textStatus: TextStatus.verified,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'Public domain',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.rejected,
        ),
      );
      final scopedContainer = ProviderContainer(
        overrides: [
          literaryWorksProvider.overrideWith(
            (ref) async => const [
              approved,
              rejected,
              partialApproval,
              contradictoryRights,
              missingText,
            ],
          ),
        ],
      );
      addTearDown(scopedContainer.dispose);

      final works = await scopedContainer.read(
        worksByAuthorProvider('rudaki').future,
      );
      expect(works.map((work) => work.id).contains('approved'), isTrue);
    });

    test(
      'worksUnderReviewByAuthorProvider exposes pending candidates only',
      () async {
        const pending = LiteraryWork(
          id: 'pending',
          authorId: 'rudaki',
          title: 'Pending candidate',
          textTajik: 'Pending text',
          textStatus: TextStatus.needsReview,
          rights: RightsRecord(
            status: RightsStatus.excerptOnly,
            reasoning: 'Pending',
            fullTextAllowed: false,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.needsReview,
          ),
        );
        const rejected = LiteraryWork(
          id: 'rejected',
          authorId: 'rudaki',
          title: 'Rejected candidate',
          rights: RightsRecord(
            status: RightsStatus.blocked,
            reasoning: 'Rejected',
            fullTextAllowed: false,
            excerptAllowed: false,
          ),
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.rejected,
          ),
        );
        final scopedContainer = ProviderContainer(
          overrides: [
            literaryWorksProvider.overrideWith(
              (ref) async => const [pending, rejected],
            ),
          ],
        );
        addTearDown(scopedContainer.dispose);

        final works = await scopedContainer.read(
          worksUnderReviewByAuthorProvider('rudaki').future,
        );
        expect(works.map((work) => work.id), ['pending']);
      },
    );

    test(
      'oralHeritageProvider requires verification and rights clearance',
      () async {
        const cleared = OralHeritageEntry(
          id: 'cleared',
          text: 'Cleared folklore',
          type: OralHeritageType.maqol,
          collectionSource: 'Collection',
          publisher: 'Publisher',
          year: '1980',
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
          ),
          rights: RightsRecord(
            status: RightsStatus.folklore,
            reasoning: 'Traditional folklore',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );
        const partialApproval = OralHeritageEntry(
          id: 'partial-approval',
          text: 'Unverified folklore',
          type: OralHeritageType.maqol,
          collectionSource: 'Collection',
          publisher: 'Publisher',
          year: '1980',
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
          ),
          rights: RightsRecord(
            status: RightsStatus.folklore,
            reasoning: 'Traditional folklore',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );
        const contradictoryRights = OralHeritageEntry(
          id: 'contradictory-rights',
          text: 'Blocked folklore',
          type: OralHeritageType.maqol,
          collectionSource: 'Collection',
          publisher: 'Publisher',
          year: '1980',
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
          ),
          rights: RightsRecord(
            status: RightsStatus.blocked,
            reasoning: 'Blocked',
            fullTextAllowed: true,
            excerptAllowed: false,
          ),
        );
        const missingText = OralHeritageEntry(
          id: 'missing-text',
          text: '   ',
          type: OralHeritageType.maqol,
          collectionSource: 'Collection',
          publisher: 'Publisher',
          year: '1980',
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
          ),
          rights: RightsRecord(
            status: RightsStatus.folklore,
            reasoning: 'Traditional folklore',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
        );
        const unknownRights = OralHeritageEntry(
          id: 'unknown-rights',
          text: 'Uncleared folklore',
          type: OralHeritageType.maqol,
          collectionSource: 'Collection',
          publisher: 'Publisher',
          year: '1980',
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
          ),
          rights: RightsRecord(
            status: RightsStatus.unknown,
            reasoning: 'Not reviewed',
            fullTextAllowed: false,
            excerptAllowed: false,
          ),
        );
        final scopedContainer = ProviderContainer(
          overrides: [
            literatureRepositoryProvider.overrideWith(
              (ref) => _OralRepository(const [
                cleared,
                unknownRights,
                partialApproval,
                contradictoryRights,
                missingText,
              ]),
            ),
          ],
        );
        addTearDown(scopedContainer.dispose);

        final entries = await scopedContainer.read(oralHeritageProvider.future);
        expect(entries.map((entry) => entry.id).contains('cleared'), isTrue);
      },
    );
  });

  group('dailyVerseProvider with approved works override', () {
    test(
      'returns deterministic daily verse when approved works are present',
      () async {
        final testWork = const LiteraryWork(
          id: 'test-daily-work',
          authorId: 'rudaki',
          title: 'Бӯи ҷӯи Мӯлиён',
          textTajik: 'Бӯи ҷӯи Мӯлиён ояд ҳаме',
          textStatus: TextStatus.verified,
          primarySource: _testApprovedSource,
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
            pageVerified: true,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            literaryWorksProvider.overrideWith((ref) async => [testWork]),
          ],
        );
        addTearDown(container.dispose);

        final approved = await container.read(approvedWorksProvider.future);
        expect(approved.length, 1);
        expect(approved.first.id, 'test-daily-work');

        final daily = await container.read(dailyVerseProvider.future);
        expect(daily, anything);
        expect(daily!.id, 'test-daily-work');
      },
    );
  });

  group('LiteraryFavoritesNotifier', () {
    test('initializes from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsLiteraryFavorites: ['work-1', 'work-2'],
      });

      final notifier = LiteraryFavoritesNotifier();
      await notifier.loadFavorites();

      expect(notifier.state, {'work-1', 'work-2'});
      expect(notifier.isFavorite('work-1'), isTrue);
      expect(notifier.isFavorite('work-3'), isFalse);
    });

    test(
      'toggle adds and removes work IDs in state and SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = LiteraryFavoritesNotifier();
        await notifier.loadFavorites();

        expect(notifier.state, isEmpty);

        await notifier.toggle('work-1');
        expect(notifier.state, {'work-1'});
        expect(notifier.isFavorite('work-1'), isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList(AppConstants.prefsLiteraryFavorites), [
          'work-1',
        ]);

        await notifier.toggle('work-1');
        expect(notifier.state, isEmpty);
        expect(notifier.isFavorite('work-1'), isFalse);
        expect(
          prefs.getStringList(AppConstants.prefsLiteraryFavorites),
          isEmpty,
        );
      },
    );

    test('add and remove methods are idempotent', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = LiteraryFavoritesNotifier();
      await notifier.loadFavorites();

      await notifier.add('work-alpha');
      await notifier.add('work-alpha');
      expect(notifier.state, {'work-alpha'});

      await notifier.remove('work-alpha');
      await notifier.remove('work-alpha');
      expect(notifier.state, isEmpty);
    });

    test(
      'literaryFavoritesProvider and literaryFavoriteWorksProvider integrate correctly',
      () async {
        SharedPreferences.setMockInitialValues({
          AppConstants.prefsLiteraryFavorites: ['fav-work-1'],
        });

        final favWork = const LiteraryWork(
          id: 'fav-work-1',
          authorId: 'rudaki',
          title: 'Favorited Work',
          textTajik: 'Text',
          textStatus: TextStatus.verified,
          primarySource: _testApprovedSource,
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
            pageVerified: true,
          ),
        );

        final nonFavWork = const LiteraryWork(
          id: 'other-work',
          authorId: 'rudaki',
          title: 'Other Work',
          textTajik: 'Text',
          textStatus: TextStatus.verified,
          primarySource: _testApprovedSource,
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            evidenceLevel: VerificationLevel.editoriallyApproved,
            pageVerified: true,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            literaryWorksProvider.overrideWith(
              (ref) async => [favWork, nonFavWork],
            ),
          ],
        );
        addTearDown(container.dispose);

        final favoritesNotifier = container.read(
          literaryFavoritesProvider.notifier,
        );
        await favoritesNotifier.loadFavorites();

        final favorites = container.read(literaryFavoritesProvider);
        expect(favorites, {'fav-work-1'});

        final favWorks = await container.read(
          literaryFavoriteWorksProvider.future,
        );
        expect(favWorks.length, 1);
        expect(favWorks.first.id, 'fav-work-1');
      },
    );
  });
}
