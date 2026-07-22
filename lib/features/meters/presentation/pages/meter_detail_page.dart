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
import '../../../readings/presentation/cubit/reading_history_cubit.dart';
import '../../../readings/presentation/widgets/consumption_timeline_view.dart';
import '../../domain/entities/meter.dart';
import '../meter_type_ui.dart';

/// Per-meter overview: accent header, quick actions, and the current cycle's
/// consumption timeline. Links out to full history and statistics.
class MeterDetailPage extends StatelessWidget {
  const MeterDetailPage({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReadingHistoryCubit>(
      create: (_) => sl<ReadingHistoryCubit>()..load(meter),
      child: _MeterDetailView(meter: meter),
    );
  }
}

class _MeterDetailView extends StatelessWidget {
  const _MeterDetailView({required this.meter});

  final Meter meter;

  void _reload(BuildContext context) =>
      context.read<ReadingHistoryCubit>().load(meter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meter.name),
        actions: [
          IconButton(
            tooltip: 'Edit meter',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              await context.push(RouteNames.editMeter(meter.id!), extra: meter);
              if (context.mounted) _reload(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<ReadingHistoryCubit, ReadingHistoryState>(
        builder: (context, state) {
          return switch (state.status) {
            HistoryStatus.loading => const LoadingView(),
            HistoryStatus.error => ErrorView(
                message: state.error ?? 'Could not load this meter.',
                onRetry: () => _reload(context),
              ),
            HistoryStatus.loaded => ListView(
                padding: AppSpacing.page,
                children: [
                  _headerCard(context),
                  const SizedBox(height: AppSpacing.md),
                  _actions(context),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.isEmpty)
                    _noReadings(context)
                  else ...[
                    ConsumptionTimelineView(
                      timeline: state.timelines.first,
                      meter: meter,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () => _goHistory(context),
                      icon: const Icon(Icons.timeline_rounded),
                      label: const Text('View full history'),
                    ),
                  ],
                ],
              ),
          };
        },
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = meter.accent(scheme);

    return AppCard(
      child: Row(
        children: [
          Hero(
            tag: 'meter-avatar-${meter.id}',
            child: CircleAvatar(
              radius: 28,
              backgroundColor: accent.withValues(alpha: 0.16),
              child: Icon(meter.displayIcon, color: accent, size: 30),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meter.type.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (meter.meterNumber?.isNotEmpty == true)
                  Text(
                    'No. ${meter.meterNumber}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                Text(
                  'Reads on day ${meter.expectedReadingDayOfMonth} · ${meter.unit}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _goReading(context),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Take reading'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.push(RouteNames.newBill(meter.id!), extra: meter);
                  if (context.mounted) _reload(context);
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Bill'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _goStats(context),
                icon: const Icon(Icons.insights_rounded),
                label: const Text('Stats'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _noReadings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: EmptyState(
        icon: Icons.camera_alt_rounded,
        title: 'No readings yet',
        message: 'Take your first reading to start this meter\'s timeline.',
        actionLabel: 'Take reading',
        onAction: () => _goReading(context),
      ),
    );
  }

  Future<void> _goReading(BuildContext context) async {
    await context.push(RouteNames.takeReading(meter.id!), extra: meter);
    if (context.mounted) _reload(context);
  }

  void _goHistory(BuildContext context) =>
      context.push(RouteNames.history(meter.id!), extra: meter);

  void _goStats(BuildContext context) =>
      context.push(RouteNames.stats(meter.id!), extra: meter);
}
