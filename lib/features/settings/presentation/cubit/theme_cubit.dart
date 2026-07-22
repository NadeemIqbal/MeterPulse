import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/settings_repository.dart';

/// Holds the app-wide theme preference. Registered as a singleton (it sits
/// above `MaterialApp`). [load] is awaited during startup so the first frame
/// paints in the right mode with no flash.
class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit(this._repo) : super(AppThemeMode.system);

  final SettingsRepository _repo;

  Future<void> load() async {
    final settings = await _repo.getSettings();
    emit(settings.themeMode);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    final current = await _repo.getSettings();
    await _repo.saveSettings(current.copyWith(themeMode: mode));
  }
}
