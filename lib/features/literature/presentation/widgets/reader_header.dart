import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/domain.dart';

/// Title block of the poem reader.
///
/// By day («Муҳр») the title is set large, then one meta line
/// (genre · poet › · dates). At night («Шаб») the same facts open as a
/// centred title card — title and a pedigree line — before the
/// verse begins. Every word of the pedigree comes from the data (genre, poet
/// name, dates). The source is one line under the poem (`SourceLine`).
class ReaderHeader extends StatelessWidget {
  const ReaderHeader({
    super.key,
    required this.work,
    required this.title,
    required this.titleDirection,
    required this.genre,
    required this.authorName,
    required this.lifespan,
    required this.lang,
  });

  final LiteraryWork work;
  final String title;
  final TextDirection titleDirection;
  final String genre;
  final String authorName;
  final String? lifespan;
  final DisplayLanguage lang;

  @override
  Widget build(BuildContext context) {
    final night = Theme.of(context).brightness == Brightness.dark;
    return night ? _titleCard(context) : _dayHeader(context);
  }

  Widget _dayHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final meta = QalamTypography.meta(
      color: colors.onSurfaceVariant,
      fontSize: 14,
    );
    final separator = Text('  ·  ', style: meta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textDirection: titleDirection,
          style: QalamTypography.monographTitle(
            color: colors.onSurface,
            fontSize: 38,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            Text(genre, style: meta),
            separator,
            _AuthorLink(work: work, authorName: authorName),
            if (lifespan != null && lifespan!.isNotEmpty) ...[
              separator,
              Text(lifespan!, style: meta),
            ],
          ],
        ),
        ..._composition(meta),
      ],
    );
  }

  Widget _titleCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pedigree = [
      authorName,
      if (lifespan != null && lifespan!.isNotEmpty) lifespan!,
      genre,
    ].join(' · ');
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            textDirection: titleDirection,
            style: QalamTypography.monographTitle(
              color: colors.onSurface,
              fontSize: 36,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            pedigree,
            textAlign: TextAlign.center,
            style: QalamTypography.meta(color: colors.primary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _AuthorLink(work: work, authorName: authorName, compact: true),
          ..._composition(
            QalamTypography.meta(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _composition(TextStyle meta) {
    if (!work.hasAuditableCompositionEvidence ||
        lang == DisplayLanguage.persian) {
      return const [];
    }
    return [
      if (work.compositionDate?.trim().isNotEmpty ?? false)
        Text(
          AppTranslations.get('lit_comp_date', lang, [
            AppTranslations.formatDigits(work.compositionDate!, lang),
          ]),
          style: meta,
        ),
      if (work.compositionContext?.trim().isNotEmpty ?? false)
        Text(
          AppTranslations.get('lit_comp_context', lang, [
            work.compositionContext!,
          ]),
          style: meta,
        ),
    ];
  }
}

/// The poet's name as a link to their dossier (48 px target).
class _AuthorLink extends StatelessWidget {
  const _AuthorLink({
    required this.work,
    required this.authorName,
    this.compact = false,
  });

  final LiteraryWork work;
  final String authorName;

  /// In the title card the name is already in the pedigree line; the link
  /// is a small "dossier" affordance.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: work.authorId.isEmpty
          ? null
          : () => context.push('/literature/poet/${work.authorId}'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              authorName,
              style: QalamTypography.meta(
                color: colors.primary,
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isRtl ? Icons.chevron_left : Icons.chevron_right,
              size: 18,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
