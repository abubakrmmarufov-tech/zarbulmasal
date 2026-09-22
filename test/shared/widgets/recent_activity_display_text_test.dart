import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';
import 'package:zarbulmasal/shared/providers/recent_activity_provider.dart';
import 'package:zarbulmasal/shared/widgets/recent_activity_display_text.dart';

void main() {
  const persianLabels = {
    RecentActivityType.proverb: 'ضرب‌المثل‌ها',
    RecentActivityType.poet: 'شاعران',
    RecentActivityType.work: 'آثار منظوم',
    RecentActivityType.history: 'تاریخ',
    RecentActivityType.level: 'آموزش',
  };

  test('Persian recent activity never renders saved Tajik metadata', () {
    for (final entry in persianLabels.entries) {
      final activity = RecentActivity(
        id: 'test-id',
        type: entry.key,
        title: 'Таърихи тоҷикӣ',
        subtitle: 'Асрҳои IX–X',
        timestamp: DateTime.utc(2026),
        route: '/internal/test',
      );

      expect(
        RecentActivityDisplayText.title(activity, DisplayLanguage.persian),
        entry.value,
      );
      expect(
        RecentActivityDisplayText.subtitle(activity, DisplayLanguage.persian),
        isNull,
      );
    }
  });

  test('Persian recent activity keeps already Persian text contextual', () {
    final activity = RecentActivity(
      id: 'rudaki',
      type: RecentActivityType.poet,
      title: 'ابوعبدالله رودکی',
      subtitle: 'قرن نهم',
      timestamp: DateTime.utc(2026),
      route: '/literature/poet/rudaki',
    );

    expect(
      RecentActivityDisplayText.title(activity, DisplayLanguage.persian),
      activity.title,
    );
    expect(
      RecentActivityDisplayText.subtitle(activity, DisplayLanguage.persian),
      activity.subtitle,
    );
  });

  test('Tajik recent activity retains its stored title and subtitle', () {
    final activity = RecentActivity(
      id: 'rudaki',
      type: RecentActivityType.poet,
      title: 'Абӯабдуллоҳи Рӯдакӣ',
      subtitle: 'Асрҳои IX–X',
      timestamp: DateTime.utc(2026),
      route: '/literature/poet/rudaki',
    );

    expect(
      RecentActivityDisplayText.title(activity, DisplayLanguage.tajik),
      activity.title,
    );
    expect(
      RecentActivityDisplayText.subtitle(activity, DisplayLanguage.tajik),
      activity.subtitle,
    );
  });

  test('language changes retain both canonical activity labels', () {
    final activity = RecentActivity(
      id: 'rudaki',
      type: RecentActivityType.poet,
      title: 'ابوعبدالله رودکی',
      subtitle: 'قرن نهم',
      titleTajik: 'Абӯабдуллоҳи Рӯдакӣ',
      titlePersian: 'ابوعبدالله رودکی',
      subtitleTajik: 'Асрҳои IX–X',
      subtitlePersian: 'قرن نهم',
      timestamp: DateTime.utc(2026),
      route: '/literature/poet/rudaki',
    );

    expect(
      RecentActivityDisplayText.title(activity, DisplayLanguage.persian),
      'ابوعبدالله رودکی',
    );
    expect(
      RecentActivityDisplayText.subtitle(activity, DisplayLanguage.persian),
      'قرن نهم',
    );
    expect(
      RecentActivityDisplayText.title(activity, DisplayLanguage.tajik),
      'Абӯабдуллоҳи Рӯдакӣ',
    );
    expect(
      RecentActivityDisplayText.subtitle(activity, DisplayLanguage.tajik),
      'Асрҳои IX–X',
    );

    final restored = RecentActivity.fromJson(activity.toJson());
    expect(
      RecentActivityDisplayText.title(restored, DisplayLanguage.tajik),
      'Абӯабдуллоҳи Рӯдакӣ',
    );
  });

  test('legacy activity text falls back safely after a language switch', () {
    final persianLegacy = RecentActivity(
      id: 'rudaki',
      type: RecentActivityType.poet,
      title: 'ابوعبدالله رودکی',
      subtitle: 'قرن نهم',
      timestamp: DateTime.utc(2026),
      route: '/literature/poet/rudaki',
    );
    final tajikLegacy = RecentActivity(
      id: 'rudaki',
      type: RecentActivityType.poet,
      title: 'Абӯабдуллоҳи Рӯдакӣ',
      subtitle: 'Асрҳои IX–X',
      timestamp: DateTime.utc(2026),
      route: '/literature/poet/rudaki',
    );

    expect(
      RecentActivityDisplayText.title(persianLegacy, DisplayLanguage.tajik),
      'Шоирон',
    );
    expect(
      RecentActivityDisplayText.subtitle(persianLegacy, DisplayLanguage.tajik),
      isNull,
    );
    expect(
      RecentActivityDisplayText.title(tajikLegacy, DisplayLanguage.persian),
      'شاعران',
    );
    expect(
      RecentActivityDisplayText.subtitle(tajikLegacy, DisplayLanguage.persian),
      isNull,
    );
  });
}
