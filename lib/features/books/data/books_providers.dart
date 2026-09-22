import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import '../domain/book_domain.dart';
import 'books_repository.dart';

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  return BooksRepository();
});

final bookProvidersProvider = FutureProvider<List<BookProvider>>((ref) async {
  return ref.watch(booksRepositoryProvider).loadProviders();
});

final booksProvider = FutureProvider<List<Book>>((ref) async {
  return ref.watch(booksRepositoryProvider).loadBooks();
});

final bookByIdProvider = FutureProvider.family<Book?, String>((ref, id) async {
  final books = await ref.watch(booksProvider.future);
  return books.where((book) => book.id == id).firstOrNull;
});

final booksByCategoryProvider = Provider.family<List<Book>, String>((ref, id) {
  final books = ref.watch(booksProvider).valueOrNull ?? const [];
  return books
      .where((book) => book.categoryIds.contains(id))
      .toList(growable: false);
});

final booksByAuthorProvider = Provider.family<List<Book>, String>((ref, id) {
  final books = ref.watch(booksProvider).valueOrNull ?? const [];
  return books.where((book) => book.authorId == id).toList(growable: false);
});

class BookFavoritesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences? _prefs;
  late final Future<void> _initFuture;

  BookFavoritesNotifier([this._prefs]) : super(const {}) {
    _initFuture = _load();
  }

  Future<void> _load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final ids = prefs.getStringList(AppConstants.prefsBookFavorites) ?? [];
    if (mounted) state = ids.toSet();
  }

  Future<void> toggle(String bookId) async {
    await _initFuture;
    final next = Set<String>.from(state);
    if (!next.add(bookId)) next.remove(bookId);
    await _persist(next);
  }

  Future<void> _persist(Set<String> next) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.prefsBookFavorites, next.toList());
    if (mounted) state = next;
  }
}

final bookFavoritesProvider =
    StateNotifierProvider<BookFavoritesNotifier, Set<String>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return BookFavoritesNotifier(prefs);
    });

final favoriteBooksProvider = FutureProvider<List<Book>>((ref) async {
  final books = await ref.watch(booksProvider.future);
  final favorites = ref.watch(bookFavoritesProvider);
  return books.where((book) => favorites.contains(book.id)).toList();
});

final bookCategoryIdsProvider = Provider<List<String>>((ref) {
  final books = ref.watch(booksProvider).valueOrNull ?? const [];
  return books.expand((book) => book.categoryIds).toSet().toList()..sort();
});
