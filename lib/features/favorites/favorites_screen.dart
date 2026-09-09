import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesListProvider);
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: tr('home_edition'),
                title: tr('favorites_title'),
                subtitle: '${favorites.length} ${tr('favorites_count')}',
              ),
            ),
            if (favorites.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.bookmark_outline,
                  title: tr('favorites_empty'),
                  subtitle: tr('favorites_empty_hint'),
                  action: OutlinedButton(
                    onPressed: () => context.go('/proverbs'),
                    child: Text(tr('home_explore')),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) => QalamProverbCard(
                  key: ValueKey(favorites[index].id),
                  proverb: favorites[index],
                  onTap: () => context.push('/proverb/${favorites[index].id}'),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
