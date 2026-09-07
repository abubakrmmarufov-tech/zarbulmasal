import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system.dart';
import '../l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';

/// The daily folio: a single confident ink field with generous text margins.
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
    final persian = lang == DisplayLanguage.persian;
    final now = DateTime.now();
    return Material(
      color: QalamColors.ink,
      child: InkWell(
        onTap: onOpen,
        splashColor: QalamColors.paper.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.get('home_daily_proverb', lang),
                      style: QalamTypography.eyebrow(
                        color: QalamColors.paperTextSoft,
                      ),
                    ),
                  ),
                  QalamBookmark(
                    proverbId: proverb.id,
                    color: QalamColors.paper,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                persian ? proverb.persianText : proverb.tajikCyrillic,
                textDirection: persian ? TextDirection.rtl : TextDirection.ltr,
                style: QalamTypography.heroProverb(
                  color: QalamColors.paper,
                  fontSize: compact ? 27 : 31,
                  height: 1.42,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                persian ? proverb.tajikCyrillic : proverb.persianText,
                textDirection: persian ? TextDirection.ltr : TextDirection.rtl,
                style: QalamTypography.bodySecondary(
                  color: QalamColors.paperTextSoft,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              const Divider(color: Color(0x4DF3F0E7)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${now.day} ${AppTranslations.getMonthName(now.month, lang)} / ${now.year}',
                      style: QalamTypography.meta(
                        color: QalamColors.paperTextSoft,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onOpen,
                    style: TextButton.styleFrom(
                      foregroundColor: QalamColors.paper,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppTranslations.get('home_read', lang)),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, size: 20),
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
