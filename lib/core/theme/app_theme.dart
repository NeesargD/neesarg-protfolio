import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the global [ThemeData] for the portfolio.
class AppTheme {
  AppTheme._();

  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.background,
        primary: AppColors.accent,
        secondary: AppColors.accentSoft,
        onSurface: AppColors.ink,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.accent,
        cursorColor: AppColors.accent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(color: AppColors.surface),
        textStyle: AppText.mono(color: AppColors.ink, size: 12),
      ),
    );
  }
}
