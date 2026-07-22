import '../../../../core/calculation_engine/date_math.dart';
import '../../../../core/error/result.dart';
import '../../../billing_cycles/domain/entities/billing_cycle.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../meters/domain/entities/meter.dart';
import '../entities/reading.dart';
import '../repositories/reading_repository.dart';

/// Saves a reading and keeps the meter's billing cycles consistent.
///
/// This is the *only* place cycle state mutates, and only in response to an
/// explicit user save (no background jobs). Three cases:
///  1. No open cycle yet → create the meter's first cycle; this reading is its
///     baseline.
///  2. [startNewCycle] true → close the current cycle at its latest reading,
///     then open a new cycle with this reading as the baseline.
///  3. Otherwise → attach the reading to the current cycle as a mid-cycle
///     check-in.
class AddReading {
  const AddReading(this._readings, this._cycles);

  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;

  /// Returns the saved reading's id.
  Future<Result<int>> call({
    required Reading reading,
    required Meter meter,
    bool startNewCycle = false,
  }) {
    return guard(() async {
      final meterId = meter.id!;
      final open = await _cycles.getOpenCycle(meterId);

      if (open == null) {
        return _openCycleWithBaseline(meter, reading);
      }

      if (startNewCycle) {
        await _closeCycle(open, meterId);
        return _openCycleWithBaseline(meter, reading);
      }

      // Mid-cycle reading.
      final id =
          await _readings.saveReading(reading.copyWith(billingCycleId: open.id));
      if (open.startReadingId == null) {
        await _cycles.saveCycle(open.copyWith(startReadingId: id));
      }
      return id;
    });
  }

  /// Creates a fresh open cycle for [meter] and saves [reading] as its baseline.
  Future<int> _openCycleWithBaseline(Meter meter, Reading reading) async {
    final cycle = BillingCycle(
      meterId: meter.id!,
      cycleStartDate: reading.readingDate,
      expectedReadingDate: nextReadingDate(
        meter.expectedReadingDayOfMonth,
        from: reading.readingDate,
      ),
      createdAt: DateTime.now(),
    );
    final cycleId = await _cycles.saveCycle(cycle);
    final readingId =
        await _readings.saveReading(reading.copyWith(billingCycleId: cycleId));
    await _cycles.saveCycle(cycle.copyWith(id: cycleId, startReadingId: readingId));
    return readingId;
  }

  /// Closes [open] using the meter's most recent existing reading as the end.
  Future<void> _closeCycle(BillingCycle open, int meterId) async {
    final latest = await _readings.getLatestReading(meterId);
    await _cycles.saveCycle(
      open.copyWith(
        isClosed: true,
        endReadingId: latest?.id,
        cycleEndDate: latest?.readingDate ?? DateTime.now(),
      ),
    );
  }
}
