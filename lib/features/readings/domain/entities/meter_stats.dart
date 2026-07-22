import 'package:equatable/equatable.dart';

/// Aggregate statistics for a meter across all its readings/cycles, shown on
/// the Statistics screen. Computed by the history cubit via the calculation
/// engine.
class MeterStats extends Equatable {
  const MeterStats({
    this.highestReading,
    this.lowestReading,
    required this.totalUnits,
    this.averageMonthly,
    this.averageYearly,
    required this.cycleCount,
    required this.readingCount,
  });

  const MeterStats.empty()
      : highestReading = null,
        lowestReading = null,
        totalUnits = 0,
        averageMonthly = null,
        averageYearly = null,
        cycleCount = 0,
        readingCount = 0;

  final double? highestReading;
  final double? lowestReading;
  final double totalUnits;
  final double? averageMonthly;
  final double? averageYearly;
  final int cycleCount;
  final int readingCount;

  @override
  List<Object?> get props => [
        highestReading,
        lowestReading,
        totalUnits,
        averageMonthly,
        averageYearly,
        cycleCount,
        readingCount,
      ];
}
