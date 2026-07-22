import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';

enum BillFormStatus { editing, saving, success, error }

class BillFormState extends Equatable {
  const BillFormState({this.status = BillFormStatus.editing, this.error});

  final BillFormStatus status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}

/// Persists a bill from the add/edit form and reports the outcome.
class BillFormCubit extends Cubit<BillFormState> {
  BillFormCubit(this._repo) : super(const BillFormState());

  final BillRepository _repo;

  Future<void> save(Bill bill) async {
    emit(const BillFormState(status: BillFormStatus.saving));
    final result = await guard(() => _repo.saveBill(bill));
    switch (result) {
      case Ok():
        emit(const BillFormState(status: BillFormStatus.success));
      case Err(:final failure):
        emit(BillFormState(status: BillFormStatus.error, error: failure.message));
    }
  }
}
