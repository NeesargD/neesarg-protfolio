import 'package:flutter/animation.dart';

/// Shared motion language.
///
/// Per high-end-visual-design guidance, nothing uses stock `linear` /
/// `easeInOut`. Everything springs with real-world mass via custom
/// cubic-beziers, and durations are generous enough to read as "cinematic".
class AppMotion {
  AppMotion._();

  /// Expressive decelerate — the house curve for reveals & entrances.
  /// (Matches the popular "expo-out" feel.)
  static const Curve expo = Cubic(0.16, 1.0, 0.3, 1.0);

  /// Heavy, weighted ease used for large transforms (nav, curtains, rows).
  static const Curve weighted = Cubic(0.32, 0.72, 0.0, 1.0);

  /// Snappy but soft — for small hover / state changes.
  static const Curve soft = Cubic(0.22, 1.0, 0.36, 1.0);

  static const Duration fast = Duration(milliseconds: 260);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 850);
}
