import '../entities/bill.dart';

/// Persistence contract for bills.
abstract interface class BillRepository {
  /// A meter's bills, newest first.
  Future<List<Bill>> getBillsForMeter(int meterId);

  /// Every bill across all meters, newest first. Backs the global bills screen.
  Future<List<Bill>> getAllBills();

  /// The most recent bill for a meter, or null if none.
  Future<Bill?> getLatestBill(int meterId);

  /// A single bill by id, or null if it no longer exists.
  Future<Bill?> getBill(int id);

  Future<int> saveBill(Bill bill);

  Future<void> setPaid(int id, {required bool isPaid});

  Future<void> setArchived(int id, {required bool isArchived});

  Future<void> deleteBill(int id);
}
