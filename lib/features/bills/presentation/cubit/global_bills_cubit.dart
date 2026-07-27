import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/domain/repositories/meter_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/bills_overview.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../domain/usecases/compute_bills_overview.dart';
import '../../domain/usecases/delete_bill.dart';

enum GlobalBillsStatus { loading, loaded, error }

class GlobalBillsState extends Equatable {
  const GlobalBillsState({
    this.status = GlobalBillsStatus.loading,
    this.overview = const BillsOverview.empty(),
    this.archived = const [],
    this.filter = BillFilter.all,
    this.currencySymbol = 'PKR',
    this.error,
  });

  final GlobalBillsStatus status;
  final BillsOverview overview;

  /// Archived bills, loaded alongside so switching chips needs no round trip.
  final List<BillListItem> archived;
  final BillFilter filter;
  final String currencySymbol;
  final String? error;

  /// The rows to render for the selected chip.
  List<BillListItem> get visibleItems => switch (filter) {
        BillFilter.all => overview.items,
        BillFilter.unpaid => overview.items
            .where((i) => i.status != BillPaymentStatus.paid)
            .toList(),
        BillFilter.archived => archived,
      };

  bool get isEmpty =>
      status == GlobalBillsStatus.loaded && visibleItems.isEmpty;

  GlobalBillsState copyWith({
    GlobalBillsStatus? status,
    BillsOverview? overview,
    List<BillListItem>? archived,
    BillFilter? filter,
    String? currencySymbol,
    String? error,
  }) {
    return GlobalBillsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      archived: archived ?? this.archived,
      filter: filter ?? this.filter,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, overview, archived, filter, currencySymbol, error];
}

/// Loads every meter's bills, joins them to their meters and derives the
/// outstanding totals for the global bills screen.
class GlobalBillsCubit extends Cubit<GlobalBillsState> {
  GlobalBillsCubit({
    required BillRepository billRepository,
    required MeterRepository meterRepository,
    required SettingsRepository settingsRepository,
    required ComputeBillsOverview compute,
    required DeleteBill deleteBill,
  })  : _bills = billRepository,
        _meters = meterRepository,
        _settings = settingsRepository,
        _compute = compute,
        _deleteBill = deleteBill,
        super(const GlobalBillsState());

  final BillRepository _bills;
  final MeterRepository _meters;
  final SettingsRepository _settings;
  final ComputeBillsOverview _compute;
  final DeleteBill _deleteBill;

  Future<void> load() async {
    emit(state.copyWith(status: GlobalBillsStatus.loading));

    final result = await guard(() async {
      final bills = await _bills.getAllBills();
      final meters = await _meters.getMeters(includeInactive: true);
      final settings = await _settings.getSettings();
      return (bills: bills, meters: meters, settings: settings);
    });

    switch (result) {
      case Ok(:final value):
        final overview = _compute(bills: value.bills, meters: value.meters);
        emit(
          state.copyWith(
            status: GlobalBillsStatus.loaded,
            overview: overview,
            archived: _archivedItems(value.bills, value.meters),
            currencySymbol: value.settings.currencySymbol,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: GlobalBillsStatus.error,
            error: failure.message,
          ),
        );
    }
  }

  void setFilter(BillFilter filter) => emit(state.copyWith(filter: filter));

  Future<void> setPaid(int id, {required bool isPaid}) async {
    await guard(() => _bills.setPaid(id, isPaid: isPaid));
    await load();
  }

  Future<void> setArchived(int id, {required bool isArchived}) async {
    await guard(() => _bills.setArchived(id, isArchived: isArchived));
    await load();
  }

  /// Removes the bill and the reading it created (see [DeleteBill]).
  Future<void> delete(int id) async {
    await _deleteBill(id);
    await load();
  }

  /// Archived bills carry no due-date urgency, so they skip the overview maths
  /// and are joined to their meters directly.
  List<BillListItem> _archivedItems(List<Bill> bills, List<Meter> meters) {
    final metersById = {
      for (final meter in meters)
        if (meter.id != null) meter.id!: meter,
    };

    return [
      for (final bill in bills)
        if (bill.isArchived)
          BillListItem(
            bill: bill,
            meter: metersById[bill.meterId],
            status: bill.isPaid
                ? BillPaymentStatus.paid
                : BillPaymentStatus.unpaid,
          ),
    ];
  }
}
