import 'package:equatable/equatable.dart';

/// Total consumption of one completed billing cycle over [days] days.
///
/// Feeds the average-monthly/yearly calculations, which normalise each cycle to
/// a daily rate first so irregular cycle lengths don't skew the average.
class CycleConsumption extends Equatable {
  const CycleConsumption({required this.totalUnits, required this.days});

  /// Units consumed across the whole cycle.
  final double totalUnits;

  /// Number of days the cycle spanned.
  final int days;

  @override
  List<Object?> get props => [totalUnits, days];
}
