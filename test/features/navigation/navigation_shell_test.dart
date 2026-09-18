import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/settings/settings_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import '../../helpers/test_helper.dart';

void main() {
  group('Navigation Shell (4-Destination Architecture)', () {
    testWidgets(
      'renders all 4 bottom navigation tabs with visible labels in Tajik',
      (tester) async {
        await openApp(tester, route: '/', language: DisplayLanguage.tajik);

        expect(find.byTooltip('Асосӣ'), findsOneWidget);
        expect(find.byTooltip('Кашф'), findsOneWidget);
        expect(find.byTooltip('Омӯзиш'), findsOneWidget);
        expect(find.byTooltip('Маҳфуз'), findsOneWidget);

        // Verify settings icon is NOT in bottom nav bar
        final bottomBar = find.byType(DecoratedBox).first;
        expect(
          find.descendant(of: bottomBar, matching: find.byIcon(Icons.settings)),
          findsNothing,
        );
      },
    );

    testWidgets(
      'renders all 4 bottom navigation tabs with visible labels in Persian',
      (tester) async {
        await openApp(tester, route: '/', language: DisplayLanguage.persian);

        expect(find.byTooltip('خانه'), findsOneWidget);
        expect(find.byTooltip('کشف'), findsOneWidget);
        expect(find.byTooltip('آموزش'), findsOneWidget);
        expect(find.byTooltip('ذخیره'), findsOneWidget);
      },
    );

    testWidgets('switching tabs switches screens correctly', (tester) async {
      await openApp(tester, route: '/');

      // Tap Explore tab
      await tester.tap(find.byTooltip('Кашф'));
      await tester.pumpAndSettle();
      expect(find.text('Шоирон ва нависандагон'), findsOneWidget);

      // Tap Learn tab
      await tester.tap(find.byTooltip('Омӯзиш'));
      await tester.pumpAndSettle();
      expect(find.text('Роҳҳои омӯзишӣ'), findsOneWidget);

      // Tap Saved tab
      await tester.tap(find.byTooltip('Маҳфуз'));
      await tester.pumpAndSettle();
      expect(find.text('Маҳфузҳо'), findsOneWidget);

      // Tap Home tab
      await tester.tap(find.byTooltip('Асосӣ'));
      await tester.pumpAndSettle();
      expect(find.text('Кашфи фарҳанги тоҷик'), findsOneWidget);
    });

    testWidgets(
      'settings icon in top app bar navigates to settings and can return',
      (tester) async {
        await openApp(tester, route: '/');

        // Tap settings icon in app bar
        final settingsIcon = find.byTooltip('Танзимот');
        expect(settingsIcon, findsOneWidget);
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();

        // Now on settings screen
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.text('Ҳолати торик'), findsOneWidget);

        // Tap back button
        final backButton = find.byTooltip('Бозгашт');
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Back on Home
        expect(find.text('Кашфи фарҳанги тоҷик'), findsOneWidget);
      },
    );
  });
}
