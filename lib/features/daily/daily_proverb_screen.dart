import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../shared/providers/app_providers.dart';

class DailyProverbScreen extends ConsumerWidget {
  const DailyProverbScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      QalamReadingPage(proverb: ref.watch(dailyProverbProvider), daily: true);
}
