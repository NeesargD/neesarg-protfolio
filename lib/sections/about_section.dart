import 'package:flutter/material.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/reveal.dart';
import '../widgets/section_header.dart';
import '../widgets/section_shell.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final isMobile = Responsive.isMobile(context);
    final statementSize = Responsive.value(
      context,
      mobile: 26.0,
      tablet: 36.0,
      desktop: 44.0,
    );

    final statement = Reveal(
      child: _AccentedStatement(
        text: ResumeData.aboutExpanded,
        size: statementSize,
        highlights: const [
          'healthcare',
          'clean-architecture',
          'stable',
          'millions',
        ],
      ),
    );

    return SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(index: '01', label: 'About'),
          const SizedBox(height: 56),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Reveal(child: _Portrait(width: double.infinity)),
                const SizedBox(height: 40),
                statement,
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Reveal(child: _Portrait(width: 380)),
                const SizedBox(width: 72),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: statement,
                  ),
                ),
              ],
            ),
          SizedBox(height: isMobile ? 64 : 110),
          const _StatsStrip(),
        ],
      ),
    );
  }
}

/// Neesarg's portrait, cold-graded (desaturated + a cool wash) to sit inside
/// the cinematic palette.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.width});
  final double width;

  static const _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: _grayscale,
              child: Image.asset(
                'assets/me.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.2, -0.1),
                errorBuilder: (_, _, _) =>
                    ColoredBox(color: AppColors.surface),
              ),
            ),
            // Cool wash + depth scrim.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.28),
                    AppColors.accent.withValues(alpha: 0.05),
                    AppColors.background.withValues(alpha: 0.75),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 16,
              child: Text(
                'NEESARG DARJI · AHMEDABAD',
                style: AppText.mono(size: 10, color: AppColors.ink),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lineStrong),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a paragraph where selected words are painted in the accent colour.
class _AccentedStatement extends StatelessWidget {
  const _AccentedStatement({
    required this.text,
    required this.size,
    required this.highlights,
  });

  final String text;
  final double size;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final base = AppText.sans(
      size: size,
      height: 1.45,
      weight: FontWeight.w500,
      letterSpacing: -0.5,
      color: AppColors.ink,
    );

    final words = text.split(' ');
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          for (final w in words)
            TextSpan(
              text: '$w ',
              style: highlights.any(
                (h) => w.toLowerCase().contains(h.toLowerCase()),
              )
                  ? base.copyWith(
                      color: AppColors.accent,
                      fontStyle: FontStyle.italic,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final isMobile = Responsive.isMobile(context);
    final stats = ResumeData.stats;

    final tiles = [
      for (var i = 0; i < stats.length; i++)
        Reveal(
          delay: Duration(milliseconds: 100 * i),
          child: _StatTile(stat: stats[i]),
        ),
    ];

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.05,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        children: tiles,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          Expanded(child: tiles[i]),
          if (i != tiles.length - 1) const SizedBox(width: 24),
        ],
      ],
    );
  }
}

/// A "double-bezel" stat card: an outer shell (machined tray) cradling an
/// inner core with its own fill and inset top highlight — concentric radii.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});
  final Stat stat;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    const outerRadius = 24.0;
    const shellPad = 6.0;
    return Container(
      // Outer shell.
      padding: const EdgeInsets.all(shellPad),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: Container(
        // Inner core.
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(outerRadius - shellPad),
          // Subtle inner highlight along the top edge.
          border: Border.all(
            color: AppColors.ink.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04),
              blurRadius: 1,
              offset: const Offset(0, 1),
              spreadRadius: -0.5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scale the figure down to fit narrow cards on one line.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                stat.value,
                maxLines: 1,
                style: AppText.display(
                  size: 52,
                  weight: FontWeight.w600,
                  letterSpacing: -2,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              stat.label,
              style: AppText.mono(size: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
