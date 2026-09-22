import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/l10n/app_translations.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import '../../helpers/test_helper.dart';

const _tajikOnlyWork = LiteraryWork(
  id: 'saved-tajik-only-work',
  authorId: 'test-author',
  title: 'Сарлавҳаи тоҷикӣ',
  incipit: 'Мисраи тоҷикӣ',
  type: WorkType.poem,
  rights: RightsRecord(
    status: RightsStatus.unknown,
    reasoning: 'Test fixture without a Persian title.',
    fullTextAllowed: false,
    excerptAllowed: false,
  ),
  verification: VerificationRecord(
    evidenceLevel: VerificationLevel.primaryChecked,
    pageVerified: true,
  ),
);

void main() {
  testWidgets('Persian Saved hides untranslated poem title and incipit', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/saved',
      language: DisplayLanguage.persian,
      overrides: [
        literaryFavoriteWorksProvider.overrideWith(
          (ref) => Future.value([_tajikOnlyWork]),
        ),
      ],
    );

    expect(find.text('عنوان فارسی اثر در دسترس نیست'), findsOneWidget);
    expect(find.text('Сарлавҳаи тоҷикӣ'), findsNothing);
    expect(find.text('Мисраи тоҷикӣ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Persian Saved labels the original Tajik proverb explanation', (
    tester,
  ) async {
    final proverb = seedProverbs.first;
    await openApp(
      tester,
      route: '/saved',
      language: DisplayLanguage.persian,
      overrides: [
        favoritesListProvider.overrideWithValue([proverb]),
      ],
    );

    final label = AppTranslations.get(
      'reading_tajik_explanation',
      DisplayLanguage.persian,
    );
    expect(find.textContaining(label), findsOneWidget);
    expect(find.textContaining(proverb.meaningTj), findsOneWidget);
  });
}
