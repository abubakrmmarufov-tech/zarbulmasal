import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_system.dart';
import '../l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';

/// A two-sided reading page. Each side scrolls independently for long text.
class QalamFlashCard extends StatefulWidget {
  final Proverb proverb;
  final bool isPersian;
  final bool showMeaning;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onTap;

  const QalamFlashCard({
    super.key,
    required this.proverb,
    required this.isPersian,
    required this.showMeaning,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
  });

  @override
  State<QalamFlashCard> createState() => _QalamFlashCardState();
}

class _QalamFlashCardState extends State<QalamFlashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: widget.showMeaning ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant QalamFlashCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showMeaning != oldWidget.showMeaning) {
      final target = widget.showMeaning ? 1.0 : 0.0;
      if (MediaQuery.disableAnimationsOf(context)) {
        _flip.value = target;
      } else {
        _flip.animateTo(target, curve: Curves.easeInOutCubic);
      }
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  String get _hint => widget.showMeaning
      ? (widget.isPersian
            ? 'برای دیدن ضرب‌المثل لمس کنید'
            : 'Барои дидани мақол ламс кунед')
      : (widget.isPersian
            ? 'برای دیدن معنی لمس کنید'
            : 'Барои дидани маъно ламс кунед');

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _hint,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => _dragDistance = 0,
        onHorizontalDragUpdate: (details) =>
            _dragDistance += details.primaryDelta ?? 0,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (_dragDistance.abs() < 64 && velocity.abs() < 150) return;
          final direction = _dragDistance.abs() >= 64
              ? _dragDistance
              : velocity;
          // Physical swipe left advances; swipe right returns in both scripts.
          if (direction < 0) {
            widget.onSwipeRight?.call();
          } else {
            widget.onSwipeLeft?.call();
          }
        },
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, child) {
            final angle = _flip.value * math.pi;
            final front = _flip.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(front ? 0 : math.pi),
                child: _page(context, front),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _page(BuildContext context, bool front) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lang = widget.isPersian
        ? DisplayLanguage.persian
        : DisplayLanguage.tajik;
    const ink = Color(0xFF202720);
    const paper = Color(0xFFF3F0E7);
    final bg = front ? ink : colors.surface;
    final fg = front ? paper : colors.onSurface;
    final secondary = front ? const Color(0xFFC5C9BE) : colors.onSurfaceVariant;
    final proverb = widget.proverb;
    return Material(
      color: bg,
      shape: Border.all(color: front ? ink : colors.outlineVariant),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey('${proverb.id}-$front'),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      front
                          ? (widget.isPersian ? 'ضرب‌المثل' : 'МАҚОЛ')
                          : AppTranslations.get('flashcards_meaning', lang),
                      style: QalamTypography.eyebrow(color: secondary),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      front
                          ? (widget.isPersian
                                ? proverb.persianText
                                : proverb.tajikCyrillic)
                          : proverb.meaningTj,
                      textDirection: front && widget.isPersian
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: QalamTypography.heroProverb(
                        color: fg,
                        fontSize: front ? 30 : 26,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: secondary.withValues(alpha: 0.4), height: 1),
                    const SizedBox(height: 24),
                    if (!front) ...[
                      Text(
                        AppTranslations.get('flashcards_explanation', lang),
                        style: QalamTypography.eyebrow(color: secondary),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      front
                          ? (widget.isPersian
                                ? proverb.tajikCyrillic
                                : proverb.persianText)
                          : proverb.simpleExplanationTj,
                      textDirection: front && !widget.isPersian
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: QalamTypography.body(
                        color: secondary,
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: secondary.withValues(alpha: 0.25), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _hint,
                      style: QalamTypography.meta(color: secondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.flip_outlined, color: secondary, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
