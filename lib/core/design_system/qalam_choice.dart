import 'package:flutter/material.dart';
import 'design_system.dart';

/// An answer line with an explicit, accessible correct/incorrect state.
class QalamChoice extends StatelessWidget {
  final String text;
  final String correctLabel;
  final String incorrectLabel;
  final bool isSelected;
  final bool isCorrect;
  final bool revealed;
  final VoidCallback? onTap;
  final TextDirection? textDirection;
  final int? index;

  const QalamChoice({
    super.key,
    required this.text,
    required this.correctLabel,
    required this.incorrectLabel,
    this.isSelected = false,
    this.isCorrect = false,
    this.revealed = false,
    this.onTap,
    this.textDirection,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final correct = revealed && isCorrect;
    final incorrect = revealed && isSelected && !isCorrect;
    final success = theme.brightness == Brightness.dark
        ? const Color(0xFFB0C9B3)
        : const Color(0xFF35543E);
    final accent = correct
        ? success
        : incorrect
        ? colors.error
        : colors.primary;
    final emphasized = correct || incorrect || isSelected;
    return Semantics(
      selected: isSelected,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: emphasized
              ? accent.withValues(alpha: 0.07)
              : Colors.transparent,
          border: Border.all(
            color: emphasized ? accent : colors.outlineVariant,
            width: emphasized ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  textDirection: textDirection,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: correct || incorrect
                          ? Icon(
                              correct ? Icons.check : Icons.close,
                              semanticLabel: correct
                                  ? correctLabel
                                  : incorrectLabel,
                              size: 22,
                              color: accent,
                            )
                          : Text(
                              index == null
                                  ? '—'
                                  : '${index! + 1}'.padLeft(2, '0'),
                              style: QalamTypography.meta(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        textDirection: textDirection,
                        style: QalamTypography.body(
                          color: emphasized ? accent : colors.onSurface,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
