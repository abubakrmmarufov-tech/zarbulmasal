import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/app.dart';
import 'package:zarbulmasal/router/app_router.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

void main() {
  testWidgets(
    'real app starts, dismisses splash, and supplies both script localizations',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      appRouter.go('/');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ZarbulmasalApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final screenContext = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(screenContext), TextDirection.ltr);
      expect(Localizations.localeOf(screenContext).languageCode, 'tg');
      expect(
        Localizations.of<MaterialLocalizations>(
          screenContext,
          MaterialLocalizations,
        ),
        isNotNull,
      );
      expect(
        Localizations.of<CupertinoLocalizations>(
          screenContext,
          CupertinoLocalizations,
        ),
        isNotNull,
      );
      await container
          .read(displayLanguageProvider.notifier)
          .setLanguage(DisplayLanguage.persian);
      await tester.pumpAndSettle();
      final persianContext = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(persianContext), TextDirection.rtl);
      expect(Localizations.localeOf(persianContext).languageCode, 'fa');
      expect(
        MaterialLocalizations.of(persianContext).searchFieldLabel,
        isNotEmpty,
      );
      expect(
        CupertinoLocalizations.of(persianContext).copyButtonLabel,
        isNotEmpty,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
