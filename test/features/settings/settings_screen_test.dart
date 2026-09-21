import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/data/reader_preferences_provider.dart';
import 'package:zarbulmasal/features/settings/settings_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import '../../helpers/test_helper.dart';

void main() {
  group('SettingsScreen Comprehensive Tests', () {
    testWidgets('renders all settings sections in Tajik', (tester) async {
      await openApp(
        tester,
        route: '/settings',
        height: 1600,
        language: DisplayLanguage.tajik,
      );

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Танзимот'), findsWidgets);
      expect(find.text('НАМОИШ'), findsOneWidget);
      expect(find.text('Ҳолати зоҳирӣ'), findsOneWidget);
      expect(find.text('ХОНДАН'), findsOneWidget);
      expect(find.text('Андозаи матн'), findsOneWidget);
      expect(find.text('Фосилаи сатрҳо'), findsOneWidget);
      expect(find.text('Ҳолати хониш'), findsOneWidget);
      expect(find.text('ЗАБОН'), findsOneWidget);
      expect(find.text('МАЪЛУМОТ ВА ТАЪРИХ'), findsOneWidget);
      expect(find.text('Пок кардани таърихи фаъолият'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Иҷозатномаҳои кушодаасос'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('МАЪЛУМОТ'), findsOneWidget);
      expect(find.text('Сиёсати махфият'), findsOneWidget);
      expect(find.text('Иҷозатномаҳои кушодаасос'), findsOneWidget);
    });

    testWidgets('renders all settings sections in Persian', (tester) async {
      await openApp(
        tester,
        route: '/settings',
        height: 1600,
        language: DisplayLanguage.persian,
      );

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('تنظیمات'), findsWidgets);
      expect(find.text('نمایش'), findsOneWidget);
      expect(find.text('حالت ظاهری'), findsOneWidget);
      expect(find.text('خوانش'), findsOneWidget);
      expect(find.text('اندازهٔ قلم'), findsOneWidget);
      expect(find.text('فاصلهٔ سطرها'), findsOneWidget);
      expect(find.text('حالت خواندن'), findsOneWidget);
      expect(find.text('زبان'), findsOneWidget);
      expect(find.text('داده‌ها و تاریخچه'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('مجوزهای منبع‌باز'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('سیاست حفظ حریم خصوصی'), findsOneWidget);
      expect(find.text('مجوزهای منبع‌باز'), findsOneWidget);
    });

    testWidgets('theme mode switching updates provider state', (tester) async {
      final app = await openApp(
        tester,
        route: '/settings',
        height: 1600,
        language: DisplayLanguage.tajik,
      );

      // Select Dark mode
      await tester.tap(find.text('Торик'));
      await tester.pumpAndSettle();
      expect(app.container.read(themeModeProvider), ThemeMode.dark);

      // Select Light mode
      await tester.tap(find.text('Рӯшан'));
      await tester.pumpAndSettle();
      expect(app.container.read(themeModeProvider), ThemeMode.light);

      // Select System mode
      await tester.tap(find.text('Мутобиқи система'));
      await tester.pumpAndSettle();
      expect(app.container.read(themeModeProvider), ThemeMode.system);
    });

    testWidgets(
      'reading font size, line spacing, and reader mode controls work',
      (tester) async {
        final app = await openApp(
          tester,
          route: '/settings',
          height: 1600,
          language: DisplayLanguage.tajik,
        );

        // Increase font size
        final addBtn = find.byTooltip('Калон кардан');
        expect(addBtn, findsOneWidget);
        await tester.tap(addBtn);
        await tester.pumpAndSettle();
        expect(
          app.container.read(readerPreferencesProvider).fontSizeDelta,
          2.0,
        );

        // Reset font size
        final resetBtn = find.byTooltip('Андозаи аввала');
        expect(resetBtn, findsOneWidget);
        await tester.tap(resetBtn);
        await tester.pumpAndSettle();
        expect(
          app.container.read(readerPreferencesProvider).fontSizeDelta,
          0.0,
        );

        // Select Compact line spacing
        await tester.tap(find.text('Зич'));
        await tester.pumpAndSettle();
        expect(
          app.container.read(readerPreferencesProvider).lineHeightMultiplier,
          1.4,
        );

        // Select Relaxed line spacing
        await tester.tap(find.text('Васеъ'));
        await tester.pumpAndSettle();
        expect(
          app.container.read(readerPreferencesProvider).lineHeightMultiplier,
          1.8,
        );

        // Select Parallel reader mode
        await tester.tap(find.text('Мувозӣ (духатта)'));
        await tester.pumpAndSettle();
        expect(
          app.container.read(readerPreferencesProvider).defaultReaderMode,
          'parallel',
        );
      },
    );

    testWidgets('privacy policy dialog opens and can be dismissed', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/settings',
        height: 1600,
        language: DisplayLanguage.tajik,
      );

      await tester.tap(find.text('Сиёсати махфият'));
      await tester.pumpAndSettle();

      expect(find.text('Махфият ва амнияти додаҳо'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Пӯшидан'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'clear recent activity shows confirmation and can cancel or confirm',
      (tester) async {
        await openApp(
          tester,
          route: '/settings',
          height: 1600,
          language: DisplayLanguage.tajik,
        );

        await tester.tap(find.text('Пок кардани таърихи фаъолият'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.text('Оё мехоҳед таърихи фаъолиятро пок кунед?'),
          findsOneWidget,
        );

        // Tap Cancel
        await tester.tap(find.text('Бекор кардан'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);

        // Tap again and confirm
        await tester.tap(find.text('Пок кардани таърихи фаъолият'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ҳа'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Таърихи фаъолият пок шуд'), findsOneWidget);
      },
    );
  });
}
