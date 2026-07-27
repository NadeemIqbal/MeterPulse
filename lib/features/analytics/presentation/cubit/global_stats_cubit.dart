import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../meters/domain/entities/meter_type.dart';
import '../../../meters/domain/repositories/meter_repository.dart';
import '../../../readings/domain/repositories/reading_repository.dart';
import '../../domain/entities/global_stats.dart';
import '../../domain/usecases/compute_global_stats.dart';

enum GlobalStatsStatus { loading, loaded, error }

class GlobalStatsState extends Equatable {
  const GlobalStatsState({
    this.status = GlobalStatsStatus.loading,
    this.stats,
    this.availableTypes = const [],
    this.selectedType,
    this.error,
  });

  final GlobalStatsStatus status;
  final GlobalStats? stats;

  /// Meter types the user actually has, in a stable order.
  final List<MeterType> availableTypes;
  final MeterType? selectedType;
  final String? error;

  bool get hasMeters => availableTypes.isNotEmpty;

  GlobalStatsState copyWith({
    GlobalStatsStatus? status,
    GlobalStats? stats,
    List<MeterType>? availableTypes,
    MeterType? selectedType,
    String? error,
  }) {
    return GlobalStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      availableTypes: availableTypes ?? this.availableTypes,
      selectedType: selectedType ?? this.selectedType,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, stats, availableTypes, selectedType, error];
}

/// Loads every meter's full reading history and aggregates it per meter type.
///
/// Readings are cached in memory for the screen's lifetime so switching the
/// type selector re-aggregates without re-querying.
class GlobalStatsCubit extends Cubit<GlobalStatsState> {
  GlobalStatsCubit({
    required MeterRepository meterRepository,
    required ReadingRepository readingRepository,
    required ComputeGlobalStats compute,
  })  : _meters = meterRepository,
        _readings = readingRepository,
        _compute = compute,
        super(const GlobalStatsState());

  final MeterRepository _meters;
  final ReadingRepository _readings;
  final ComputeGlobalStats _compute;

  List<MeterReadings> _cache = const [];

  Future<void> load({MeterType? type}) async {
    emit(state.copyWith(status: GlobalStatsStatus.loading));

    final result = await guard(() async {
      final meters = await _meters.getMeters();
      return [
        for (final meter in meters)
          (
            meter: meter,
            // The repository returns newest first; the aggregation walks
            // consecutive pairs forwards, so flip to oldest first.
            readings: (await _readings.getReadingsForMeter(meter.id!))
                .reversed
                .toList(),
          ),
      ];
    });

    switch (result) {
      case Ok(:final value):
        _cache = value;
        final types = _typesIn(value);
        final selected = type ?? state.selectedType;
        final active = types.contains(selected)
            ? selected!
            : (types.isEmpty ? MeterType.electricity : types.first);

        emit(
          GlobalStatsState(
            status: GlobalStatsStatus.loaded,
            stats: _aggregate(active),
            availableTypes: types,
            selectedType: active,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: GlobalStatsStatus.error,
            error: failure.message,
          ),
        );
    }
  }

  void selectType(MeterType type) {
    if (type == state.selectedType) return;
    emit(state.copyWith(selectedType: type, stats: _aggregate(type)));
  }

  GlobalStats _aggregate(MeterType type) => _compute(
        type: type,
        meterReadings: _cache,
        now: DateTime.now(),
      );

  /// Preserves MeterType declaration order so the selector doesn't reshuffle.
  List<MeterType> _typesIn(List<MeterReadings> data) {
    final present = data.map((e) => e.meter.type).toSet();
    return MeterType.values.where(present.contains).toList();
  }
}
