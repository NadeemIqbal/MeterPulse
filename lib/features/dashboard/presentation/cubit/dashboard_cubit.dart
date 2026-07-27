import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../../core/services/notification_service.dart';
import '../../../billing_cycles/domain/entities/billing_cycle.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../bills/domain/repositories/bill_repository.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/domain/entities/meter_type.dart';
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

  /// Reorders meter cards on the dashboard and persists the updated order.
  Future<void> reorderSummaries(int oldIndex, int newIndex) async {
    if (state.status != DashboardStatus.loaded) return;
    final list = List<MeterSummary>.from(state.summaries);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    emit(DashboardState(status: DashboardStatus.loaded, summaries: list));

    final orderedIds =
        list.map((s) => s.meter.id).whereType<int>().toList();
    await _meters.updateMeterOrders(orderedIds);
  }

  /// Reschedules reading/bill reminders on app open (the app has no background
  /// jobs, so this "catch-up" reschedule is how reminders stay current).
  /// Entirely best-effort — notification failures never affect the dashboard.
  Future<void> _syncNotifications(List<MeterSummary> summaries) async {
    try {
      final settings = await _settings.getSettings();
      if (!settings.anyNotificationsOn) {
        await _notifications.cancelAll();
        return;
      }
      final minutes = settings.reminderTimeMinutes ?? 8 * 60; // default 8am
      for (final s in summaries) {
        final meterId = s.meter.id;
        if (meterId == null) continue;

        final readingDue =
            settings.readingRemindersOn ? s.cycle?.expectedReadingDate : null;
        if (readingDue != null) {
          await _notifications.scheduleReadingReminder(
            meterId: meterId,
            meterName: s.meter.name,
            when: _at(readingDue, minutes),
          );
        }

        final bill = settings.billAlertsOn ? s.latestBill : null;
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
      if (meter.id == null) continue;
      final cycle = await _cycles.getOpenCycle(meter.id!);
      final cycleReadings = cycle == null
          ? const <Reading>[]
          : await _readings.getReadingsForCycle(cycle.id!);
      final latestBill = await _bills.getLatestBill(meter.id!);

      Reading? previousOverride;
      final allReadings = await _readings.getReadingsForMeter(meter.id!);
      if (allReadings.isNotEmpty) {
        final current = cycleReadings.isNotEmpty ? cycleReadings.last : allReadings.first;
        final candidates = allReadings.where((r) => current.id == null || r.id != current.id).toList();
        if (candidates.isNotEmpty) {
          previousOverride = candidates.firstWhere(
            (r) =>
                r.readingDate.isBefore(current.readingDate) ||
                (r.readingDate.isAtSameMomentAs(current.readingDate) &&
                    (r.id ?? 0) < (current.id ?? 0)),
            orElse: () => candidates.first,
          );
        }
      }


      summaries.add(
        _compute(
          meter: meter,
          cycle: cycle,
          cycleReadings: cycleReadings,
          latestBill: latestBill,
          now: now,
          previousReadingOverride: previousOverride,
        ),
      );
    }
    return summaries;
  }

  /// Adds sample meters and readings so the user can immediately experience the app.
  Future<void> addDemoData() async {
    emit(const DashboardState(status: DashboardStatus.loading));
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 15);
    final readingDate = now;

    // 1. Electricity Meter
    final elecMeter = Meter(
      name: 'Main Electricity',
      type: MeterType.electricity,
      unit: 'kWh',
      expectedReadingDayOfMonth: 15,
      highUsageThreshold: 300,
      createdAt: now,
    );
    final elecId = await _meters.saveMeter(elecMeter);

    final elecCycle = BillingCycle(
      meterId: elecId,
      cycleStartDate: startDate,
      expectedReadingDate: DateTime(now.year, now.month + 1, 14),
      createdAt: now,
    );
    final elecCycleId = await _cycles.saveCycle(elecCycle);

    await _readings.saveReading(
      Reading(
        meterId: elecId,
        billingCycleId: elecCycleId,
        readingValue: 1200.0,
        readingDate: startDate,
        createdAt: startDate,
      ),
    );
    await _readings.saveReading(
      Reading(
        meterId: elecId,
        billingCycleId: elecCycleId,
        readingValue: 1320.0,
        readingDate: readingDate,
        createdAt: readingDate,
      ),
    );

    // 2. Gas Meter
    final gasMeter = Meter(
      name: 'Gas Line',
      type: MeterType.gas,
      unit: 'm³',
      expectedReadingDayOfMonth: 15,
      highUsageThreshold: 100,
      createdAt: now,
    );
    final gasId = await _meters.saveMeter(gasMeter);

    final gasCycle = BillingCycle(
      meterId: gasId,
      cycleStartDate: startDate,
      expectedReadingDate: DateTime(now.year, now.month + 1, 14),
      createdAt: now,
    );
    final gasCycleId = await _cycles.saveCycle(gasCycle);

    await _readings.saveReading(
      Reading(
        meterId: gasId,
        billingCycleId: gasCycleId,
        readingValue: 450.0,
        readingDate: startDate,
        createdAt: startDate,
      ),
    );
    await _readings.saveReading(
      Reading(
        meterId: gasId,
        billingCycleId: gasCycleId,
        readingValue: 485.0,
        readingDate: readingDate,
        createdAt: readingDate,
      ),
    );

    await load();
  }
}
