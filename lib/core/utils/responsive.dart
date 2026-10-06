import 'package:flutter/widgets.dart';

/// Lightweight responsive helpers. Desktop-first, graceful down to mobile.
class Responsive {
  Responsive._();

  static const double mobileMax = 640;
  static const double tabletMax = 1024;

  static bool isMobile(BuildContext c) =>
      MediaQuery.sizeOf(c).width <= mobileMax;

  static bool isTablet(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    return w > mobileMax && w <= tabletMax;
  }

  static bool isDesktop(BuildContext c) =>
      MediaQuery.sizeOf(c).width > tabletMax;

  /// Picks a value based on the current breakpoint.
  static T value<T>(
    BuildContext c, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(c)) return mobile;
    if (isTablet(c)) return tablet ?? desktop;
    return desktop;
  }

  /// Horizontal page gutter.
  static double gutter(BuildContext c) =>
      value(c, mobile: 24.0, tablet: 48.0, desktop: 120.0);

  /// Clamps content to a comfortable reading / layout width.
  static double maxContentWidth(BuildContext c) => 1440;
}
