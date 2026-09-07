import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

/// Brief typographic opening. The routed child stays mounted while it appears.
class SplashScreen extends ConsumerStatefulWidget {
  final Widget child;
  const SplashScreen({super.key, required this.child});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  bool _visible = true;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;
    final visible = _visible && !MediaQuery.disableAnimationsOf(context);
    return Stack(
      children: [
        widget.child,
        if (visible)
          Positioned.fill(
            child: ColoredBox(
              color: colors.surface,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'З',
                        style: QalamTypography.pageTitle(
                          color: colors.primary,
                          fontSize: 88,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppTranslations.get('app_name', lang),
                        textAlign: TextAlign.center,
                        style: QalamTypography.sectionTitle(
                          color: colors.onSurface,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppTranslations.get('app_tagline', lang),
                        textAlign: TextAlign.center,
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
