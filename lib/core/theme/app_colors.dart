import 'package:flutter/material.dart';

/// An immutable set of the 9 themed colours.
@immutable
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentSoft,
    required this.line,
    required this.lineStrong,
  });

  final Color background;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color accent;
  final Color accentSoft;
  final Color line;
  final Color lineStrong;
}

/// Dark (default): warm editorial — near-black + vermilion.
const AppPalette kDarkPalette = AppPalette(
  background: Color(0xFF0A0908),
  surface: Color(0xFF121010),
  ink: Color(0xFFF2EEE6),
  muted: Color(0xFF9A938A),
  faint: Color(0xFF5A554E),
  accent: Color(0xFFFF5A1F),
  accentSoft: Color(0xFFFF8A5C),
  line: Color(0x1AF2EEE6),
  lineStrong: Color(0x40F2EEE6),
);

/// Light: warm paper white + a fresh emerald accent (a nod to healthtech).
const AppPalette kLightPalette = AppPalette(
  background: Color(0xFFF2F0E9),
  surface: Color(0xFFFBFAF5),
  ink: Color(0xFF17140F),
  muted: Color(0xFF6B6459),
  faint: Color(0xFFADA596),
  accent: Color(0xFF0E9E6E),
  accentSoft: Color(0xFF53C79A),
  line: Color(0x1A17140F),
  lineStrong: Color(0x3317140F),
);

/// Static mirror of the *current* palette, for non-widget code (CustomPainters,
/// text-style helpers). Swapped on theme toggle; painters repaint and pick it
/// up, and reactive widgets rebuild via [PaletteProvider] / [context.watchTheme].
class AppColors {
  AppColors._();

  static AppPalette current = kDarkPalette;

  static Color get background => current.background;
  static Color get surface => current.surface;
  static Color get ink => current.ink;
  static Color get muted => current.muted;
  static Color get faint => current.faint;
  static Color get accent => current.accent;
  static Color get accentSoft => current.accentSoft;
  static Color get line => current.line;
  static Color get lineStrong => current.lineStrong;
}

/// Provides the current palette to the tree and exposes a [toggle]. Widgets
/// that call [context.watchTheme] (or [context.palette]) rebuild when it flips.
class PaletteProvider extends InheritedWidget {
  const PaletteProvider({
    super.key,
    required this.palette,
    required this.isDark,
    required this.toggle,
    required super.child,
  });

  final AppPalette palette;
  final bool isDark;
  final VoidCallback toggle;

  static PaletteProvider? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PaletteProvider>();

  @override
  bool updateShouldNotify(PaletteProvider old) =>
      palette != old.palette || isDark != old.isDark;
}

extension PaletteContext on BuildContext {
  /// The live palette (also registers a rebuild dependency).
  AppPalette get palette => PaletteProvider.maybeOf(this)?.palette ?? kDarkPalette;

  /// Register a theme dependency without needing the palette value — call at
  /// the top of a build that reads colours via [AppColors].
  void watchTheme() => PaletteProvider.maybeOf(this);

  bool get isDarkTheme => PaletteProvider.maybeOf(this)?.isDark ?? true;

  VoidCallback? get toggleTheme => PaletteProvider.maybeOf(this)?.toggle;
}
