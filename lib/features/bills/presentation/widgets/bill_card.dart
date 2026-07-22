import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/bill.dart';

/// A single bill row: amount, date, paid/due status, and an actions menu.
class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    required this.unit,
    this.onEdit,
    this.onTogglePaid,
    this.onDelete,
  });

  final Bill bill;
  final String unit;
  final VoidCallback? onEdit;
  final VoidCallback? onTogglePaid;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final paidColor = const Color(0xFF2E7D32);
    final accent = bill.isPaid ? paidColor : scheme.primary;

    return AppCard(
      onTap: onEdit,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.16),
            child: Icon(
              bill.isPaid ? Icons.task_alt_rounded : Icons.receipt_long_rounded,
              color: accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.currency(bill.billAmount),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (bill.photoPath != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Icon(Icons.image_rounded,
                  size: 18, color: scheme.onSurfaceVariant),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                case 'paid':
                  onTogglePaid?.call();
                case 'delete':
                  onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'paid',
                child: Text(bill.isPaid ? 'Mark unpaid' : 'Mark paid'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final parts = <String>['Billed ${Formatters.date(bill.billDate)}'];
    if (bill.unitsBilled != null) {
      parts.add('${Formatters.units(bill.unitsBilled)} $unit');
    }
    if (bill.isPaid) {
      parts.add('Paid');
    } else if (bill.dueDate != null) {
      parts.add('Due ${Formatters.date(bill.dueDate)}');
    }
    return parts.join(' · ');
  }
}
