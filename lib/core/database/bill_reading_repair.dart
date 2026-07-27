import '../../features/billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../features/bills/domain/entities/bill.dart';
import '../../features/bills/domain/repositories/bill_repository.dart';
import '../../features/readings/domain/entities/reading.dart';
import '../../features/readings/domain/repositories/reading_repository.dart';

/// Marker written into the `notes` of a reading created from a bill. It is the
/// only way to recognise rows created before `Bill.readingId` existed.
const String billReadingMarker = 'Bill reading for ';

/// What a [BillReadingRepair] run changed. Reported rather than logged silently
/// so a caller can surface it and so the run is verifiable in tests.
class BillReadingRepairReport {
  const BillReadingRepairReport({
    this.billsLinked = 0,
    this.meterReadingsBackfilled = 0,
    this.orphanReadingsRemoved = 0,
    this.cyclePointersRepaired = 0,
  });

  final int billsLinked;
  final int meterReadingsBackfilled;
  final int orphanReadingsRemoved;
  final int cyclePointersRepaired;

  bool get changedAnything =>
      billsLinked > 0 ||
      meterReadingsBackfilled > 0 ||
      orphanReadingsRemoved > 0 ||
      cyclePointersRepaired > 0;

  @override
  String toString() => 'BillReadingRepairReport(linked: $billsLinked, '
      'backfilled: $meterReadingsBackfilled, '
      'orphansRemoved: $orphanReadingsRemoved, '
      'cyclesRepaired: $cyclePointersRepaired)';
}

/// One-time repair of bill/reading consistency, safe to run on every startup.
///
/// Bills used to create readings without keeping a reference to them, so editing
/// a bill's date inserted a second reading and abandoned the first. Two rows then
/// carried the same value and consumption between them computed as zero. This
/// reconciles the historical damage:
///
///  1. Backfills `Bill.meterReading` from `unitsBilled` *only* where the stored
///     figure is unambiguously an absolute meter total.
///  2. Links each bill to the reading it created, populating `readingId`.
///  3. Deletes bill-created readings that no bill claims.
///  4. Repoints billing cycles whose baseline reading was removed.
///
/// Every step is idempotent: a second run over repaired data changes nothing.
class BillReadingRepair {
  const BillReadingRepair(this._bills, this._readings, this._cycles);

  final BillRepository _bills;
  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;

  Future<BillReadingRepairReport> run() async {
    final allBills = await _bills.getAllBills();
    if (allBills.isEmpty) return const BillReadingRepairReport();

    final byMeter = <int, List<Bill>>{};
    for (final bill in allBills) {
      byMeter.putIfAbsent(bill.meterId, () => []).add(bill);
    }

    var linked = 0;
    var backfilled = 0;
    var removed = 0;
    var cyclesFixed = 0;

    for (final entry in byMeter.entries) {
      final result = await _repairMeter(entry.key, entry.value);
      linked += result.billsLinked;
      backfilled += result.meterReadingsBackfilled;
      removed += result.orphanReadingsRemoved;
      cyclesFixed += result.cyclePointersRepaired;
    }

    return BillReadingRepairReport(
      billsLinked: linked,
      meterReadingsBackfilled: backfilled,
      orphanReadingsRemoved: removed,
      cyclePointersRepaired: cyclesFixed,
    );
  }

  Future<BillReadingRepairReport> _repairMeter(
    int meterId,
    List<Bill> bills,
  ) async {
    final readings = await _readings.getReadingsForMeter(meterId);
    if (readings.isEmpty) return const BillReadingRepairReport();

    final billCreated = readings.where(_isBillCreated).toList();
    // Readings the user captured themselves establish what an absolute meter
    // total looks like for this meter.
    final userCaptured =
        readings.where((r) => !_isBillCreated(r)).map((r) => r.readingValue);
    final minUserReading = userCaptured.isEmpty
        ? null
        : userCaptured.reduce((a, b) => a < b ? a : b);

    var linked = 0;
    var backfilled = 0;
    final claimed = <int>{};

    // Oldest bill first, so an older bill cannot steal a newer bill's reading.
    final ordered = [...bills]..sort((a, b) => a.billDate.compareTo(b.billDate));

    for (final bill in ordered) {
      var updated = bill;
      var dirty = false;

      // 1. Backfill meterReading, but only when it is not a judgement call.
      // A bill's opening reading is the previous cycle's total, so it sits just
      // *below* the meter's current value — an exact `>=` test would never hold.
      // What separates the two meanings is magnitude: a meter total is within
      // the same order as real readings, while billed consumption is orders
      // smaller (56 against 20970). Half the smallest real reading splits them
      // with room to spare. Anything below that is consumption, and promoting it
      // would write a bogus opening reading into a real record — so it is left
      // for the user rather than guessed at.
      if (updated.meterReading == null &&
          updated.unitsBilled != null &&
          minUserReading != null &&
          updated.unitsBilled! >= minUserReading * 0.5) {
        updated = updated.copyWith(meterReading: updated.unitsBilled);
        dirty = true;
        backfilled++;
      }

      // 2. Adopt the reading this bill created, matched on its exact date.
      if (updated.readingId == null) {
        final match = billCreated
            .where((r) =>
                r.id != null &&
                !claimed.contains(r.id) &&
                _sameDay(r.readingDate, updated.billDate))
            .firstOrNull;
        if (match != null) {
          claimed.add(match.id!);
          updated = updated.copyWith(readingId: match.id);
          dirty = true;
          linked++;
        }
      } else {
        claimed.add(updated.readingId!);
      }

      if (dirty) await _bills.saveBill(updated);
    }

    // 3. Bill-created readings nobody claims are the abandoned duplicates.
    // Never strip a meter down to no readings at all.
    final orphans = billCreated
        .where((r) => r.id != null && !claimed.contains(r.id))
        .toList();
    var removed = 0;
    if (orphans.length < readings.length) {
      for (final orphan in orphans) {
        await _readings.deleteReading(orphan.id!);
        removed++;
      }
    }

    final cyclesFixed =
        removed == 0 ? 0 : await _repairCyclePointers(meterId, orphans);

    return BillReadingRepairReport(
      billsLinked: linked,
      meterReadingsBackfilled: backfilled,
      orphanReadingsRemoved: removed,
      cyclePointersRepaired: cyclesFixed,
    );
  }

  /// Repoints any cycle whose baseline was one of the [deleted] readings to the
  /// earliest reading it still holds, so `startReadingId` never dangles.
  Future<int> _repairCyclePointers(int meterId, List<Reading> deleted) async {
    final deletedIds = deleted.map((r) => r.id).whereType<int>().toSet();
    if (deletedIds.isEmpty) return 0;

    final cycles = await _cycles.getCyclesForMeter(meterId);
    var fixed = 0;

    for (final cycle in cycles) {
      if (cycle.id == null) continue;
      final startGone =
          cycle.startReadingId != null && deletedIds.contains(cycle.startReadingId);
      final endGone =
          cycle.endReadingId != null && deletedIds.contains(cycle.endReadingId);
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
      fixed++;
    }

    return fixed;
  }

  bool _isBillCreated(Reading r) =>
      r.notes != null && r.notes!.startsWith(billReadingMarker);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
