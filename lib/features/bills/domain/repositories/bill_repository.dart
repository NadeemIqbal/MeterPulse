import '../entities/bill.dart';

/// Persistence contract for bills.
abstract interface class BillRepository {
  /// A meter's bills, newest first.
  Future<List<Bill>> getBillsForMeter(int meterId);

  /// The most recent bill for a meter, or null if none.
  Future<Bill?> getLatestBill(int meterId);

  Future<int> saveBill(Bill bill);

  Future<void> setPaid(int id, {required bool isPaid});

  Future<void> deleteBill(int id);
}
