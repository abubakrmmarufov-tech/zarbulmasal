import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

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
      expect(authors.length, 10);
      expect(authors.first.id, 'rudaki');
    });

    test('literaryWorksProvider loads works', () async {
      final works = await container.read(literaryWorksProvider.future);
      expect(works, isA<List<LiteraryWork>>());
      expect(works, isEmpty);
    });

    test(
      'approvedWorksProvider filters works to only displayable ones',
      () async {
        final approved = await container.read(approvedWorksProvider.future);
        expect(approved, isA<List<LiteraryWork>>());
        expect(approved, isEmpty);
      },
    );

    test(
      'dailyVerseProvider returns null when no approved works exist',
      () async {
        final dailyVerse = await container.read(dailyVerseProvider.future);
        expect(dailyVerse, isNull);
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
      expect(oral, isEmpty);
    });

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
      expect(rudakiCanon, isNotEmpty);
      expect(rudakiCanon.every((c) => c.authorId == 'rudaki'), isTrue);
    });

    test('worksByAuthorProvider filters works by author id', () async {
      final works = await container.read(
        worksByAuthorProvider('rudaki').future,
      );
      expect(works, isEmpty);
    });
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
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            primarySourceChecked: true,
            secondSourceChecked: true,
            titleChecked: true,
            authorshipChecked: true,
            pageChecked: true,
            textLineByLineChecked: true,
            scriptChecked: true,
            copyrightChecked: true,
            finalStatus: VerificationStatus.approved,
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
        expect(daily, isNotNull);
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
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            primarySourceChecked: true,
            secondSourceChecked: true,
            titleChecked: true,
            authorshipChecked: true,
            pageChecked: true,
            textLineByLineChecked: true,
            scriptChecked: true,
            copyrightChecked: true,
            finalStatus: VerificationStatus.approved,
          ),
        );

        final nonFavWork = const LiteraryWork(
          id: 'other-work',
          authorId: 'rudaki',
          title: 'Other Work',
          textTajik: 'Text',
          textStatus: TextStatus.verified,
          rights: RightsRecord(
            status: RightsStatus.publicDomain,
            reasoning: 'PD',
            fullTextAllowed: true,
            excerptAllowed: true,
          ),
          verification: VerificationRecord(
            primarySourceChecked: true,
            secondSourceChecked: true,
            titleChecked: true,
            authorshipChecked: true,
            pageChecked: true,
            textLineByLineChecked: true,
            scriptChecked: true,
            copyrightChecked: true,
            finalStatus: VerificationStatus.approved,
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
