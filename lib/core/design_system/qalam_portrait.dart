import 'package:flutter/material.dart';

import '../../features/literature/domain/portrait_record.dart';
import 'qalam_monogram_plate.dart';
import 'qalam_spacing.dart';

/// The image a [QalamPortrait] of [height] draws: the bundled asset, decoded
/// at the size shown. Precaching this same provider fills the cache the
/// portrait reads from.
ImageProvider portraitImage(
  PortraitRecord portrait, {
  required double height,
  required double devicePixelRatio,
}) => ResizeImage.resizeIfNeeded(
  null,
  height.isFinite ? (height * devicePixelRatio).round() : null,
  AssetImage(portrait.assetPath),
);

/// Decodes the portraits of the first screenful of a poet list, drawn at
/// [height], so the list shows them at once.
Future<void> precachePortraits(
  BuildContext context,
  Iterable<PortraitRecord> portraits, {
  double height = QalamPortrait.defaultHeight,
}) async {
  final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
  for (final portrait in portraits) {
    if (!context.mounted) return;
    if (!portrait.isDisplayable) continue;
    await precacheImage(
      portraitImage(
        portrait,
        height: height,
        devicePixelRatio: devicePixelRatio,
      ),
      context,
      onError: (_, _) {},
    );
  }
}

/// A consistent, accessible portrait treatment for poet cards and dossiers.
///
/// A portrait image is shown when it comes from one of the two approved
/// sources (a textbook page or maorif.tj). Otherwise the slot shows a
/// [QalamMonogramPlate], which keeps the layout stable without implying that
/// a face has been verified.
class QalamPortrait extends StatefulWidget {
  final PortraitRecord? portrait;
  final String label;
  final double width;
  final double height;
  final String? unavailableLabel;
  final String? citationLabel;

  /// The person's names for the monogram plate (Cyrillic, Persian script).
  /// [monogramName] defaults to [label].
  final String? monogramName;
  final String? persianName;

  const QalamPortrait({
    super.key,
    required this.portrait,
    required this.label,
    this.width = 64,
    this.height = defaultHeight,
    this.unavailableLabel,
    this.citationLabel,
    this.monogramName,
    this.persianName,
  });

  /// The height of a portrait in a poet card.
  static const double defaultHeight = 80;

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
    final sourceBacked = widget.portrait?.isDisplayable == true;
    final child = sourceBacked && !_assetFailed
        ? Image(
            // Decoded at the size shown: the list shows dozens of portraits.
            image: portraitImage(
              widget.portrait!,
              height: widget.height,
              devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
            ),
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              _markAssetFailed();
              return QalamMonogramPlate(
                name: widget.monogramName ?? widget.label,
                persianName: widget.persianName,
                width: widget.width,
                height: widget.height,
              );
            },
          )
        : QalamMonogramPlate(
            name: widget.monogramName ?? widget.label,
            persianName: widget.persianName,
            width: widget.width,
            height: widget.height,
          );

    return Semantics(
      image: true,
      label: sourceBacked && !_assetFailed
          ? '${widget.label}, ${_citationLabel(widget.portrait!)}'
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

  /// Localized citation only: the record's own citation is built from a
  /// repository file name and must never reach a screen reader.
  String _citationLabel(PortraitRecord portrait) =>
      widget.citationLabel?.trim() ?? '';
}
