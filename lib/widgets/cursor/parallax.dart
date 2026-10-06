import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/utils/responsive.dart';
import 'cursor_controller.dart';

/// Translates [child] a little toward the pointer, with smooth trailing lag —
/// giving the hero depth (layer different [strength] values for parallax).
///
/// Reads the shared [CursorController], so it tracks the same pointer as the
/// custom cursor. The smoothing ticker stops once settled, so an idle mouse
/// costs zero frames. No-op on touch / small screens.
class Parallax extends StatefulWidget {
  const Parallax({
    super.key,
    required this.child,
    this.strength = 24,
  });

  final Widget child;

  /// Maximum travel in logical pixels at the screen edges.
  final double strength;

  @override
  State<Parallax> createState() => _ParallaxState();
}

class _ParallaxState extends State<Parallax>
    with SingleTickerProviderStateMixin {
  CursorController? _cursor;
  late final Ticker _ticker;
  final ValueNotifier<Offset> _offset = ValueNotifier(Offset.zero);
  Offset _target = Offset.zero;
  Size _screen = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screen = MediaQuery.sizeOf(context);
    final c = CursorScope.maybeOf(context);
    if (c != _cursor) {
      _cursor?.target.removeListener(_onCursor);
      _cursor = c;
      _cursor?.target.addListener(_onCursor);
    }
  }

  void _onCursor() {
    if (_screen.width == 0) return;
    final p = _cursor!.target.value;
    // Normalise to -1..1 around screen centre.
    final nx = ((p.dx / _screen.width) - 0.5) * 2;
    final ny = ((p.dy / _screen.height) - 0.5) * 2;
    _target = Offset(nx * widget.strength, ny * widget.strength);
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration _) {
    final cur = _offset.value;
    final next = Offset(
      lerpDouble(cur.dx, _target.dx, 0.08)!,
      lerpDouble(cur.dy, _target.dy, 0.08)!,
    );
    if ((next - _target).distanceSquared < 0.05) {
      _offset.value = _target;
      _ticker.stop();
    } else {
      _offset.value = next;
    }
  }

  @override
  void dispose() {
    _cursor?.target.removeListener(_onCursor);
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isDesktop(context)) return widget.child;
    return ValueListenableBuilder<Offset>(
      valueListenable: _offset,
      builder: (context, offset, child) {
        return Transform.translate(offset: offset, child: child);
      },
      child: widget.child,
    );
  }
}
