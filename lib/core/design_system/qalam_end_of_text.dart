import 'package:flutter/material.dart';

import 'qalam_folio.dart';
import 'qalam_typography.dart';

/// A neighbouring text in a collection ("← Қаблӣ" / "Баъдӣ →").
@immutable
class QalamNeighbour {
  const QalamNeighbour({
    required this.label,
    required this.title,
    required this.onTap,
    this.titleDirection,
  });

  /// "Қаблӣ" / "Баъдӣ" (the arrow is added by [QalamEndOfText]).
  final String label;
  final String title;
  final VoidCallback onTap;

  /// Set when the title's script differs from the interface direction.
  final TextDirection? titleDirection;
}

/// One group of connections under the text ("Боз аз Рӯдакӣ", "Ҳамон давра").
@immutable
class QalamRelatedGroup {
  const QalamRelatedGroup({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;
}

/// End-of-text navigation: previous/next in the collection, then groups of
/// connections, so a reader can keep reading without going back to a list.
///
/// Renders nothing when there is nowhere to go; empty groups are dropped.
class QalamEndOfText extends StatelessWidget {
  const QalamEndOfText({
    super.key,
    required this.heading,
    this.previous,
    this.next,
    this.groups = const [],
  });

  final String heading;
  final QalamNeighbour? previous;
  final QalamNeighbour? next;
  final List<QalamRelatedGroup> groups;

  /// Below this width the two neighbours stack instead of sitting side by
  /// side, so long titles never squeeze to one word per line.
  static const double _sideBySideMinWidth = 480;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visibleGroups = groups.where((group) => group.rows.isNotEmpty);
    if (previous == null && next == null && visibleGroups.isEmpty) {
      return const SizedBox.shrink();
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.onSurface)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                heading.toUpperCase(),
                style: QalamTypography.eyebrow(color: colors.primary),
              ),
            ),
            if (previous != null || next != null) ...[
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final before = previous == null
                      ? null
                      : _NeighbourLink(neighbour: previous!, isNext: false);
                  final after = next == null
                      ? null
                      : _NeighbourLink(neighbour: next!, isNext: true);
                  if (constraints.maxWidth < _sideBySideMinWidth) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [?before, ?after],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: before ?? const SizedBox.shrink()),
                      const SizedBox(width: 24),
                      Expanded(child: after ?? const SizedBox.shrink()),
                    ],
                  );
                },
              ),
            ],
            for (final group in visibleGroups) ...[
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(
                  group.title,
                  style: QalamTypography.meta(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              ...group.rows,
            ],
          ],
        ),
      ),
    );
  }
}

class _NeighbourLink extends StatelessWidget {
  const _NeighbourLink({required this.neighbour, required this.isNext});

  final QalamNeighbour neighbour;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Arrows follow the interface direction: in Persian "next" points left.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final arrow = (isNext != rtl) ? '→' : '←';
    final label = isNext
        ? '${neighbour.label} $arrow'
        : '$arrow ${neighbour.label}';
    final align = isNext ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Semantics(
      button: true,
      label: '${neighbour.label}: ${neighbour.title}',
      excludeSemantics: true,
      onTap: neighbour.onTap,
      child: QalamSlip(
        onTap: neighbour.onTap,
        showChevron: false,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: align,
            children: [
              Text(label, style: QalamTypography.meta(color: colors.primary)),
              const SizedBox(height: 4),
              Text(
                neighbour.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: neighbour.titleDirection,
                // Absolute alignment: the title may be in another script's
                // direction than the interface.
                textAlign: isNext == rtl ? TextAlign.left : TextAlign.right,
                style: QalamTypography.literaryTitle(
                  color: colors.onSurface,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
