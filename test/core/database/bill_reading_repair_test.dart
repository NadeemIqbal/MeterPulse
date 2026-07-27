import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/database/bill_reading_repair.dart';
import 'package:meter_pulse/features/billing_cycles/domain/entities/billing_cycle.dart';
import 'package:meter_pulse/features/billing_cycles/domain/repositories/billing_cycle_repository.dart';
import 'package:meter_pulse/features/bills/domain/entities/bill.dart';
import 'package:meter_pulse/features/bills/domain/repositories/bill_repository.dart';
import 'package:meter_pulse/features/readings/domain/entities/reading.dart';
import 'package:meter_pulse/features/readings/domain/repositories/reading_repository.dart';

/// In-memory [BillRepository]. Insertion-ordered; only the reads the repair
/// actually performs are meaningfully implemented.
class _FakeBills implements BillRepository {
  _FakeBills(List<Bill> seed) {
    for (final b in seed) {
      store[b.id!] = b;
    }
  }

  final Map<int, Bill> store = {};
  var saveCount = 0;

  @override
  Future<List<Bill>> getAllBills() async => store.values.toList();

  @override
  Future<List<Bill>> getBillsForMeter(int meterId) async =>
      store.values.where((b) => b.meterId == meterId).toList();

  @override
  Future<Bill?> getLatestBill(int meterId) async =>
      (await getBillsForMeter(meterId)).firstOrNull;

  @override
  Future<int> saveBill(Bill bill) async {
    saveCount++;
    final id = bill.id ?? (store.keys.fold(0, (m, k) => k > m ? k : m) + 1);
    store[id] = bill.copyWith(id: id);
    return id;
  }

  @override
  Future<void> deleteBill(int id) async => store.remove(id);

  @override
  Future<void> setPaid(int id, {required bool isPaid}) async {}

  @override
  Future<void> setArchived(int id, {required bool isArchived}) async {}
}

/// In-memory [ReadingRepository] preserving the real ordering contracts:
/// per-meter newest-first, per-cycle oldest-first.
class _FakeReadings implements ReadingRepository {
  _FakeReadings(List<Reading> seed) {
    for (final r in seed) {
      store[r.id!] = r;
    }
  }

  final Map<int, Reading> store = {};
  final List<int> deleted = [];

  @override
  Future<List<Reading>> getReadingsForMeter(int meterId) async {
    final list = store.values.where((r) => r.meterId == meterId).toList()
      ..sort((a, b) => b.readingDate.compareTo(a.readingDate));
    return list;
  }

  @override
  Future<List<Reading>> getReadingsForCycle(int cycleId) async {
    final list = store.values.where((r) => r.billingCycleId == cycleId).toList()
      ..sort((a, b) => a.readingDate.compareTo(b.readingDate));
    return list;
  }

  @override
  Future<Reading?> getLatestReading(int meterId) async =>
      (await getReadingsForMeter(meterId)).firstOrNull;

  @override
  Future<Reading?> getReading(int id) async => store[id];

  @override
  Future<int> saveReading(Reading reading) async {
    final id = reading.id ?? (store.keys.fold(0, (m, k) => k > m ? k : m) + 1);
    store[id] = reading.copyWith(id: id);
    return id;
  }

  @override
  Future<void> deleteReading(int id) async {
    deleted.add(id);
    store.remove(id);
  }
}

class _FakeCycles implements BillingCycleRepository {
  _FakeCycles([List<BillingCycle> seed = const []]) {
    for (final c in seed) {
      store[c.id!] = c;
    }
  }

  final Map<int, BillingCycle> store = {};

  @override
  Future<BillingCycle?> getOpenCycle(int meterId) async => store.values
      .where((c) => c.meterId == meterId && !c.isClosed)
      .firstOrNull;

  @override
  Future<List<BillingCycle>> getCyclesForMeter(int meterId) async =>
      store.values.where((c) => c.meterId == meterId).toList();

  @override
  Future<BillingCycle?> getCycle(int id) async => store[id];

  @override
  Future<int> saveCycle(BillingCycle cycle) async {
    final id = cycle.id ?? (store.keys.fold(0, (m, k) => k > m ? k : m) + 1);
    store[id] = cycle.copyWith(id: id);
    return id;
  }
}

Reading _billReading({
  required int id,
  required DateTime date,
  required double value,
  int? cycleId,
}) =>
    Reading(
      id: id,
      meterId: 1,
      billingCycleId: cycleId,
      readingValue: value,
      readingDate: date,
      notes: '${billReadingMarker}whenever',
      createdAt: date,
    );

Reading _userReading({
  required int id,
  required DateTime date,
  required double value,
  int? cycleId,
}) =>
    Reading(
      id: id,
      meterId: 1,
      billingCycleId: cycleId,
      readingValue: value,
      readingDate: date,
      createdAt: date,
    );

void main() {
  group('BillReadingRepair', () {
    test('removes the duplicate left behind when a bill date was edited', () async {
      // Reproduces the reported state: a bill first created a reading on 26 Jul,
      // then its date was changed to 15 Jul, which inserted a second reading
      // with the identical value and abandoned the first. Consumption between
      // two equal readings is zero, which is why no difference showed.
      final bills = _FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 20914,
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = _FakeReadings([
        _userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
        _billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914),
        _billReading(id: 201, date: DateTime(2026, 7, 15), value: 20914),
      ]);

      final report =
          await BillReadingRepair(bills, readings, _FakeCycles()).run();

      // The 15 Jul row matches the bill's date, so the bill adopts it and the
      // 26 Jul leftover goes.
      expect(bills.store[51]!.readingId, 201);
      expect(readings.deleted, [200]);
      expect(readings.store.containsKey(201), isTrue);
      expect(readings.store.containsKey(100), isTrue);
      expect(report.billsLinked, 1);
      expect(report.orphanReadingsRemoved, 1);
    });

    test('backfills meterReading when the stored figure is a meter total',
        () async {
      final bills = _FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 20914,
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = _FakeReadings([
        _userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
      ]);

      final report =
          await BillReadingRepair(bills, readings, _FakeCycles()).run();

      // 20914 sits in the same order of magnitude as the real reading 20970 —
      // just below it, as a previous-cycle total should be — so it is a meter
      // total and is safe to promote.
      expect(bills.store[51]!.meterReading, 20914);
      expect(report.meterReadingsBackfilled, 1);
    });

    test('refuses to guess when the stored figure looks like consumption',
        () async {
      final bills = _FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 56, // consumption, as the old field label asked for
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = _FakeReadings([
        _userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
      ]);

      final report =
          await BillReadingRepair(bills, readings, _FakeCycles()).run();

      // Promoting 56 to a meter total would write a bogus opening reading into
      // a real record, so it is left for the user to fill in.
      expect(bills.store[51]!.meterReading, isNull);
      expect(report.meterReadingsBackfilled, 0);
    });

    test('is idempotent — a second run over repaired data changes nothing',
        () async {
      final bills = _FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 20914,
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = _FakeReadings([
        _userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
        _billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914),
        _billReading(id: 201, date: DateTime(2026, 7, 15), value: 20914),
      ]);
      final repair = BillReadingRepair(bills, readings, _FakeCycles());

      await repair.run();
      final savesAfterFirst = bills.saveCount;
      final deletesAfterFirst = [...readings.deleted];

      final second = await repair.run();

      expect(second.changedAnything, isFalse);
      expect(bills.saveCount, savesAfterFirst);
      expect(readings.deleted, deletesAfterFirst);
    });

    test('never strips a meter down to no readings', () async {
      // A single unclaimed bill-created reading is all this meter has. Deleting
      // it would erase the meter's history to fix a cosmetic inconsistency.
      final bills = _FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = _FakeReadings([
        _billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914),
      ]);

      final report =
          await BillReadingRepair(bills, readings, _FakeCycles()).run();

      expect(readings.deleted, isEmpty);
      expect(report.orphanReadingsRemoved, 0);
    });

    test('repoints a cycle whose baseline reading was removed', () async {
      final bills = _FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      // Reading 200 is both an unclaimed leftover and the cycle's baseline, so
      // deleting it would leave startReadingId dangling.
      final readings = _FakeReadings([
        _billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914, cycleId: 11),
        _userReading(id: 100, date: DateTime(2026, 7, 27), value: 20970, cycleId: 11),
        _userReading(id: 101, date: DateTime(2026, 7, 28), value: 21000, cycleId: 11),
      ]);
      final cycles = _FakeCycles([
        BillingCycle(
          id: 11,
          meterId: 1,
          cycleStartDate: DateTime(2026, 7, 26),
          startReadingId: 200,
          createdAt: DateTime(2026, 7, 26),
        ),
      ]);

      final report = await BillReadingRepair(bills, readings, cycles).run();

      expect(readings.deleted, [200]);
      expect(cycles.store[11]!.startReadingId, 100);
      expect(cycles.store[11]!.cycleStartDate, DateTime(2026, 7, 27));
      expect(report.cyclePointersRepaired, 1);
    });
  });
}
