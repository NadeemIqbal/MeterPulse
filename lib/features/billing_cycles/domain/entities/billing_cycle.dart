import 'package:equatable/equatable.dart';

/// One billing cycle for a meter. The single cycle with `isClosed == false` is
/// the current/active one; closed cycles are historical and read-only.
class BillingCycle extends Equatable {
  const BillingCycle({
    this.id,
    required this.meterId,
    required this.cycleStartDate,
    this.cycleEndDate,
    this.startReadingId,
    this.endReadingId,
    this.isClosed = false,
    this.expectedReadingDate,
    required this.createdAt,
  });

  final int? id;
  final int meterId;
  final DateTime cycleStartDate;
  final DateTime? cycleEndDate;
  final int? startReadingId;
  final int? endReadingId;
  final bool isClosed;
  final DateTime? expectedReadingDate;
  final DateTime createdAt;

  BillingCycle copyWith({
    int? id,
    DateTime? cycleEndDate,
    int? startReadingId,
    int? endReadingId,
    bool? isClosed,
    DateTime? expectedReadingDate,
  }) {
    return BillingCycle(
      id: id ?? this.id,
      meterId: meterId,
      cycleStartDate: cycleStartDate,
      cycleEndDate: cycleEndDate ?? this.cycleEndDate,
      startReadingId: startReadingId ?? this.startReadingId,
      endReadingId: endReadingId ?? this.endReadingId,
      isClosed: isClosed ?? this.isClosed,
      expectedReadingDate: expectedReadingDate ?? this.expectedReadingDate,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        meterId,
        cycleStartDate,
        cycleEndDate,
        startReadingId,
        endReadingId,
        isClosed,
        expectedReadingDate,
        createdAt,
      ];
}
