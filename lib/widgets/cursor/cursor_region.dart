import 'package:flutter/widgets.dart';

import 'cursor_controller.dart';

/// Wraps any element so that hovering it morphs the custom cursor.
///
/// Falls back gracefully: if no [CursorScope] is present (e.g. on touch
/// devices where the layer is disabled) it simply renders [child].
class CursorRegion extends StatelessWidget {
  const CursorRegion({
    super.key,
    required this.child,
    this.variant = CursorVariant.hover,
    this.label,
    this.onTap,
  });

  final Widget child;
  final CursorVariant variant;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final controller = CursorScope.maybeOf(context);

    Widget content = MouseRegion(
      onEnter: (_) => controller?.enter(variant, withLabel: label),
      onExit: (_) => controller?.reset(),
      child: child,
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
