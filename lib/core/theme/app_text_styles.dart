import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typographic system.
///
/// Three families, each with a job:
///  • [display]  — Fraunces, an expressive serif, for huge editorial headings.
///  • [sans]     — Space Grotesk, a modern grotesque, for body & UI.
///  • [mono]     — JetBrains Mono, for section indices, labels & numbers.
class AppText {
  AppText._();

  static TextStyle display({
    double size = 120,
    FontWeight weight = FontWeight.w600,
    double height = 0.95,
    double letterSpacing = -2,
    Color? color,
    FontStyle style = FontStyle.normal,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.ink,
      fontStyle: style,
    );
  }

  static TextStyle sans({
    double size = 18,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
    double letterSpacing = 0,
    Color? color,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.ink,
    );
  }

  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 1.5,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.muted,
    );
  }
}
