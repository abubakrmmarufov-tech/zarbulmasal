import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tajikistan observes a fixed UTC+5 offset year-round (no daylight saving).
const Duration tajikistanUtcOffset = Duration(hours: 5);

/// Injectable clock returning the current instant.
///
/// Tests pin this provider instead of reaching for the device-local
/// `DateTime.now()`, so daily selection never depends on where the user is.
typedef InstantClock = DateTime Function();

/// The device clock. Override in tests to pin the current instant.
final systemInstantClockProvider = Provider<InstantClock>(
  (ref) => DateTime.now,
);

/// The calendar day currently observed in Tajikistan, derived from the
/// injectable [systemInstantClockProvider].
///
/// The returned value is a UTC-normalized midnight so callers can compare or
/// index it without being influenced by the device time zone.
final tajikistanDayProvider = Provider<DateTime>((ref) {
  final instant = ref.watch(systemInstantClockProvider)();
  return tajikistanCalendarDay(instant);
});

/// The calendar date currently observed in Tajikistan for [instant].
///
/// The instant is first normalized to UTC so the same absolute moment yields
/// the same Tajikistan day regardless of the device clock's local offset.
DateTime tajikistanCalendarDay(DateTime instant) {
  final utc = instant.toUtc();
  final local = utc.add(tajikistanUtcOffset);
  return DateTime.utc(local.year, local.month, local.day);
}

/// Deterministic, gapless day index for [instant] on the Tajikistan calendar.
///
/// Advances by exactly one per Tajikistan calendar day across month/year
/// boundaries, and is stable for the same absolute instant in every offset.
int tajikistanDayIndex(DateTime instant, int catalogLength) {
  if (catalogLength <= 0) return 0;
  final epoch = DateTime.utc(2020, 1, 1);
  final days = tajikistanCalendarDay(instant).difference(epoch).inDays;
  return ((days % catalogLength) + catalogLength) % catalogLength;
}
