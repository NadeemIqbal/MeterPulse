import '../../../../core/calculation_engine/date_math.dart';
import '../../../meters/domain/entities/meter.dart';
import '../entities/bill.dart';
import '../entities/bills_overview.dart';

/// Rolls every meter's bills into the totals behind the global bills screen.
///
/// Archived bills are excluded from [BillsOverview.items] and from all totals;
/// the archived slice is loaded separately by the cubit.
class ComputeBillsOverview {
  const ComputeBillsOverview();

  BillsOverview call({
    required List<Bill> bills,
    required List<Meter> meters,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final metersById = {
      for (final meter in meters)
        if (meter.id != null) meter.id!: meter,
    };

    final items = <BillListItem>[];
    var totalOutstanding = 0.0;
    var unpaidCount = 0;
    var overdueCount = 0;
    BillListItem? nextDue;

    for (final bill in bills) {
      if (bill.isArchived) continue;

      final daysUntilDue = bill.dueDate == null
          ? null
          : daysUntil(bill.dueDate!, from: today);
      final status = _statusOf(bill, daysUntilDue);

      final item = BillListItem(
        bill: bill,
        meter: metersById[bill.meterId],
        status: status,
        daysUntilDue: daysUntilDue,
      );
      items.add(item);

      if (status == BillPaymentStatus.paid) continue;

      totalOutstanding += bill.billAmount;
      unpaidCount++;
      if (status == BillPaymentStatus.overdue) overdueCount++;
      if (_isSooner(item, than: nextDue)) nextDue = item;
    }

    return BillsOverview(
      items: items,
      totalOutstanding: totalOutstanding,
      nextDue: nextDue,
      unpaidCount: unpaidCount,
      overdueCount: overdueCount,
    );
  }

  BillPaymentStatus _statusOf(Bill bill, int? daysUntilDue) {
    if (bill.isPaid) return BillPaymentStatus.paid;
    if (daysUntilDue != null && daysUntilDue < 0) {
      return BillPaymentStatus.overdue;
    }
    return BillPaymentStatus.unpaid;
  }

  /// Orders unpaid bills by urgency. Bills without a due date never win, so a
  /// dateless bill can't mask a real deadline in the hero card.
  bool _isSooner(BillListItem candidate, {required BillListItem? than}) {
    if (candidate.daysUntilDue == null) return false;
    if (than?.daysUntilDue == null) return true;
    return candidate.daysUntilDue! < than!.daysUntilDue!;
  }
}
