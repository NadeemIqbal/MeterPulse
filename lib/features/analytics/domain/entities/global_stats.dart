import 'package:equatable/equatable.dart';

import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../meters/domain/entities/meter_type.dart';

/// Consumption attributed to one calendar month, summed across every meter of
/// the selected type.
class MonthlyUsage extends Equatable {
  const MonthlyUsage({required this.month, required this.units});

  /// First day of the month the usage falls in.
  final DateTime month;
  final double units;

  @override
  List<Object?> get props => [month, units];
}

/// Portfolio-wide analytics for a single [MeterType].
///
/// Scoped to one type on purpose: `Meter.unit` is free-form, so summing
/// kWh with m³ would produce a meaningless total.
class GlobalStats extends Equatable {
  const GlobalStats({
    required this.type,
    required this.unit,
    required this.meterCount,
    required this.readingCount,
    required this.totalUnits,
    this.averageMonthlyUnits,
    this.peakMonthlyUnits,
    this.peakMonth,
    this.previousPeriodChangePercent,
    this.paceForecast,
    this.currentCycleUnits,
    this.targetLimit,
    this.monthlyUsage = const [],
  });

  const GlobalStats.empty(this.type)
      : unit = '',
        meterCount = 0,
        readingCount = 0,
        totalUnits = 0,
        averageMonthlyUnits = null,
        peakMonthlyUnits = null,
        peakMonth = null,
        previousPeriodChangePercent = null,
        paceForecast = null,
        currentCycleUnits = null,
        targetLimit = null,
        monthlyUsage = const [];

  final MeterType type;

  /// Display unit shared by the meters of this type (e.g. "kWh").
  final String unit;

  final int meterCount;
  final int readingCount;

  /// All consumption ever recorded for meters of this type.
  final double totalUnits;

  /// Mean consumption across the months that have data.
  final double? averageMonthlyUnits;

  /// The single heaviest month, and when it was.
  final double? peakMonthlyUnits;
  final DateTime? peakMonth;

  /// Change from the previous complete month to the one before it. Negative
  /// means consumption fell.
  final double? previousPeriodChangePercent;

  /// Aggregate pace for the current month across all meters of this type.
  final PaceForecast? paceForecast;
  final double? currentCycleUnits;

  /// Summed thresholds of the contributing meters, when all of them set one.
  final double? targetLimit;

  /// Oldest month first, ready for the bar chart.
  final List<MonthlyUsage> monthlyUsage;

  bool get hasData => readingCount > 0 && monthlyUsage.isNotEmpty;

  @override
  List<Object?> get props => [
        type,
        unit,
        meterCount,
        readingCount,
        totalUnits,
        averageMonthlyUnits,
        peakMonthlyUnits,
        peakMonth,
        previousPeriodChangePercent,
        paceForecast,
        currentCycleUnits,
        targetLimit,
        monthlyUsage,
      ];
}
