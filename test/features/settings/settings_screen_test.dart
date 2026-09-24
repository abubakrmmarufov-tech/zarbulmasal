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
      expect(find.text('Андозаи матни барнома'), findsOneWidget);
      // The scale hints describe the real scope: the app scale covers all
      // text; the poem scale only the poem-reading page.
      expect(
        find.text('Ба ҳамаи матнҳои барнома таъсир мерасонад.'),
        findsOneWidget,
      );
      expect(find.text('Андозаи шеър'), findsOneWidget);
      expect(
        find.text(
          'Танҳо ба андозаи матни шеър дар саҳифаи хониши шеър таъсир мерасонад.',
        ),
        findsOneWidget,
      );
      expect(find.text('Фосилаи сатрҳо'), findsOneWidget);
      expect(find.text('Ҳолати хониш'), findsOneWidget);
      expect(find.text('ЗАБОНИ БАРНОМА'), findsOneWidget);
      expect(find.text('Хатти матнҳо'), findsOneWidget);
      expect(find.text('МАЪЛУМОТ ВА ТАЪРИХ'), findsOneWidget);
      expect(find.text('Пок кардани таърихи фаъолият'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('МАЪЛУМОТ'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('МАЪЛУМОТ'), findsOneWidget);
      // Feedback is near the bottom of the scrollable list, so scroll until
      // the label is actually visible before asserting.
      await tester.scrollUntilVisible(
        find.text('Пешниҳодҳо'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Пешниҳодҳо'), findsOneWidget);
      // Privacy and Licenses rows are intentionally absent from Settings.
      expect(find.text('Сиёсати махфият'), findsNothing);
      expect(find.text('Иҷозатномаҳои кушодаасос'), findsNothing);
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
      expect(find.text('اندازهٔ قلم برنامه'), findsOneWidget);
      // The scale hints describe the real scope: the app scale covers all
      // text; the poem scale only the poem-reading page.
      expect(find.text('بر تمام متن‌های برنامه اثر می‌گذارد.'), findsOneWidget);
      expect(find.text('اندازهٔ شعر'), findsOneWidget);
      expect(
        find.text('فقط بر اندازهٔ متن شعر در صفحهٔ خوانش شعر اثر می‌گذارد.'),
        findsOneWidget,
      );
      expect(find.text('فاصلهٔ سطرها'), findsOneWidget);
      expect(find.text('حالت خواندن'), findsOneWidget);
      expect(find.text('زبان برنامه'), findsOneWidget);
      expect(find.text('خط متن‌ها'), findsOneWidget);
      expect(find.text('داده‌ها و تاریخچه'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('اطلاعات'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('اطلاعات'), findsOneWidget);
      // Feedback is near the bottom of the scrollable list, so scroll until
      // the label is actually visible before asserting.
      await tester.scrollUntilVisible(
        find.text('پیشنهادها'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('پیشنهادها'), findsOneWidget);
      // Privacy and Licenses rows are intentionally absent from Settings.
      expect(find.text('سیاست حفظ حریم خصوصی'), findsNothing);
      expect(find.text('مجوزهای منبع‌باز'), findsNothing);
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
      'app and poem font size, line spacing, and reader mode controls work',
      (tester) async {
        final app = await openApp(
          tester,
          route: '/settings',
          height: 1600,
          language: DisplayLanguage.tajik,
        );

        await tester.tap(find.text('Хеле калон'));
        await tester.pumpAndSettle();
        expect(
          app.container.read(appTextScaleProvider),
          AppTextScaleNotifier.maximum,
        );

        // Increase poem font size
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

    testWidgets('contact row shows the new @zarbulmasalcom handle', (
      tester,
    ) async {
      await openApp(
        tester,
        route: '/settings',
        height: 1600,
        language: DisplayLanguage.tajik,
      );

      // The contact handle is reachable only after scrolling the Information
      // section into view.
      await tester.scrollUntilVisible(
        find.text('Пешниҳодҳо'),
        200,
        scrollable: find.byType(Scrollable),
      );

      // Row subtitle advertises the new handle, never the old one.
      expect(find.text('Telegram · @zarbulmasalcom'), findsOneWidget);
      expect(find.textContaining('@imarufov'), findsNothing);

      // Tapping opens the contact dialog, which still exposes a selectable
      // (copyable) handle.
      await tester.tap(find.text('Пешниҳодҳо'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Telegram: @zarbulmasalcom'), findsOneWidget);
      expect(find.textContaining('@imarufov'), findsNothing);
      expect(find.byType(SelectableText), findsOneWidget);
    });
  });
}
