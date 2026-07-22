import 'package:isar_community/isar.dart';

import '../../domain/entities/billing_cycle.dart';
import '../../domain/repositories/billing_cycle_repository.dart';
import '../models/billing_cycle_model.dart';

/// Isar-backed [BillingCycleRepository].
class BillingCycleRepositoryImpl implements BillingCycleRepository {
  BillingCycleRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<BillingCycle?> getOpenCycle(int meterId) async {
    final model = await _isar.billingCycleModels
        .filter()
        .meterIdEqualTo(meterId)
        .isClosedEqualTo(false)
        .findFirst();
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<List<BillingCycle>> getCyclesForMeter(int meterId) async {
    final models = await _isar.billingCycleModels
        .filter()
        .meterIdEqualTo(meterId)
        .sortByCycleStartDateDesc()
        .findAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<BillingCycle?> getCycle(int id) async {
    final model = await _isar.billingCycleModels.get(id);
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<int> saveCycle(BillingCycle cycle) {
    return _isar.writeTxn(() => _isar.billingCycleModels.put(_toModel(cycle)));
  }

  BillingCycleModel _toModel(BillingCycle c) => BillingCycleModel()
    ..id = c.id ?? Isar.autoIncrement
    ..meterId = c.meterId
    ..cycleStartDate = c.cycleStartDate
    ..cycleEndDate = c.cycleEndDate
    ..startReadingId = c.startReadingId
    ..endReadingId = c.endReadingId
    ..isClosed = c.isClosed
    ..expectedReadingDate = c.expectedReadingDate
    ..createdAt = c.createdAt;

  BillingCycle _toEntity(BillingCycleModel c) => BillingCycle(
        id: c.id,
        meterId: c.meterId,
        cycleStartDate: c.cycleStartDate,
        cycleEndDate: c.cycleEndDate,
        startReadingId: c.startReadingId,
        endReadingId: c.endReadingId,
        isClosed: c.isClosed,
        expectedReadingDate: c.expectedReadingDate,
        createdAt: c.createdAt,
      );
}
