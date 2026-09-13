import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

class PoetsListScreen extends ConsumerStatefulWidget {
  const PoetsListScreen({super.key});

  @override
  ConsumerState<PoetsListScreen> createState() => _PoetsListScreenState();
}

class _PoetsListScreenState extends ConsumerState<PoetsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);

    final allPoets = ref.watch(poetsProvider);
    final poets = allPoets.where((p) {
      final query = _searchQuery.toLowerCase();
      if (query.isEmpty) return true;
      return p.nameTj.toLowerCase().contains(query) ||
          (p.namePersian?.toLowerCase().contains(query) ?? false) ||
          (p.penName?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('poets_title'),
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
      body: poets.isEmpty
          ? Center(child: Text(tr('empty_no_proverbs_found'))) // fallback
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: poets.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final poet = poets[index];
                return ListTile(
                  title: Text(
                    poet.nameTj,
                    style: QalamTypography.body(color: colors.onSurface),
                  ),
                  subtitle: Text('${poet.birthYear} - ${poet.deathYear}'),
                  onTap: () => context.push('/poet/${poet.id}'),
                );
              },
            ),
    );
  }
}
