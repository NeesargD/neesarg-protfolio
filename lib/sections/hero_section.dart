import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/aurora_background.dart';
import '../widgets/cursor/parallax.dart';
import '../widgets/marquee.dart';
import '../widgets/rising_text.dart';
import '../widgets/wireframe_phone.dart';

/// A fixed hero the "camera" flies into: as the page scrolls through its first
/// viewport, the whole hero scales up toward the wireframe phone and fades,
/// revealing the next section beneath. Decorative, so it ignores pointers and
/// lets scroll pass through to the list underneath.
class HeroZoomOverlay extends StatelessWidget {
  const HeroZoomOverlay({
    super.key,
    required this.scroll,
    required this.viewportH,
    required this.play,
  });

  final ValueListenable<double> scroll;
  final double viewportH;
  final bool play;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return IgnorePointer(
      child: ValueListenableBuilder<double>(
        valueListenable: scroll,
        builder: (context, offset, _) {
          final p = (offset / viewportH).clamp(0.0, 1.0);
          // Fully gone — don't build the hero (frees its tickers).
          if (p >= 1.0) return const SizedBox.shrink();
          // Ease-in so the fly-in accelerates (feels like diving into it).
          final e = p * p;
          final scale = 1 + e * 6.5;
          // Hold, then dissolve over the last ~40% to reveal the content.
          final fade = (1 - ((p - 0.6) / 0.4)).clamp(0.0, 1.0);
          return Opacity(
            opacity: fade,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: HeroSection(play: play),
            ),
          );
        },
      ),
    );
  }
}

/// Full-viewport opening: oversized editorial name + intro, an animated glow
/// backdrop and a skills marquee anchored to the bottom.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.play});

  /// Flips true once the intro loader lifts, triggering the headline reveal.
  final bool play;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final size = MediaQuery.sizeOf(context);
    final gutter = Responsive.gutter(context);
    final isMobile = Responsive.isMobile(context);

    // Fluid display size: scales with width, clamped to sane bounds.
    final displaySize =
        (size.width * (isMobile ? 0.18 : 0.14)).clamp(44.0, 200.0);

    // Centred phone is the focal point the camera flies into on scroll.
    final objSize = isMobile ? size.width * 1.02 : size.height * 0.98;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          const Positioned.fill(
            child: Parallax(strength: 46, child: AuroraBackground()),
          ),
          Positioned(
            left: (size.width - objSize) / 2,
            top: (size.height - objSize) / 2,
            width: objSize,
            height: objSize,
            child: const Parallax(strength: 20, child: WireframePhone()),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, 100, gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  _Eyebrow(play: play),
                  const SizedBox(height: 20),
                  Parallax(
                    strength: 15,
                    child: RisingLines(
                      play: play,
                      startDelay: const Duration(milliseconds: 150),
                      lines: const [
                        ResumeData.heroLineOne,
                        ResumeData.heroLineTwo,
                        ResumeData.heroLineThree,
                      ],
                      style: AppText.display(
                        size: displaySize,
                        weight: FontWeight.w600,
                        letterSpacing: -displaySize * 0.02,
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  _IntroRow(play: play, isMobile: isMobile),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: _BottomMarquee(play: play),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.play});
  final bool play;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(),
          const SizedBox(width: 10),
          Text(
            'AVAILABLE FOR WORK · BASED IN AHMEDABAD',
            style: AppText.mono(size: 12, color: AppColors.muted),
          ),
        ],
      ),
    )
        .animate(target: play ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return SizedBox(
          width: 10,
          height: 10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - _c.value).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1 + _c.value * 1.8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent),
                    ),
                  ),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IntroRow extends StatelessWidget {
  const _IntroRow({required this.play, required this.isMobile});
  final bool play;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final intro = Text(
      ResumeData.intro,
      style: AppText.sans(
        size: isMobile ? 15 : 18,
        height: 1.6,
        color: AppColors.muted,
      ),
    );

    final scrollCue = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('SCROLL', style: AppText.mono(size: 11)),
        const SizedBox(width: 10),
        Icon(Icons.arrow_downward, size: 16, color: AppColors.accent),
      ],
    );

    final content = isMobile
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: intro,
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: intro,
              ),
              const SizedBox(width: 48),
              scrollCue,
            ],
          );

    return content.animate(target: play ? 1 : 0).fadeIn(
          duration: 700.ms,
          delay: 700.ms,
        );
  }
}

class _BottomMarquee extends StatelessWidget {
  const _BottomMarquee({required this.play});
  final bool play;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return Column(
      children: [
        Divider(color: AppColors.line, height: 1),
        const SizedBox(height: 18),
        Marquee(
          velocity: 40,
          spacing: 44,
          children: [
            for (final s in ResumeData.skillMarquee)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s,
                    style: AppText.display(
                      size: 20,
                      weight: FontWeight.w500,
                      letterSpacing: 0,
                      style: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 44),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ).animate(target: play ? 1 : 0).fadeIn(duration: 800.ms, delay: 900.ms);
  }
}
