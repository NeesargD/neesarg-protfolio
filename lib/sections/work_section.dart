import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/cursor/cursor_region.dart';
import '../widgets/reveal.dart';
import '../widgets/section_header.dart';

/// "Selected Work" — a focused coverflow walkthrough of real, shipped App Store
/// apps. One app is in sharp focus; neighbours scale down and dim. Auto-advances
/// (pauses on hover/drag, stops off-screen) and each card links to its listing.
class WorkSection extends StatelessWidget {
  const WorkSection({super.key});

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final isMobile = Responsive.isMobile(context);
    final gutter = Responsive.gutter(context);
    final vPad = Responsive.value<double>(
      context,
      mobile: 70,
      tablet: 105,
      desktop: 140,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: vPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.maxContentWidth(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(index: '03', label: 'Selected Work'),
                    const SizedBox(height: 44),
                    Reveal(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Things I’ve shipped.',
                            style: AppText.display(
                              size: Responsive.value(context,
                                  mobile: 34, tablet: 52, desktop: 68),
                              weight: FontWeight.w600,
                              height: 0.98,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Text(
                              'Live apps on the App Store — a healthcare '
                              'platform of connected apps, plus retail at '
                              'national scale.',
                              style: AppText.sans(
                                  size: 16,
                                  height: 1.55,
                                  color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 36 : 56),
          const _WorkCarousel(),
        ],
      ),
    );
  }
}

class _WorkCarousel extends StatefulWidget {
  const _WorkCarousel();

  @override
  State<_WorkCarousel> createState() => _WorkCarouselState();
}

class _WorkCarouselState extends State<_WorkCarousel> {
  static const _autoAdvance = Duration(seconds: 9);

  late PageController _controller;
  Timer? _timer;
  int _active = 0;
  bool _paused = false;
  bool _visible = false;

  List<WorkProject> get _items => ResumeData.featuredWork;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
      viewportFraction: 0.78, // overridden per-breakpoint in didChangeDependencies
    );
  }

  // viewportFraction can't change after creation, so rebuild the controller
  // when the breakpoint changes.
  double? _vf;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isMobile = Responsive.isMobile(context);
    final vf = isMobile ? 0.74 : 0.40;
    if (vf != _vf) {
      _vf = vf;
      final old = _controller;
      _controller = PageController(
        initialPage: _active,
        viewportFraction: vf,
      );
      // Dispose the previous one after this frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoAdvance, (_) {
      if (_paused || !_visible || !mounted) return;
      final next = _active + 1 >= _items.length ? 0 : _active + 1;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: AppMotion.weighted,
      );
    });
  }

  void _onVisibility(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.15;
    if (visible == _visible) return;
    setState(() => _visible = visible); // propagate `play` to cards
    if (visible) {
      _restartTimer();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _openActive() async {
    final uri = Uri.parse(_items[_active].url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index.clamp(0, _items.length - 1),
      duration: const Duration(milliseconds: 600),
      curve: AppMotion.weighted,
    );
  }

  double _page() {
    if (_controller.positions.isNotEmpty &&
        _controller.position.haveDimensions) {
      return _controller.page ?? _active.toDouble();
    }
    return _active.toDouble();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final isMobile = Responsive.isMobile(context);
    final cardW = isMobile ? 228.0 : 304.0;
    final shotH = (cardW * 0.58) * 1.95;
    final cardH = shotH + 80;
    final carouselH = cardH + 28;

    return VisibilityDetector(
      key: const ValueKey('work-carousel'),
      onVisibilityChanged: _onVisibility,
      child: MouseRegion(
        onEnter: (_) => _paused = true,
        onExit: (_) => _paused = false,
        child: Column(
          children: [
            SizedBox(
              height: carouselH,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollStartNotification) _paused = true;
                  if (n is ScrollEndNotification) {
                    // resume only if pointer isn't still hovering handled by MouseRegion
                    _paused = false;
                    _restartTimer();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _active = i),
                  itemCount: _items.length,
                  padEnds: true,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final delta = (_page() - index);
                        final ad = delta.abs();
                        final scale = (1 - ad * 0.16).clamp(0.82, 1.0);
                        final op = (1 - ad * 0.55).clamp(0.3, 1.0);
                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(opacity: op, child: child),
                          ),
                        );
                      },
                      child: _Card(
                        project: _items[index],
                        width: cardW,
                        height: cardH,
                        play: index == _active && _visible,
                        onTap: () =>
                            index == _active ? _openActive() : _goTo(index),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: isMobile ? 32 : 44),
            _Details(
              project: _items[_active],
              index: _active,
              total: _items.length,
              isMobile: isMobile,
              onPrev: () => _goTo(_active - 1),
              onNext: () => _goTo(_active + 1),
              onOpen: _openActive,
            ),
          ],
        ),
      ),
    );
  }
}

/// The app card inside the coverflow: a fanned deck of the app's 2-3
/// screenshots, all visible at once. When [play] is true (focused) the deck
/// fans OUT and the screens continuously rotate through the front position;
/// otherwise it collapses to a tight, static stack. Paint-only transforms.
class _Card extends StatefulWidget {
  const _Card({
    required this.project,
    required this.width,
    required this.height,
    required this.play,
    required this.onTap,
  });

  final WorkProject project;
  final double width;
  final double height;
  final bool play;
  final VoidCallback onTap;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  static const _spin = Duration(milliseconds: 2600);
  Timer? _timer;
  int _rot = 0;

  int get _n => widget.project.shots.length.clamp(1, 3);

  @override
  void initState() {
    super.initState();
    if (widget.play) _start();
  }

  @override
  void didUpdateWidget(_Card old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) {
      _start();
    } else if (!widget.play && old.play) {
      _stop();
    }
  }

  void _start() {
    _timer?.cancel();
    if (_n < 2) return;
    _timer = Timer.periodic(_spin, (_) {
      if (mounted) setState(() => _rot++);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (_rot != 0) setState(() => _rot = 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Per-slot placement. Slot 0 = front, 1 = right-back, 2 = left-back.
  ({double dx, double rot, double scale, int z}) _slot(int slot) {
    final spread = widget.play ? widget.width * 0.235 : widget.width * 0.085;
    final angle = widget.play ? 0.13 : 0.05;
    switch (slot) {
      case 0:
        return (dx: 0, rot: 0, scale: 1.0, z: 2);
      case 1:
        return (dx: spread, rot: angle, scale: 0.9, z: 1);
      default:
        return (dx: -spread, rot: -angle, scale: 0.9, z: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final shots = widget.project.shots;
    final n = _n;
    final shotW = widget.width * 0.58;
    final shotH = shotW * 1.95;

    // Each image keeps a stable key and animates toward its current slot.
    final entries = <({int z, Widget w})>[];
    for (var i = 0; i < n; i++) {
      final slot = (i + _rot) % n;
      final s = _slot(slot);
      entries.add((
        z: s.z,
        w: AnimatedContainer(
          key: ValueKey('shot-$i'),
          duration: const Duration(milliseconds: 620),
          curve: AppMotion.expo,
          width: shotW,
          height: shotH,
          transform: Matrix4.identity()
            ..translateByDouble(s.dx, 0, 0, 1)
            ..rotateZ(s.rot)
            ..scaleByDouble(s.scale, s.scale, 1, 1),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.lineStrong),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 44,
                spreadRadius: -10,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  shots[i],
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  cacheWidth: (shotW * 2).round(),
                  errorBuilder: (_, _, _) =>
                      _ShotPlaceholder(label: widget.project.name),
                ),
                AnimatedOpacity(
                  opacity: slot == 0 ? 1 : 0,
                  duration: AppMotion.fast,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _IconBadge(asset: widget.project.icon),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }

    // Paint back-to-front (front slot last / on top).
    entries.sort((a, b) => a.z.compareTo(b.z));

    return CursorRegion(
      label: 'view',
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [for (final e in entries) e.w],
        ),
      ),
    );
  }
}

/// The active-app details panel below the carousel; animates on change.
class _Details extends StatelessWidget {
  const _Details({
    required this.project,
    required this.index,
    required this.total,
    required this.isMobile,
    required this.onPrev,
    required this.onNext,
    required this.onOpen,
  });

  final WorkProject project;
  final int index;
  final int total;
  final bool isMobile;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final gutter = Responsive.gutter(context);

    final text = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _TagPill(label: project.tag),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: AppMotion.medium,
          switchInCurve: AppMotion.expo,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Column(
            key: ValueKey(index),
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: AppText.display(
                  size: isMobile ? 30 : 40,
                  weight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text(
                  project.blurb,
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: AppText.sans(
                      size: 15.5, height: 1.55, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        _AppStoreButton(onTap: onOpen),
      ],
    );

    final controls = _Controls(
      index: index,
      total: total,
      onPrev: onPrev,
      onNext: onNext,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          child: isMobile
              ? Column(children: [text, const SizedBox(height: 32), controls])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: text),
                    const SizedBox(width: 40),
                    controls,
                  ],
                ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final progress = (index + 1) / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowButton(icon: Icons.arrow_back, onTap: onPrev),
            const SizedBox(width: 14),
            _ArrowButton(icon: Icons.arrow_forward, onTap: onNext),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (index + 1).toString().padLeft(2, '0'),
              style: AppText.mono(size: 13, color: AppColors.ink),
            ),
            Text(' / ${total.toString().padLeft(2, '0')}',
                style: AppText.mono(size: 13, color: AppColors.faint)),
          ],
        ),
        const SizedBox(height: 12),
        // Progress track.
        SizedBox(
          width: 180,
          child: Stack(
            children: [
              Container(height: 2, color: AppColors.line),
              AnimatedFractionallySizedBox(
                duration: AppMotion.medium,
                curve: AppMotion.weighted,
                widthFactor: progress,
                child: Container(height: 2, color: AppColors.accent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatefulWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return CursorRegion(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.soft,
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hover ? AppColors.accent : Colors.transparent,
            border: Border.all(
              color: _hover ? AppColors.accent : AppColors.lineStrong,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: _hover ? AppColors.background : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _AppStoreButton extends StatefulWidget {
  const _AppStoreButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AppStoreButton> createState() => _AppStoreButtonState();
}

class _AppStoreButtonState extends State<_AppStoreButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return CursorRegion(
      label: 'open',
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.soft,
          padding: const EdgeInsets.fromLTRB(22, 14, 16, 14),
          decoration: BoxDecoration(
            color: _hover ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.accent, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View on App Store',
                style: AppText.sans(
                  size: 15,
                  weight: FontWeight.w600,
                  color: _hover ? AppColors.background : AppColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_outward,
                  size: 18,
                  color: _hover ? AppColors.background : AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          cacheWidth: 120,
          errorBuilder: (_, _, _) => ColoredBox(color: AppColors.surface),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: AppText.mono(size: 11, color: AppColors.muted),
      ),
    );
  }
}

class _ShotPlaceholder extends StatelessWidget {
  const _ShotPlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF17150F), AppColors.background],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.sans(size: 16, weight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
