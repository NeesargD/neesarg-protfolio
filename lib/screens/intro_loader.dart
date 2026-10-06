import 'package:flutter/material.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// A one-shot intro curtain: a 0→100 counter over the name, then the panel
/// wipes upward to reveal the page.
///
///  • [onRevealStart]    fires as the wipe begins (cue the hero to animate in).
///  • [onRevealComplete] fires once the curtain is fully gone (remove me).
class IntroLoader extends StatefulWidget {
  const IntroLoader({
    super.key,
    required this.onRevealStart,
    required this.onRevealComplete,
  });

  final VoidCallback onRevealStart;
  final VoidCallback onRevealComplete;

  @override
  State<IntroLoader> createState() => _IntroLoaderState();
}

class _IntroLoaderState extends State<IntroLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _count;
  late final Animation<double> _wipe;
  bool _revealFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _count = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.72, curve: AppMotion.soft),
    );
    _wipe = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 1.0, curve: AppMotion.weighted),
    );

    _controller.addListener(() {
      if (!_revealFired && _controller.value >= 0.82) {
        _revealFired = true;
        widget.onRevealStart();
      }
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onRevealComplete();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final gutter = Responsive.gutter(context);
    final counterSize = Responsive.value(
      context,
      mobile: 90.0,
      tablet: 160.0,
      desktop: 220.0,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final percent = (_count.value * 100).round();
        return Transform.translate(
          offset: Offset(0, -_wipe.value * MediaQuery.sizeOf(context).height),
          child: Container(
            color: AppColors.background,
            padding: EdgeInsets.all(gutter),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Opacity(
                    opacity: (1 - _wipe.value).clamp(0.0, 1.0),
                    child: Text(
                      ResumeData.contact.name.toUpperCase(),
                      style: AppText.mono(size: 13, color: AppColors.muted),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Opacity(
                    opacity: (1 - _wipe.value).clamp(0.0, 1.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percent',
                          style: AppText.display(
                            size: counterSize,
                            weight: FontWeight.w600,
                            height: 0.9,
                            letterSpacing: -counterSize * 0.03,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: counterSize * 0.12),
                          child: Text(
                            '%',
                            style: AppText.display(
                              size: counterSize * 0.28,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Opacity(
                    opacity: (1 - _wipe.value).clamp(0.0, 1.0),
                    child: _ProgressLine(value: _count.value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final width = Responsive.value(
      context,
      mobile: 180.0,
      tablet: 280.0,
      desktop: 360.0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LOADING PORTFOLIO', style: AppText.mono(size: 11)),
        const SizedBox(height: 14),
        Stack(
          children: [
            Container(height: 2, width: width, color: AppColors.line),
            Container(height: 2, width: width * value, color: AppColors.accent),
          ],
        ),
      ],
    );
  }
}
