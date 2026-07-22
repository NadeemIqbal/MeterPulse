import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../features/meters/domain/entities/meter.dart';
import '../../features/meters/domain/repositories/meter_repository.dart';

/// Resolves the [Meter] a meter-scoped route needs.
///
/// Navigation from the dashboard/list passes the [Meter] via GoRouter `extra`
/// for an instant build; if that's absent (e.g. after a process restart on a
/// deep link) it loads by [meterId] so the route still works.
class MeterResolver extends StatelessWidget {
  const MeterResolver({
    super.key,
    required this.meterId,
    this.meter,
    required this.builder,
  });

  final int meterId;
  final Meter? meter;
  final Widget Function(Meter meter) builder;

  @override
  Widget build(BuildContext context) {
    if (meter != null) return builder(meter!);

    return FutureBuilder<Meter?>(
      future: sl<MeterRepository>().getMeter(meterId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: LoadingView(itemCount: 1));
        }
        final resolved = snapshot.data;
        if (resolved == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'That meter could no longer be found.'),
          );
        }
        return builder(resolved);
      },
    );
  }
}
