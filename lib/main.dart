import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  // Throttle visibility polling. Every Reveal / Marquee / Aurora registers a
  // detector; polling them too often adds measurable scroll-time overhead.
  VisibilityDetectorController.instance.updateInterval =
      const Duration(milliseconds: 250);
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neesarg Darji — Senior Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      scrollBehavior: const _SmoothScrollBehavior(),
      home: const HomeScreen(),
    );
  }
}

/// Enables mouse-drag scrolling and trackpad on web, with a gentler physics.
class _SmoothScrollBehavior extends MaterialScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}
