import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/reading_position_provider.dart';
import '../../../shared/providers/reading_script_provider.dart';
import '../../../shared/providers/recent_activity_provider.dart';
import '../../../shared/widgets/reading_room.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../data/reader_preferences_provider.dart';
import '../domain/domain.dart';
import 'literary_author_display_text.dart';
import 'literary_work_display_text.dart';
import 'widgets/reader_end_of_text.dart';
import 'widgets/reader_header.dart';
import 'widgets/reader_script_bar.dart';
import 'widgets/reader_toolbar.dart';
import 'widgets/source_line.dart';
import 'widgets/verse_view.dart';

/// A reader screen displaying a verified [LiteraryWork] with full provenance,
/// script-aware typography, one status line, and a bottom action bar.
class PoemReaderScreen extends ConsumerWidget {
  final String workId;

  /// 1-based bayt/line to open at (from Continue reading), if any.
  final int? initialAnchor;

  const PoemReaderScreen({super.key, required this.workId, this.initialAnchor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final worksAsync = ref.watch(approvedWorksProvider);
    final allWorksAsync = ref.watch(literaryWorksProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          AppTranslations.get('lit_reader_title', lang),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 18,
          ),
        ),
      ),
      body: worksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: AppTranslations.get('lit_work_error_title', lang),
            subtitle: AppTranslations.get('lit_work_error_sub', lang),
            action: OutlinedButton(
              onPressed: () {
                ref.invalidate(literaryWorksProvider);
                ref.invalidate(approvedWorksProvider);
              },
              child: Text(AppTranslations.get('btn_retry', lang)),
            ),
          ),
        ),
        data: (works) {
          final work = works.cast<LiteraryWork?>().firstWhere(
            (w) => w?.id == workId,
            orElse: () => null,
          );

          if (work == null) {
            final pendingWork = allWorksAsync.valueOrNull
                ?.cast<LiteraryWork?>()
                .firstWhere(
                  (candidate) => candidate?.id == workId,
                  orElse: () => null,
                );
            if (pendingWork != null &&
                (pendingWork.verification.evidenceLevel ==
                        VerificationLevel.needsReview ||
                    pendingWork.verification.evidenceLevel ==
                        VerificationLevel.primaryChecked)) {
              return _PendingWorkState(work: pendingWork);
            }

            return Center(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: AppTranslations.get('lit_work_not_found_title', lang),
                subtitle: AppTranslations.get('lit_work_not_found_sub', lang),
                action: OutlinedButton(
                  onPressed: () => qalamBack(context),
                  child: Text(AppTranslations.get('back', lang)),
                ),
              ),
            );
          }

          return _PoemReaderContent(
            key: ValueKey(work.id),
            work: work,
            initialAnchor: initialAnchor,
          );
        },
      ),
    );
  }
}

/// Explains why a known textbook candidate cannot be read yet.
class _PendingWorkState extends ConsumerWidget {
  final LiteraryWork work;

  const _PendingWorkState({required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final citation = LiteraryWorkDisplayText.shortCitation(work, lang);
    final sourceNote = citation == null
        ? ''
        : '\n\n${AppTranslations.get('lit_source_line', lang, [citation])}';

    return Center(
      child: EmptyState(
        icon: Icons.hourglass_empty,
        title: AppTranslations.get('lit_work_pending_title', lang),
        subtitle:
            '${AppTranslations.get('lit_work_pending_sub', lang)}$sourceNote',
        action: OutlinedButton(
          onPressed: () => qalamBack(context),
          child: Text(AppTranslations.get('back', lang)),
        ),
      ),
    );
  }
}

class _PoemReaderContent extends ConsumerStatefulWidget {
  final LiteraryWork work;
  final int? initialAnchor;

  const _PoemReaderContent({super.key, required this.work, this.initialAnchor});

  @override
  ConsumerState<_PoemReaderContent> createState() => _PoemReaderContentState();
}

class _PoemReaderContentState extends ConsumerState<_PoemReaderContent> {
  /// Per-screen script override from the chips; the saved reading script
  /// (Settings → Reading) stays untouched.
  ReaderScriptMode? _userScriptMode;

  final _viewportKey = GlobalKey();
  List<GlobalKey> _unitKeys = const [];
  ReaderScriptMode? _unitKeysMode;
  bool _unitsAreBayts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _recordVisit();
      _jumpToInitialAnchor();
    });
  }

  void _recordVisit() {
    final work = widget.work;
    final lang = ref.read(displayLanguageProvider);
    final route = '/literature/work/${work.id}';
    ref
        .read(recentActivityProvider.notifier)
        .addActivity(
          RecentActivity(
            id: work.id,
            type: RecentActivityType.work,
            title: LiteraryWorkDisplayText.title(work, lang),
            subtitle: AppTranslations.get('lit_genre_poem', lang),
            titleTajik: work.title,
            titlePersian: work.titlePersian,
            subtitleTajik: AppTranslations.get(
              'lit_genre_poem',
              DisplayLanguage.tajik,
            ),
            subtitlePersian: AppTranslations.get(
              'lit_genre_poem',
              DisplayLanguage.persian,
            ),
            timestamp: DateTime.now(),
            route: route,
          ),
        );
    ref
        .read(readingPositionProvider.notifier)
        .open(
          ReadingPosition(
            kind: ReadingKind.work,
            id: work.id,
            route: route,
            titleTajik: work.title,
            titlePersian: work.titlePersian,
            titlePersianGenerated: work.titlePersianSource == 'generated',
            timestamp: DateTime.now(),
          ),
        );
  }

  void _jumpToInitialAnchor() {
    final anchor = widget.initialAnchor;
    if (anchor == null || anchor < 2 || anchor > _unitKeys.length) return;
    final target = _unitKeys[anchor - 1].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, alignment: 0.15);
  }

  /// Stores the first bayt/line visible at the top of the viewport.
  bool _onScrollEnd(ScrollEndNotification notification) {
    final viewport =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewport == null || _unitKeys.isEmpty) return false;
    final top = viewport.localToGlobal(Offset.zero).dy;
    for (var i = 0; i < _unitKeys.length; i++) {
      final box = _unitKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
      if (bottom > top + 8) {
        ref
            .read(readingPositionProvider.notifier)
            .updateAnchor(
              kind: ReadingKind.work,
              id: widget.work.id,
              anchor: i + 1,
              total: _unitKeys.length,
              isBayt: _unitsAreBayts,
            );
        break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final work = widget.work;
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final readingScript = ref.watch(readingScriptProvider);
    final prefersPersianScript = readingScript == ReadingScript.persian;
    final readerPrefs = ref.watch(readerPreferencesProvider);
    final author = ref.watch(authorByIdProvider(work.authorId)).valueOrNull;

    final hasGeneratedPersian =
        work.persianScriptSource == 'generated' && work.hasPersianDisplay;
    final hasBothScripts = work.hasTajikText && work.hasPersianText;
    final mode =
        _userScriptMode ??
        _defaultScriptMode(
          work: work,
          prefersPersian: prefersPersianScript,
          prefersParallel: readerPrefs.defaultReaderMode == 'parallel',
        );
    final showsPersianText =
        mode == ReaderScriptMode.persian &&
        (work.hasPersianText || hasGeneratedPersian);
    final hasVerifiedText =
        work.isDisplayable &&
        ((mode == ReaderScriptMode.tajik && work.hasTajikText) ||
            showsPersianText ||
            (mode == ReaderScriptMode.parallel && hasBothScripts));
    final persianTextUnavailable =
        mode == ReaderScriptMode.persian &&
        work.hasTajikText &&
        !work.hasPersianText &&
        !hasGeneratedPersian;
    final showScriptBar =
        hasBothScripts ||
        (work.hasTajikText && hasGeneratedPersian) ||
        (prefersPersianScript && work.hasTajikText);

    final titleInPersian = mode == ReaderScriptMode.persian;
    final title = titleInPersian
        ? LiteraryWorkDisplayText.title(work, DisplayLanguage.persian)
        : work.title;
    final authorName = LiteraryAuthorDisplayText.nameOrFallback(
      author,
      lang,
      work.authorId,
    );
    final lifespan = author != null && author.hasAuditableBiographySource
        ? LiteraryAuthorDisplayText.lifespan(author, lang)
        : null;

    // Verse is set in the reading serif (PT Serif; Naskh for Persian script).
    final readerFontSize = (20.0 + readerPrefs.fontSizeDelta).clamp(14.0, 34.0);
    final verseStyle = QalamTypography.verseText(
      color: colors.onSurface,
      fontSize: readerFontSize,
      height: readerPrefs.lineHeightMultiplier,
    );
    final verseText = showsPersianText
        ? (work.textPersian ?? work.persianScriptRepresentation ?? '')
        : (work.textTajik ??
              work.textPersian ??
              work.persianScriptRepresentation ??
              '');
    final layout = VerseLayout.of(verseText, work.type);
    // One key per bayt/line of the text currently shown; a script switch
    // shows a different text, so it gets fresh keys.
    if (_unitKeysMode != mode || _unitKeys.length != layout.unitCount) {
      _unitKeys = List.generate(layout.unitCount, (_) => GlobalKey());
      _unitKeysMode = mode;
    }
    _unitsAreBayts = layout.isBaytText;

    final activeText = mode == ReaderScriptMode.parallel && hasBothScripts
        ? '${work.textTajik}\n\n${work.textPersian}'
        : verseText;
    final copyText = hasVerifiedText
        ? '$title\n$authorName\n\n$activeText'
        : '$title\n$authorName';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop reading room: the record and the connections sit in a
        // context pane beside the text instead of behind a tab.
        final hasPane =
            constraints.maxWidth >= ReadingRoom.contextPaneBreakpoint;
        final reader = Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollEndNotification>(
                onNotification: _onScrollEnd,
                child: SelectionArea(
                  child: CustomScrollView(
                    key: _viewportKey,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ReaderHeader(
                                work: work,
                                title: title,
                                titleDirection: titleInPersian
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                genre: _genreName(work.type, lang),
                                authorName: authorName,
                                lifespan: lifespan,
                                lang: lang,
                              ),
                              const SizedBox(height: 28),
                              ...[
                                if (showScriptBar)
                                  ReaderScriptBar(
                                    mode: mode,
                                    showParallel: hasBothScripts,
                                    onSelected: (value) =>
                                        setState(() => _userScriptMode = value),
                                  ),
                                if (showsPersianText && hasGeneratedPersian)
                                  _GeneratedScriptLabel(lang: lang),
                                if (hasVerifiedText)
                                  mode == ReaderScriptMode.parallel &&
                                          hasBothScripts
                                      ? _ParallelVerses(
                                          tajikText: work.textTajik!,
                                          persianText: work.textPersian!,
                                          style: verseStyle,
                                        )
                                      : VerseView(
                                          layout: layout,
                                          style: verseStyle,
                                          textDirection: showsPersianText
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          unitKeys: _unitKeys,
                                        )
                                else
                                  _ReviewPlaceholder(
                                    work: work,
                                    persianTextUnavailable:
                                        persianTextUnavailable,
                                    showIncipit: mode == ReaderScriptMode.tajik,
                                    fontSizeDelta: readerPrefs.fontSizeDelta,
                                    lang: lang,
                                  ),
                                const SizedBox(height: 28),
                                SourceLine(work: work, lang: lang),
                                const SizedBox(height: 40),
                                ReaderEndOfText(
                                  work: work,
                                  showConnections: !hasPane,
                                ),
                              ],
                              // `editorialNotes` are internal English audit notes;
                              // they stay in the data and never reach readers.
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ReaderToolbar(work: work, copyText: copyText),
          ],
        );
        if (!hasPane) return reader;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: reader),
            _ReaderContextPane(work: work),
          ],
        );
      },
    );
  }

  ReaderScriptMode _defaultScriptMode({
    required LiteraryWork work,
    required bool prefersPersian,
    required bool prefersParallel,
  }) {
    if (prefersParallel && work.hasTajikText && work.hasPersianText) {
      return ReaderScriptMode.parallel;
    }
    // In Persian reading mode a Tajik-only poem starts in the explicit
    // unavailable state until the reader opts into the original script.
    if (prefersPersian) return ReaderScriptMode.persian;
    if (work.hasTajikText) return ReaderScriptMode.tajik;
    return ReaderScriptMode.persian;
  }

  String _genreName(WorkType type, DisplayLanguage lang) {
    final key = switch (type) {
      WorkType.ghazal => 'lit_genre_ghazal',
      WorkType.rubai => 'lit_genre_rubai',
      WorkType.qasida => 'lit_genre_qasida',
      WorkType.poem => 'lit_genre_poem',
      WorkType.fragment => 'lit_genre_qita',
      WorkType.folk => 'lit_genre_folk',
      WorkType.anthem => 'lit_genre_song',
      WorkType.epic => 'lit_genre_masnavi',
      WorkType.other => 'lit_genre_other',
    };
    return AppTranslations.get(key, lang);
  }
}

/// The desktop context pane: the connections (more by the poet, the
/// period), always visible beside the text.
class _ReaderContextPane extends StatelessWidget {
  const _ReaderContextPane({required this.work});

  final LiteraryWork work;

  static const double width = 360;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          children: [ReaderEndOfText(work: work, showNeighbours: false)],
        ),
      ),
    );
  }
}

/// States that the Persian-script text is a mechanical transliteration, not
/// a Persian source (data: `persianScriptSource: "generated"`).
class _GeneratedScriptLabel extends StatelessWidget {
  const _GeneratedScriptLabel({required this.lang});

  final DisplayLanguage lang;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppTranslations.get('lit_generated_script_label', lang),
              style: QalamTypography.meta(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewPlaceholder extends StatelessWidget {
  const _ReviewPlaceholder({
    required this.work,
    required this.persianTextUnavailable,
    required this.showIncipit,
    required this.fontSizeDelta,
    required this.lang,
  });

  final LiteraryWork work;
  final bool persianTextUnavailable;
  final bool showIncipit;
  final double fontSizeDelta;
  final DisplayLanguage lang;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    String tr(String key) => AppTranslations.get(key, lang);
    final incipit = work.incipit;
    // A plain block (no box): the page already frames it.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_empty, size: 20, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr(
                    persianTextUnavailable
                        ? 'lit_persian_text_unavailable_title'
                        : 'lit_editorial_review_pending',
                  ),
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              persianTextUnavailable
                  ? 'lit_persian_text_unavailable'
                  : 'lit_editorial_policy_notice',
            ),
            style: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          if (showIncipit && incipit != null && incipit.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              tr('lit_incipit_label'),
              style: QalamTypography.meta(color: colors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              '«$incipit»',
              style: QalamTypography.heroProverb(
                color: colors.onSurface,
                fontSize: (18.0 + fontSizeDelta * 0.5).clamp(14.0, 28.0),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Genuinely bilingual works only: each Tajik line above its Persian line.
class _ParallelVerses extends StatelessWidget {
  const _ParallelVerses({
    required this.tajikText,
    required this.persianText,
    required this.style,
  });

  final String tajikText;
  final String persianText;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    List<String> lines(String text) =>
        text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final tj = lines(tajikText);
    final fa = lines(persianText);
    final count = tj.length > fa.length ? tj.length : fa.length;
    final indent = (style.fontSize ?? 20) * VerseView.hangingIndentEm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (i < tj.length)
                  HangingIndentLine(
                    text: tj[i],
                    textDirection: TextDirection.ltr,
                    style: style,
                    indent: indent,
                  ),
                if (i < fa.length)
                  HangingIndentLine(
                    text: fa[i],
                    textDirection: TextDirection.rtl,
                    indent: indent,
                    style: style.copyWith(
                      color: colors.primary,
                      fontSize: (style.fontSize ?? 20) * 0.95,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
