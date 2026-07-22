import 'package:flutter/widgets.dart';

/// 4dp-based spacing scale. Use these tokens instead of magic numbers so gaps
/// and padding stay consistent across every screen.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Standard screen edge padding.
  static const EdgeInsets page = EdgeInsets.all(lg);

  /// Padding inside cards.
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Minimum comfortable touch-target size (Material guidance).
  static const double minTouchTarget = 48;
}

/// Corner-radius tokens for the rounded, minimal Material You look.
abstract final class AppRadius {
  static const double card = 20;
  static const double field = 14;
  static const double button = 14;
  static const double chip = 999;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(field));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
}
