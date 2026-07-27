import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/bills_overview.dart';

/// Blue gradient hero showing what is still owed across every meter, plus the
/// next deadline.
class OutstandingHeroCard extends StatelessWidget {
  const OutstandingHeroCard({
    super.key,
    required this.totalOutstanding,
    required this.currencySymbol,
    this.nextDue,
  });

  final double totalOutstanding;
  final String currencySymbol;
  final BillListItem? nextDue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSettled = totalOutstanding <= 0;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0058BE), Color(0xFF2170E4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0058BE).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -12,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL OUTSTANDING',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Formatters.currency(totalOutstanding, symbol: currencySymbol),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _footerPill(context, isSettled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerPill(BuildContext context, bool isSettled) {
    final theme = Theme.of(context);
    final due = nextDue;

    final (icon, text) = switch ((isSettled, due?.daysUntilDue)) {
      (true, _) => (Icons.task_alt_rounded, 'No outstanding bills'),
      (_, null) => (Icons.receipt_long_rounded, 'No due date set'),
      (_, final days) when days! < 0 => (
          Icons.warning_amber_rounded,
          'Overdue by ${days.abs()} ${days.abs() == 1 ? 'day' : 'days'}',
        ),
      (_, final days) => (
          Icons.event_rounded,
          'Next bill due ${Formatters.relativeDays(days!)}',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
