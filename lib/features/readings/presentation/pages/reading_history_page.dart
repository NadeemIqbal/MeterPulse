import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../meters/domain/entities/meter.dart';
import '../cubit/reading_history_cubit.dart';
import '../widgets/consumption_timeline_view.dart';

/// Full reading history: every cycle rendered as a consumption timeline, newest
/// first.
class ReadingHistoryPage extends StatelessWidget {
  const ReadingHistoryPage({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReadingHistoryCubit>(
      create: (_) => sl<ReadingHistoryCubit>()..load(meter),
      child: Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: BlocBuilder<ReadingHistoryCubit, ReadingHistoryState>(
          builder: (context, state) {
            return switch (state.status) {
              HistoryStatus.loading => const LoadingView(),
              HistoryStatus.error => ErrorView(
                  message: state.error ?? 'Could not load history.',
                  onRetry: () => context.read<ReadingHistoryCubit>().load(meter),
                ),
              HistoryStatus.loaded => state.isEmpty
                  ? const EmptyState(
                      icon: Icons.timeline_rounded,
                      title: 'No history yet',
                      message: 'Readings you take will appear here, grouped by '
                          'billing cycle.',
                    )
                  : ListView.separated(
                      padding: AppSpacing.page,
                      itemCount: state.timelines.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) => ConsumptionTimelineView(
                        timeline: state.timelines[index],
                        meter: meter,
                      ),
                    ),
            };
          },
        ),
      ),
    );
  }
}
