import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/history/data/history_repository.dart';
import 'package:zarbulmasal/features/history/domain/history_book.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';

void main() {
  const entries = [
    HistoryEntry(
      id: 'samanids',
      kind: HistoryEntryKind.empire,
      title: 'Сомониён',
      summary: 'Давлати Сомониён дар китобҳои синфи 7.',
      period: 'асрҳои IX–X',
      grade: '7',
      sourceBookId: 'history-7',
      sourceSection: 'Сомониён',
      keywords: ['давлат', 'Бухоро'],
    ),
    HistoryEntry(
      id: 'rudaki',
      kind: HistoryEntryKind.poem,
      title: 'Калила ва Димна — Рӯдакӣ',
      summary: 'Нақли манбаи адабӣ дар таърихи забон.',
      period: 'асри X',
      grade: '6',
      sourceBookId: 'history-6',
      sourceSection: 'Забони форсии тоҷикӣ',
      keywords: ['шоир', 'Калила'],
    ),
    HistoryEntry(
      id: 'spitamen',
      kind: HistoryEntryKind.person,
      title: 'Спитамен',
      summary: 'Фармондеҳи муқовимат бар зидди Искандар.',
      period: 'асри IV то милод',
      grade: '5',
      sourceBookId: 'history-5',
      sourceSection: 'Юнону Бохтар',
    ),
    HistoryEntry(
      id: 'persian-kalila',
      kind: HistoryEntryKind.poem,
      title: 'کَالیلا',
      summary: 'نمونهٔ فارسی برای سنجش جست‌وجو.',
      period: '—',
      grade: '6',
      sourceBookId: 'history-6',
      sourceSection: 'ادبیات',
    ),
  ];

  test('search is accent- and whitespace-tolerant across indexed fields', () {
    final repository = HistoryRepository();

    expect(repository.search(entries, '  Бухоро '), hasLength(1));
    expect(repository.search(entries, 'калила'), hasLength(1));
    expect(repository.search(entries, 'کالیلا'), hasLength(1));
  });

  test('missing book years remain empty instead of rendering null', () {
    final book = HistoryBook.fromJson({
      'id': 'unknown',
      'grade': 8,
      'title': 'Unknown',
      'author': 'Unknown',
      'description': '',
      'sourceUrl': 'https://maorif.tj/books/unknown',
    });

    expect(book.year, isEmpty);
  });

  test('grade and kind filters combine with text search', () {
    final repository = HistoryRepository();

    expect(
      repository
          .search(entries, '', grade: '7', kind: HistoryEntryKind.empire)
          .single
          .title,
      'Сомониён',
    );
    expect(
      repository
          .search(entries, 'Искандар', kind: HistoryEntryKind.person)
          .single
          .title,
      'Спитамен',
    );
  });
}
