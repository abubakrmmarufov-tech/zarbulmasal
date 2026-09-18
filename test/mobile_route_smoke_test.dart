import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'helpers/test_helper.dart';

void main() {
  const routes = [
    '/',
    '/explore',
    '/learn',
    '/saved',
    '/search',
    '/proverbs',
    '/categories',
    '/favorites',
    '/settings',
    '/levels',
    '/quiz',
    '/flashcards',
    '/daily',
    '/literature',
    '/literature/poets',
    '/literature/works',
    '/literature/school',
    '/literature/oral',
    '/literature/search',
    '/history',
  ];
  const textScales = [1.3, 2.0];

  for (final route in routes) {
    testWidgets('route $route renders on a small phone with readable text', (
      tester,
    ) async {
      for (final language in DisplayLanguage.values) {
        for (final textScale in textScales) {
          await openApp(
            tester,
            route: route,
            width: 320,
            height: 568,
            scale: textScale,
            language: language,
            onboardingComplete: true,
            disableAnimations: true,
            settle: false,
          );

          expect(
            tester.takeException(),
            isNull,
            reason: '$route failed in ${language.name} at $textScale',
          );
        }
      }
    });
  }
}
