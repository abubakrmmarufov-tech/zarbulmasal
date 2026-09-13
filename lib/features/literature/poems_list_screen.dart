import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

class PoemsListScreen extends ConsumerStatefulWidget {
  const PoemsListScreen({super.key});

  @override
  ConsumerState<PoemsListScreen> createState() => _PoemsListScreenState();
}

class _PoemsListScreenState extends ConsumerState<PoemsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);

    final allPoems = ref.watch(poemsProvider);
    final poems = allPoems.where((p) {
      final query = _searchQuery.toLowerCase();
      if (query.isEmpty) return true;
      return p.title.toLowerCase().contains(query) ||
          p.text.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('poems_title'),
          style: QalamTypography.sectionTitle(color: colors.onSurface),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: tr('search'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: poems.isEmpty
          ? Center(child: Text(tr('empty_no_proverbs_found'))) // fallback
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: poems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final poem = poems[index];
                return ListTile(
                  title: Text(
                    poem.title,
                    style: QalamTypography.body(color: colors.onSurface),
                  ),
                  onTap: () => context.push('/poem/${poem.id}'),
                );
              },
            ),
    );
  }
}
