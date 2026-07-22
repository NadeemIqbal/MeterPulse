import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/meter.dart';
import '../../domain/repositories/meter_repository.dart';

enum MeterListStatus { loading, loaded, error }

class MeterListState extends Equatable {
  const MeterListState({
    this.status = MeterListStatus.loading,
    this.meters = const [],
    this.error,
  });

  final MeterListStatus status;
  final List<Meter> meters;
  final String? error;

  bool get isEmpty => status == MeterListStatus.loaded && meters.isEmpty;

  MeterListState copyWith({
    MeterListStatus? status,
    List<Meter>? meters,
    String? error,
  }) {
    return MeterListState(
      status: status ?? this.status,
      meters: meters ?? this.meters,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, meters, error];
}

/// Loads every meter (active and inactive) for the meter-management screen and
/// handles activate/deactivate and delete, reloading after each mutation.
class MeterListCubit extends Cubit<MeterListState> {
  MeterListCubit(this._repo) : super(const MeterListState());

  final MeterRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: MeterListStatus.loading));
    final result = await guard(() => _repo.getMeters(includeInactive: true));
    switch (result) {
      case Ok(:final value):
        emit(MeterListState(status: MeterListStatus.loaded, meters: value));
      case Err(:final failure):
        emit(MeterListState(
          status: MeterListStatus.error,
          error: failure.message,
        ));
    }
  }

  Future<void> toggleActive(Meter meter) async {
    if (meter.id == null) return;
    await guard(() => _repo.setActive(meter.id!, isActive: !meter.isActive));
    await load();
  }

  Future<void> delete(int id) async {
    await guard(() => _repo.deleteMeter(id));
    await load();
  }
}
