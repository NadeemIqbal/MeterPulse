import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/presentation/meter_type_ui.dart';
import '../../domain/entities/meter_stats.dart';
import '../cubit/reading_history_cubit.dart';

/// Aggregate statistics for a meter. Charts arrive in Phase 2; Phase 1 shows the
/// computed figures.
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReadingHistoryCubit>(
      create: (_) => sl<ReadingHistoryCubit>()..load(meter),
      child: Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: BlocBuilder<ReadingHistoryCubit, ReadingHistoryState>(
          builder: (context, state) {
            return switch (state.status) {
              HistoryStatus.loading => const LoadingView(),
              HistoryStatus.error => ErrorView(
                  message: state.error ?? 'Could not load statistics.',
                  onRetry: () => context.read<ReadingHistoryCubit>().load(meter),
                ),
              HistoryStatus.loaded => state.isEmpty
                  ? const EmptyState(
                      icon: Icons.insights_rounded,
                      title: 'Nothing to summarise yet',
                      message: 'Take a few readings to see usage statistics.',
                    )
                  : _stats(context, state.stats),
            };
          },
        ),
      ),
    );
  }

  Widget _stats(BuildContext context, MeterStats stats) {
    final unit = meter.unit;
    final tiles = <Widget>[
      _tile('Total consumed', Formatters.units(stats.totalUnits), unit),
      _tile('Avg / month', Formatters.units(stats.averageMonthly), unit),
      _tile('Avg / year', Formatters.units(stats.averageYearly), unit),
      _tile('Highest reading', Formatters.units(stats.highestReading), unit),
      _tile('Lowest reading', Formatters.units(stats.lowestReading), unit),
      _tile('Cycles tracked', Formatters.whole(stats.cycleCount), null),
      _tile('Readings taken', Formatters.whole(stats.readingCount), null),
    ];

    return ListView(
      padding: AppSpacing.page,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 96,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) => tiles[index],
        ),
        const SizedBox(height: AppSpacing.lg),
        _chartsComingSoon(context),
      ],
    );
  }

  Widget _tile(String label, String value, String? unit) {
    return AppCard(
      child: StatTile(label: label, value: value, unit: unit, icon: meter.type.icon),
    );
  }

  Widget _chartsComingSoon(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.show_chart_rounded, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Usage charts and trends arrive in a future update.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
