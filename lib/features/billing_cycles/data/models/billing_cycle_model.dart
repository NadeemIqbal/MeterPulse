import 'package:isar_community/isar.dart';

part 'billing_cycle_model.g.dart';

/// Isar collection for a billing cycle. Exactly one open cycle (`isClosed ==
/// false`) should exist per meter; the composite index on (meterId, isClosed)
/// makes finding it cheap.
@collection
class BillingCycleModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('isClosed')])
  late int meterId;

  late DateTime cycleStartDate;
  DateTime? cycleEndDate;

  /// Reading that opened / closed this cycle.
  int? startReadingId;
  int? endReadingId;

  bool isClosed = false;

  /// Projected next reading date (from the meter's day-of-month).
  DateTime? expectedReadingDate;

  late DateTime createdAt;
}
