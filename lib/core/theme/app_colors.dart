import 'package:flutter/material.dart';

/// Central colour palette for the portfolio.
///
/// The look is a warm near-black "editorial dark" canvas with a single
/// vermilion accent — a nod to Neesarg's healthcare / ambulance work.
class AppColors {
  AppColors._();

  /// Primary page background — warm near-black.
  static const Color background = Color(0xFF0A0908);

  /// Slightly lifted surface used for cards / elevated blocks.
  static const Color surface = Color(0xFF121010);

  /// Primary text — a warm off-white rather than pure white.
  static const Color ink = Color(0xFFF2EEE6);

  /// Secondary text.
  static const Color muted = Color(0xFF9A938A);

  /// Tertiary / disabled text and quiet captions.
  static const Color faint = Color(0xFF5A554E);

  /// Signature accent.
  static const Color accent = Color(0xFFFF5A1F);

  /// Softer accent used for glows / wash backgrounds.
  static const Color accentSoft = Color(0xFFFF8A5C);

  /// Hairline dividers / outlines.
  static const Color line = Color(0x1AF2EEE6);

  /// Stronger hairline for hovered / active states.
  static const Color lineStrong = Color(0x40F2EEE6);
}
