import 'package:isar_community/isar.dart';

import '../../domain/entities/meter_type.dart';

part 'meter_model.g.dart';

/// Isar collection for a configured meter.
///
/// Foreign keys elsewhere reference [id] as a plain `int`. Phase-2 config fields
/// are nullable and present from day one so turning on reminders/alerts later
/// needs no schema migration.
@collection
class MeterModel {
  Id id = Isar.autoIncrement;

  late String name;
  String? meterNumber;

  @Enumerated(EnumType.name)
  late MeterType type;

  /// Display unit (kWh, m³, …).
  late String unit;

  @Index()
  bool isActive = true;

  /// Day of the month (1–31) the meter reading is expected; drives cycle
  /// rollover and the dashboard "days until reading".
  late int expectedReadingDayOfMonth;

  /// Value at which the physical meter wraps back to 0. Null = never wraps.
  double? rolloverValue;

  /// User-picked accent (ARGB int). Null = fall back to the type's default.
  int? colorValue;

  /// Chosen icon code point. Null = default per type.
  int? iconCodePoint;

  String? notes;

  // --- Phase 2 configuration (unused in Phase 1, nullable to avoid migration) ---
  double? highUsageThreshold;
  double? expectedMonthlyUnits;
  int? reminderStartDaysBefore;
  int? reminderFrequencyDays;
  int? billReminderFrequencyDays;

  late DateTime createdAt;
}
