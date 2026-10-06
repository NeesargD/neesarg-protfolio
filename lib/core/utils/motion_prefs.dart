import 'package:flutter/widgets.dart';

/// Honours the OS / browser "reduce motion" accessibility setting.
///
/// On the web, `MediaQuery.disableAnimations` reflects the
/// `prefers-reduced-motion` media query. When true we skip the intro curtain
/// and collapse reveal/entrance animations to instant.
class MotionPrefs {
  MotionPrefs._();

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
