import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/theme/app_theme.dart';
import 'package:meter_pulse/features/dashboard/domain/entities/meter_summary.dart';
import 'package:meter_pulse/features/dashboard/presentation/widgets/meter_summary_card.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter_type.dart';
import 'package:meter_pulse/features/readings/domain/entities/reading.dart';

/// Regression cover for the blank-dashboard bug: the app theme sets
/// `minimumSize: Size.fromHeight(52)`, and `Size.fromHeight` puts
/// `double.infinity` in the *width*. A themed FilledButton/OutlinedButton
/// placed directly in a Row (which hands non-flex children an unbounded main
/// axis) then asks for an infinite width, the layout assertion throws, the
/// card never gets a size, and the enclosing sliver takes the whole list down
/// with it — the dashboard renders completely empty.
void main() {
  final meter = Meter(
    id: 1,
    name: 'Main Electricity',
    type: MeterType.electricity,
    unit: 'kWh',
    expectedReadingDayOfMonth: 25,
    highUsageThreshold: 300,
    createdAt: DateTime(2026, 1, 1),
  );

  final reading = Reading(
    id: 10,
    meterId: 1,
    readingValue: 1250,
    readingDate: DateTime(2026, 7, 20),
    createdAt: DateTime(2026, 7, 20),
  );

  final summary = MeterSummary(
    meter: meter,
    currentReading: reading,
    unitsUsed: 120,
    averagePerDay: 6,
    readingCount: 2,
    readingStatus: ReadingStatus.upToDate,
    billStatus: BillStatus.noBill,
  );

  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light(null),
        home: Scaffold(
          body: ListView(padding: const EdgeInsets.all(16), children: [child]),
        ),
      );

  testWidgets('lays out inside a ListView without throwing', (tester) async {
    await tester.pumpWidget(host(MeterSummaryCard(summary: summary)));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Main Electricity'), findsOneWidget);
  });

  testWidgets('the card and its action bar get a real size', (tester) async {
    await tester.pumpWidget(host(MeterSummaryCard(summary: summary)));
    await tester.pump();

    // A zero/missing size here is what previously cascaded into the sliver
    // assertion and blanked the entire dashboard.
    final cardSize = tester.getSize(find.byType(MeterSummaryCard));
    expect(cardSize.height, greaterThan(0));
    expect(cardSize.width, greaterThan(0));

    expect(find.text('Take Reading'), findsOneWidget);
    expect(tester.getSize(find.text('Take Reading')).width, greaterThan(0));
  });

  testWidgets('lays out inside the ReorderableListView the dashboard uses',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(null),
        home: Scaffold(
          body: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            header: const SizedBox(height: 24),
            itemCount: 1,
            onReorder: (_, _) {},
            itemBuilder: (context, index) => Padding(
              key: const ValueKey('meter-card-1'),
              padding: const EdgeInsets.only(bottom: 12),
              child: MeterSummaryCard(summary: summary, index: index),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Main Electricity'), findsOneWidget);
  });

  testWidgets('a themed FilledButton in a Row must not demand infinite width',
      (tester) async {
    // Guards the underlying footgun directly, so re-introducing a bare themed
    // button inside a Row fails here rather than silently blanking a screen.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(null),
        home: Scaffold(
          body: Row(
            children: [
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                child: const Text('Pay Now'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
