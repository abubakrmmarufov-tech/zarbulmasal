import 'package:flutter/material.dart';

import '../../features/literature/domain/portrait_record.dart';
import 'qalam_colors.dart';
import 'qalam_spacing.dart';

/// A consistent, accessible portrait treatment for poet cards and dossiers.
///
/// Missing portraits intentionally render a neutral placeholder. This keeps
/// the layout stable without implying that a face has been verified.
class QalamPortrait extends StatefulWidget {
  final PortraitRecord? portrait;
  final String label;
  final double width;
  final double height;
  final String? unavailableLabel;

  const QalamPortrait({
    super.key,
    required this.portrait,
    required this.label,
    this.width = 64,
    this.height = 80,
    this.unavailableLabel,
  });

  @override
  State<QalamPortrait> createState() => _QalamPortraitState();
}

class _QalamPortraitState extends State<QalamPortrait> {
  bool _assetFailed = false;

  @override
  void didUpdateWidget(covariant QalamPortrait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.portrait?.assetPath != widget.portrait?.assetPath) {
      _assetFailed = false;
    }
  }

  void _markAssetFailed() {
    if (_assetFailed || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_assetFailed) {
        setState(() => _assetFailed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sourceBacked = widget.portrait?.isSourceBacked == true;
    final child = sourceBacked && !_assetFailed
        ? Image.asset(
            widget.portrait!.assetPath,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              _markAssetFailed();
              return _Placeholder(
                width: widget.width,
                height: widget.height,
                color: colors,
              );
            },
          )
        : _Placeholder(
            width: widget.width,
            height: widget.height,
            color: colors,
          );

    return Semantics(
      image: true,
      label: sourceBacked && !_assetFailed
          ? '${widget.label}, ${widget.portrait!.citation}'
          : '${widget.label}, ${widget.unavailableLabel ?? 'portrait unavailable'}',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant, width: 0.5),
              borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme color;

  const _Placeholder({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark
          ? QalamColors.ink.withValues(alpha: 0.75)
          : color.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline,
        size: height * 0.34,
        color: color.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    );
  }
}
