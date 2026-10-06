import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';
import 'cursor_controller.dart';

/// Renders a single, smoothly-trailing cursor driven by [CursorController].
///
/// The cursor lerps toward the live pointer every frame (gentle lag, like
/// andrevv.com) and morphs between a dot, a ring, and a labelled pill. The
/// per-frame position is pushed through a [ValueNotifier] so only the glyph
/// repaints — never the whole widget tree.
class CustomCursorLayer extends StatefulWidget {
  const CustomCursorLayer({super.key, required this.controller});

  final CursorController controller;

  @override
  State<CustomCursorLayer> createState() => _CustomCursorLayerState();
}

class _CustomCursorLayerState extends State<CustomCursorLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<Offset> _current = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    // Only run the per-frame lerp while the pointer is actually moving; when
    // it settles we stop the ticker so the engine can go idle (no forced 60fps).
    widget.controller.target.addListener(_wake);
  }

  void _wake() {
    if (!_ticker.isActive) _ticker.start();
  }

  void _onTick(Duration _) {
    final target = widget.controller.target.value;
    final cur = _current.value;
    // Exponential smoothing — responsive but with a soft trailing lag.
    final next = Offset(
      lerpDouble(cur.dx, target.dx, 0.18)!,
      lerpDouble(cur.dy, target.dy, 0.18)!,
    );
    if ((next - target).distanceSquared < 0.1) {
      // Settled — snap and stop producing frames until the next move.
      _current.value = target;
      _ticker.stop();
    } else {
      _current.value = next;
    }
  }

  @override
  void dispose() {
    widget.controller.target.removeListener(_wake);
    _ticker.dispose();
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.controller.visible,
        builder: (context, visible, _) {
          return AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: AppMotion.fast,
            child: ValueListenableBuilder<CursorVariant>(
              valueListenable: widget.controller.variant,
              builder: (context, variant, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: widget.controller.label,
                  builder: (context, label, _) {
                    return ValueListenableBuilder<Offset>(
                      valueListenable: _current,
                      builder: (context, position, _) {
                        return _CursorShape(
                          position: position,
                          variant: variant,
                          label: label,
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CursorShape extends StatelessWidget {
  const _CursorShape({
    required this.position,
    required this.variant,
    required this.label,
  });

  final Offset position;
  final CursorVariant variant;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;

    late final double width;
    late final double height;
    late final Widget child;

    switch (variant) {
      case CursorVariant.normal:
        width = height = 10;
        child = const _Dot();
      case CursorVariant.text:
        width = 3;
        height = 28;
        child = Container(
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case CursorVariant.hover:
        if (hasLabel) {
          width = 96;
          height = 96;
          child = _LabelBubble(label: label!);
        } else {
          width = 52;
          height = 52;
          child = _Ring();
        }
    }

    // A Stack + Positioned(left/top only) gives the cursor LOOSE constraints,
    // so its explicit width/height are honoured. (Placing it directly under a
    // Positioned.fill would impose tight constraints and blow the glyph up to
    // fill the screen.)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: position.dx - width / 2,
          top: position.dy - height / 2,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.soft,
            width: width,
            height: height,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
    );
  }
}

class _LabelBubble extends StatelessWidget {
  const _LabelBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppText.mono(
          color: AppColors.background,
          size: 11,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}
