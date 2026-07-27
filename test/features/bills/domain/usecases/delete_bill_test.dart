import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/features/billing_cycles/domain/entities/billing_cycle.dart';
import 'package:meter_pulse/features/bills/domain/entities/bill.dart';
import 'package:meter_pulse/features/bills/domain/usecases/delete_bill.dart';

import '../../../../support/fake_repositories.dart';

void main() {
  group('DeleteBill', () {
    test('removes the reading the bill created', () async {
      // The reported Motor case: a bill owning the 4849 reading was deleted, but
      // the reading stayed behind in the meter's history.
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 3200,
          billDate: DateTime(2026, 7, 15),
          meterReading: 4849,
          readingId: 200,
          createdAt: DateTime(2026, 7, 15),
        ),
      ]);
      final readings = FakeReadings([
        billReading(id: 200, date: DateTime(2026, 7, 15), value: 4849),
        userReading(id: 201, date: DateTime(2026, 7, 25), value: 4914),
      ]);

      await DeleteBill(bills, readings, FakeCycles())(51);

      expect(bills.store.containsKey(51), isFalse);
      expect(readings.deleted, [200]);
      // The user's own 25 Jul reading is untouched.
      expect(readings.store[201]!.readingValue, 4914);
    });

    test('leaves readings alone when the bill never created one', () async {
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 3200,
          billDate: DateTime(2026, 7, 15),
          createdAt: DateTime(2026, 7, 15),
        ),
      ]);
      final readings = FakeReadings([
        userReading(id: 201, date: DateTime(2026, 7, 25), value: 4914),
      ]);

      await DeleteBill(bills, readings, FakeCycles())(51);

      expect(bills.store.containsKey(51), isFalse);
      expect(readings.deleted, isEmpty);
    });

    test('repoints a cycle whose baseline was the deleted bill reading',
        () async {
      final bills = FakeBills([
        Bill(
          id: 51,
          meterId: 1,
          billAmount: 3200,
          billDate: DateTime(2026, 7, 15),
          meterReading: 4849,
          readingId: 200,
          createdAt: DateTime(2026, 7, 15),
        ),
      ]);
      final readings = FakeReadings([
        billReading(id: 200, date: DateTime(2026, 7, 15), value: 4849, cycleId: 11),
        userReading(id: 201, date: DateTime(2026, 7, 25), value: 4914, cycleId: 11),
      ]);
      final cycles = FakeCycles([
        BillingCycle(
          id: 11,
          meterId: 1,
          cycleStartDate: DateTime(2026, 7, 15),
          startReadingId: 200,
          createdAt: DateTime(2026, 7, 15),
        ),
      ]);

      await DeleteBill(bills, readings, cycles)(51);

      // startReadingId must not be left pointing at a deleted row.
      expect(cycles.store[11]!.startReadingId, 201);
      expect(cycles.store[11]!.cycleStartDate, DateTime(2026, 7, 25));
    });

    test('deleting an already-missing bill is harmless', () async {
      final bills = FakeBills();
      final readings = FakeReadings([
        userReading(id: 201, date: DateTime(2026, 7, 25), value: 4914),
      ]);

      final result = await DeleteBill(bills, readings, FakeCycles())(999);

      expect(result.isOk, isTrue);
      expect(readings.deleted, isEmpty);
    });
  });
}
