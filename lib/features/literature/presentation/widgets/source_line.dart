import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/domain.dart';
import '../literary_work_display_text.dart';

/// The one source line under a poem: «Манбаъ: book, grade (year)».
/// Renders nothing when the work records no source title.
class SourceLine extends StatelessWidget {
  const SourceLine({super.key, required this.work, required this.lang});

  final LiteraryWork work;
  final DisplayLanguage lang;

  @override
  Widget build(BuildContext context) {
    final citation = LiteraryWorkDisplayText.shortCitation(work, lang);
    if (citation == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      child: Text(
        AppTranslations.get('lit_source_line', lang, [citation]),
        style: QalamTypography.meta(
          color: colors.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
    );
  }
}
