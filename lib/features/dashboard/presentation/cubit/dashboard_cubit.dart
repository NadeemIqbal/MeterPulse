import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../../core/services/notification_service.dart';
import '../../../bills/domain/repositories/bill_repository.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../meters/domain/repositories/meter_repository.dart';
import '../../../readings/domain/entities/reading.dart';
import '../../../readings/domain/repositories/reading_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/meter_summary.dart';
import '../../domain/usecases/compute_meter_summary.dart';

enum DashboardStatus { loading, loaded, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.summaries = const [],
    this.error,
  });

  final DashboardStatus status;
  final List<MeterSummary> summaries;
  final String? error;

  bool get isEmpty =>
      status == DashboardStatus.loaded && summaries.isEmpty;

  /// Total units used across all active meters this cycle.
  double get totalUnitsUsed =>
      summaries.fold(0, (sum, s) => sum + (s.unitsUsed ?? 0));

  MeterSummary? get highestConsumer => summaries.isEmpty
      ? null
      : summaries.reduce((a, b) => (a.unitsUsed ?? 0) >= (b.unitsUsed ?? 0) ? a : b);

  MeterSummary? get lowestConsumer => summaries.isEmpty
      ? null
      : summaries.reduce((a, b) => (a.unitsUsed ?? 0) <= (b.unitsUsed ?? 0) ? a : b);

  @override
  List<Object?> get props => [status, summaries, error];
}

/// Loads active meters and builds a [MeterSummary] for each by pulling the open
/// cycle, its readings and the latest bill, then delegating to
/// [ComputeMeterSummary]. Reloaded whenever the dashboard is (re)shown so
/// "days remaining"/status recompute against the current date.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required MeterRepository meterRepository,
    required ReadingRepository readingRepository,
    required BillingCycleRepository cycleRepository,
    required BillRepository billRepository,
    required SettingsRepository settingsRepository,
    required NotificationService notificationService,
    ComputeMeterSummary compute = const ComputeMeterSummary(),
  })  : _meters = meterRepository,
        _readings = readingRepository,
        _cycles = cycleRepository,
        _bills = billRepository,
        _settings = settingsRepository,
        _notifications = notificationService,
        _compute = compute,
        super(const DashboardState());

  final MeterRepository _meters;
  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;
  final BillRepository _bills;
  final SettingsRepository _settings;
  final NotificationService _notifications;
  final ComputeMeterSummary _compute;

  Future<void> load() async {
    emit(const DashboardState(status: DashboardStatus.loading));
    final result = await guard(_buildSummaries);
    switch (result) {
      case Ok(:final value):
        emit(DashboardState(status: DashboardStatus.loaded, summaries: value));
        // Best-effort: reschedule reminders against the current data. Not
        // awaited so it never delays the dashboard render.
        _syncNotifications(value);
      case Err(:final failure):
        emit(DashboardState(
          status: DashboardStatus.error,
          error: failure.message,
        ));
    }
  }

  /// Reschedules reading/bill reminders on app open (the app has no background
  /// jobs, so this "catch-up" reschedule is how reminders stay current).
  /// Entirely best-effort — notification failures never affect the dashboard.
  Future<void> _syncNotifications(List<MeterSummary> summaries) async {
    try {
      final settings = await _settings.getSettings();
      if (!(settings.notificationsEnabled ?? false)) {
        await _notifications.cancelAll();
        return;
      }
      final minutes = settings.reminderTimeMinutes ?? 8 * 60; // default 8am
      for (final s in summaries) {
        final meterId = s.meter.id;
        if (meterId == null) continue;

        final readingDue = s.cycle?.expectedReadingDate;
        if (readingDue != null) {
          await _notifications.scheduleReadingReminder(
            meterId: meterId,
            meterName: s.meter.name,
            when: _at(readingDue, minutes),
          );
        }

        final bill = s.latestBill;
        final billDue = (bill != null && !bill.isPaid) ? bill.dueDate : null;
        if (billDue != null) {
          await _notifications.scheduleBillReminder(
            meterId: meterId,
            meterName: s.meter.name,
            when: _at(billDue, minutes),
          );
        }
      }
    } catch (_) {
      // Notifications are best-effort.
    }
  }

  DateTime _at(DateTime date, int minutesFromMidnight) => DateTime(
        date.year,
        date.month,
        date.day,
        minutesFromMidnight ~/ 60,
        minutesFromMidnight % 60,
      );

  Future<List<MeterSummary>> _buildSummaries() async {
    final meters = await _meters.getMeters();
    final now = DateTime.now();
    final summaries = <MeterSummary>[];
    for (final meter in meters) {
      final cycle = await _cycles.getOpenCycle(meter.id!);
      final cycleReadings = cycle == null
          ? const <Reading>[]
          : await _readings.getReadingsForCycle(cycle.id!);
      final latestBill = await _bills.getLatestBill(meter.id!);
      summaries.add(
        _compute(
          meter: meter,
          cycle: cycle,
          cycleReadings: cycleReadings,
          latestBill: latestBill,
          now: now,
        ),
      );
    }
    return summaries;
  }
}
