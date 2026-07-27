import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/database/bill_reading_repair.dart';
import 'package:meter_pulse/features/billing_cycles/domain/entities/billing_cycle.dart';
import 'package:meter_pulse/features/bills/domain/entities/bill.dart';

import '../../support/fake_repositories.dart';


/// All repair fixtures use a single meter with id 1.
FakeMeters metersFake() => FakeMeters([testMeterWithId(1)]);

void main() {
  group('BillReadingRepair', () {
    test('removes the duplicate left behind when a bill date was edited', () async {
      // Reproduces the reported state: a bill first created a reading on 26 Jul,
      // then its date was changed to 15 Jul, which inserted a second reading
      // with the identical value and abandoned the first. Consumption between
      // two equal readings is zero, which is why no difference showed.
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 20914,
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = FakeReadings([
        userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
        billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914),
        billReading(id: 201, date: DateTime(2026, 7, 15), value: 20914),
      ]);

      final report =
          await BillReadingRepair(bills, readings, FakeCycles(), metersFake()).run();

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
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 20914,
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = FakeReadings([
        userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
      ]);

      final report =
          await BillReadingRepair(bills, readings, FakeCycles(), metersFake()).run();

      // 20914 sits in the same order of magnitude as the real reading 20970 —
      // just below it, as a previous-cycle total should be — so it is a meter
      // total and is safe to promote.
      expect(bills.store[51]!.meterReading, 20914);
      expect(report.meterReadingsBackfilled, 1);
    });

    test('refuses to guess when the stored figure looks like consumption',
        () async {
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 56, // consumption, as the old field label asked for
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = FakeReadings([
        userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
      ]);

      final report =
          await BillReadingRepair(bills, readings, FakeCycles(), metersFake()).run();

      // Promoting 56 to a meter total would write a bogus opening reading into
      // a real record, so it is left for the user to fill in.
      expect(bills.store[51]!.meterReading, isNull);
      expect(report.meterReadingsBackfilled, 0);
    });

    test('is idempotent — a second run over repaired data changes nothing',
        () async {
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          unitsBilled: 20914,
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = FakeReadings([
        userReading(id: 100, date: DateTime(2026, 7, 25), value: 20970),
        billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914),
        billReading(id: 201, date: DateTime(2026, 7, 15), value: 20914),
      ]);
      final repair = BillReadingRepair(bills, readings, FakeCycles(), metersFake());

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
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 11183,
          billDate: DateTime(2026, 7, 15),
          createdAt: DateTime(2026, 7, 20),
        ),
      ]);
      final readings = FakeReadings([
        billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914),
      ]);

      final report =
          await BillReadingRepair(bills, readings, FakeCycles(), metersFake()).run();

      expect(readings.deleted, isEmpty);
      expect(report.orphanReadingsRemoved, 0);
    });

    test('repoints a cycle whose baseline reading was removed', () async {
      final bills = FakeBills([
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
      final readings = FakeReadings([
        billReading(id: 200, date: DateTime(2026, 7, 26), value: 20914, cycleId: 11),
        userReading(id: 100, date: DateTime(2026, 7, 27), value: 20970, cycleId: 11),
        userReading(id: 101, date: DateTime(2026, 7, 28), value: 21000, cycleId: 11),
      ]);
      final cycles = FakeCycles([
        BillingCycle(
          id: 11,
          meterId: 1,
          cycleStartDate: DateTime(2026, 7, 26),
          startReadingId: 200,
          createdAt: DateTime(2026, 7, 26),
        ),
      ]);

      final report = await BillReadingRepair(bills, readings, cycles, metersFake()).run();

      expect(readings.deleted, [200]);
      expect(cycles.store[11]!.startReadingId, 100);
      expect(cycles.store[11]!.cycleStartDate, DateTime(2026, 7, 27));
      expect(report.cyclePointersRepaired, 1);
    });
    test('cleans orphans on a meter whose bill was deleted', () async {
      // The reported Motor case. Keying the sweep off the bill list meant a
      // meter with no bills left was never visited, so deleting the bill made
      // its abandoned readings permanently unreachable.
      final bills = FakeBills();
      final readings = FakeReadings([
        billReading(id: 300, date: DateTime(2026, 7, 15), value: 4849),
        userReading(id: 301, date: DateTime(2026, 7, 25), value: 4914),
        billReading(id: 302, date: DateTime(2026, 7, 26), value: 4849),
        userReading(id: 303, date: DateTime(2026, 7, 27), value: 4925),
      ]);

      final report = await BillReadingRepair(
        bills,
        readings,
        FakeCycles(),
        metersFake(),
      ).run();

      // Both 4849 rows go; the readings the user captured are untouched.
      expect(readings.deleted..sort(), [300, 302]);
      expect(readings.store[301]!.readingValue, 4914);
      expect(readings.store[303]!.readingValue, 4925);
      expect(report.orphanReadingsRemoved, 2);
    });
  });
}
