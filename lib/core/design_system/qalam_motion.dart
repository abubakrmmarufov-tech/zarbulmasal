import 'package:flutter/material.dart';

/// Qalam motion / animation tokens.
///
/// Provides consistent dur/curve pairs for the whole app.
class QalamMotion {
  QalamMotion._();

  // ??? Durations ?????????????????????????????????????????????????????????
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration med = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration reveal = Duration(milliseconds: 800);

  // ??? Curves ????????????????????????????????????????????????????????????
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve springIn = Curves.easeOutBack;
  static const Curve expressive = Curves.easeOutCubic;

  // ??? Pre-built animations ??????????????????????????????????????????????
  static Animation<double> fadeIn(AnimationController c) => Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(parent: c, curve: decelerate));

  static Animation<double> slideUp(AnimationController c) => Tween<double>(
    begin: 20,
    end: 0,
  ).animate(CurvedAnimation(parent: c, curve: expressive));

  static Animation<double> scaleIn(AnimationController c) => Tween<double>(
    begin: 0.94,
    end: 1.0,
  ).animate(CurvedAnimation(parent: c, curve: springIn));
}

/// A short page turn without zoom or bounce; accessibility can disable it.
class QalamPageTransitions extends PageTransitionsBuilder {
  const QalamPageTransitions();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final direction = Directionality.of(context) == TextDirection.rtl
        ? -1.0
        : 1.0;
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.035 * direction, 0),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}
