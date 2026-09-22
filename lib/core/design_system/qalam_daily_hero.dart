import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system.dart';
import '../l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';

/// The daily folio: a single confident ink field with generous text margins and cultural gravity.
class QalamDailyHero extends ConsumerWidget {
  final Proverb proverb;
  final VoidCallback? onOpen;
  final bool compact;

  const QalamDailyHero({
    super.key,
    required this.proverb,
    this.onOpen,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final persian = lang == DisplayLanguage.persian;
    final now = DateTime.now();

    final bg = isDark ? QalamColors.inkCard : QalamColors.ink;
    final textPrimary = isDark ? QalamColors.paperText : QalamColors.paperHigh;
    final textMuted = isDark ? QalamColors.paperTextSoft : QalamColors.paperLow;
    final accentGold = isDark
        ? QalamColors.antiqueGoldSoft
        : QalamColors.antiqueGoldSoft;
    final ruleColor = isDark
        ? QalamColors.hairlineDark
        : const Color(0x33F3F0E7);

    return Material(
      color: bg,
      child: InkWell(
        onTap: onOpen,
        splashColor: QalamColors.paperHigh.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            QalamSpacing.pageH,
            20,
            QalamSpacing.pageH,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        QalamSpacing.radiusXs,
                      ),
                    ),
                    child: Text(
                      AppTranslations.get('home_daily_proverb', lang),
                      style: QalamTypography.eyebrow(color: accentGold),
                    ),
                  ),
                  const Spacer(),
                  QalamBookmark(proverbId: proverb.id, color: accentGold),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                persian ? proverb.persianText : proverb.tajikCyrillic,
                textDirection: persian ? TextDirection.rtl : TextDirection.ltr,
                style: QalamTypography.heroProverb(
                  color: textPrimary,
                  fontSize: compact ? 22 : 26,
                  height: 1.48,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                persian ? proverb.tajikCyrillic : proverb.persianText,
                textDirection: persian ? TextDirection.ltr : TextDirection.rtl,
                style: QalamTypography.bodySecondary(
                  color: textMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: ruleColor, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${AppTranslations.formatDigits('${now.day}', lang)} ${AppTranslations.getMonthName(now.month, lang)} · ${AppTranslations.formatDigits('${now.year}', lang)}',
                      style: QalamTypography.meta(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onOpen,
                    style: TextButton.styleFrom(
                      foregroundColor: textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minimumSize: const Size(48, 48),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppTranslations.get('home_read', lang),
                          style: QalamTypography.label(
                            color: textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          persian ? Icons.arrow_back : Icons.arrow_forward,
                          size: 16,
                          color: textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
