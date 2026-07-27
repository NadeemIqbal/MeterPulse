import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/domain/repositories/meter_repository.dart';
import '../../domain/entities/bills_overview.dart';
import '../cubit/global_bills_cubit.dart';
import '../widgets/bill_list_tile.dart';
import '../widgets/outstanding_hero_card.dart';
import 'add_edit_bill_page.dart';

/// Bills across every meter: an outstanding-balance hero, filter chips and the
/// full payment history. Reached from the "Bills" tab.
class GlobalBillsPage extends StatelessWidget {
  const GlobalBillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GlobalBillsCubit>(
      create: (_) => sl<GlobalBillsCubit>()..load(),
      child: const _GlobalBillsView(),
    );
  }
}

class _GlobalBillsView extends StatelessWidget {
  const _GlobalBillsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBill(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<GlobalBillsCubit, GlobalBillsState>(
        builder: (context, state) {
          return switch (state.status) {
            GlobalBillsStatus.loading => const LoadingView(),
            GlobalBillsStatus.error => ErrorView(
                message: state.error ?? 'Could not load bills.',
                onRetry: () => context.read<GlobalBillsCubit>().load(),
              ),
            GlobalBillsStatus.loaded => _content(context, state),
          };
        },
      ),
    );
  }

  Widget _content(BuildContext context, GlobalBillsState state) {
    final theme = Theme.of(context);
    final items = state.visibleItems;

    return RefreshIndicator(
      onRefresh: () => context.read<GlobalBillsCubit>().load(),
      child: ListView(
        padding: AppSpacing.page,
        children: [
          OutstandingHeroCard(
            totalOutstanding: state.overview.totalOutstanding,
            currencySymbol: state.currencySymbol,
            nextDue: state.overview.nextDue,
          ),
          const SizedBox(height: AppSpacing.lg),
          _FilterChips(
            selected: state.filter,
            unpaidCount: state.overview.unpaidCount,
            archivedCount: state.archived.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            _emptyForFilter(context, state.filter)
          else ...[
            Text(
              'Payment History',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: BillListTile(
                  item: item,
                  currencySymbol: state.currencySymbol,
                  onMarkPaid: item.status == BillPaymentStatus.paid
                      ? null
                      : () => context
                          .read<GlobalBillsCubit>()
                          .setPaid(item.bill.id!, isPaid: true),
                  onTap: () => _editBill(context, item),
                  onArchive: () => context.read<GlobalBillsCubit>().setArchived(
                        item.bill.id!,
                        isArchived: !item.bill.isArchived,
                      ),
                  onDelete: () =>
                      context.read<GlobalBillsCubit>().delete(item.bill.id!),
                ),
              ),
          ],
          const SizedBox(height: 90), // clear the bottom nav bar
        ],
      ),
    );
  }

  Widget _emptyForFilter(BuildContext context, BillFilter filter) {
    return switch (filter) {
      BillFilter.all => EmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'No bills yet',
          message: 'Record a bill to track amounts and due dates.',
          actionLabel: 'Add bill',
          onAction: () => _addBill(context),
        ),
      BillFilter.unpaid => const EmptyState(
          icon: Icons.task_alt_rounded,
          title: 'All settled',
          message: 'Every bill you have recorded is marked paid.',
        ),
      BillFilter.archived => const EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Nothing archived',
          message: 'Archived bills are hidden from the main list but kept here.',
        ),
    };
  }

  Future<void> _editBill(BuildContext context, BillListItem item) async {
    final meter = item.meter;
    if (meter == null) return;

    final cubit = context.read<GlobalBillsCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditBillPage(meter: meter, bill: item.bill),
      ),
    );
    await cubit.load();
  }

  /// A bill belongs to a meter, so adding one from the global list needs a
  /// meter first: skip the picker when there is only one.
  Future<void> _addBill(BuildContext context) async {
    final cubit = context.read<GlobalBillsCubit>();
    final meters = await sl<MeterRepository>().getMeters();
    if (!context.mounted) return;

    if (meters.isEmpty) {
      await context.push(RouteNames.newMeter);
      if (context.mounted) await cubit.load();
      return;
    }

    final meter = meters.length == 1
        ? meters.first
        : await _pickMeter(context, meters);
    if (meter == null || !context.mounted) return;

    await context.push(RouteNames.newBill(meter.id!), extra: meter);
    if (context.mounted) await cubit.load();
  }

  Future<Meter?> _pickMeter(BuildContext context, List<Meter> meters) {
    return showModalBottomSheet<Meter>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Which meter is this bill for?',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final meter in meters)
              ListTile(
                title: Text(meter.name),
                subtitle: Text(meter.unit),
                onTap: () => Navigator.of(sheetContext).pop(meter),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.unpaidCount,
    required this.archivedCount,
  });

  final BillFilter selected;
  final int unpaidCount;
  final int archivedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(context, BillFilter.all, 'All Bills'),
        const SizedBox(width: AppSpacing.sm),
        _chip(
          context,
          BillFilter.unpaid,
          unpaidCount > 0 ? 'Unpaid ($unpaidCount)' : 'Unpaid',
        ),
        const SizedBox(width: AppSpacing.sm),
        _chip(
          context,
          BillFilter.archived,
          archivedCount > 0 ? 'Archived ($archivedCount)' : 'Archived',
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, BillFilter filter, String label) {
    final isSelected = filter == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => context.read<GlobalBillsCubit>().setFilter(filter),
    );
  }
}

/// Shared status styling for the bills list, kept next to its only consumers.
extension BillPaymentStatusUi on BillPaymentStatus {
  String get label => switch (this) {
        BillPaymentStatus.paid => 'PAID',
        BillPaymentStatus.unpaid => 'UNPAID',
        BillPaymentStatus.overdue => 'OVERDUE',
      };

  IconData get icon => switch (this) {
        BillPaymentStatus.paid => Icons.check_circle_outline_rounded,
        BillPaymentStatus.unpaid => Icons.schedule_rounded,
        BillPaymentStatus.overdue => Icons.warning_amber_rounded,
      };

  Color color(ColorScheme scheme) => switch (this) {
        BillPaymentStatus.paid => const Color(0xFF00687A),
        BillPaymentStatus.unpaid => scheme.primary,
        BillPaymentStatus.overdue => scheme.error,
      };

  /// Overdue rows get a red wash so they read as urgent in a long list.
  Color? background(ColorScheme scheme) => switch (this) {
        BillPaymentStatus.overdue => scheme.errorContainer.withValues(alpha: 0.35),
        _ => null,
      };
}

/// "Due July 25, 2024", plus urgency wording once a bill is close or late.
String formatDueDate(BillListItem item) {
  final due = item.bill.dueDate;
  if (due == null) return 'No due date';

  final days = item.daysUntilDue;
  if (item.status == BillPaymentStatus.paid || days == null) {
    return 'Due ${Formatters.date(due)}';
  }
  return 'Due ${Formatters.date(due)} · ${Formatters.relativeDays(days)}';
}
