import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book_domain.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/literature/presentation/poet_detail_screen.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

// A long source-language birthplace that would previously be ellipsized on a
// narrow phone when forced onto the same row as the lifespan.
const _longBirthPlace =
    'Деҳаи Панҷрӯд, дар наздикии Қаротегин, дар доманаи қаторкӯҳи Зарафшон';

const _author = LiteraryAuthor(
  id: 'rudaki',
  canonicalName: 'Абӯабдуллоҳи Рӯдакӣ',
  birthYear: '858',
  deathYear: '941',
  birthPlace: _longBirthPlace,
  literaryPeriod: 'Асри IX-X',
  biographyTj: 'Сардафтари адабиёти классикии тоҷик.',
  biographySource: 'Адабиёти тоҷик, синфи 5, Маориф, Душанбе, 2017, с. 49',
  biographyTjProvenance: 'SOURCE_BACKED',
  rights: RightsRecord(
    status: RightsStatus.publicDomain,
    reasoning: 'Муаллифи асри X.',
    fullTextAllowed: true,
    excerptAllowed: true,
  ),
);

void main() {
  testWidgets(
    'poet birthplace is fully readable on a narrow phone without ellipsis',
    (tester) async {
      tester.view.physicalSize = const Size(320, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          displayLanguageProvider.overrideWith(
            (ref) => DisplayLanguageNotifier()..state = DisplayLanguage.tajik,
          ),
          authorByIdProvider.overrideWith(
            (ref, id) => Future.value(id == 'rudaki' ? _author : null),
          ),
          worksByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <LiteraryWork>[]),
          ),
          worksUnderReviewByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <LiteraryWork>[]),
          ),
          schoolCanonByAuthorProvider.overrideWith(
            (ref, id) => Future.value(const <SchoolCanonEntry>[]),
          ),
          booksByAuthorProvider.overrideWith((ref, id) => const <Book>[]),
          historyEntriesProvider.overrideWith(
            (ref) => Future.value(const <HistoryEntry>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PoetDetailScreen(poetId: 'rudaki'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The full birthplace string is rendered on screen.
      final birthPlaceText = find.text(_longBirthPlace);
      expect(birthPlaceText, findsOneWidget);

      // It must not be ellipsized (the whole string is visible, no overflow).
      final textWidget = tester.widget<Text>(birthPlaceText);
      expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
      expect(textWidget.softWrap, isTrue);
    },
  );
}
