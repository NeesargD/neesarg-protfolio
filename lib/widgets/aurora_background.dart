import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Static radial glows behind the hero — depth without imagery.
///
/// Built from plain [RadialGradient] decorations (no CustomPaint, no per-frame
/// work). Painted once and composited cheaply.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.45, -0.35),
                  radius: 0.95,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.16),
                    AppColors.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.6, 0.35),
                  radius: 0.75,
                  colors: [
                    AppColors.accentSoft.withValues(alpha: 0.08),
                    AppColors.accentSoft.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
