import 'package:flutter/material.dart';

/// Reveals a stack of text lines by sliding each one up from behind a mask,
/// staggered top-to-bottom — the classic editorial headline entrance.
///
/// Set [play] to true (e.g. once the intro loader finishes) to trigger it.
class RisingLines extends StatefulWidget {
  const RisingLines({
    super.key,
    required this.lines,
    required this.style,
    this.play = true,
    this.startDelay = Duration.zero,
    this.stagger = const Duration(milliseconds: 120),
    this.lineDuration = const Duration(milliseconds: 900),
    this.textAlign = TextAlign.start,
  });

  final List<String> lines;
  final TextStyle style;
  final bool play;
  final Duration startDelay;
  final Duration stagger;
  final Duration lineDuration;
  final TextAlign textAlign;

  @override
  State<RisingLines> createState() => _RisingLinesState();
}

class _RisingLinesState extends State<RisingLines>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _buildController();
    if (widget.play) _schedule();
  }

  void _buildController() {
    final total = widget.startDelay +
        widget.lineDuration +
        widget.stagger * (widget.lines.length - 1).clamp(0, 999);
    _controller = AnimationController(vsync: this, duration: total);

    final totalMs = total.inMilliseconds;
    _animations = List.generate(widget.lines.length, (i) {
      final startMs = widget.startDelay.inMilliseconds +
          widget.stagger.inMilliseconds * i;
      final endMs = startMs + widget.lineDuration.inMilliseconds;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (startMs / totalMs).clamp(0.0, 1.0),
          (endMs / totalMs).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(RisingLines old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) _schedule();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final align = widget.textAlign == TextAlign.center
        ? CrossAxisAlignment.center
        : widget.textAlign == TextAlign.end
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        for (var i = 0; i < widget.lines.length; i++)
          ClipRect(
            child: AnimatedBuilder(
              animation: _animations[i],
              builder: (context, child) {
                final v = _animations[i].value;
                return Transform.translate(
                  offset: Offset(0, (1 - v) * (widget.style.fontSize ?? 100)),
                  child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
                );
              },
              child: Text(
                widget.lines[i],
                textAlign: widget.textAlign,
                style: widget.style,
              ),
            ),
          ),
      ],
    );
  }
}
