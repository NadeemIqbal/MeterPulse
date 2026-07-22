import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/calculation_engine/date_math.dart';
import '../../../../core/calculation_engine/models/cycle_consumption.dart';
import '../../../../core/error/result.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../domain/entities/consumption_timeline.dart';
import '../../domain/entities/meter_stats.dart';
import '../../domain/repositories/reading_repository.dart';

enum HistoryStatus { loading, loaded, error }

class ReadingHistoryState extends Equatable {
  const ReadingHistoryState({
    this.status = HistoryStatus.loading,
    this.timelines = const [],
    this.stats = const MeterStats.empty(),
    this.error,
  });

  final HistoryStatus status;
  final List<CycleTimeline> timelines;
  final MeterStats stats;
  final String? error;

  bool get isEmpty =>
      status == HistoryStatus.loaded && stats.readingCount == 0;

  @override
  List<Object?> get props => [status, timelines, stats, error];
}

/// Loads a meter's full reading history, grouped into per-cycle timelines with
/// computed per-reading deltas, plus aggregate [MeterStats]. Backs both the
/// History and Statistics screens.
class ReadingHistoryCubit extends Cubit<ReadingHistoryState> {
  ReadingHistoryCubit(this._readings, this._cycles)
      : super(const ReadingHistoryState());

  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;

  Future<void> load(Meter meter) async {
    emit(const ReadingHistoryState(status: HistoryStatus.loading));
    final result = await guard(() => _build(meter));
    switch (result) {
      case Ok(:final value):
        emit(value);
      case Err(:final failure):
        emit(ReadingHistoryState(
          status: HistoryStatus.error,
          error: failure.message,
        ));
    }
  }

  Future<ReadingHistoryState> _build(Meter meter) async {
    final meterId = meter.id!;
    final cycles = await _cycles.getCyclesForMeter(meterId);
    final rolloverMax = meter.rolloverValue;

    final timelines = <CycleTimeline>[];
    final cycleConsumptions = <CycleConsumption>[];
    var totalUnits = 0.0;

    for (final cycle in cycles) {
      final readings = await _readings.getReadingsForCycle(cycle.id!);
      final entries = <TimelineEntry>[];
      for (var i = 0; i < readings.length; i++) {
        double? delta;
        if (i > 0) {
          delta = unitsConsumed(
            readings[i].readingValue,
            readings[i - 1].readingValue,
            rolloverMax: rolloverMax,
          ).units;
        }
        entries.add(TimelineEntry(
          reading: readings[i],
          consumedSincePrevious: delta,
        ));
      }

      double? cycleTotal;
      if (readings.length >= 2) {
        cycleTotal = unitsConsumed(
          readings.last.readingValue,
          readings.first.readingValue,
          rolloverMax: rolloverMax,
        ).units;
        if (cycleTotal != null) {
          totalUnits += cycleTotal;
          final days = daysBetween(
            readings.first.readingDate,
            readings.last.readingDate,
          );
          if (days > 0) {
            cycleConsumptions
                .add(CycleConsumption(totalUnits: cycleTotal, days: days));
          }
        }
      }

      timelines.add(CycleTimeline(
        cycle: cycle,
        entries: entries,
        totalUnits: cycleTotal,
      ));
    }

    final allReadings = await _readings.getReadingsForMeter(meterId);
    final values = allReadings.map((r) => r.readingValue).toList();

    final stats = MeterStats(
      highestReading: highestReading(values),
      lowestReading: lowestReading(values),
      totalUnits: totalUnits,
      averageMonthly: averageMonthlyConsumption(cycleConsumptions),
      averageYearly: averageYearlyConsumption(cycleConsumptions),
      cycleCount: cycles.length,
      readingCount: allReadings.length,
    );

    return ReadingHistoryState(
      status: HistoryStatus.loaded,
      timelines: timelines,
      stats: stats,
    );
  }
}
