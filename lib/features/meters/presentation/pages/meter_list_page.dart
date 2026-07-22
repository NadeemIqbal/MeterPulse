import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/meter.dart';
import '../cubit/meter_list_cubit.dart';
import '../meter_type_ui.dart';

/// Manage screen: every meter (active and inactive) with edit / activate /
/// delete actions.
class MeterListPage extends StatelessWidget {
  const MeterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeterListCubit>(
      create: (_) => sl<MeterListCubit>()..load(),
      child: const _MeterListView(),
    );
  }
}

class _MeterListView extends StatelessWidget {
  const _MeterListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meters')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMeter(context),
        icon: const Icon(Icons.add),
        label: const Text('Add meter'),
      ),
      body: BlocBuilder<MeterListCubit, MeterListState>(
        builder: (context, state) {
          return switch (state.status) {
            MeterListStatus.loading => const LoadingView(),
            MeterListStatus.error => ErrorView(
                message: state.error ?? 'Could not load meters.',
                onRetry: () => context.read<MeterListCubit>().load(),
              ),
            MeterListStatus.loaded => state.isEmpty
                ? EmptyState(
                    icon: Icons.speed_rounded,
                    title: 'No meters yet',
                    message: 'Add a meter to start tracking.',
                    actionLabel: 'Add meter',
                    onAction: () => _addMeter(context),
                  )
                : ListView.separated(
                    padding: AppSpacing.page,
                    itemCount: state.meters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _MeterTile(meter: state.meters[index]),
                  ),
          };
        },
      ),
    );
  }

  static Future<void> _addMeter(BuildContext context) async {
    final cubit = context.read<MeterListCubit>();
    await context.push(RouteNames.newMeter);
    await cubit.load();
  }
}

class _MeterTile extends StatelessWidget {
  const _MeterTile({required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = meter.accent(scheme);

    return Opacity(
      opacity: meter.isActive ? 1 : 0.55,
      child: AppCard(
        onTap: () => _edit(context),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: 0.16),
              child: Icon(meter.displayIcon, color: accent),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          meter.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!meter.isActive) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _tag(context, 'Inactive'),
                      ],
                    ],
                  ),
                  Text(
                    meter.meterNumber?.isNotEmpty == true
                        ? '${meter.type.label} · ${meter.meterNumber}'
                        : meter.type.label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _onMenu(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(meter.isActive ? 'Deactivate' : 'Activate'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.chip)),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }

  Future<void> _onMenu(BuildContext context, String value) async {
    final cubit = context.read<MeterListCubit>();
    switch (value) {
      case 'edit':
        await _edit(context);
      case 'toggle':
        await cubit.toggleActive(meter);
      case 'delete':
        await _confirmDelete(context);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<MeterListCubit>();
    await context.push(RouteNames.editMeter(meter.id!), extra: meter);
    await cubit.load();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<MeterListCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete meter?'),
        content: Text(
          'This permanently deletes "${meter.name}" and all its readings and '
          'bills. This cannot be undone.',
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
    if (confirmed == true && meter.id != null) {
      await cubit.delete(meter.id!);
    }
  }
}
