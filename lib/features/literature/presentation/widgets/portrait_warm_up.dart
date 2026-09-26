import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/literature_providers.dart';
import '../../domain/domain.dart';

/// Portraits of the poets the poet list shows before any scrolling: about
/// eight cards fit a phone screen.
const firstScreenfulPortraits = 8;

/// The portraits of the first screenful of the poet list, in list order.
Iterable<PortraitRecord> firstScreenfulOf(List<LiteraryAuthor> authors) =>
    authors
        .where((author) => author.hasCanonicalName)
        .take(firstScreenfulPortraits)
        .map((author) => author.portrait)
        .whereType<PortraitRecord>()
        .where((portrait) => portrait.isDisplayable);

/// Draws nothing. Once the poets are loaded, decodes the portraits of the
/// poet list's first screenful at the size the list shows them, so opening
/// the list shows them at once. Runs once per app start.
class PortraitWarmUp extends ConsumerStatefulWidget {
  const PortraitWarmUp({super.key});

  @override
  ConsumerState<PortraitWarmUp> createState() => _PortraitWarmUpState();
}

bool _done = false;

/// Lets a test run the warm-up again.
@visibleForTesting
void resetPortraitWarmUp() => _done = false;

class _PortraitWarmUpState extends ConsumerState<PortraitWarmUp> {
  @override
  void initState() {
    super.initState();
    if (_done) return;
    ref.listenManual(literaryAuthorsProvider, (_, next) {
      final authors = next.valueOrNull;
      if (_done || authors == null) return;
      _done = true;
      // After the frame, so Home draws first.
      WidgetsBinding.instance
        ..addPostFrameCallback((_) {
          if (mounted) precachePortraits(context, firstScreenfulOf(authors));
        })
        ..ensureVisualUpdate();
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
