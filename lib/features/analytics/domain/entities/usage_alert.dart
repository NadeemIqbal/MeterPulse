import 'package:equatable/equatable.dart';

/// Severity of a usage alert. [high] is threshold-exceeded (already over the
/// line); [warning] is a heads-up (projected to exceed, or an unusual spike).
enum AlertSeverity { warning, high }

/// A rule-based usage alert surfaced on the dashboard (and, in Phase 2, as a
/// notification).
class UsageAlert extends Equatable {
  const UsageAlert({
    required this.severity,
    required this.title,
    required this.message,
  });

  final AlertSeverity severity;
  final String title;
  final String message;

  bool get isHigh => severity == AlertSeverity.high;

  @override
  List<Object?> get props => [severity, title, message];
}
