import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the global [ThemeData] for the portfolio from an [AppPalette].
class AppTheme {
  AppTheme._();

  static ThemeData build(AppPalette p, bool isDark) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      colorScheme: base.colorScheme.copyWith(
        surface: p.background,
        primary: p.accent,
        secondary: p.accentSoft,
        onSurface: p.ink,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: p.ink,
        displayColor: p.ink,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: p.accent,
        cursorColor: p.accent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: p.surface),
        textStyle: AppText.mono(color: p.ink, size: 12),
      ),
    );
  }
}
