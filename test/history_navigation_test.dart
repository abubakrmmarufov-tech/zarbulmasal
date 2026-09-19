import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_book.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';
import 'package:zarbulmasal/features/history/presentation/history_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  testWidgets('history screen stays 100% in-app without external redirects', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({AppConstants.prefsLanguage: 'tj'});

    const testBooks = [
      HistoryBook(
        id: 'history-5',
        grade: '5',
        title: 'Таърихи халқи тоҷик: Замони ориёиҳо',
        author: 'Юсуфшоҳ Яъқубов',
        year: '2015',
        description: 'Китоби дарсии синфи 5 оид ба замони қадим ва ориёиҳо.',
        sourceUrl: 'https://maorif.tj/libraries?category=27',
      ),
    ];

    const testEntries = [
      HistoryEntry(
        id: 'spitamen',
        kind: HistoryEntryKind.person,
        title: 'Спитамен',
        summary:
            'Сарлашкар ва қаҳрамони муборизаи халқҳои Суғду Бохтар бар зидди лашкари Искандари Мақдунӣ.',
        period: 'Солҳои 329–327 пеш аз милод',
        grade: '5',
        sourceBookId: 'history-5',
        sourceSection: 'Муборизаи Спитамен',
        significance: 'Рамзи фидокории миллӣ ва озодихоҳӣ дар таърихи тоҷикон.',
        dates: '329–327 п.м.',
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        displayLanguageProvider.overrideWith(
          (ref) => DisplayLanguageNotifier(),
        ),
        historyBooksProvider.overrideWith((ref) => Future.value(testBooks)),
        historyEntriesProvider.overrideWith((ref) => Future.value(testEntries)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify textbook card tap opens native in-app bottom sheet
    final bookCard = find.text('Таърихи халқи тоҷик: Замони ориёиҳо');
    expect(bookCard, findsOneWidget);
    await tester.tap(bookCard);
    await tester.pumpAndSettle();

    expect(find.text('Китоби дарсии синфи 5'), findsOneWidget);
    expect(find.text('Дидани мавзӯъҳои синфи 5'), findsOneWidget);

    // Tap "Дидани мавзӯъҳои синфи 5" to close sheet and filter in-app
    await tester.tap(find.text('Дидани мавзӯъҳои синфи 5'));
    await tester.pumpAndSettle();

    // 2. Verify history entry card tap opens native entry detail sheet
    final entryCard = find.text('Спитамен');
    expect(entryCard, findsWidgets);
    await tester.tap(entryCard.first);
    await tester.pumpAndSettle();

    expect(find.text('Хулосаи таърихӣ'), findsOneWidget);
    expect(find.text('Аҳамияти таърихӣ'), findsOneWidget);
    expect(
      find.text('Сарчашмаи таълимӣ: Китоби дарсии «Таърихи халқи тоҷик»'),
      findsOneWidget,
    );
  });
}
