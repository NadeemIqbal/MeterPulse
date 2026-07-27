import 'package:equatable/equatable.dart';

import '../../../readings/domain/entities/reading.dart';
import 'meter.dart';

/// A meter plus the live figures the manage-meters card shows: its latest
/// reading and how far this cycle's usage has eaten into the configured
/// threshold.
class MeterListItem extends Equatable {
  const MeterListItem({
    required this.meter,
    this.latestReading,
    this.unitsThisCycle,
    this.threshold,
  });

  final Meter meter;
  final Reading? latestReading;

  /// Units consumed since the current cycle's baseline reading.
  final double? unitsThisCycle;

  /// The meter's usage budget, when one is configured.
  final double? threshold;

  /// 0–1 progress toward [threshold], or null when there is nothing to
  /// measure against.
  double? get progress {
    final limit = threshold;
    final used = unitsThisCycle;
    if (limit == null || limit <= 0 || used == null) return null;
    return (used / limit).clamp(0.0, 1.0);
  }

  bool get hasReading => latestReading != null;

  @override
  List<Object?> get props => [meter, latestReading, unitsThisCycle, threshold];
}
