import '../../../core/calculation_engine/date_math.dart';
import '../../../core/utils/formatters.dart';
import '../../meters/domain/entities/meter.dart';
import '../../readings/domain/entities/reading.dart';
import 'entities/usage_alert.dart';

/// Detects rule-based usage alerts for a meter's current cycle. Pure and
/// deterministic (takes [now] rather than reading the clock), so it's easy to
/// reason about and could be unit-tested.
///
/// Rules:
///  1. **High usage** — units used this cycle already exceed the configured
///     threshold.
///  2. **On track to exceed** — the projected month-end exceeds the threshold.
///  3. **Usage spike** — the most recent day-rate is ≥50% above the cycle's
///     average day-rate (possible leak / heavy appliance use).
List<UsageAlert> detectUsageAlerts({
  required Meter meter,
  required List<Reading> cycleReadings,
  required double? unitsUsed,
  required double? projectedMonthEnd,
  required DateTime now,
}) {
  final alerts = <UsageAlert>[];
  final threshold = meter.highUsageThreshold;
  final unit = meter.unit;

  if (threshold != null) {
    if ((unitsUsed ?? 0) > threshold) {
      alerts.add(UsageAlert(
        severity: AlertSeverity.high,
        title: 'High usage',
        message: 'Used ${Formatters.units(unitsUsed)} $unit this cycle — over '
            'your ${Formatters.units(threshold)} $unit threshold.',
      ));
    } else if ((projectedMonthEnd ?? 0) > threshold) {
      alerts.add(UsageAlert(
        severity: AlertSeverity.warning,
        title: 'On track to exceed',
        message: 'Projected ${Formatters.units(projectedMonthEnd)} $unit by '
            'month end — above your ${Formatters.units(threshold)} $unit '
            'threshold.',
      ));
    }
  }

  final spike = _detectSpike(cycleReadings);
  if (spike != null) alerts.add(spike);

  return alerts;
}

/// Compares the most recent day-rate against the cycle average day-rate.
UsageAlert? _detectSpike(List<Reading> readings) {
  if (readings.length < 3) return null;
  final first = readings.first;
  final last = readings[readings.length - 1];
  final prev = readings[readings.length - 2];

  final totalDays = daysBetween(first.readingDate, last.readingDate);
  final recentDays = daysBetween(prev.readingDate, last.readingDate);
  if (totalDays <= 0 || recentDays <= 0) return null;

  final totalUnits = last.readingValue - first.readingValue;
  final recentUnits = last.readingValue - prev.readingValue;
  // Ignore rollover/anomalous drops.
  if (totalUnits <= 0 || recentUnits <= 0) return null;

  final avgRate = totalUnits / totalDays;
  final recentRate = recentUnits / recentDays;
  if (avgRate <= 0) return null;

  final ratio = recentRate / avgRate;
  if (ratio < 1.5) return null;

  final percent = ((ratio - 1) * 100).round();
  return UsageAlert(
    severity: AlertSeverity.warning,
    title: 'Usage spike',
    message: 'Recent usage is $percent% above this cycle\'s average — check '
        'for a leak or heavy appliance use.',
  );
}
