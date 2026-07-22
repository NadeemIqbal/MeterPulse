import 'package:isar_community/isar.dart';

import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository.dart';
import '../models/reading_model.dart';

/// Isar-backed [ReadingRepository]. Queries use the (meterId, readingDate)
/// composite index so a meter's history stays fast at thousands of rows.
class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<Reading>> getReadingsForMeter(int meterId) async {
    final models = await _isar.readingModels
        .filter()
        .meterIdEqualTo(meterId)
        .sortByReadingDateDesc()
        .findAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<Reading>> getReadingsForCycle(int cycleId) async {
    final models = await _isar.readingModels
        .filter()
        .billingCycleIdEqualTo(cycleId)
        .sortByReadingDate()
        .findAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<Reading?> getLatestReading(int meterId) async {
    final model = await _isar.readingModels
        .filter()
        .meterIdEqualTo(meterId)
        .sortByReadingDateDesc()
        .findFirst();
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<int> saveReading(Reading reading) {
    return _isar.writeTxn(() => _isar.readingModels.put(_toModel(reading)));
  }

  @override
  Future<void> deleteReading(int id) {
    return _isar.writeTxn(() => _isar.readingModels.delete(id));
  }

  ReadingModel _toModel(Reading r) => ReadingModel()
    ..id = r.id ?? Isar.autoIncrement
    ..meterId = r.meterId
    ..billingCycleId = r.billingCycleId
    ..readingValue = r.readingValue
    ..readingDate = r.readingDate
    ..photoPath = r.photoPath
    ..ocrConfidence = r.ocrConfidence
    ..ocrRawText = r.ocrRawText
    ..isManualEntry = r.isManualEntry
    ..notes = r.notes
    ..createdAt = r.createdAt;

  Reading _toEntity(ReadingModel r) => Reading(
        id: r.id,
        meterId: r.meterId,
        billingCycleId: r.billingCycleId,
        readingValue: r.readingValue,
        readingDate: r.readingDate,
        photoPath: r.photoPath,
        ocrConfidence: r.ocrConfidence,
        ocrRawText: r.ocrRawText,
        isManualEntry: r.isManualEntry,
        notes: r.notes,
        createdAt: r.createdAt,
      );
}
