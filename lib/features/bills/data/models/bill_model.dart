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

  /// Units the provider billed (may differ from calculated consumption).
  double? unitsBilled;

  bool isPaid = false;
  DateTime? paidDate;

  /// Absolute path to a photo of the paper bill (no OCR in Phase 1).
  String? photoPath;

  String? notes;

  late DateTime createdAt;
}
