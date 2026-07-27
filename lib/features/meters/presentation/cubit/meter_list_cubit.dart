import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/error/result.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../readings/domain/repositories/reading_repository.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/meter_list_item.dart';
import '../../domain/repositories/meter_repository.dart';

enum MeterListStatus { loading, loaded, error }

class MeterListState extends Equatable {
  const MeterListState({
    this.status = MeterListStatus.loading,
    this.items = const [],
    this.query = '',
    this.error,
  });

  final MeterListStatus status;
  final List<MeterListItem> items;

  /// Free-text search over meter name, type and meter number.
  final String query;
  final String? error;

  /// Every meter, regardless of the search box.
  int get totalCount => items.length;

  List<MeterListItem> get visibleItems {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((item) {
      final meter = item.meter;
      return meter.name.toLowerCase().contains(q) ||
          meter.type.name.toLowerCase().contains(q) ||
          (meter.meterNumber?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  bool get isEmpty => status == MeterListStatus.loaded && items.isEmpty;

  /// True when meters exist but the current query hides them all.
  bool get isFilteredEmpty =>
      status == MeterListStatus.loaded && items.isNotEmpty && visibleItems.isEmpty;

  MeterListState copyWith({
    MeterListStatus? status,
    List<MeterListItem>? items,
    String? query,
    String? error,
  }) {
    return MeterListState(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, query, error];
}

/// Loads every meter (active and inactive) with its latest reading and
/// current-cycle usage for the manage-meters screen, and handles
/// activate/deactivate and delete.
class MeterListCubit extends Cubit<MeterListState> {
  MeterListCubit({
    required MeterRepository meterRepository,
    required ReadingRepository readingRepository,
    required BillingCycleRepository cycleRepository,
  })  : _meters = meterRepository,
        _readings = readingRepository,
        _cycles = cycleRepository,
        super(const MeterListState());

  final MeterRepository _meters;
  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;

  Future<void> load() async {
    emit(state.copyWith(status: MeterListStatus.loading));

    final result = await guard(() async {
      final meters = await _meters.getMeters(includeInactive: true);
      return [for (final meter in meters) await _buildItem(meter)];
    });

    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(status: MeterListStatus.loaded, items: value));
      case Err(:final failure):
        emit(
          state.copyWith(
            status: MeterListStatus.error,
            error: failure.message,
          ),
        );
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  Future<void> toggleActive(Meter meter) async {
    if (meter.id == null) return;
    await guard(() => _meters.setActive(meter.id!, isActive: !meter.isActive));
    await load();
  }

  Future<void> delete(int id) async {
    await guard(() => _meters.deleteMeter(id));
    await load();
  }

  Future<MeterListItem> _buildItem(Meter meter) async {
    if (meter.id == null) return MeterListItem(meter: meter);

    final latest = await _readings.getLatestReading(meter.id!);
    final cycle = await _cycles.getOpenCycle(meter.id!);
    final cycleReadings =
        cycle?.id == null ? const [] : await _readings.getReadingsForCycle(cycle!.id!);

    // Usage this cycle is the run from the cycle's baseline to its newest
    // reading; a single reading means the cycle has only just started.
    double? unitsThisCycle;
    if (cycleReadings.length >= 2) {
      unitsThisCycle = unitsConsumed(
        cycleReadings.last.readingValue,
        cycleReadings.first.readingValue,
        rolloverMax: meter.rolloverValue,
      ).units;
    } else if (cycleReadings.length == 1) {
      unitsThisCycle = 0;
    }

    return MeterListItem(
      meter: meter,
      latestReading: latest,
      unitsThisCycle: unitsThisCycle,
      threshold: meter.highUsageThreshold ?? meter.expectedMonthlyUnits,
    );
  }
}
