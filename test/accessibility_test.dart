import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/design_system/qalam_choice.dart';
import 'package:zarbulmasal/core/design_system/qalam_colors.dart';
import 'package:zarbulmasal/core/design_system/qalam_literature_card.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'helpers/test_helper.dart';

double contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return (math.max(first, second) + .05) / (math.min(first, second) + .05);
}

void main() {
  testWidgets('Home and Explore search entries expose named buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      for (final (route, label) in [
        ('/explore', 'Ҷустуҷӯи шоир, шеър, таърих...'),
        ('/', 'Ҷустуҷӯи шоирон, шеърҳо, зарбулмасалҳо, таърих...'),
      ]) {
        final app = await openApp(tester, route: route);

        final searchEntry = find.text(label);
        expect(searchEntry, findsOneWidget);
        final description = tester.getSemantics(searchEntry).toStringDeep();
        expect(description, contains(label));
        expect(label.allMatches(description).length, 1);
        expect(description, contains('isButton'));
        expect(description, contains('tap'));

        await tester.tap(searchEntry);
        await tester.pump();
        expect(app.router.state.uri.path, '/search');
      }
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'quiz feedback announces outcomes without revealing answers early',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        for (final labels in [
          (correct: 'Ҷавоби дуруст', incorrect: 'Ҷавоби нодуруст'),
          (correct: 'پاسخ درست', incorrect: 'پاسخ نادرست'),
        ]) {
          Future<String> announced({
            required bool revealed,
            required bool correct,
            required bool selected,
          }) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.lightTheme,
                home: Scaffold(
                  body: QalamChoice(
                    text: 'Маънои мақол',
                    correctLabel: labels.correct,
                    incorrectLabel: labels.incorrect,
                    revealed: revealed,
                    isCorrect: correct,
                    isSelected: selected,
                    onTap: revealed ? null : () {},
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            return tester.getSemantics(find.byType(QalamChoice)).toStringDeep();
          }

          final unanswered = await announced(
            revealed: false,
            correct: true,
            selected: false,
          );
          expect(unanswered, isNot(contains(labels.correct)));
          expect(unanswered, isNot(contains(labels.incorrect)));

          final correct = await announced(
            revealed: true,
            correct: true,
            selected: false,
          );
          expect(correct, contains(labels.correct));
          expect(correct, isNot(contains(labels.incorrect)));

          final incorrect = await announced(
            revealed: true,
            correct: false,
            selected: true,
          );
          expect(incorrect, contains(labels.incorrect));
          expect(incorrect, isNot(contains(labels.correct)));
        }
      } finally {
        semantics.dispose();
      }
    },
  );

  test(
    'reading, metadata, buttons and answer feedback meet normal-text contrast',
    () {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        final colors = theme.colorScheme;
        final textPairs = [
          (colors.onSurface, colors.surface),
          (colors.onSurfaceVariant, colors.surface),
          (colors.primary, colors.surface),
          (colors.onPrimary, colors.primary),
          (
            colors.error,
            Color.alphaBlend(
              colors.error.withValues(alpha: .07),
              colors.surface,
            ),
          ),
        ];
        for (final (foreground, background) in textPairs) {
          expect(
            contrast(foreground, background),
            greaterThanOrEqualTo(4.5),
            reason: '${theme.brightness} $foreground on $background',
          );
        }
      }
    },
  );

  testWidgets('Literary Heritage card text meets normal-text contrast', (
    tester,
  ) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: QalamLiteratureCard(
              sectionLabel: 'Literature section',
              title: 'Literary Heritage',
              subtitle: 'Verified sources and reading',
              onTap: () {},
            ),
          ),
        ),
      );

      final background = theme.brightness == Brightness.dark
          ? QalamColors.inkCard
          : QalamColors.ink;
      for (final label in [
        'Literature section',
        'Literary Heritage',
        'Verified sources and reading',
      ]) {
        final text = tester.widget<Text>(find.text(label));
        expect(
          contrast(text.style!.color!, background),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.brightness} $label on $background',
        );
      }
    }
  });
}
