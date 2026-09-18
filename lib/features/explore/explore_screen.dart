import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('explore_title', lang),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Search Hero
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isPersian
                          ? 'جستجوی شاعر، شعر، تاریخ...'
                          : 'Ҷустуҷӯи шоир, шеър, таърих...',
                      style: QalamTypography.body(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Literature Section
          Text(
            isPersian ? 'ادبیات' : 'Адабиёт',
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildExploreCard(
            context,
            icon: Icons.people_outline,
            title: isPersian ? 'شاعران و نویسندگان' : 'Шоирон ва нависандагон',
            subtitle: isPersian
                ? 'زندگی‌نامه و گلچین آثار'
                : 'Зиндагинома ва осор',
            onTap: () => context.push('/literature/poets'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.auto_stories_outlined,
            title: isPersian ? 'شعرها و کتاب‌ها' : 'Шеърҳо ва китобҳо',
            subtitle: isPersian
                ? 'مجموعه اشعار معتبر'
                : 'Маҷмӯаи шеърҳои тасдиқшуда',
            onTap: () => context.push('/literature/works'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.school_outlined,
            title: isPersian ? 'ادبیات مکتب' : 'Адабиёти мактабӣ',
            subtitle: isPersian
                ? 'برنامه درسی صنف‌های ۵–۱۱'
                : 'Барномаи таълимии синфҳои 5–11',
            onTap: () => context.push('/literature/school'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.record_voice_over_outlined,
            title: isPersian
                ? 'ادبیات شفاهی (عامیانه)'
                : 'Адабиёти шифоҳӣ (халқӣ)',
            subtitle: isPersian
                ? 'افسانه‌ها، چیستان‌ها و ترانه‌ها'
                : 'Афсонаҳо, чистонҳо ва сурудҳо',
            onTap: () => context.push('/literature/oral'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.hub_outlined,
            title: isPersian ? 'مرکز میراث ادبی' : 'Маркази мероси адабӣ',
            subtitle: isPersian
                ? 'مرور کامل میراث ادبی و بیت روز'
                : 'Шарҳи комили мероси адабӣ ва байти рӯз',
            onTap: () => context.push('/literature'),
          ),
          const SizedBox(height: 32),

          // History Section
          Text(
            isPersian ? 'تاریخ' : 'Таърих',
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildExploreCard(
            context,
            icon: Icons.timeline,
            title: isPersian ? 'تاریخ مردم تاجیک' : 'Таърихи халқи тоҷик',
            subtitle: isPersian
                ? 'رویدادها، سلسله‌ها و افراد'
                : 'Рӯйдодҳо, сулолаҳо ва шахсиятҳо',
            onTap: () => context.push('/history'),
          ),
          const SizedBox(height: 32),

          // Proverbs Section
          Text(
            isPersian ? 'ضرب‌المثل‌ها' : 'Зарбулмасалҳо',
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildExploreCard(
            context,
            icon: Icons.format_list_bulleted,
            title: isPersian ? 'موضوعات' : 'Мавзӯъҳо',
            subtitle: isPersian
                ? 'دسته‌بندی موضوعی ضرب‌المثل‌ها'
                : 'Гурӯҳбандии мавзӯии мақолҳо',
            onTap: () => context.push('/categories'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.menu_book_outlined,
            title: isPersian ? 'مرور همه' : 'Мурури ҳама',
            subtitle: isPersian
                ? 'فهرست کامل ضرب‌المثل‌ها'
                : 'Феҳристи комили зарбулмасалҳо',
            onTap: () => context.push('/proverbs'),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: QalamTypography.body(color: colors.onSurface),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
