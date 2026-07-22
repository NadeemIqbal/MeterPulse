import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/meter.dart';
import '../../domain/repositories/meter_repository.dart';

enum MeterFormStatus { editing, saving, success, error }

class MeterFormState extends Equatable {
  const MeterFormState({
    this.status = MeterFormStatus.editing,
    this.savedId,
    this.error,
  });

  final MeterFormStatus status;
  final int? savedId;
  final String? error;

  @override
  List<Object?> get props => [status, savedId, error];
}

/// Persists a meter from the add/edit form. The form widget owns the field
/// state and hands a fully-built [Meter] to [save]; this cubit only reports the
/// save outcome.
class MeterFormCubit extends Cubit<MeterFormState> {
  MeterFormCubit(this._repo) : super(const MeterFormState());

  final MeterRepository _repo;

  Future<void> save(Meter meter) async {
    emit(const MeterFormState(status: MeterFormStatus.saving));
    final result = await guard(() => _repo.saveMeter(meter));
    switch (result) {
      case Ok(:final value):
        emit(MeterFormState(status: MeterFormStatus.success, savedId: value));
      case Err(:final failure):
        emit(MeterFormState(
          status: MeterFormStatus.error,
          error: failure.message,
        ));
    }
  }
}
