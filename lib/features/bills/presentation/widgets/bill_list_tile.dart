import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/bills_overview.dart';
import '../pages/global_bills_page.dart';

/// One bill in the global list: month heading, meter name, status chip, the
/// usage/amount pair and a due-date footer that offers "Pay Now" when unpaid.
class BillListTile extends StatelessWidget {
  const BillListTile({
    super.key,
    required this.item,
    required this.currencySymbol,
    this.onMarkPaid,
    this.onTap,
    this.onArchive,
    this.onDelete,
  });

  final BillListItem item;
  final String currencySymbol;

  /// Null when the bill is already paid.
  final VoidCallback? onMarkPaid;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bill = item.bill;
    final isOverdue = item.status == BillPaymentStatus.overdue;

    return Material(
      color: item.status.background(scheme) ?? scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.monthYear(bill.billDate),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          item.meterName,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: item.status),
                  if (onArchive != null || onDelete != null)
                    _overflowMenu(context),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      context,
                      'USAGE',
                      bill.unitsBilled == null
                          ? '—'
                          : Formatters.units(bill.unitsBilled),
                    ),
                  ),
                  Expanded(
                    child: _metric(
                      context,
                      'AMOUNT',
                      Formatters.currency(
                        bill.billAmount,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.error_outline_rounded
                        : Icons.calendar_today_rounded,
                    size: 16,
                    color: isOverdue ? scheme.error : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      formatDueDate(item),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isOverdue ? scheme.error : scheme.onSurfaceVariant,
                        fontWeight:
                            isOverdue ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onMarkPaid != null)
                    FilledButton(
                      onPressed: onMarkPaid,
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        // The theme's Size.fromHeight(52) sets minWidth to
                        // infinity, which a Row cannot satisfy.
                        minimumSize: const Size(0, 40),
                      ),
                      child: const Text('Pay Now'),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _overflowMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Bill actions',
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (value) => switch (value) {
        'archive' => onArchive?.call(),
        'delete' => _confirmDelete(context),
        _ => null,
      },
      itemBuilder: (context) => [
        if (onArchive != null)
          PopupMenuItem(
            value: 'archive',
            child: Text(item.bill.isArchived ? 'Unarchive' : 'Archive'),
          ),
        if (onDelete != null)
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete bill?'),
        content: Text(
          'The ${Formatters.monthYear(item.bill.billDate)} bill for '
          '${item.meterName} will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onDelete?.call();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BillPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status.color(theme.colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
