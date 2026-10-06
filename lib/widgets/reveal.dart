import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/theme/app_motion.dart';
import '../core/utils/motion_prefs.dart';

/// Fades and slides its [child] into place the first time it scrolls into view.
///
/// Gives the "content assembling as you scroll" feel — using only `opacity`
/// and `transform` (GPU-cheap). Reveals once, then stays. Collapses to instant
/// when reduce-motion is requested.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 48,
    this.duration = AppMotion.slow,
    this.threshold = 0.1,
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;
  final double threshold;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: AppMotion.expo);
  }

  void _onVisibility(VisibilityInfo info) {
    if (_triggered) return;
    if (info.visibleFraction >= widget.threshold) {
      _triggered = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessibility: skip the animation entirely.
    if (MotionPrefs.reduced(context)) return widget.child;

    return VisibilityDetector(
      key: ValueKey('reveal-${identityHashCode(this)}'),
      onVisibilityChanged: _onVisibility,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) {
          final v = _curve.value;
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, (1 - v) * widget.offset),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
