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
    this.isPaid = false,
    this.paidDate,
    this.photoPath,
    this.notes,
    required this.createdAt,
  });

  final int? id;
  final int meterId;
  final int? billingCycleId;
  final double billAmount;
  final DateTime billDate;
  final DateTime? dueDate;
  final double? unitsBilled;
  final bool isPaid;
  final DateTime? paidDate;
  final String? photoPath;
  final String? notes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        meterId,
        billingCycleId,
        billAmount,
        billDate,
        dueDate,
        unitsBilled,
        isPaid,
        paidDate,
        photoPath,
        notes,
        createdAt,
      ];
}
