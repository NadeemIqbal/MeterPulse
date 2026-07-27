import 'package:isar_community/isar.dart';

part 'bill_model.g.dart';

/// Isar collection for a bill. Phase 1 is manual entry + optional photo; the
/// provider's billed units may differ from the app's calculated consumption,
/// so [unitsBilled] is stored separately.
@collection
class BillModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int meterId;

  @Index()
  int? billingCycleId;

  late double billAmount;
  late DateTime billDate;
  DateTime? dueDate;

  /// Units the provider billed — a *consumption* figure for the period (e.g.
  /// 56 kWh), which may differ from the app's calculated consumption.
  double? unitsBilled;

  /// The cumulative meter reading printed on the bill (e.g. 20970).
  ///
  /// Purely additive and nullable, so Isar reads pre-existing rows as null
  /// without migrating or dropping any stored bill. [unitsBilled] used to serve
  /// double duty as this value, which broke the maths whenever a user entered
  /// the billed units the field's label actually asked for.
  double? meterReading;

  /// Id of the reading auto-created from [meterReading], if any.
  ///
  /// Also additive/nullable. Gives a bill ownership of one reading so edits
  /// update it in place instead of inserting a duplicate and orphaning the old
  /// row. Null for bills written before this field existed.
  int? readingId;

  bool isPaid = false;
  DateTime? paidDate;

  /// Hidden from the default bills list without being deleted.
  ///
  /// Purely additive: Isar gives pre-existing rows the `false` default on read,
  /// so adding this field does not migrate or drop any stored bill.
  bool isArchived = false;

  /// Absolute path to a photo of the paper bill (no OCR in Phase 1).
  String? photoPath;

  String? notes;

  late DateTime createdAt;
}
