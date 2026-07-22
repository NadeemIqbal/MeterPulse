/// User's theme preference, persisted in settings.
///
/// Kept independent of Flutter's `ThemeMode` so the data/domain layers don't
/// import `material.dart`; the presentation layer maps between the two.
enum AppThemeMode { system, light, dark }
