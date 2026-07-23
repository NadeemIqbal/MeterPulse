import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/calculation_engine/consumption_calculator.dart';
import '../../bills/domain/repositories/bill_repository.dart';
import '../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../meters/domain/repositories/meter_repository.dart';
import '../../readings/domain/repositories/reading_repository.dart';

/// Exports all readings and bills as two CSV files and opens the share sheet
/// so the user can save/send them. Fully offline; nothing is uploaded.
class ExportService {
  ExportService({
    required MeterRepository meterRepository,
    required ReadingRepository readingRepository,
    required BillingCycleRepository cycleRepository,
    required BillRepository billRepository,
  })  : _meters = meterRepository,
        _readings = readingRepository,
        _cycles = cycleRepository,
        _bills = billRepository;

  final MeterRepository _meters;
  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;
  final BillRepository _bills;

  Future<void> exportAll() async {
    final meters = await _meters.getMeters(includeInactive: true);

    final readingRows = <List<dynamic>>[
      ['Meter', 'Meter number', 'Type', 'Cycle start', 'Reading date',
        'Reading', 'Units consumed', 'Notes'],
    ];
    final billRows = <List<dynamic>>[
      ['Meter', 'Bill date', 'Due date', 'Amount', 'Units billed', 'Paid',
        'Notes'],
    ];

    for (final meter in meters) {
      final cycles = await _cycles.getCyclesForMeter(meter.id!);
      // Oldest cycle first for a natural chronological export.
      for (final cycle in cycles.reversed) {
        final readings = await _readings.getReadingsForCycle(cycle.id!);
        for (var i = 0; i < readings.length; i++) {
          final consumed = i == 0
              ? null
              : unitsConsumed(
                  readings[i].readingValue,
                  readings[i - 1].readingValue,
                  rolloverMax: meter.rolloverValue,
                ).units;
          readingRows.add([
            meter.name,
            meter.meterNumber ?? '',
            meter.type.name,
            _date(cycle.cycleStartDate),
            _date(readings[i].readingDate),
            readings[i].readingValue,
            consumed ?? '',
            readings[i].notes ?? '',
          ]);
        }
      }

      final bills = await _bills.getBillsForMeter(meter.id!);
      for (final bill in bills) {
        billRows.add([
          meter.name,
          _date(bill.billDate),
          bill.dueDate == null ? '' : _date(bill.dueDate!),
          bill.billAmount,
          bill.unitsBilled ?? '',
          bill.isPaid ? 'Yes' : 'No',
          bill.notes ?? '',
        ]);
      }
    }

    final dir = await getTemporaryDirectory();
    const converter = CsvEncoder();
    final readingsFile = File('${dir.path}/meterpulse-readings.csv');
    await readingsFile.writeAsString(converter.convert(readingRows));
    final billsFile = File('${dir.path}/meterpulse-bills.csv');
    await billsFile.writeAsString(converter.convert(billRows));

    await Share.shareXFiles(
      [XFile(readingsFile.path), XFile(billsFile.path)],
      subject: 'MeterPulse export',
      text: 'MeterPulse readings and bills (CSV).',
    );
  }

  String _date(DateTime d) => d.toIso8601String().split('T').first;
}
