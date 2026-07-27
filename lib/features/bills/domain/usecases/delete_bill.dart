import '../../../../core/error/result.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../readings/domain/repositories/reading_repository.dart';
import '../repositories/bill_repository.dart';

/// Deletes a bill together with the reading it owns.
///
/// A bill auto-creates one reading from its `meterReading` and tracks it via
/// `readingId`. Deleting only the bill row left that reading behind as an
/// orphan, still showing in the meter's history with the bill's value and still
/// skewing consumption — so removing the bill has to remove its reading too.
///
/// Readings the user captured themselves are never touched: a bill only ever
/// claims a reading it created, so `readingId` is safe to delete outright.
class DeleteBill {
  const DeleteBill(this._bills, this._readings, this._cycles);

  final BillRepository _bills;
  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;

  Future<Result<void>> call(int billId) {
    return guard(() async {
      // Read the bill before deleting it — afterwards there is no way to find
      // which reading it owned.
      final bill = await _bills.getBill(billId);
      final readingId = bill?.readingId;
      final meterId = bill?.meterId;

      await _bills.deleteBill(billId);
      if (readingId == null || meterId == null) return;

      await _readings.deleteReading(readingId);
      await _repointCycles(meterId, readingId);
    });
  }

  /// Moves any cycle that referenced [removedReadingId] onto a reading it still
  /// holds, so `startReadingId`/`endReadingId` never point at a deleted row.
  Future<void> _repointCycles(int meterId, int removedReadingId) async {
    final cycles = await _cycles.getCyclesForMeter(meterId);
    for (final cycle in cycles) {
      if (cycle.id == null) continue;
      final startGone = cycle.startReadingId == removedReadingId;
      final endGone = cycle.endReadingId == removedReadingId;
      if (!startGone && !endGone) continue;

      final remaining = await _readings.getReadingsForCycle(cycle.id!);
      if (remaining.isEmpty) continue;

      await _cycles.saveCycle(
        cycle.copyWith(
          startReadingId: startGone ? remaining.first.id : null,
          cycleStartDate: startGone ? remaining.first.readingDate : null,
          endReadingId: endGone ? remaining.last.id : null,
        ),
      );
    }
  }
}
