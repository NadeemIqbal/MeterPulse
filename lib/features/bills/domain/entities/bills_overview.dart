import 'package:equatable/equatable.dart';

import '../../../meters/domain/entities/meter.dart';
import 'bill.dart';

/// Payment state of a single bill, as shown on the bills list chip.
///
/// Distinct from the dashboard's `BillStatus`, which describes a *meter's*
/// standing based only on its latest bill.
enum BillPaymentStatus { paid, unpaid, overdue }

/// Which slice of the bills list is on screen.
enum BillFilter { all, unpaid, archived }

/// One row of the global bills list: a bill joined to its meter, with the
/// payment status already derived so the widget layer only formats.
class BillListItem extends Equatable {
  const BillListItem({
    required this.bill,
    required this.meter,
    required this.status,
    this.daysUntilDue,
  });

  final Bill bill;

  /// Null when the bill's meter has been deleted underneath it.
  final Meter? meter;
  final BillPaymentStatus status;

  /// Negative means the due date has passed. Null when the bill has no due date.
  final int? daysUntilDue;

  String get meterName => meter?.name ?? 'Unknown meter';

  @override
  List<Object?> get props => [bill, meter, status, daysUntilDue];
}

/// Everything the global bills screen needs, precomputed by
/// [ComputeBillsOverview].
class BillsOverview extends Equatable {
  const BillsOverview({
    required this.items,
    required this.totalOutstanding,
    this.nextDue,
    required this.unpaidCount,
    required this.overdueCount,
  });

  const BillsOverview.empty()
      : items = const [],
        totalOutstanding = 0,
        nextDue = null,
        unpaidCount = 0,
        overdueCount = 0;

  /// All non-archived bills, newest first. Filtering happens in the cubit so
  /// the counts above stay stable as the user switches chips.
  final List<BillListItem> items;

  /// Sum of every unpaid, non-archived bill.
  final double totalOutstanding;

  /// The soonest-due unpaid bill, or null when nothing is outstanding.
  final BillListItem? nextDue;

  final int unpaidCount;
  final int overdueCount;

  bool get hasOutstanding => totalOutstanding > 0;

  @override
  List<Object?> get props => [
        items,
        totalOutstanding,
        nextDue,
        unpaidCount,
        overdueCount,
      ];
}
