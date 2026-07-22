import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../meters/domain/entities/meter.dart';
import '../cubit/bill_cubit.dart';
import '../widgets/bill_card.dart';
import 'add_edit_bill_page.dart';

/// Lists a meter's bills with add / mark-paid / delete.
class BillListPage extends StatelessWidget {
  const BillListPage({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillCubit>(
      create: (_) => sl<BillCubit>()..load(meter.id!),
      child: _BillListView(meter: meter),
    );
  }
}

class _BillListView extends StatelessWidget {
  const _BillListView({required this.meter});

  final Meter meter;

  Future<void> _addBill(BuildContext context) async {
    final cubit = context.read<BillCubit>();
    await context.push(RouteNames.newBill(meter.id!), extra: meter);
    await cubit.load(meter.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addBill(context),
        icon: const Icon(Icons.add),
        label: const Text('Add bill'),
      ),
      body: BlocBuilder<BillCubit, BillListState>(
        builder: (context, state) {
          return switch (state.status) {
            BillListStatus.loading => const LoadingView(),
            BillListStatus.error => ErrorView(
                message: state.error ?? 'Could not load bills.',
                onRetry: () => context.read<BillCubit>().load(meter.id!),
              ),
            BillListStatus.loaded => state.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'No bills yet',
                    message: 'Record a bill to track amounts and due dates.',
                    actionLabel: 'Add bill',
                    onAction: () => _addBill(context),
                  )
                : ListView.separated(
                    padding: AppSpacing.page,
                    itemCount: state.bills.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final bill = state.bills[index];
                      return BillCard(
                        bill: bill,
                        unit: meter.unit,
                        onEdit: () async {
                          final cubit = context.read<BillCubit>();
                          // Edit carries the bill via a direct route push
                          // (GoRouter `extra` is reserved for the Meter).
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  AddEditBillPage(meter: meter, bill: bill),
                            ),
                          );
                          await cubit.load(meter.id!);
                        },
                        onTogglePaid: () => context
                            .read<BillCubit>()
                            .setPaid(bill.id!, isPaid: !bill.isPaid),
                        onDelete: () =>
                            context.read<BillCubit>().delete(bill.id!),
                      );
                    },
                  ),
          };
        },
      ),
    );
  }
}
