import 'package:isar_community/isar.dart';

part 'reading_model.g.dart';

/// Isar collection for a single meter reading.
///
/// Photos are stored as file paths, never bytes. The composite index on
/// (meterId, readingDate) serves the hot query: a meter's readings ordered by
/// date.
@collection
class ReadingModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('readingDate')])
  late int meterId;

  @Index()
  int? billingCycleId;

  late double readingValue;
  late DateTime readingDate;

  /// Absolute path to the captured photo (or null for manual entry).
  String? photoPath;

  /// Synthesized OCR confidence 0–1, or null when entered manually.
  double? ocrConfidence;

  /// Raw ML Kit text, retained to help debug a poor scan.
  String? ocrRawText;

  bool isManualEntry = false;

  String? notes;

  /// Audit timestamp, distinct from [readingDate] which the user may backdate.
  late DateTime createdAt;
}
