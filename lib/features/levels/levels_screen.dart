import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/cultural_header.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  Color _getLevelColor(int level) {
    if (level <= 2) return const Color(0xFF4D7C0F);
    if (level <= 4) return const Color(0xFF7C3AED);
    if (level <= 6) return const Color(0xFFD97706);
    if (level <= 8) return const Color(0xFFB91C1C);
    return const Color(0xFF7C2D12);
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1: return 'Мақолҳои оддӣ барои оғоз';
      case 2: return 'Мақолҳои осон';
      case 3: return 'Мақолҳои асосӣ';
      case 4: return 'Мақолҳои содда';
      case 5: return 'Мақолҳои миёна';
      case 6: return 'Мақолҳои мураккал';
      case 7: return 'Мақолҳои хуби қавӣ';
      case 8: return 'Мақолҳои бисёр мураккал';
      case 9: return 'Мақолҳои усто';
      case 10: return 'Мақолҳои олимӣ';
      default: return '';
    }
  }

  String _getProgressionLabel(int level) {
    if (level <= 3) return 'Оғоз';
    if (level <= 6) return 'Миёна';
    if (level <= 9) return 'Продвинута';
    return 'Олим';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedLevel = ref.watch(selectedLevelProvider);

    return Scaffold(
      body: Column(
        children: [
          const CulturalHeader(
            title: 'Сатҳҳо',
            subtitle: 'Аз оғоз то олим — 10 сатҳ',
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) {
                final level = index + 1;
                final isSelected = selectedLevel == level;
                final color = _getLevelColor(level);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: isSelected
                          ? BorderSide(color: color, width: 2)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      onTap: () {
                        ref.read(selectedLevelProvider.notifier).state =
                            isSelected ? null : level;
                        context.go('/proverbs');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: isSelected
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    color.withValues(alpha: 0.08),
                                    color.withValues(alpha: 0.0),
                                  ],
                                ),
                              )
                            : null,
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: color, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$level',
                                  style: TextStyle(
                                    fontFamily: 'NotoSerif',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppConstants.getLevelName(level),
                                        style: TextStyle(
                                          fontFamily: 'NotoSerif',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _getProgressionLabel(level),
                                          style: TextStyle(
                                            fontFamily: 'NotoSans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getLevelDescription(level),
                                    style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: color, size: 28)
                            else
                              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
