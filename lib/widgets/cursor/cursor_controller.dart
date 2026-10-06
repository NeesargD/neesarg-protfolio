import 'package:flutter/widgets.dart';

/// Visual states the custom cursor can take.
enum CursorVariant {
  /// Idle dot.
  normal,

  /// Enlarged ring over interactive elements.
  hover,

  /// Thin beam over selectable text.
  text,
}

/// Holds the live pointer position and the desired cursor appearance.
///
/// Hover-aware widgets push updates here; the [CustomCursorLayer] listens and
/// renders a single smoothed cursor on top of everything.
class CursorController {
  final ValueNotifier<Offset> target = ValueNotifier(Offset.zero);
  final ValueNotifier<CursorVariant> variant =
      ValueNotifier(CursorVariant.normal);
  final ValueNotifier<String?> label = ValueNotifier(null);
  final ValueNotifier<bool> visible = ValueNotifier(false);

  void moveTo(Offset position) {
    target.value = position;
    if (!visible.value) visible.value = true;
  }

  void enter(CursorVariant v, {String? withLabel}) {
    variant.value = v;
    label.value = withLabel;
  }

  void reset() {
    variant.value = CursorVariant.normal;
    label.value = null;
  }

  void hide() => visible.value = false;

  void dispose() {
    target.dispose();
    variant.dispose();
    label.dispose();
    visible.dispose();
  }
}

/// Exposes the [CursorController] to the widget subtree.
class CursorScope extends InheritedWidget {
  const CursorScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final CursorController controller;

  static CursorController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CursorScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(CursorScope oldWidget) =>
      controller != oldWidget.controller;
}
