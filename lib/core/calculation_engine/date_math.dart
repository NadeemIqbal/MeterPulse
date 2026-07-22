/// Pure, date-only calendar arithmetic used by the calculation engine, the
/// dashboard "days remaining" fields and billing-cycle scheduling.
///
/// All functions truncate to the date (time-of-day is ignored) and are
/// DST-safe: differences are taken in hours and divided by 24 so a local day
/// that is 23 or 25 hours long across a DST transition still counts as one day.
library;

/// Whole days from [from] to [to], counting the date only.
///
/// Positive when [to] is after [from], negative when before, `0` on the same
/// calendar day (even at different times of day).
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(to.year, to.month, to.day);
  return (b.difference(a).inHours / 24).round();
}

/// Last calendar day of the month containing [date] (day 0 of the next month).
DateTime lastDayOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

/// Days from [from] until the end of its calendar month (`0` on the last day).
int daysRemainingInMonth(DateTime from) =>
    daysBetween(from, lastDayOfMonth(from));

/// Days from [from] until [target]; negative if [target] is already past.
int daysUntil(DateTime target, {required DateTime from}) =>
    daysBetween(from, target);

/// The next date on or after [from] whose day-of-month is [dayOfMonth].
///
/// [dayOfMonth] is clamped to each month's length, so day 31 becomes 30 in
/// June and 28/29 in February. If this month's occurrence is already past,
/// rolls to next month (and across a year boundary).
DateTime nextReadingDate(int dayOfMonth, {required DateTime from}) {
  DateTime occurrenceIn(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, dayOfMonth.clamp(1, lastDay));
  }

  final fromDateOnly = DateTime(from.year, from.month, from.day);
  final thisMonth = occurrenceIn(from.year, from.month);
  if (!thisMonth.isBefore(fromDateOnly)) return thisMonth;

  return from.month == 12
      ? occurrenceIn(from.year + 1, 1)
      : occurrenceIn(from.year, from.month + 1);
}
