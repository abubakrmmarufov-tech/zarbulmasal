import 'package:flutter/material.dart';

import 'atlas_cover.dart';
import 'qalam_controls.dart';
import 'qalam_typography.dart';

/// Corner radius shared by folio tiles and slips: small, like cut paper.
const double _folioRadius = 6;

/// The raised paper a tile or slip is cut from: lighter than the page by
/// day, a lifted lapis at night.
Color _folioPaper(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.surfaceContainer
      : theme.colorScheme.surfaceContainerLowest;
}

/// A collection "folio": a paper rectangle with an ink hairline, crowned by
/// a band of the collection's own «Атлас» ikat (seeded from [seed], so every
/// collection is recognisable at a glance). Icon, serif title and one line
/// of real counts sit on the paper, never on the pattern.
class QalamFolioTile extends StatelessWidget {
  const QalamFolioTile({
    super.key,
    required this.title,
    required this.onTap,
    this.seed,
    this.icon,
    this.subtitle,
    this.large = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Collection ID for the ikat band; null draws a plain ink rule instead.
  final String? seed;
  final VoidCallback onTap;

  /// A domain tile (bigger title and band) rather than one of its parts.
  final bool large;

  static const double _bandHeight = 30;
  static const double _largeBandHeight = 44;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final band = large ? _largeBandHeight : _bandHeight;
    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: _folioPaper(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_folioRadius),
          side: BorderSide(color: colors.onSurface.withValues(alpha: 0.22)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (seed != null)
                SizedBox(
                  height: band,
                  child: RepaintBoundary(
                    child: ClipRect(child: AtlasCover(seed: seed!)),
                  ),
                )
              else
                Container(height: 3, color: colors.primary),
              Container(
                height: 1,
                color: colors.onSurface.withValues(alpha: 0.22),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14, large ? 16 : 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: large ? 22 : 19,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: QalamTypography.monographTitle(
                              color: colors.onSurface,
                              fontSize: large ? 24 : 19,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays tiles out in equal-height rows: two columns on a phone, more as the
/// page widens (each column at least [minTileWidth]).
///
/// Rows are measured with [IntrinsicHeight] and built eagerly: meant for a
/// handful of collection tiles, not for long lists (use slips there).
class QalamTileGrid extends StatelessWidget {
  const QalamTileGrid({
    super.key,
    required this.children,
    this.minTileWidth = 160,
    this.maxColumns = 3,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double minTileWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit =
            ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
                .floor();
        final columns = fit.clamp(1, maxColumns);
        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final cells = <Widget>[];
          for (var i = 0; i < columns; i++) {
            if (i > 0) cells.add(SizedBox(width: spacing));
            final index = start + i;
            cells.add(
              Expanded(
                child: index < children.length
                    ? children[index]
                    : const SizedBox.shrink(),
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cells,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

/// A catalogue slip: the boxed row used for every list item (a hairline
/// rectangle on paper, with space between slips). [child] is the content.
class QalamSlip extends StatelessWidget {
  const QalamSlip({
    super.key,
    required this.child,
    required this.onTap,
    this.showChevron = true,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 12, 14),
  });

  final Widget child;
  final VoidCallback onTap;
  final bool showChevron;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _folioPaper(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_folioRadius),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: padding,
              child: Row(
                children: [
                  Expanded(child: child),
                  if (showChevron) ...[
                    const SizedBox(width: 8),
                    const QalamChevron(size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
