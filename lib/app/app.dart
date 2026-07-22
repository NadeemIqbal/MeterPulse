import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/domain/entities/app_theme_mode.dart';
import '../features/settings/presentation/app_theme_mode_x.dart';
import '../features/settings/presentation/cubit/theme_cubit.dart';

/// Root widget. Provides the app-global [ThemeCubit] above [MaterialApp] and
/// builds light/dark themes from the device's dynamic (Material You) colours,
/// falling back to a seed scheme when none are available.
class MeterPulseApp extends StatelessWidget {
  const MeterPulseApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, mode) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              return MaterialApp.router(
                title: 'MeterPulse',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(lightDynamic?.harmonized()),
                darkTheme: AppTheme.dark(darkDynamic?.harmonized()),
                themeMode: mode.material,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
