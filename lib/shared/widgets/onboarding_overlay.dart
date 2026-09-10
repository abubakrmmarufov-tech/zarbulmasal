import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// A lightweight coach-mark overlay that spotlights UI elements on first launch.
///
/// The overlay dims the full screen, cuts a transparent spotlight over the
/// target area, and positions a tooltip with a short description plus
/// Next / Skip / Got-it controls.
class OnboardingOverlay extends StatefulWidget {
  final List<OnboardingStep> steps;
  final Future<void> Function() onComplete;
  const OnboardingOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentStep = 0;
  bool _finishing = false;
  bool _hasStarted = false;
  Rect? _targetRect;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scheduleTargetMeasurement();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scheduleTargetMeasurement();
  }

  void _scheduleTargetMeasurement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureTarget();
    });
  }

  void _measureTarget() {
    if (_currentStep >= widget.steps.length) return;
    final step = widget.steps[_currentStep];
    final renderObject = step.targetKey?.currentContext?.findRenderObject();
    if (renderObject is RenderBox &&
        renderObject.hasSize &&
        renderObject.attached) {
      final pos = renderObject.localToGlobal(Offset.zero);
      final rect = pos & renderObject.size;
      if (_targetRect != rect) {
        setState(() {
          _targetRect = rect;
        });
      }
    } else {
      // Re-try on next frame if layout has not yet completed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ro = step.targetKey?.currentContext?.findRenderObject();
        if (ro is RenderBox && ro.hasSize && ro.attached) {
          final pos = ro.localToGlobal(Offset.zero);
          setState(() {
            _targetRect = pos & ro.size;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    _anim
      ..duration = duration
      ..reverseDuration = duration;
    if (!_hasStarted) {
      _hasStarted = true;
      _anim.forward();
    }
    _scheduleTargetMeasurement();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _anim.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
        _targetRect = null;
      });
      _scheduleTargetMeasurement();
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    try {
      await _anim.reverse();
      await widget.onComplete();
    } on TickerCanceled {
      // The parent route was disposed while the overlay was closing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isLast = _currentStep == widget.steps.length - 1;
    final safePadding = MediaQuery.of(context).padding;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // Derive target rectangle from measured bounds or current RenderBox
    Rect target;
    final renderObject = step.targetKey?.currentContext?.findRenderObject();
    if (renderObject is RenderBox &&
        renderObject.hasSize &&
        renderObject.attached) {
      final pos = renderObject.localToGlobal(Offset.zero);
      target = pos & renderObject.size;
    } else if (_targetRect != null) {
      target = _targetRect!;
    } else {
      _scheduleTargetMeasurement();
      target = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 120,
        height: 48,
      );
    }

    // Tooltip positioning: below or above the spotlight
    final spotlightPadding = 14.0;
    final spotlightRect = Rect.fromLTRB(
      math.max(8, target.left - spotlightPadding),
      math.max(safePadding.top + 4, target.top - spotlightPadding),
      math.min(size.width - 8, target.right + spotlightPadding),
      math.min(
        size.height - safePadding.bottom - 4,
        target.bottom + spotlightPadding,
      ),
    );

    final spaceBelow =
        size.height - safePadding.bottom - spotlightRect.bottom - 16;
    final spaceAbove = spotlightRect.top - safePadding.top - 16;
    final tooltipBelow = spaceBelow >= 220 || spaceBelow > spaceAbove;
    final tooltipTop = tooltipBelow ? spotlightRect.bottom + 12 : null;
    final tooltipBottom = tooltipBelow
        ? null
        : size.height - spotlightRect.top + 12;
    final tooltipMaxHeight = math.max(
      120.0,
      tooltipBelow ? spaceBelow : spaceAbove,
    );

    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          label: '${step.title}. ${step.description}',
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      target: spotlightRect,
                      dimColor: Colors.black.withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ),
              const ModalBarrier(dismissible: false, color: Colors.transparent),

              Positioned(
                left: 16,
                right: 16,
                top: tooltipTop,
                bottom: tooltipBottom,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: tooltipMaxHeight),
                  child: DecoratedBox(
                    key: const ValueKey('onboarding-tooltip'),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                      child: AnimatedSwitcher(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        child: Column(
                          key: ValueKey(_currentStep),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${_currentStep + 1} / ${widget.steps.length}',
                                style: QalamTypography.meta(
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step.title,
                              style: QalamTypography.sectionTitle(
                                color: colors.onSurface,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step.description,
                              style: QalamTypography.body(
                                color: colors.onSurfaceVariant,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (!isLast)
                                  TextButton(
                                    onPressed: _finishing ? null : _finish,
                                    child: Text(step.skipLabel),
                                  ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: _finishing ? null : _next,
                                  child: Text(
                                    isLast ? step.finishLabel : step.nextLabel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One step in the onboarding tour.
class OnboardingStep {
  final GlobalKey? targetKey;
  final String title;
  final String description;
  final String nextLabel;
  final String skipLabel;
  final String finishLabel;

  const OnboardingStep({
    this.targetKey,
    required this.title,
    required this.description,
    this.nextLabel = 'Баъдӣ',
    this.skipLabel = 'Гузаштан',
    this.finishLabel = 'Оғоз!',
  });
}

/// Custom painter that dims the entire screen except for a rounded spotlight.
class _SpotlightPainter extends CustomPainter {
  final Rect target;
  final Color dimColor;

  _SpotlightPainter({required this.target, required this.dimColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dimColor;
    final fullRect = Offset.zero & size;

    // Create path with cutout
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(target, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.target != target;
}
