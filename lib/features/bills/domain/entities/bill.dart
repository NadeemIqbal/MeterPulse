import 'package:equatable/equatable.dart';

/// A bill for a meter. Phase 1 is manual entry plus an optional photo.
class Bill extends Equatable {
  const Bill({
    this.id,
    required this.meterId,
    this.billingCycleId,
    required this.billAmount,
    required this.billDate,
    this.dueDate,
    this.unitsBilled,
    this.meterReading,
    this.readingId,
    this.isPaid = false,
    this.paidDate,
    this.photoPath,
    this.notes,
    this.isArchived = false,
    required this.createdAt,
  });

  final int? id;
  final int meterId;
  final int? billingCycleId;
  final double billAmount;
  final DateTime billDate;
  final DateTime? dueDate;

  /// Units the provider charged for this period — a *consumption* figure, e.g.
  /// 56 kWh. Never a meter face value; see [meterReading].
  final double? unitsBilled;

  /// The cumulative meter reading printed on the bill, e.g. 20970. This is the
  /// absolute value the consumption maths needs; [unitsBilled] is the delta the
  /// provider charged. Keeping them apart is deliberate — a single field was
  /// previously labelled as consumption but consumed as an opening reading,
  /// which corrupted every derived figure when a user entered the billed units.
  final double? meterReading;

  /// The reading auto-created from this bill's [meterReading], if any.
  ///
  /// Gives the bill ownership of exactly one reading so edits update that row
  /// in place. Without this back-link, changing the bill date inserted a second
  /// reading and orphaned the first.
  final int? readingId;

  final bool isPaid;
  final DateTime? paidDate;
  final String? photoPath;
  final String? notes;

  /// Hidden from the default bills list without being deleted.
  final bool isArchived;
  final DateTime createdAt;

  /// Copy with a new [id] and/or [readingId]. `clearReadingId` drops the link
  /// (a plain null for [readingId] cannot express "unset" here).
  Bill copyWith({
    int? id,
    int? readingId,
    double? meterReading,
    bool clearReadingId = false,
  }) {
    return Bill(
      id: id ?? this.id,
      meterId: meterId,
      billingCycleId: billingCycleId,
      billAmount: billAmount,
      billDate: billDate,
      dueDate: dueDate,
      unitsBilled: unitsBilled,
      meterReading: meterReading ?? this.meterReading,
      readingId: clearReadingId ? null : (readingId ?? this.readingId),
      isPaid: isPaid,
      paidDate: paidDate,
      photoPath: photoPath,
      notes: notes,
      isArchived: isArchived,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        meterId,
        billingCycleId,
        billAmount,
        billDate,
        dueDate,
        unitsBilled,
        meterReading,
        readingId,
        isPaid,
        paidDate,
        photoPath,
        notes,
        isArchived,
        createdAt,
      ];
}
