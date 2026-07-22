import 'package:equatable/equatable.dart';

import '../../../billing_cycles/domain/entities/billing_cycle.dart';
import 'reading.dart';

/// One row in a cycle's consumption timeline: a reading plus the units consumed
/// since the previous reading in that cycle (null for the baseline/first row or
/// an anomalous drop).
class TimelineEntry extends Equatable {
  const TimelineEntry({required this.reading, this.consumedSincePrevious});

  final Reading reading;
  final double? consumedSincePrevious;

  bool get isBaseline => consumedSincePrevious == null;

  @override
  List<Object?> get props => [reading, consumedSincePrevious];
}

/// A cycle and its readings as a timeline, newest cycle shown first in the UI.
class CycleTimeline extends Equatable {
  const CycleTimeline({
    required this.cycle,
    required this.entries,
    this.totalUnits,
  });

  final BillingCycle cycle;

  /// Oldest reading first (baseline at index 0).
  final List<TimelineEntry> entries;

  /// Total units across the cycle (last − first), or null if not computable.
  final double? totalUnits;

  bool get isCurrent => !cycle.isClosed;

  @override
  List<Object?> get props => [cycle, entries, totalUnits];
}
