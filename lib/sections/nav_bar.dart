import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/cursor/cursor_region.dart';

class NavEntry {
  const NavEntry(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
}

/// A floating glass "island" nav — detached from the top edge, rounded-full,
/// blurred. (Deliberately NOT an edge-to-edge sticky bar.)
class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.scrolled,
    required this.entries,
    required this.onLogoTap,
  });

  final bool scrolled;
  final List<NavEntry> entries;
  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final isMobile = Responsive.isMobile(context);
    final gutter = Responsive.gutter(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 22, gutter, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          // Solid, slightly translucent fill instead of a live BackdropFilter
          // blur — a backdrop blur re-blurs all scrolling content every frame
          // and is the single biggest cause of scroll jank on Flutter web.
          child: AnimatedContainer(
            duration: AppMotion.medium,
            curve: AppMotion.soft,
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                AppColors.surface.withValues(alpha: scrolled ? 0.96 : 0.82),
                AppColors.background,
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: scrolled ? AppColors.lineStrong : AppColors.line,
              ),
              boxShadow: [
                // Soft, diffused ambient shadow — never a harsh drop.
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Brand(onTap: onLogoTap),
                if (!isMobile)
                  Row(
                    children: [
                      for (final e in entries) ...[
                        _NavLink(entry: e),
                        const SizedBox(width: 30),
                      ],
                      const _ThemeToggle(),
                      const SizedBox(width: 16),
                      _StatusPill(),
                    ],
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _ThemeToggle(),
                      const SizedBox(width: 12),
                      _StatusPill(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return CursorRegion(
      label: 'top',
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 11),
          Text(
            'Neesarg Darji',
            style: AppText.sans(
              size: 15,
              weight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small "available" eyebrow pill, per the skill's eyebrow-tag guidance.
class _StatusPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        'OPEN TO WORK',
        style: AppText.mono(
          size: 10,
          color: AppColors.accent,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Light/dark toggle — a round button whose icon rotates/crossfades between a
/// moon (dark) and a sun (light).
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final isDark = context.isDarkTheme;
    return CursorRegion(
      label: isDark ? 'light' : 'dark',
      onTap: context.toggleTheme,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.medium,
          switchInCurve: AppMotion.expo,
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween(begin: 0.6, end: 1.0).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            key: ValueKey(isDark),
            size: 17,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.entry});
  final NavEntry entry;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return CursorRegion(
      onTap: widget.entry.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.entry.label,
              style: AppText.sans(
                size: 14,
                weight: FontWeight.w500,
                color: _hover ? AppColors.ink : AppColors.muted,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.soft,
              height: 1.5,
              width: _hover ? 20 : 0,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
