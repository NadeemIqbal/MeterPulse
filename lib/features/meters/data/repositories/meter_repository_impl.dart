import 'package:isar_community/isar.dart';

import '../../../bills/data/models/bill_model.dart';
import '../../../billing_cycles/data/models/billing_cycle_model.dart';
import '../../../readings/data/models/reading_model.dart';
import '../../domain/entities/meter.dart';
import '../../domain/repositories/meter_repository.dart';
import '../models/meter_model.dart';

/// Isar-backed [MeterRepository].
class MeterRepositoryImpl implements MeterRepository {
  MeterRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<Meter>> getMeters({bool includeInactive = false}) async {
    final models = await _isar.meterModels.where().findAll();
    final meters = models
        .where((m) => includeInactive || m.isActive)
        .map(_toEntity)
        .toList();
    // Active first, then alphabetical — the dashboard order.
    meters.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return meters;
  }

  @override
  Future<Meter?> getMeter(int id) async {
    final model = await _isar.meterModels.get(id);
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<int> saveMeter(Meter meter) {
    return _isar.writeTxn(() => _isar.meterModels.put(_toModel(meter)));
  }

  @override
  Future<void> setActive(int id, {required bool isActive}) {
    return _isar.writeTxn(() async {
      final model = await _isar.meterModels.get(id);
      if (model == null) return;
      model.isActive = isActive;
      await _isar.meterModels.put(model);
    });
  }

  @override
  Future<void> deleteMeter(int id) {
    // Cascade: a meter's readings, bills and cycles are meaningless without it,
    // so purge them atomically in the same transaction.
    return _isar.writeTxn(() async {
      await _isar.readingModels.filter().meterIdEqualTo(id).deleteAll();
      await _isar.billModels.filter().meterIdEqualTo(id).deleteAll();
      await _isar.billingCycleModels.filter().meterIdEqualTo(id).deleteAll();
      await _isar.meterModels.delete(id);
    });
  }

  MeterModel _toModel(Meter m) => MeterModel()
    ..id = m.id ?? Isar.autoIncrement
    ..name = m.name
    ..meterNumber = m.meterNumber
    ..type = m.type
    ..unit = m.unit
    ..isActive = m.isActive
    ..expectedReadingDayOfMonth = m.expectedReadingDayOfMonth
    ..rolloverValue = m.rolloverValue
    ..colorValue = m.colorValue
    ..iconCodePoint = m.iconCodePoint
    ..notes = m.notes
    ..highUsageThreshold = m.highUsageThreshold
    ..expectedMonthlyUnits = m.expectedMonthlyUnits
    ..reminderStartDaysBefore = m.reminderStartDaysBefore
    ..reminderFrequencyDays = m.reminderFrequencyDays
    ..billReminderFrequencyDays = m.billReminderFrequencyDays
    ..createdAt = m.createdAt;

  Meter _toEntity(MeterModel m) => Meter(
        id: m.id,
        name: m.name,
        meterNumber: m.meterNumber,
        type: m.type,
        unit: m.unit,
        isActive: m.isActive,
        expectedReadingDayOfMonth: m.expectedReadingDayOfMonth,
        rolloverValue: m.rolloverValue,
        colorValue: m.colorValue,
        iconCodePoint: m.iconCodePoint,
        notes: m.notes,
        highUsageThreshold: m.highUsageThreshold,
        expectedMonthlyUnits: m.expectedMonthlyUnits,
        reminderStartDaysBefore: m.reminderStartDaysBefore,
        reminderFrequencyDays: m.reminderFrequencyDays,
        billReminderFrequencyDays: m.billReminderFrequencyDays,
        createdAt: m.createdAt,
      );
}
