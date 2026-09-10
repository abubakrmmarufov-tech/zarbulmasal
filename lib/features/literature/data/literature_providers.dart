import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

/// Provider for the [LiteratureRepository] instance.
final literatureRepositoryProvider = Provider<LiteratureRepository>((ref) {
  return LiteratureRepository();
});

/// Loads all verified literary authors.
final literaryAuthorsProvider =
    FutureProvider<List<LiteraryAuthor>>((ref) async {
  final repository = ref.watch(literatureRepositoryProvider);
  return repository.loadAuthors();
});

/// Loads all registered literary works.
final literaryWorksProvider =
    FutureProvider<List<LiteraryWork>>((ref) async {
  final repository = ref.watch(literatureRepositoryProvider);
  return repository.loadWorks();
});

/// Filters literary works to only those approved and safe for display.
final approvedWorksProvider =
    FutureProvider<List<LiteraryWork>>((ref) async {
  final repository = ref.watch(literatureRepositoryProvider);
  final works = await ref.watch(literaryWorksProvider.future);
  return repository.getApprovedWorks(works);
});

/// Deterministically selects the daily verse work from approved works.
final dailyVerseProvider = FutureProvider<LiteraryWork?>((ref) async {
  final repository = ref.watch(literatureRepositoryProvider);
  final approved = await ref.watch(approvedWorksProvider.future);
  return repository.getDailyVerse(DateTime.now(), approved);
});

/// Loads the official school curriculum literary canon entries.
final schoolCanonProvider =
    FutureProvider<List<SchoolCanonEntry>>((ref) async {
  final repository = ref.watch(literatureRepositoryProvider);
  return repository.loadSchoolCanon();
});

/// Loads verified oral heritage and folklore entries.
final oralHeritageProvider =
    FutureProvider<List<OralHeritageEntry>>((ref) async {
  final repository = ref.watch(literatureRepositoryProvider);
  return repository.loadOralHeritage();
});

/// Loads bibliographical source editions.
final sourceEditionsProvider =
    FutureProvider<List<SourceEdition>>((ref) async {
  final repository = ref.watch(literatureRepositoryProvider);
  return repository.loadSources();
});

/// StateNotifier managing bookmarked literary work IDs.
class LiteraryFavoritesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences? _prefs;

  LiteraryFavoritesNotifier([this._prefs]) : super(const {}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppConstants.prefsLiteraryFavorites) ?? [];
    if (!mounted) return;
    state = list.toSet();
  }

  /// Explicitly reloads bookmarks from SharedPreferences.
  Future<void> loadFavorites() => _loadFavorites();

  /// Toggles the bookmark status of a work by [workId].
  Future<void> toggle(String workId) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state);
    if (newSet.contains(workId)) {
      newSet.remove(workId);
    } else {
      newSet.add(workId);
    }
    await prefs.setStringList(
      AppConstants.prefsLiteraryFavorites,
      newSet.toList(),
    );
    if (mounted) {
      state = newSet;
    }
  }

  /// Adds a work to bookmarks.
  Future<void> add(String workId) async {
    if (state.contains(workId)) return;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state)..add(workId);
    await prefs.setStringList(
      AppConstants.prefsLiteraryFavorites,
      newSet.toList(),
    );
    if (mounted) {
      state = newSet;
    }
  }

  /// Removes a work from bookmarks.
  Future<void> remove(String workId) async {
    if (!state.contains(workId)) return;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state)..remove(workId);
    await prefs.setStringList(
      AppConstants.prefsLiteraryFavorites,
      newSet.toList(),
    );
    if (mounted) {
      state = newSet;
    }
  }

  /// Checks whether a work is bookmarked.
  bool isFavorite(String workId) => state.contains(workId);
}

/// Provider for managing bookmarked literary work IDs backed by SharedPreferences.
final literaryFavoritesProvider =
    StateNotifierProvider<LiteraryFavoritesNotifier, Set<String>>((ref) {
  return LiteraryFavoritesNotifier();
});

/// Convenience provider returning the list of approved works that are favorited.
final literaryFavoriteWorksProvider =
    FutureProvider<List<LiteraryWork>>((ref) async {
  final approved = await ref.watch(approvedWorksProvider.future);
  final favorites = ref.watch(literaryFavoritesProvider);
  return approved.where((w) => favorites.contains(w.id)).toList();
});

/// Convenience family provider for looking up an author by [id].
final authorByIdProvider =
    FutureProvider.family<LiteraryAuthor?, String>((ref, id) async {
  final authors = await ref.watch(literaryAuthorsProvider.future);
  for (final author in authors) {
    if (author.id == id) return author;
  }
  return null;
});

/// Convenience family provider for finding works by [authorId].
final worksByAuthorProvider =
    FutureProvider.family<List<LiteraryWork>, String>((ref, authorId) async {
  final works = await ref.watch(literaryWorksProvider.future);
  return works.where((w) => w.authorId == authorId).toList();
});

/// Convenience family provider for finding school canon entries by [authorId].
final schoolCanonByAuthorProvider =
    FutureProvider.family<List<SchoolCanonEntry>, String>((ref, authorId) async {
  final canon = await ref.watch(schoolCanonProvider.future);
  return canon.where((entry) => entry.authorId == authorId).toList();
});
