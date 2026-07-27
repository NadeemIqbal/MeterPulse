import 'package:equatable/equatable.dart';

/// Zone classification based on usage pace relative to a target threshold.
enum UsageZone {
  /// Projected end-of-cycle usage is safely below threshold (<= 80%).
  green,

  /// Projected end-of-cycle usage is approaching threshold (80% - 100%).
  orange,

  /// Projected end-of-cycle usage exceeds threshold (> 100%) or already exceeded.
  red,
}

/// Pace forecast details for a meter during an active billing cycle.
class PaceForecast extends Equatable {
  const PaceForecast({
    required this.dailyRate,
    required this.projectedUnits,
    required this.zone,
    this.targetLimit,
    this.percentOfLimit,
    this.daysToCrossMax,
    this.dateToCrossMax,
  });

  /// Units consumed per day at current pace.
  final double dailyRate;

  /// Forecasted total units by the end of the cycle.
  final double projectedUnits;

  /// Usage status zone (green, orange, red).
  final UsageZone zone;

  /// Target or max usage threshold configured for the meter (e.g. highUsageThreshold).
  final double? targetLimit;

  /// Percentage of target limit projected by end of cycle (e.g., 85.0 for 85%).
  final double? percentOfLimit;

  /// Estimated number of days from current reading until target limit is crossed.
  /// `0` if already crossed, `null` if limit is null or won't be crossed within cycle.
  final int? daysToCrossMax;

  /// Estimated date when target limit will be crossed, or `null`.
  final DateTime? dateToCrossMax;

  /// Whether the forecast predicts exceeding the configured limit before or at cycle end.
  bool get isWillExceed => daysToCrossMax != null && zone == UsageZone.red;

  @override
  List<Object?> get props => [
        dailyRate,
        projectedUnits,
        zone,
        targetLimit,
        percentOfLimit,
        daysToCrossMax,
        dateToCrossMax,
      ];
}
