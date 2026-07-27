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
import '../../domain/entities/meter_list_item.dart';
import '../cubit/meter_list_cubit.dart';
import '../meter_type_ui.dart';

/// Manage screen: every meter (active and inactive) with its latest reading,
/// threshold progress, a live-tracking switch and edit / delete actions.
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
      appBar: AppBar(title: const Text('Manage Meters')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMeter(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Meter'),
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
                : _content(context, state),
          };
        },
      ),
    );
  }

  Widget _content(BuildContext context, MeterListState state) {
    final theme = Theme.of(context);
    final items = state.visibleItems;

    return RefreshIndicator(
      onRefresh: () => context.read<MeterListCubit>().load(),
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Meters',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${state.totalCount} total '
                      '${state.totalCount == 1 ? 'monitor' : 'monitors'} '
                      'connected',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.insights_rounded,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SearchField(query: state.query),
          const SizedBox(height: AppSpacing.md),
          if (state.isFilteredEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No meters match "${state.query}".',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MeterCard(item: item),
              ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static Future<void> _addMeter(BuildContext context) async {
    final cubit = context.read<MeterListCubit>();
    await context.push(RouteNames.newMeter);
    await cubit.load();
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.query});

  final String query;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.query);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) => context.read<MeterListCubit>().search(value),
      decoration: InputDecoration(
        hintText: 'Search meters…',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _controller.clear();
                  context.read<MeterListCubit>().search('');
                },
              ),
      ),
    );
  }
}

class _MeterCard extends StatelessWidget {
  const _MeterCard({required this.item});

  final MeterListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final meter = item.meter;
    final accent = meter.accent(scheme);
    final isActive = meter.isActive;

    return Opacity(
      opacity: isActive ? 1 : 0.6,
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _edit(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isActive
                            ? accent
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        meter.displayIcon,
                        color: isActive ? Colors.white : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meter.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          _StatusChip(isActive: isActive, accent: accent),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit meter',
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _edit(context),
                    ),
                    IconButton(
                      tooltip: 'Delete meter',
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.hasReading ? 'Current Reading' : 'No readings yet',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    if (item.hasReading)
                      Text(
                        '${Formatters.reading(item.latestReading!.readingValue)}'
                        ' ${meter.unit}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (item.progress != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.units(item.unitsThisCycle)} of '
                    '${Formatters.units(item.threshold)} ${meter.unit} '
                    'this cycle',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Live Tracking',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: isActive,
                      onChanged: (_) =>
                          context.read<MeterListCubit>().toggleActive(meter),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<MeterListCubit>();
    await context.push(RouteNames.editMeter(item.meter.id!), extra: item.meter);
    await cubit.load();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<MeterListCubit>();
    final meter = item.meter;
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
    if ((confirmed ?? false) && meter.id != null) {
      await cubit.delete(meter.id!);
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive, required this.accent});

  final bool isActive;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? accent : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
