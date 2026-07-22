import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../bills/domain/repositories/bill_repository.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../meters/domain/repositories/meter_repository.dart';
import '../../../readings/domain/entities/reading.dart';
import '../../../readings/domain/repositories/reading_repository.dart';
import '../../domain/entities/meter_summary.dart';
import '../../domain/usecases/compute_meter_summary.dart';

enum DashboardStatus { loading, loaded, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.summaries = const [],
    this.error,
  });

  final DashboardStatus status;
  final List<MeterSummary> summaries;
  final String? error;

  bool get isEmpty =>
      status == DashboardStatus.loaded && summaries.isEmpty;

  /// Total units used across all active meters this cycle.
  double get totalUnitsUsed =>
      summaries.fold(0, (sum, s) => sum + (s.unitsUsed ?? 0));

  MeterSummary? get highestConsumer => summaries.isEmpty
      ? null
      : summaries.reduce((a, b) => (a.unitsUsed ?? 0) >= (b.unitsUsed ?? 0) ? a : b);

  MeterSummary? get lowestConsumer => summaries.isEmpty
      ? null
      : summaries.reduce((a, b) => (a.unitsUsed ?? 0) <= (b.unitsUsed ?? 0) ? a : b);

  @override
  List<Object?> get props => [status, summaries, error];
}

/// Loads active meters and builds a [MeterSummary] for each by pulling the open
/// cycle, its readings and the latest bill, then delegating to
/// [ComputeMeterSummary]. Reloaded whenever the dashboard is (re)shown so
/// "days remaining"/status recompute against the current date.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required MeterRepository meterRepository,
    required ReadingRepository readingRepository,
    required BillingCycleRepository cycleRepository,
    required BillRepository billRepository,
    ComputeMeterSummary compute = const ComputeMeterSummary(),
  })  : _meters = meterRepository,
        _readings = readingRepository,
        _cycles = cycleRepository,
        _bills = billRepository,
        _compute = compute,
        super(const DashboardState());

  final MeterRepository _meters;
  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;
  final BillRepository _bills;
  final ComputeMeterSummary _compute;

  Future<void> load() async {
    emit(const DashboardState(status: DashboardStatus.loading));
    final result = await guard(_buildSummaries);
    switch (result) {
      case Ok(:final value):
        emit(DashboardState(status: DashboardStatus.loaded, summaries: value));
      case Err(:final failure):
        emit(DashboardState(
          status: DashboardStatus.error,
          error: failure.message,
        ));
    }
  }

  Future<List<MeterSummary>> _buildSummaries() async {
    final meters = await _meters.getMeters();
    final now = DateTime.now();
    final summaries = <MeterSummary>[];
    for (final meter in meters) {
      final cycle = await _cycles.getOpenCycle(meter.id!);
      final cycleReadings = cycle == null
          ? const <Reading>[]
          : await _readings.getReadingsForCycle(cycle.id!);
      final latestBill = await _bills.getLatestBill(meter.id!);
      summaries.add(
        _compute(
          meter: meter,
          cycle: cycle,
          cycleReadings: cycleReadings,
          latestBill: latestBill,
          now: now,
        ),
      );
    }
    return summaries;
  }
}
