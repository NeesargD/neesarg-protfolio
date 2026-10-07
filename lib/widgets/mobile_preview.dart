import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// A looping, auto-scrolling "mobile view" of the portfolio — used as the live
/// screen content inside the hero phone. It gently scrolls its content column
/// upward forever (seamless loop), so the phone always looks alive.
class MobilePreview extends StatefulWidget {
  const MobilePreview({super.key, this.speed = 26});

  /// Scroll speed, logical px/second.
  final double speed;

  @override
  State<MobilePreview> createState() => _MobilePreviewState();
}

class _MobilePreviewState extends State<MobilePreview>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _offset = ValueNotifier(0);
  double _blockH = 0;
  Duration _last = Duration.zero;
  bool _visible = false;
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) setState(() => _blockH = box.size.height);
  }

  void _onTick(Duration elapsed) {
    if (_blockH == 0) {
      _last = elapsed;
      return;
    }
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    var next = _offset.value + widget.speed * dt;
    if (next >= _blockH) next -= _blockH;
    _offset.value = next;
  }

  void _onVisibility(VisibilityInfo info) {
    final v = info.visibleFraction > 0.02;
    if (v == _visible) return;
    _visible = v;
    if (v) {
      _last = Duration.zero;
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final block = _Block(blockKey: _key);
    return VisibilityDetector(
      key: const ValueKey('mobile-preview'),
      onVisibilityChanged: _onVisibility,
      child: ColoredBox(
        color: AppColors.background,
        child: ClipRect(
          child: ValueListenableBuilder<double>(
            valueListenable: _offset,
            builder: (context, off, _) {
              return Transform.translate(
                offset: Offset(0, -off),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [block, const _Block()],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// One repeat of the preview content.
class _Block extends StatelessWidget {
  const _Block({this.blockKey});
  final Key? blockKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: blockKey,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('AVAILABLE FOR WORK', style: AppText.mono(size: 8)),
            ],
          ),
          const SizedBox(height: 16),
          // Portrait
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/me.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.2, -0.1),
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: AppColors.surface)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.18),
                          AppColors.background.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Senior\nFlutter\nDeveloper',
            style: AppText.display(
                size: 34, height: 0.98, weight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Text(
            '5+ years shipping production iOS & Android apps in healthcare '
            'and e-commerce.',
            style: AppText.sans(size: 12, height: 1.5, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          // Stat chips
          Row(
            children: [
              Expanded(child: _Stat(ResumeData.stats[0])),
              const SizedBox(width: 10),
              Expanded(child: _Stat(ResumeData.stats[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _Stat(ResumeData.stats[2])),
              const SizedBox(width: 10),
              Expanded(child: _Stat(ResumeData.stats[3])),
            ],
          ),
          const SizedBox(height: 18),
          Text('SELECTED WORK', style: AppText.mono(size: 8)),
          const SizedBox(height: 10),
          _AppRow(ResumeData.featuredWork[0]),
          const SizedBox(height: 8),
          _AppRow(ResumeData.featuredWork[1]),
          const SizedBox(height: 8),
          _AppRow(ResumeData.featuredWork[2]),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.stat);
  final Stat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.value,
              style: AppText.display(
                  size: 26, weight: FontWeight.w600, color: AppColors.accent)),
          const SizedBox(height: 4),
          Text(stat.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.mono(size: 7)),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow(this.project);
  final WorkProject project;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.asset(project.icon,
              width: 34,
              height: 34,
              fit: BoxFit.cover,
              cacheWidth: 80,
              errorBuilder: (_, _, _) =>
                  const SizedBox(width: 34, height: 34)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(size: 12, weight: FontWeight.w600)),
              Text(project.tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono(size: 7)),
            ],
          ),
        ),
        Icon(Icons.north_east, size: 12, color: AppColors.accent),
      ],
    );
  }
}
