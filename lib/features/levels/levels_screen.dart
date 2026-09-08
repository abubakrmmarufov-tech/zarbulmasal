import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedLevelProvider);
    final language = ref.watch(displayLanguageProvider);
    final isPersian = language == DisplayLanguage.persian;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
                    icon: const BackButtonIcon(),
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: isPersian ? '۰۳ / فصل‌ها' : '03 / БОБҲО',
                title: AppTranslations.get('levels_title', language),
                subtitle: AppTranslations.get('levels_subtitle', language),
              ),
            ),
            if (selected != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: QalamSpacing.pageH,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () =>
                          ref.read(selectedLevelProvider.notifier).state = null,
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: Text(
                        isPersian ? 'پاک کردن فیلتر سطح' : 'Тоза кардани сатҳ',
                      ),
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                QalamSpacing.pageH,
                0,
                QalamSpacing.pageH,
                48,
              ),
              sliver: SliverList.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  return QalamLevelCard(
                    level: level,
                    isSelected: selected == level,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      ref.read(searchQueryProvider.notifier).state = '';
                      ref.read(selectedLevelProvider.notifier).state =
                          selected == level ? null : level;
                      context.go('/proverbs');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
