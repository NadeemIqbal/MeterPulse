import '../entities/billing_cycle.dart';

/// Persistence contract for billing cycles.
abstract interface class BillingCycleRepository {
  /// The single open (active) cycle for a meter, or null if none exists yet.
  Future<BillingCycle?> getOpenCycle(int meterId);

  /// All cycles for a meter, newest first.
  Future<List<BillingCycle>> getCyclesForMeter(int meterId);

  Future<BillingCycle?> getCycle(int id);

  Future<int> saveCycle(BillingCycle cycle);
}
