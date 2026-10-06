import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_motion.dart';
import '../core/utils/motion_prefs.dart';

/// Gently pulls its [child] toward the pointer while hovered, scales down on
/// press, then springs back — the "magnetic" micro-interaction.
///
/// Continuous pointer values are pushed through [ValueNotifier]s so only the
/// transform rebuilds, never the whole subtree (avoids per-move re-renders).
class Magnetic extends StatefulWidget {
  const Magnetic({
    super.key,
    required this.child,
    this.strength = 0.35,
    this.maxPull = 22,
  });

  final Widget child;
  final double strength;
  final double maxPull;

  @override
  State<Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<Magnetic> {
  final _pull = ValueNotifier<Offset>(Offset.zero);
  final _pressed = ValueNotifier<bool>(false);

  void _onHover(PointerHoverEvent event, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delta = (event.localPosition - center) * widget.strength;
    _pull.value = Offset(
      delta.dx.clamp(-widget.maxPull, widget.maxPull),
      delta.dy.clamp(-widget.maxPull, widget.maxPull),
    );
  }

  @override
  void dispose() {
    _pull.dispose();
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduced-motion: no magnet, no press scale.
    if (MotionPrefs.reduced(context)) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (e) => _onHover(e, constraints.biggest),
          onExit: (_) => _pull.value = Offset.zero,
          child: Listener(
            onPointerDown: (_) => _pressed.value = true,
            onPointerUp: (_) => _pressed.value = false,
            onPointerCancel: (_) => _pressed.value = false,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pull, _pressed]),
              builder: (context, child) {
                final scale = _pressed.value ? 0.97 : 1.0;
                return AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.soft,
                  transform: Matrix4.identity()
                    ..translateByDouble(_pull.value.dx, _pull.value.dy, 0, 1)
                    ..scaleByDouble(scale, scale, 1, 1),
                  transformAlignment: Alignment.center,
                  child: child,
                );
              },
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
