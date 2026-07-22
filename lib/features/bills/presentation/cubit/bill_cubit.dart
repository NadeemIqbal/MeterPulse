import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';

enum BillListStatus { loading, loaded, error }

class BillListState extends Equatable {
  const BillListState({
    this.status = BillListStatus.loading,
    this.bills = const [],
    this.error,
  });

  final BillListStatus status;
  final List<Bill> bills;
  final String? error;

  bool get isEmpty => status == BillListStatus.loaded && bills.isEmpty;

  @override
  List<Object?> get props => [status, bills, error];
}

/// Lists a meter's bills and handles add / mark-paid / delete, reloading after
/// each change.
class BillCubit extends Cubit<BillListState> {
  BillCubit(this._repo) : super(const BillListState());

  final BillRepository _repo;

  late int _meterId;

  Future<void> load(int meterId) async {
    _meterId = meterId;
    emit(const BillListState(status: BillListStatus.loading));
    final result = await guard(() => _repo.getBillsForMeter(meterId));
    switch (result) {
      case Ok(:final value):
        emit(BillListState(status: BillListStatus.loaded, bills: value));
      case Err(:final failure):
        emit(BillListState(status: BillListStatus.error, error: failure.message));
    }
  }

  Future<void> saveBill(Bill bill) async {
    await guard(() => _repo.saveBill(bill));
    await load(_meterId);
  }

  Future<void> setPaid(int id, {required bool isPaid}) async {
    await guard(() => _repo.setPaid(id, isPaid: isPaid));
    await load(_meterId);
  }

  Future<void> delete(int id) async {
    await guard(() => _repo.deleteBill(id));
    await load(_meterId);
  }
}
