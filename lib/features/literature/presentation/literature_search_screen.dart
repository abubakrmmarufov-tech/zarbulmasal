import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_author.dart';
import '../domain/literary_work.dart';

/// A unified search screen querying across canonical authors and literary works.
class LiteratureSearchScreen extends ConsumerStatefulWidget {
  const LiteratureSearchScreen({super.key});

  @override
  ConsumerState<LiteratureSearchScreen> createState() =>
      _LiteratureSearchScreenState();
}

class _LiteratureSearchScreenState
    extends ConsumerState<LiteratureSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final worksAsync = ref.watch(approvedWorksProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppTranslations.get('lit_search_hint', lang),
            border: InputBorder.none,
            hintStyle: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
            ),
          ),
          style: QalamTypography.body(color: colors.onSurface),
          onChanged: (val) {
            setState(() {
              _query = val.trim().toLowerCase();
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _buildEmptyPrompt(
              context,
              isPersian,
              authorsAsync.valueOrNull ?? const [],
            )
          : _buildSearchResults(
              context,
              authorsAsync.valueOrNull ?? [],
              worksAsync.valueOrNull ?? [],
              isPersian,
            ),
    );
  }

  Widget _buildEmptyPrompt(
    BuildContext context,
    bool isPersian,
    List<LiteraryAuthor> authors,
  ) {
    final colors = Theme.of(context).colorScheme;
    final suggestions = authors.take(6).map((author) {
      if (isPersian && author.canonicalNamePersian != null) {
        return author.canonicalNamePersian!;
      }
      return author.canonicalName;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPersian ? 'پیشنهادهای جستجو:' : 'Пешниҳодҳои ҷустуҷӯ:',
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((term) {
              return ActionChip(
                label: Text(term),
                onPressed: () {
                  _controller.text = term;
                  setState(() => _query = term.toLowerCase());
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<LiteraryAuthor> authors,
    List<LiteraryWork> works,
    bool isPersian,
  ) {
    final matchingAuthors = authors.where((a) {
      final name = a.canonicalName.toLowerCase();
      final fa = a.canonicalNamePersian?.toLowerCase() ?? '';
      final period = a.literaryPeriod.toLowerCase();
      final place = a.birthPlace?.toLowerCase() ?? '';
      final aliases = a.aliases.any((x) => x.toLowerCase().contains(_query));
      return name.contains(_query) ||
          fa.contains(_query) ||
          period.contains(_query) ||
          place.contains(_query) ||
          aliases;
    }).toList();

    final matchingWorks = works.where((w) {
      final title = w.title.toLowerCase();
      final titleFa = w.titlePersian?.toLowerCase() ?? '';
      final incipit = w.incipit?.toLowerCase() ?? '';
      return title.contains(_query) ||
          titleFa.contains(_query) ||
          incipit.contains(_query);
    }).toList();

    if (matchingAuthors.isEmpty && matchingWorks.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off,
          title: isPersian ? 'نتیجه‌ای یافت نشد' : 'Мундариҷа ёфт нашуд',
          subtitle: isPersian
              ? 'با عبارت «$_query» اثری یا شاعری پیدا نشد.'
              : 'Бо вожаи «$_query» шоир ё асаре ёфт нашуд.',
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (matchingAuthors.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              isPersian ? 'شاعران' : 'Шоирон',
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
          ),
          for (final author in matchingAuthors)
            QalamPoetCard(
              name: (isPersian && author.canonicalNamePersian != null)
                  ? author.canonicalNamePersian!
                  : author.canonicalName,
              dates: author.lifespan,
              period: author.literaryPeriod,
              isPublicDomain: author.isPublicDomain,
              onTap: () => context.push('/literature/poet/${author.id}'),
            ),
          const SizedBox(height: 24),
        ],
        if (matchingWorks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              isPersian ? 'شعرها و آثار' : 'Шеърҳо ва осор',
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
          ),
          for (final work in matchingWorks)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 4,
              ),
              title: Text(
                (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title,
                style: QalamTypography.sectionTitle(
                  color: colors.onSurface,
                  fontSize: 17,
                ),
              ),
              subtitle: work.incipit != null
                  ? Text(
                      '«${work.incipit}»',
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => context.push('/literature/work/${work.id}'),
            ),
        ],
      ],
    );
  }
}
