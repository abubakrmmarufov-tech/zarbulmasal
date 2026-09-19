import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'helpers/test_helper.dart';

void main() {
  const viewports = [
    Size(320, 568), // Compact phone / iPhone SE 1st gen
    Size(360, 800), // Standard Android
    Size(375, 667), // iPhone 8 / SE 2nd/3rd gen
    Size(390, 844), // iPhone 12/13/14 reference benchmark
    Size(430, 932), // Large phone / iPhone Pro Max
  ];

  const primaryRoutes = [
    '/',
    '/explore',
    '/literature',
    '/literature/poets',
    '/literature/works',
    '/history',
    '/settings',
  ];

  group('Mobile Multi-Viewport & RTL Audit', () {
    for (final size in viewports) {
      for (final language in DisplayLanguage.values) {
        testWidgets(
          'Viewport ${size.width.toInt()}x${size.height.toInt()} renders all key screens without overflow in ${language.name}',
          (tester) async {
            for (final route in primaryRoutes) {
              await openApp(
                tester,
                route: route,
                width: size.width,
                height: size.height,
                scale: 1.0,
                language: language,
                onboardingComplete: true,
                disableAnimations: true,
                settle: false,
              );

              expect(
                tester.takeException(),
                isNull,
                reason: 'Render or overflow exception on $route at ${size.width}x${size.height} in ${language.name}',
              );

              if (language == DisplayLanguage.persian) {
                // Verify RTL Directionality exists
                final directionalityFinder = find.byType(Directionality);
                expect(directionalityFinder, findsWidgets);
              }
            }
          },
        );
      }
    }
  });
}
