import '../../data/models/source_ref.dart';
import '../../shared/providers/app_providers.dart';
import 'app_translations.dart';

/// One-line citation of a printed page:
/// author, «title» (city: publisher, year), page.
///
/// The printed page is preferred; a source that only has a scan page is cited
/// by that page, labelled as such, never passed off as a printed number.
String formatSourceCitation(SourceRef source, DisplayLanguage lang) {
  final parts = <String>[];
  final author = source.authorEditor?.trim() ?? '';
  if (author.isNotEmpty) parts.add(author);

  final imprint = [source.city, source.publisher]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(': ');
  final edition = [
    if (imprint.isNotEmpty) imprint,
    if (source.year != null)
      AppTranslations.formatDigits('${source.year}', lang),
  ].join(', ');
  parts.add(
    edition.isEmpty
        ? '«${source.bookTitle}»'
        : '«${source.bookTitle}» ($edition)',
  );

  final printedPage = source.printedPage;
  parts.add(
    printedPage != null
        ? AppTranslations.get('citation_page', lang, [printedPage])
        : AppTranslations.get('citation_pdf_page', lang, [source.pdfPage]),
  );
  return parts.join(', ');
}
