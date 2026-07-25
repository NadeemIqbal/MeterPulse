import 'dart:io';

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
      onTap: () => _showBillDetailsModal(context),
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
                case 'view':
                  _showBillDetailsModal(context);
                case 'edit':
                  onEdit?.call();
                case 'paid':
                  onTogglePaid?.call();
                case 'delete':
                  onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View details')),
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

  void _showBillDetailsModal(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bill Details',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: (bill.isPaid ? const Color(0xFF2E7D32) : scheme.primary)
                          .withValues(alpha: 0.14),
                      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.chip)),
                    ),
                    child: Text(
                      bill.isPaid ? 'Paid' : 'Unpaid',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: bill.isPaid ? const Color(0xFF2E7D32) : scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                Formatters.currency(bill.billAmount),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Billed Date: ${Formatters.date(bill.billDate)}',
                  style: theme.textTheme.bodyMedium),
              if (bill.dueDate != null)
                Text('Due Date: ${Formatters.date(bill.dueDate!)}',
                    style: theme.textTheme.bodyMedium),
              if (bill.unitsBilled != null)
                Text('Units Billed: ${Formatters.units(bill.unitsBilled)} $unit',
                    style: theme.textTheme.bodyMedium),
              if (bill.notes != null && bill.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('Notes: ${bill.notes}', style: theme.textTheme.bodySmall),
              ],
              if (bill.photoPath != null && File(bill.photoPath!).existsSync()) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(AppRadius.card)),
                  child: Image.file(
                    File(bill.photoPath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        onEdit?.call();
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit Bill'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        onTogglePaid?.call();
                      },
                      icon: Icon(bill.isPaid ? Icons.remove_done_rounded : Icons.check_rounded),
                      label: Text(bill.isPaid ? 'Mark Unpaid' : 'Mark Paid'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

