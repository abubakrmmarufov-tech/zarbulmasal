import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

/// Desktop "reading room" layout rules: a left rail that stays on every
/// screen from [railBreakpoint], and a wider page for reading routes so the
/// text can sit beside a context pane.
abstract final class ReadingRoom {
  /// From this window width the rail replaces the bottom bar.
  static const double railBreakpoint = 1200;

  /// Width of the rail itself.
  static const double railWidth = 232;

  /// The ordinary page column (unchanged from mobile/tablet).
  static const double columnWidth = 760;

  /// The reading page column on desktop: text plus a context pane.
  static const double wideColumnWidth = 1160;

  /// From this page width a reader shows its context pane.
  static const double contextPaneBreakpoint = 1000;

  /// Routes that use [wideColumnWidth] on desktop.
  static bool isWideRoute(String path) =>
      path.startsWith('/literature/work/') ||
      path.startsWith('/literature/works/');

  /// Which rail destination a route belongs to (null for none).
  static int? destinationFor(String path) {
    if (path == '/' || path.startsWith('/daily')) return 0;
    if (path.startsWith('/learn') ||
        path.startsWith('/quiz') ||
        path.startsWith('/flashcards') ||
        path.startsWith('/levels')) {
      return 2;
    }
    if (path.startsWith('/saved') || path.startsWith('/favorites')) return 3;
    if (path.startsWith('/settings') || path.startsWith('/search')) {
      return null;
    }
    return 1; // Every collection lives under the one index, Explore.
  }
}

/// Tells descendants whether the desktop rail is showing, so the tab shell
/// can drop its bottom bar.
class ReadingRoomScope extends InheritedWidget {
  const ReadingRoomScope({
    super.key,
    required this.railVisible,
    required super.child,
  });

  final bool railVisible;

  static bool railVisibleOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ReadingRoomScope>()
          ?.railVisible ??
      false;

  @override
  bool updateShouldNotify(ReadingRoomScope oldWidget) =>
      railVisible != oldWidget.railVisible;
}

/// The persistent left rail (right in Persian): wordmark, the four
/// destinations, then search and settings.
///
/// It sits above the Navigator (in `MaterialApp.builder`), so it navigates
/// through [router] and cannot use overlays such as tooltips.
class DesktopRail extends StatelessWidget {
  const DesktopRail({
    super.key,
    required this.router,
    required this.path,
    required this.lang,
  });

  final GoRouter router;
  final String path;
  final DisplayLanguage lang;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = ReadingRoom.destinationFor(path);
    String tr(String key) => AppTranslations.get(key, lang);
    Widget item(int? index, IconData icon, String label, String route) =>
        _RailItem(
          icon: icon,
          label: label,
          selected: index != null && index == selected,
          onTap: () => index == null ? router.push(route) : router.go(route),
        );

    return Material(
      color: colors.surface,
      child: Container(
        width: ReadingRoom.railWidth,
        decoration: BoxDecoration(
          border: BorderDirectional(end: BorderSide(color: colors.outline)),
        ),
        child: SafeArea(
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 16, 28),
                child: Text(
                  tr('app_name'),
                  style: QalamTypography.monographTitle(
                    color: colors.onSurface,
                    fontSize: 24,
                  ),
                ),
              ),
              item(0, Icons.home_outlined, tr('nav_home'), '/'),
              item(1, Icons.explore_outlined, tr('nav_explore'), '/explore'),
              item(2, Icons.school_outlined, tr('nav_learn'), '/learn'),
              item(3, Icons.bookmark_outline, tr('nav_saved'), '/saved'),
              const Spacer(),
              item(null, Icons.search, tr('nav_search'), '/search'),
              item(
                null,
                Icons.settings_outlined,
                tr('settings_title'),
                '/settings',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = selected ? colors.primary : colors.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsetsDirectional.only(start: 21, end: 16),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(
                color: selected ? colors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: QalamTypography.label(color: color).copyWith(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

/// The page frame: one centred column on phones and tablets; on desktop a
/// persistent left rail beside it, and a wider column on reading routes.
///
/// The tree shape never changes with the width (the rail slot is always
/// there), so resizing across the breakpoint keeps navigation state.
class ReadingRoomFrame extends StatelessWidget {
  const ReadingRoomFrame({
    super.key,
    required this.router,
    required this.lang,
    required this.child,
  });

  final GoRouter router;
  final DisplayLanguage lang;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final railVisible = constraints.maxWidth >= ReadingRoom.railBreakpoint;
        return ReadingRoomScope(
          railVisible: railVisible,
          child: _RouteWatcher(
            router: router,
            builder: (context, path) {
              final maxWidth = railVisible && ReadingRoom.isWideRoute(path)
                  ? ReadingRoom.wideColumnWidth
                  : ReadingRoom.columnWidth;
              return Row(
                children: [
                  if (railVisible)
                    DesktopRail(router: router, path: path, lang: lang)
                  else
                    const SizedBox.shrink(),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: child,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Rebuilds with the current path when the router moves.
///
/// The router's delegate can notify while the Router itself is building
/// (this frame sits below it, in `MaterialApp.builder`), so a change seen
/// mid-build is applied after the frame instead of marking a widget dirty
/// during build.
class _RouteWatcher extends StatefulWidget {
  const _RouteWatcher({required this.router, required this.builder});

  final GoRouter router;
  final Widget Function(BuildContext context, String path) builder;

  @override
  State<_RouteWatcher> createState() => _RouteWatcherState();
}

class _RouteWatcherState extends State<_RouteWatcher> {
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void didUpdateWidget(_RouteWatcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_onRouteChanged);
      widget.router.routerDelegate.addListener(_onRouteChanged);
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (_pending || !mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      setState(() {});
      return;
    }
    _pending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _currentPath());

  String _currentPath() {
    final matches = widget.router.routerDelegate.currentConfiguration;
    return matches.isEmpty ? '/' : matches.uri.path;
  }
}
