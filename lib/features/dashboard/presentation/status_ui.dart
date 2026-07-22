import 'package:flutter/material.dart';

import '../domain/entities/meter_summary.dart';

/// Label/icon/colour mapping for [ReadingStatus] and [BillStatus] pills.
extension ReadingStatusUi on ReadingStatus {
  String get label => switch (this) {
        ReadingStatus.noReadings => 'No readings',
        ReadingStatus.upToDate => 'On track',
        ReadingStatus.dueSoon => 'Reading due',
        ReadingStatus.overdue => 'Overdue',
      };

  IconData get icon => switch (this) {
        ReadingStatus.noReadings => Icons.help_outline_rounded,
        ReadingStatus.upToDate => Icons.check_circle_outline_rounded,
        ReadingStatus.dueSoon => Icons.schedule_rounded,
        ReadingStatus.overdue => Icons.warning_amber_rounded,
      };

  Color color(ColorScheme scheme) => switch (this) {
        ReadingStatus.noReadings => scheme.onSurfaceVariant,
        ReadingStatus.upToDate => const Color(0xFF2E7D32),
        ReadingStatus.dueSoon => const Color(0xFFEF6C00),
        ReadingStatus.overdue => scheme.error,
      };
}

extension BillStatusUi on BillStatus {
  String get label => switch (this) {
        BillStatus.noBill => 'No bill',
        BillStatus.paid => 'Paid',
        BillStatus.dueSoon => 'Bill due',
        BillStatus.overdue => 'Bill overdue',
        BillStatus.unpaid => 'Unpaid',
      };

  IconData get icon => switch (this) {
        BillStatus.noBill => Icons.receipt_long_outlined,
        BillStatus.paid => Icons.task_alt_rounded,
        BillStatus.dueSoon => Icons.schedule_rounded,
        BillStatus.overdue => Icons.warning_amber_rounded,
        BillStatus.unpaid => Icons.receipt_long_rounded,
      };

  Color color(ColorScheme scheme) => switch (this) {
        BillStatus.noBill => scheme.onSurfaceVariant,
        BillStatus.paid => const Color(0xFF2E7D32),
        BillStatus.dueSoon => const Color(0xFFEF6C00),
        BillStatus.overdue => scheme.error,
        BillStatus.unpaid => scheme.onSurfaceVariant,
      };
}
