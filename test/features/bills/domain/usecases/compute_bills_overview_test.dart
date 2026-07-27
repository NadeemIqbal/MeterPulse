import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/features/bills/domain/entities/bill.dart';
import 'package:meter_pulse/features/bills/domain/entities/bills_overview.dart';
import 'package:meter_pulse/features/bills/domain/usecases/compute_bills_overview.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter_type.dart';

void main() {
  const compute = ComputeBillsOverview();
  final now = DateTime(2026, 7, 25);

  final electricity = Meter(
    id: 1,
    name: 'Main Electricity',
    type: MeterType.electricity,
    unit: 'kWh',
    expectedReadingDayOfMonth: 25,
    createdAt: DateTime(2026, 1, 1),
  );

  final gas = Meter(
    id: 2,
    name: 'Home Gas',
    type: MeterType.gas,
    unit: 'm³',
    expectedReadingDayOfMonth: 25,
    createdAt: DateTime(2026, 1, 1),
  );

  Bill bill({
    required int id,
    int meterId = 1,
    double amount = 50.0,
    DateTime? dueDate,
    bool isPaid = false,
    bool isArchived = false,
  }) {
    return Bill(
      id: id,
      meterId: meterId,
      billAmount: amount,
      billDate: DateTime(2026, 7, 1),
      dueDate: dueDate,
      isPaid: isPaid,
      isArchived: isArchived,
      createdAt: DateTime(2026, 7, 1),
    );
  }

  group('ComputeBillsOverview', () {
    test('sums only unpaid bills into the outstanding total', () {
      final overview = compute(
        bills: [
          bill(id: 1, amount: 45.50, isPaid: true),
          bill(id: 2, amount: 52.00),
          bill(id: 3, amount: 48.20, meterId: 2),
        ],
        meters: [electricity, gas],
        now: now,
      );

      expect(overview.totalOutstanding, 100.20);
      expect(overview.unpaidCount, 2);
    });

    test('excludes archived bills from the list and the totals', () {
      final overview = compute(
        bills: [
          bill(id: 1, amount: 52.00),
          bill(id: 2, amount: 999.00, isArchived: true),
        ],
        meters: [electricity],
        now: now,
      );

      expect(overview.items, hasLength(1));
      expect(overview.items.single.bill.id, 1);
      expect(overview.totalOutstanding, 52.00);
    });

    test('marks an unpaid bill past its due date as overdue', () {
      final overview = compute(
        bills: [bill(id: 1, dueDate: DateTime(2026, 7, 20))],
        meters: [electricity],
        now: now,
      );

      final item = overview.items.single;
      expect(item.status, BillPaymentStatus.overdue);
      expect(item.daysUntilDue, -5);
      expect(overview.overdueCount, 1);
    });

    test('a paid bill stays paid even when its due date has passed', () {
      final overview = compute(
        bills: [bill(id: 1, dueDate: DateTime(2026, 7, 20), isPaid: true)],
        meters: [electricity],
        now: now,
      );

      expect(overview.items.single.status, BillPaymentStatus.paid);
      expect(overview.overdueCount, 0);
      expect(overview.totalOutstanding, 0);
    });

    test('nextDue picks the soonest-due unpaid bill across meters', () {
      final overview = compute(
        bills: [
          bill(id: 1, dueDate: DateTime(2026, 8, 20)),
          bill(id: 2, meterId: 2, dueDate: DateTime(2026, 8, 6)),
          bill(id: 3, dueDate: DateTime(2026, 8, 1), isPaid: true),
        ],
        meters: [electricity, gas],
        now: now,
      );

      expect(overview.nextDue?.bill.id, 2);
      expect(overview.nextDue?.daysUntilDue, 12);
      expect(overview.nextDue?.meterName, 'Home Gas');
    });

    test('a bill with no due date never becomes nextDue', () {
      final overview = compute(
        bills: [
          bill(id: 1),
          bill(id: 2, dueDate: DateTime(2026, 8, 6)),
        ],
        meters: [electricity],
        now: now,
      );

      expect(overview.nextDue?.bill.id, 2);
    });

    test('nextDue is null when every bill is settled', () {
      final overview = compute(
        bills: [bill(id: 1, dueDate: DateTime(2026, 8, 6), isPaid: true)],
        meters: [electricity],
        now: now,
      );

      expect(overview.nextDue, isNull);
      expect(overview.hasOutstanding, isFalse);
    });

    test('joins each bill to its meter and survives a missing one', () {
      final overview = compute(
        bills: [
          bill(id: 1, meterId: 1),
          bill(id: 2, meterId: 99),
        ],
        meters: [electricity],
        now: now,
      );

      expect(overview.items[0].meterName, 'Main Electricity');
      expect(overview.items[1].meter, isNull);
      expect(overview.items[1].meterName, 'Unknown meter');
    });
  });
}
