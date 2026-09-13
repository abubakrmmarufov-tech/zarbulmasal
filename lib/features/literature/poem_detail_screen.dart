import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../shared/providers/app_providers.dart';

class PoemDetailScreen extends ConsumerWidget {
  final String poemId;
  const PoemDetailScreen({super.key, required this.poemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final poems = ref.watch(poemsProvider);
    final poem = poems.firstWhere(
      (p) => p.id == poemId,
      orElse: () => poems.first,
    );
    final poets = ref.watch(poetsProvider);
    final poet = poets.firstWhere(
      (p) => p.id == poem.poetId,
      orElse: () => poets.first,
    );

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              poem.title,
              style: QalamTypography.sectionTitle(
                color: colors.onSurface,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              poem.text,
              textAlign: TextAlign.center,
              style: QalamTypography.body(
                color: colors.onSurface,
                fontSize: 18,
                height: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
