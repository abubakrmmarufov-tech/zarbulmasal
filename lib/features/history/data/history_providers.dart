import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/history_domain.dart';
import 'history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final historyBooksProvider = FutureProvider<List<HistoryBook>>((ref) async {
  return ref.watch(historyRepositoryProvider).loadBooks();
});

final historyEntriesProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  return ref.watch(historyRepositoryProvider).loadEntries();
});

final historyEntryByIdProvider = FutureProvider.family<HistoryEntry?, String>((
  ref,
  id,
) async {
  final entries = await ref.watch(historyEntriesProvider.future);
  return entries.where((e) => e.id == id).firstOrNull;
});
