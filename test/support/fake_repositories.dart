import 'package:meter_pulse/core/database/bill_reading_repair.dart';
import 'package:meter_pulse/features/billing_cycles/domain/entities/billing_cycle.dart';
import 'package:meter_pulse/features/billing_cycles/domain/repositories/billing_cycle_repository.dart';
import 'package:meter_pulse/features/bills/domain/entities/bill.dart';
import 'package:meter_pulse/features/bills/domain/repositories/bill_repository.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter_type.dart';
import 'package:meter_pulse/features/meters/domain/repositories/meter_repository.dart';
import 'package:meter_pulse/features/readings/domain/entities/reading.dart';
import 'package:meter_pulse/features/readings/domain/repositories/reading_repository.dart';

/// In-memory [BillRepository] for use-case tests.
class FakeBills implements BillRepository {
  FakeBills([List<Bill> seed = const []]) {
    for (final b in seed) {
      store[b.id!] = b;
    }
  }

  final Map<int, Bill> store = {};
  final List<int> deleted = [];
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
  Future<Bill?> getBill(int id) async => store[id];

  @override
  Future<int> saveBill(Bill bill) async {
    saveCount++;
    final id = bill.id ?? (store.keys.fold(0, (m, k) => k > m ? k : m) + 1);
    store[id] = bill.copyWith(id: id);
    return id;
  }

  @override
  Future<void> deleteBill(int id) async {
    deleted.add(id);
    store.remove(id);
  }

  @override
  Future<void> setPaid(int id, {required bool isPaid}) async {}

  @override
  Future<void> setArchived(int id, {required bool isArchived}) async {}
}

/// In-memory [ReadingRepository] preserving the real ordering contracts:
/// per-meter newest-first, per-cycle oldest-first.
class FakeReadings implements ReadingRepository {
  FakeReadings([List<Reading> seed = const []]) {
    for (final r in seed) {
      store[r.id!] = r;
    }
  }

  final Map<int, Reading> store = {};
  final List<int> deleted = [];

  @override
  Future<List<Reading>> getReadingsForMeter(int meterId) async =>
      store.values.where((r) => r.meterId == meterId).toList()
        ..sort((a, b) => b.readingDate.compareTo(a.readingDate));

  @override
  Future<List<Reading>> getReadingsForCycle(int cycleId) async =>
      store.values.where((r) => r.billingCycleId == cycleId).toList()
        ..sort((a, b) => a.readingDate.compareTo(b.readingDate));

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

/// In-memory [BillingCycleRepository] for use-case tests.
class FakeCycles implements BillingCycleRepository {
  FakeCycles([List<BillingCycle> seed = const []]) {
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

/// In-memory [MeterRepository] for use-case tests.
class FakeMeters implements MeterRepository {
  FakeMeters([List<Meter> seed = const []]) {
    for (final m in seed) {
      store[m.id!] = m;
    }
  }

  final Map<int, Meter> store = {};

  @override
  Future<List<Meter>> getMeters({bool includeInactive = false}) async =>
      store.values.where((m) => includeInactive || m.isActive).toList();

  @override
  Future<Meter?> getMeter(int id) async => store[id];

  @override
  Future<int> saveMeter(Meter meter) async {
    final id = meter.id ?? (store.keys.fold(0, (m, k) => k > m ? k : m) + 1);
    store[id] = meter;
    return id;
  }

  @override
  Future<void> setActive(int id, {required bool isActive}) async {}

  @override
  Future<void> updateMeterOrders(List<int> orderedMeterIds) async {}

  @override
  Future<void> deleteMeter(int id) async => store.remove(id);
}

/// A meter with just enough set for repair tests.
Meter testMeterWithId(int id, {String name = 'Motor'}) => Meter(
      id: id,
      name: name,
      type: MeterType.electricity,
      unit: 'kWh',
      expectedReadingDayOfMonth: 15,
      createdAt: DateTime(2026, 1, 1),
    );

/// A reading carrying the marker that identifies it as bill-created.
Reading billReading({
  required int id,
  required DateTime date,
  required double value,
  int meterId = 1,
  int? cycleId,
}) =>
    Reading(
      id: id,
      meterId: meterId,
      billingCycleId: cycleId,
      readingValue: value,
      readingDate: date,
      notes: '${billReadingMarker}whenever',
      createdAt: date,
    );

/// A reading the user captured themselves — no bill marker.
Reading userReading({
  required int id,
  required DateTime date,
  required double value,
  int meterId = 1,
  int? cycleId,
}) =>
    Reading(
      id: id,
      meterId: meterId,
      billingCycleId: cycleId,
      readingValue: value,
      readingDate: date,
      createdAt: date,
    );
