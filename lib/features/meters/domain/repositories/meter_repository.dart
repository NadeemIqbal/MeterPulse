import '../entities/meter.dart';

/// Persistence contract for meters. The Isar-backed implementation lives in the
/// data layer; swapping in a cloud-backed one later only touches that layer.
abstract interface class MeterRepository {
  /// All meters, active-first then by name. Inactive meters are excluded unless
  /// [includeInactive] is true.
  Future<List<Meter>> getMeters({bool includeInactive = false});

  Future<Meter?> getMeter(int id);

  /// Inserts (when [Meter.id] is null) or updates, returning the row id.
  Future<int> saveMeter(Meter meter);

  Future<void> setActive(int id, {required bool isActive});

  Future<void> deleteMeter(int id);
}
