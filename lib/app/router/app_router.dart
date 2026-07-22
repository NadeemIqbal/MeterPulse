import 'package:go_router/go_router.dart';

import '../../features/bills/presentation/pages/add_edit_bill_page.dart';
import '../../features/bills/presentation/pages/bill_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/meters/domain/entities/meter.dart';
import '../../features/meters/presentation/pages/add_edit_meter_page.dart';
import '../../features/meters/presentation/pages/meter_detail_page.dart';
import '../../features/meters/presentation/pages/meter_list_page.dart';
import '../../features/readings/presentation/pages/reading_capture_page.dart';
import '../../features/readings/presentation/pages/reading_history_page.dart';
import '../../features/readings/presentation/pages/statistics_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'meter_resolver.dart';
import 'route_names.dart';

/// Builds the app's [GoRouter]. Static sub-paths (`/meters/new`) are declared
/// before the `:id` route so they match first.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: RouteNames.dashboard,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/meters',
        builder: (context, state) => const MeterListPage(),
      ),
      GoRoute(
        path: '/meters/new',
        builder: (context, state) => const AddEditMeterPage(),
      ),
      GoRoute(
        path: '/meters/:id',
        builder: (context, state) => MeterResolver(
          meterId: _id(state),
          meter: state.extra as Meter?,
          builder: (meter) => MeterDetailPage(meter: meter),
        ),
      ),
      GoRoute(
        path: '/meters/:id/edit',
        builder: (context, state) => MeterResolver(
          meterId: _id(state),
          meter: state.extra as Meter?,
          builder: (meter) => AddEditMeterPage(meter: meter),
        ),
      ),
      GoRoute(
        path: '/meters/:id/reading',
        builder: (context, state) => MeterResolver(
          meterId: _id(state),
          meter: state.extra as Meter?,
          builder: (meter) => ReadingCapturePage(meter: meter),
        ),
      ),
      GoRoute(
        path: '/meters/:id/history',
        builder: (context, state) => MeterResolver(
          meterId: _id(state),
          meter: state.extra as Meter?,
          builder: (meter) => ReadingHistoryPage(meter: meter),
        ),
      ),
      GoRoute(
        path: '/meters/:id/stats',
        builder: (context, state) => MeterResolver(
          meterId: _id(state),
          meter: state.extra as Meter?,
          builder: (meter) => StatisticsPage(meter: meter),
        ),
      ),
      GoRoute(
        path: '/meters/:id/bills',
        builder: (context, state) => MeterResolver(
          meterId: _id(state),
          meter: state.extra as Meter?,
          builder: (meter) => BillListPage(meter: meter),
        ),
      ),
      GoRoute(
        path: '/meters/:id/bill',
        builder: (context, state) => MeterResolver(
          meterId: _id(state),
          meter: state.extra as Meter?,
          builder: (meter) => AddEditBillPage(meter: meter),
        ),
      ),
    ],
  );
}

int _id(GoRouterState state) => int.parse(state.pathParameters['id']!);
