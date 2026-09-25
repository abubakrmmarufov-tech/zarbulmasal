part of 'history_screen.dart';

class _FilterBar extends StatelessWidget {
  final HistoryViewMode viewMode;
  final String? selectedGrade;
  final HistoryEntryKind? selectedKind;
  final HistoryEpoch? selectedEpoch;
  final bool isPersian;
  final ValueChanged<HistoryViewMode> onViewModeChanged;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<HistoryEntryKind?> onKindChanged;
  final ValueChanged<HistoryEpoch?> onEpochChanged;

  const _FilterBar({
    required this.viewMode,
    required this.selectedGrade,
    required this.selectedKind,
    required this.selectedEpoch,
    required this.isPersian,
    required this.onViewModeChanged,
    required this.onGradeChanged,
    required this.onKindChanged,
    required this.onEpochChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;
    final grades = ['5', '6', '7', '8', '9', '10', '11'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _ModeChip(
                  icon: Icons.timeline_outlined,
                  label: AppTranslations.get('hist_view_timeline', lang),
                  isSelected: viewMode == HistoryViewMode.timeline,
                  onTap: () => onViewModeChanged(HistoryViewMode.timeline),
                ),
                const SizedBox(width: 8),
                _ModeChip(
                  icon: Icons.school_outlined,
                  label: AppTranslations.get('hist_view_textbooks', lang),
                  isSelected: viewMode == HistoryViewMode.canon,
                  onTap: () => onViewModeChanged(HistoryViewMode.canon),
                ),
                const SizedBox(width: 8),
                _ModeChip(
                  icon: Icons.category_outlined,
                  label: AppTranslations.get('hist_view_topics_label', lang),
                  isSelected: viewMode == HistoryViewMode.topics,
                  onTap: () => onViewModeChanged(HistoryViewMode.topics),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 72,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Row(
              children: switch (viewMode) {
                HistoryViewMode.timeline => [
                  ChoiceChip(
                    label: Text(AppTranslations.get('hist_filter_all', lang)),
                    selected:
                        selectedEpoch == null &&
                        selectedGrade == null &&
                        selectedKind == null,
                    onSelected: (_) {
                      onEpochChanged(null);
                      onGradeChanged(null);
                      onKindChanged(null);
                    },
                  ),
                  ...HistoryEpoch.values.map(
                    (epoch) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: ChoiceChip(
                        label: Text(epoch.label(lang)),
                        selected: selectedEpoch == epoch,
                        onSelected: (selected) {
                          onEpochChanged(selected ? epoch : null);
                          if (selected) {
                            onGradeChanged(null);
                            onKindChanged(null);
                          }
                        },
                      ),
                    ),
                  ),
                  ...grades.map(
                    (grade) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: ChoiceChip(
                        label: Text(
                          AppTranslations.get('hist_filter_grade', lang, [
                            grade,
                          ]),
                        ),
                        selected: selectedGrade == grade,
                        onSelected: (selected) {
                          onGradeChanged(selected ? grade : null);
                          if (selected) {
                            onEpochChanged(null);
                            onKindChanged(null);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_states', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.empire,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.empire : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_figures', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.person,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.person : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.auto_stories_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_heritage', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.poem,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.poem : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.timeline_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_events', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.event,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.event : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.record_voice_over_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_narratives', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.oral,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.oral : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                ],
                HistoryViewMode.canon => [
                  ChoiceChip(
                    label: Text(AppTranslations.get('hist_filter_all', lang)),
                    selected: selectedGrade == null,
                    onSelected: (_) => onGradeChanged(null),
                  ),
                  ...grades.map(
                    (grade) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: ChoiceChip(
                        label: Text(
                          AppTranslations.get('hist_filter_grade', lang, [
                            grade,
                          ]),
                        ),
                        selected: selectedGrade == grade,
                        onSelected: (selected) =>
                            onGradeChanged(selected ? grade : null),
                      ),
                    ),
                  ),
                ],
                HistoryViewMode.topics => [
                  ChoiceChip(
                    label: Text(AppTranslations.get('hist_filter_all', lang)),
                    selected: selectedKind == null,
                    onSelected: (_) => onKindChanged(null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_states', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.empire,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.empire : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_figures', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.person,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.person : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.auto_stories_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_heritage', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.poem,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.poem : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.timeline_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_events', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.event,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.event : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.record_voice_over_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_narratives', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.oral,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.oral : null);
                    },
                  ),
                ],
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? colors.primary : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A history entry as a typographic row: kind and grade, the title, its
/// dates and a one-line summary. Opens the entry page directly.
class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;
  final bool isPersian;
  final VoidCallback onTap;

  const _HistoryRow({
    required this.entry,
    required this.isPersian,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;
    final title = _historyRequiredTitle(entry.title, entry.titlePersian, lang);
    final summary = isPersian
        ? _historyOptionalText(entry.summaryPersian)
        : _historyOptionalText(entry.summary);
    final dates = isPersian
        ? _historyOptionalText(entry.datesPersian) ??
              _historyOptionalText(entry.periodPersian)
        : _historyOptionalText(entry.dates) ??
              _historyOptionalText(entry.period);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QalamSpacing.pageH),
      child: QalamSlip(
        onTap: onTap,
        child: Directionality(
          textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_kindLabel(entry.kind, isPersian)} · '
                '${AppTranslations.get('hist_filter_grade', lang, [entry.grade])}',
                style: QalamTypography.meta(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: QalamTypography.literaryTitle(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              if (dates != null) ...[
                const SizedBox(height: 2),
                Text(
                  dates,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.meta(color: colors.primary),
                ),
              ],
              if (summary != null) ...[
                const SizedBox(height: 6),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _kindLabel(HistoryEntryKind kind, bool isPersian) {
    final key = switch (kind) {
      HistoryEntryKind.empire => 'hist_kind_empire',
      HistoryEntryKind.dynasty => 'hist_kind_dynasty',
      HistoryEntryKind.ruler => 'hist_kind_ruler',
      HistoryEntryKind.person => 'hist_kind_person',
      HistoryEntryKind.event => 'hist_kind_event',
      HistoryEntryKind.battle => 'hist_kind_battle',
      HistoryEntryKind.place => 'hist_kind_place',
      HistoryEntryKind.cultural => 'hist_kind_cultural',
      HistoryEntryKind.poem => 'hist_kind_poem',
      HistoryEntryKind.oral => 'hist_kind_oral',
    };
    return AppTranslations.getForLang(isPersian ? 'fa' : 'tj', key);
  }
}

void _showHistoryBookDetails(
  BuildContext context,
  HistoryBook book,
  bool isPersian, {
  required ValueChanged<String?> onGradeSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;
      final details = _historyBookDetails(book, lang);
      final description = isPersian
          ? _historyOptionalText(book.descriptionPersian)
          : _historyOptionalText(book.description);
      return SafeArea(
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, size: 22, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppTranslations.get('hist_textbook_grade', lang, [
                          book.grade,
                        ]),
                        style: QalamTypography.eyebrow(color: colors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _historyRequiredTitle(book.title, book.titlePersian, lang),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      details,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (book.externalSourceUri != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        label: Text(
                          (book.isUploadedBook || book.localPath != null)
                              ? AppTranslations.get(
                                  'hist_source_study_local',
                                  lang,
                                )
                              : AppTranslations.get('hist_source_study', lang),
                        ),
                        onPressed: () async {
                          final uri = book.externalSourceUri!;
                          await openHistorySource(context, uri, lang);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: Text(
                        AppTranslations.get('hist_view_grade_topics', lang, [
                          book.grade,
                        ]),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onGradeSelected(book.grade);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
