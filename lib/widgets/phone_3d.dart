import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import 'cursor/cursor_controller.dart';
import 'mobile_preview.dart';

/// A realistic phone as a true 3D object (Matrix4 perspective). At rest it sits
/// to the RIGHT, angled, lit and cursor-reactive, its screen showing a looping
/// mobile preview of the portfolio. As [progress] grows (driven by scroll) it
/// swings to centre, faces the viewer and zooms in — so its screen fills the
/// viewport and hands off to the real (mobile-framed) page.
class Phone3D extends StatefulWidget {
  const Phone3D({super.key, required this.progress});

  /// 0 = hero at rest, 1 = zoomed fully into the screen.
  final double progress;

  @override
  State<Phone3D> createState() => _Phone3DState();
}

class _Phone3DState extends State<Phone3D> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;
  double _cx = 0, _cy = 0, _cxT = 0, _cyT = 0;
  bool _visible = false;

  CursorController? _cursor;
  Size _screenSize = Size.zero;
  final ValueNotifier<int> _tick = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.sizeOf(context);
    final c = CursorScope.maybeOf(context);
    if (c != _cursor) {
      _cursor?.target.removeListener(_onCursor);
      _cursor = c;
      _cursor?.target.addListener(_onCursor);
    }
  }

  void _onCursor() {
    if (_screenSize.width == 0) return;
    final p = _cursor!.target.value;
    _cxT = ((p.dx / _screenSize.width) - 0.5) * 2;
    _cyT = ((p.dy / _screenSize.height) - 0.5) * 2;
  }

  void _onTick(Duration elapsed) {
    _t += 0.016;
    _cx += (_cxT - _cx) * 0.05;
    _cy += (_cyT - _cy) * 0.05;
    _tick.value++;
  }

  void _onVisibility(VisibilityInfo info) {
    final v = info.visibleFraction > 0.05;
    if (v == _visible) return;
    _visible = v;
    if (v) {
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _cursor?.target.removeListener(_onCursor);
    _ticker.dispose();
    _tick.dispose();
    super.dispose();
  }

  double _ss(double a, double b, double x) {
    final t = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final vp = MediaQuery.sizeOf(context);
    final isMobile = Responsive.isMobile(context);
    final phoneH = vp.height * (isMobile ? 0.42 : 0.66);
    final phoneW = phoneH / 2.05;
    final p = widget.progress;
    final faceP = _ss(0.0, 0.5, p);
    final posP = _ss(0.0, 0.62, p);
    final scale = lerpDouble(0.96, 2.5, p * p)!;

    // Rest pose: centre-right (desktop, above the intro); lower-centre (mobile,
    // below the headline so it never overlaps the text).
    final rest =
        isMobile ? const Alignment(0, -0.26) : const Alignment(0.58, -0.04);
    final align = Alignment.lerp(rest, Alignment.center, posP)!;

    return VisibilityDetector(
      key: const ValueKey('phone3d'),
      onVisibilityChanged: _onVisibility,
      child: Align(
        alignment: align,
        child: AnimatedBuilder(
          animation: _tick,
          builder: (context, _) {
            final sway = sin(_t * 0.6);
            final rotY = (1 - faceP) * (-0.42 + sway * 0.06 + _cx * 0.3);
            final rotX = (1 - faceP) * (0.12 + _cy * 0.16 - sway * 0.03);
            final m = Matrix4.identity()
              ..setEntry(3, 2, 0.0013)
              ..rotateX(rotX)
              ..rotateY(rotY)
              ..scaleByDouble(scale, scale, 1, 1);
            return Transform(
              transform: m,
              alignment: Alignment.center,
              child: _PhoneBody(
                width: phoneW,
                height: phoneH,
                rotY: rotY,
                glow: lerpDouble(0.18, 0.5, p)!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhoneBody extends StatelessWidget {
  const _PhoneBody({
    required this.width,
    required this.height,
    required this.rotY,
    required this.glow,
  });

  final double width;
  final double height;
  final double rotY;
  final double glow;

  @override
  Widget build(BuildContext context) {
    final radius = width * 0.15;
    final bezel = width * 0.028;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2E), Color(0xFF0C0C0E)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 44,
            spreadRadius: -16,
            offset: const Offset(0, 32),
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: glow),
            blurRadius: 52,
            spreadRadius: -22,
          ),
        ],
      ),
      padding: EdgeInsets.all(bezel),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - bezel),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const MobilePreview(),
            // Notch.
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: width * 0.03),
                width: width * 0.3,
                height: width * 0.05,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
              ),
            ),
            // Glass sheen that shifts with rotation.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + rotY * 2.2, -1),
                    end: Alignment(1 + rotY * 2.2, 1),
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
