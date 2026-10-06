import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A seamless, infinitely-scrolling horizontal strip.
///
/// Lays the [children] out in a row, measures one full set, then translates
/// continuously and wraps — producing a gap-free marquee. The per-frame
/// offset is pushed through a [ValueNotifier] so only the transform rebuilds.
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.children,
    this.spacing = 64,
    this.velocity = 60, // logical pixels per second
    this.reverse = false,
  });

  final List<Widget> children;
  final double spacing;
  final double velocity;
  final bool reverse;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _offset = ValueNotifier(0);
  double _setWidth = 0;
  Duration _last = Duration.zero;
  final _setKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final box = _setKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) setState(() => _setWidth = box.size.width);
  }

  void _onTick(Duration elapsed) {
    if (_setWidth == 0) {
      _last = elapsed;
      return;
    }
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    var next = _offset.value + widget.velocity * dt;
    if (next >= _setWidth) next -= _setWidth;
    _offset.value = next;
  }

  void _onVisibility(VisibilityInfo info) {
    final visible = info.visibleFraction > 0;
    if (visible && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!visible && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  Widget _buildSet({Key? key}) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final child in widget.children) ...[
          child,
          SizedBox(width: widget.spacing),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSet(key: _setKey),
        _buildSet(),
        _buildSet(),
      ],
    );

    return VisibilityDetector(
      key: ValueKey('marquee-${identityHashCode(this)}'),
      onVisibilityChanged: _onVisibility,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: ValueListenableBuilder<double>(
            valueListenable: _offset,
            builder: (context, offset, child) {
              final dx = widget.reverse ? offset - _setWidth : -offset;
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: row,
          ),
        ),
      ),
    );
  }
}
