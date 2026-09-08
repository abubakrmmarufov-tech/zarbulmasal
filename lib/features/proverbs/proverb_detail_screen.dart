import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../shared/providers/app_providers.dart';

class ProverbDetailScreen extends ConsumerWidget {
  final String proverbId;
  const ProverbDetailScreen({super.key, required this.proverbId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(proverbsProvider).where((p) => p.id == proverbId);
    return QalamReadingPage(proverb: matches.isEmpty ? null : matches.first);
  }
}
