import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/proverb_card.dart';
import '../../shared/widgets/cultural_header.dart';
import '../../shared/widgets/pamir_silhouette.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favorites = ref.watch(favoritesListProvider);
    final displayLang = ref.watch(displayLanguageProvider);

    return Scaffold(
      body: Column(
        children: [
          CulturalHeader(
            title: AppTranslations.get('nav_favorites', displayLang),
            subtitle: AppTranslations.get('home_proverbs', displayLang),
          ),
          PamirSilhouette(
            height: 28,
            darkMode: Theme.of(context).brightness == Brightness.dark,
          ),
          Expanded(
            child: favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PamirSilhouette(
                          height: 48,
                          darkMode: Theme.of(context).brightness == Brightness.dark,
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppTranslations.get('empty_no_favorites', displayLang),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTranslations.get('empty_no_favorites_hint', displayLang),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/proverbs'),
                          child: Text(AppTranslations.get('home_proverbs', displayLang)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final proverb = favorites[index];
                      return ProverbCard(
                        proverb: proverb,
                        onTap: () => context.push('/proverb/${proverb.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
