import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/theme/app_colors.dart';
import 'cursor/cursor_controller.dart';

/// A slowly-rotating 3D wireframe smartphone — on-topic for a Flutter / mobile
/// developer. Front/back faces, side depth, a screen with a notch and a few UI
/// rows. Cursor-reactive; pauses off-screen. Lines only — cheap.
class WireframePhone extends StatefulWidget {
  const WireframePhone({super.key, this.spin = 0.2});

  /// Base spin speed (radians / second).
  final double spin;

  @override
  State<WireframePhone> createState() => _WireframePhoneState();
}

class _WireframePhoneState extends State<WireframePhone>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<List<_V3>> _lines;
  Duration _last = Duration.zero;

  double _yaw = 0;
  double _t = 0;
  final double _pitch = -0.12;
  double _cx = 0, _cy = 0, _cxT = 0, _cyT = 0;

  CursorController? _cursor;
  Size _screen = Size.zero;
  final ValueNotifier<int> _repaint = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _lines = _buildPhone();
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
    _cxT = ((p.dx / _screen.width) - 0.5) * 2;
    _cyT = ((p.dy / _screen.height) - 0.5) * 2;
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    // Gentle sway (never fully edge-on) so it always reads as a phone.
    _t += dt;
    _yaw = sin(_t * widget.spin * 2.75) * 0.7;
    _cx += (_cxT - _cx) * 0.06;
    _cy += (_cyT - _cy) * 0.06;
    _repaint.value++;
  }

  void _onVisibility(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.05;
    if (visible && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!visible && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _cursor?.target.removeListener(_onCursor);
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return VisibilityDetector(
      key: const ValueKey('wireframe-phone'),
      onVisibilityChanged: _onVisibility,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _PhonePainter(
            lines: _lines,
            repaint: _repaint,
            yaw: () => _yaw + _cx * 0.7,
            pitch: () => _pitch + _cy * 0.3,
          ),
        ),
      ),
    );
  }

  // --- Geometry (unit phone, centred at origin) ---

  static const double _hw = 0.46, _hh = 0.95, _hd = 0.07, _r = 0.16;
  static const double _shw = 0.40, _shh = 0.85, _sr = 0.10;

  List<List<_V3>> _buildPhone() {
    final lines = <List<_V3>>[];
    // Front + back shell outline.
    final front = _roundedRect(_hw, _hh, _r, _hd);
    final back = _roundedRect(_hw, _hh, _r, -_hd);
    lines.add([...front, front.first]);
    lines.add([...back, back.first]);
    // Depth connectors at the four rounded corners.
    const c = 0.7071;
    for (final s in const [
      [1.0, 1.0],
      [-1.0, 1.0],
      [-1.0, -1.0],
      [1.0, -1.0],
    ]) {
      final ax = s[0] * (_hw - _r + _r * c);
      final ay = s[1] * (_hh - _r + _r * c);
      lines.add([_V3(ax, ay, _hd), _V3(ax, ay, -_hd)]);
    }
    // Screen outline (front).
    final screen = _roundedRect(_shw, _shh, _sr, _hd);
    lines.add([...screen, screen.first]);
    // Notch pill near the top of the screen.
    final notch = _roundedRect(0.085, 0.022, 0.022, _hd)
        .map((v) => _V3(v.x, v.y + _shh - 0.06, v.z))
        .toList();
    lines.add([...notch, notch.first]);
    // A few UI rows to read as an app screen.
    const rowX = 0.30;
    for (final y in const [0.46, 0.2, -0.04, -0.28]) {
      lines.add([_V3(-rowX, y, _hd), _V3(rowX, y, _hd)]);
    }
    // Bottom tab bar.
    lines.add([_V3(-_shw + 0.04, -0.66, _hd), _V3(_shw - 0.04, -0.66, _hd)]);
    return lines;
  }

  static List<_V3> _roundedRect(double hw, double hh, double r, double z) {
    const seg = 5;
    final pts = <_V3>[];
    // Corner centres + base angle (degrees) for each quarter arc.
    final corners = [
      [hw - r, hh - r, 0.0], // TR
      [-(hw - r), hh - r, 90.0], // TL
      [-(hw - r), -(hh - r), 180.0], // BL
      [hw - r, -(hh - r), 270.0], // BR
    ];
    for (final cnr in corners) {
      for (var i = 0; i <= seg; i++) {
        final a = (cnr[2] + 90.0 * i / seg) * pi / 180.0;
        pts.add(_V3(cnr[0] + r * cos(a), cnr[1] + r * sin(a), z));
      }
    }
    return pts;
  }
}

class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;
}

class _PhonePainter extends CustomPainter {
  _PhonePainter({
    required this.lines,
    required this.repaint,
    required this.yaw,
    required this.pitch,
  }) : super(repaint: repaint);

  final List<List<_V3>> lines;
  final Listenable repaint;
  final double Function() yaw;
  final double Function() pitch;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide * 0.46;
    final center = Offset(size.width / 2, size.height / 2);
    final focal = r * 3.4;

    final cyw = cos(yaw()), syw = sin(yaw());
    final cp = cos(pitch()), sp = sin(pitch());

    Offset? project(_V3 v, void Function(double) outZ) {
      var x = v.x * cyw + v.z * syw;
      var z = -v.x * syw + v.z * cyw;
      var y = v.y;
      final y2 = y * cp - z * sp;
      final z2 = y * sp + z * cp;
      y = y2;
      z = z2;
      final persp = focal / (focal - z * r);
      outZ(z);
      return center + Offset(x * r * persp, y * r * persp);
    }

    final front = Path();
    final back = Path();
    for (final poly in lines) {
      for (var i = 0; i < poly.length - 1; i++) {
        double za = 0, zb = 0;
        final a = project(poly[i], (z) => za = z)!;
        final b = project(poly[i + 1], (z) => zb = z)!;
        final p = (za + zb) / 2 >= 0 ? front : back;
        p.moveTo(a.dx, a.dy);
        p.lineTo(b.dx, b.dy);
      }
    }

    canvas.drawPath(
      back,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.accent.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.accent.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_PhonePainter old) => false;
}
