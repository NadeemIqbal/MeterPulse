import 'package:isar_community/isar.dart';

import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../models/bill_model.dart';

/// Isar-backed [BillRepository].
class BillRepositoryImpl implements BillRepository {
  BillRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<Bill>> getBillsForMeter(int meterId) async {
    final models = await _isar.billModels
        .filter()
        .meterIdEqualTo(meterId)
        .sortByBillDateDesc()
        .findAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<Bill?> getLatestBill(int meterId) async {
    final model = await _isar.billModels
        .filter()
        .meterIdEqualTo(meterId)
        .sortByBillDateDesc()
        .findFirst();
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<int> saveBill(Bill bill) {
    return _isar.writeTxn(() => _isar.billModels.put(_toModel(bill)));
  }

  @override
  Future<void> setPaid(int id, {required bool isPaid}) {
    return _isar.writeTxn(() async {
      final model = await _isar.billModels.get(id);
      if (model == null) return;
      model.isPaid = isPaid;
      model.paidDate = isPaid ? DateTime.now() : null;
      await _isar.billModels.put(model);
    });
  }

  @override
  Future<void> deleteBill(int id) {
    return _isar.writeTxn(() => _isar.billModels.delete(id));
  }

  BillModel _toModel(Bill b) => BillModel()
    ..id = b.id ?? Isar.autoIncrement
    ..meterId = b.meterId
    ..billingCycleId = b.billingCycleId
    ..billAmount = b.billAmount
    ..billDate = b.billDate
    ..dueDate = b.dueDate
    ..unitsBilled = b.unitsBilled
    ..isPaid = b.isPaid
    ..paidDate = b.paidDate
    ..photoPath = b.photoPath
    ..notes = b.notes
    ..createdAt = b.createdAt;

  Bill _toEntity(BillModel b) => Bill(
        id: b.id,
        meterId: b.meterId,
        billingCycleId: b.billingCycleId,
        billAmount: b.billAmount,
        billDate: b.billDate,
        dueDate: b.dueDate,
        unitsBilled: b.unitsBilled,
        isPaid: b.isPaid,
        paidDate: b.paidDate,
        photoPath: b.photoPath,
        notes: b.notes,
        createdAt: b.createdAt,
      );
}
