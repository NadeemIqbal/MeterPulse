import '../entities/reading.dart';

/// Persistence contract for meter readings.
abstract interface class ReadingRepository {
  /// A meter's readings, newest first.
  Future<List<Reading>> getReadingsForMeter(int meterId);

  /// A cycle's readings, oldest first — the order the consumption timeline
  /// renders them in.
  Future<List<Reading>> getReadingsForCycle(int cycleId);

  /// The most recent reading for a meter, or null if none.
  Future<Reading?> getLatestReading(int meterId);

  Future<int> saveReading(Reading reading);

  Future<void> deleteReading(int id);
}
