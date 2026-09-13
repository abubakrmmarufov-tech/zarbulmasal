import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

class PoetDetailScreen extends ConsumerWidget {
  final String poetId;
  const PoetDetailScreen({super.key, required this.poetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);

    final poets = ref.watch(poetsProvider);
    final poet = poets.firstWhere(
      (p) => p.id == poetId,
      orElse: () => poets.first,
    );
    final poems = ref
        .watch(poemsProvider)
        .where((p) => p.poetId == poetId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          poet.nameTj,
          style: QalamTypography.sectionTitle(color: colors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr('poet_birth_death')}: ${poet.birthYear} - ${poet.deathYear}',
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
            const SizedBox(height: 16),
            if (poet.biography != null && poet.biography!.isNotEmpty) ...[
              Text(
                poet.biography!,
                style: QalamTypography.body(color: colors.onSurface),
              ),
              const SizedBox(height: 24),
            ],
            if (poems.isNotEmpty) ...[
              Text(
                tr('poet_works'),
                style: QalamTypography.sectionTitle(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              ...poems.map(
                (poem) => ListTile(
                  title: Text(
                    poem.title,
                    style: QalamTypography.body(color: colors.onSurface),
                  ),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    context.push('/poem/${poem.id}');
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
