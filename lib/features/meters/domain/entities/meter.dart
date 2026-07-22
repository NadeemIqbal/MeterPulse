import 'package:equatable/equatable.dart';

import 'meter_type.dart';

/// A configured meter. Plain immutable domain entity — repositories map it to
/// and from the Isar `MeterModel`. [id] is `null` until first persisted.
class Meter extends Equatable {
  const Meter({
    this.id,
    required this.name,
    this.meterNumber,
    required this.type,
    required this.unit,
    this.isActive = true,
    required this.expectedReadingDayOfMonth,
    this.rolloverValue,
    this.colorValue,
    this.iconCodePoint,
    this.notes,
    this.highUsageThreshold,
    this.expectedMonthlyUnits,
    this.reminderStartDaysBefore,
    this.reminderFrequencyDays,
    this.billReminderFrequencyDays,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String? meterNumber;
  final MeterType type;
  final String unit;
  final bool isActive;
  final int expectedReadingDayOfMonth;
  final double? rolloverValue;
  final int? colorValue;
  final int? iconCodePoint;
  final String? notes;

  // Phase 2 configuration.
  final double? highUsageThreshold;
  final double? expectedMonthlyUnits;
  final int? reminderStartDaysBefore;
  final int? reminderFrequencyDays;
  final int? billReminderFrequencyDays;

  final DateTime createdAt;

  /// Returns a copy with the given non-null overrides applied. Cannot clear a
  /// nullable field back to null — the setup form builds a fresh [Meter] for
  /// full edits; this is for small changes like toggling [isActive].
  Meter copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return Meter(
      id: id ?? this.id,
      name: name ?? this.name,
      meterNumber: meterNumber,
      type: type,
      unit: unit,
      isActive: isActive ?? this.isActive,
      expectedReadingDayOfMonth: expectedReadingDayOfMonth,
      rolloverValue: rolloverValue,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      notes: notes,
      highUsageThreshold: highUsageThreshold,
      expectedMonthlyUnits: expectedMonthlyUnits,
      reminderStartDaysBefore: reminderStartDaysBefore,
      reminderFrequencyDays: reminderFrequencyDays,
      billReminderFrequencyDays: billReminderFrequencyDays,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        meterNumber,
        type,
        unit,
        isActive,
        expectedReadingDayOfMonth,
        rolloverValue,
        colorValue,
        iconCodePoint,
        notes,
        highUsageThreshold,
        expectedMonthlyUnits,
        reminderStartDaysBefore,
        reminderFrequencyDays,
        billReminderFrequencyDays,
        createdAt,
      ];
}
