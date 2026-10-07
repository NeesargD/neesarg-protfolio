import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_motion.dart';
import '../core/utils/motion_prefs.dart';
import '../core/utils/responsive.dart';
import '../sections/about_section.dart';
import '../sections/contact_section.dart';
import '../sections/experience_section.dart';
import '../sections/hero_section.dart';
import '../sections/nav_bar.dart';
import '../sections/skills_section.dart';
import '../sections/work_section.dart';
import '../widgets/cursor/cursor_controller.dart';
import '../widgets/cursor/custom_cursor_layer.dart';
import '../widgets/grain_overlay.dart';
import 'intro_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _cursor = CursorController();

  final _aboutKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _workKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _topKey = GlobalKey();

  /// Live scroll offset — drives the hero zoom transition.
  final ValueNotifier<double> _scroll = ValueNotifier(0);

  bool _scrolled = false;
  bool _heroPlay = false;
  bool _showLoader = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _scroll.value = _scrollController.offset;
    final scrolled = _scrollController.offset > 40;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
  }

  Future<void> _openResume() async {
    final uri = Uri.base.resolve(ResumeData.resumeFile);
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 950),
      curve: AppMotion.weighted,
      alignment: 0.0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scroll.dispose();
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useCursor = Responsive.isDesktop(context);
    // Reduced-motion: skip the intro curtain and show the hero immediately.
    final reduced = MotionPrefs.reduced(context);
    final showLoader = _showLoader && !reduced;
    final heroPlay = _heroPlay || reduced;

    final entries = <NavEntry>[
      NavEntry('About', () => _scrollTo(_aboutKey)),
      NavEntry('Skills', () => _scrollTo(_skillsKey)),
      NavEntry('Work', () => _scrollTo(_workKey)),
      NavEntry('Contact', () => _scrollTo(_contactKey)),
    ];

    final viewportH = MediaQuery.sizeOf(context).height;

    Widget page = Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Zoom budget: one viewport of scroll drives the hero zoom.
                // The real hero is a fixed overlay (below), not in the flow.
                SizedBox(key: _topKey, height: viewportH),
                KeyedSubtree(key: _aboutKey, child: const AboutSection()),
                KeyedSubtree(key: _skillsKey, child: const SkillsSection()),
                KeyedSubtree(key: _workKey, child: const WorkSection()),
                const ExperienceSection(),
                KeyedSubtree(key: _contactKey, child: const ContactSection()),
              ],
            ),
          ),
        ),
        // Fixed hero that the "camera" flies into as you scroll the first
        // viewport. IgnorePointer so scroll passes through to the list.
        Positioned.fill(
          child: HeroZoomOverlay(
            scroll: _scroll,
            viewportH: viewportH,
            play: heroPlay,
          ),
        ),
        const Positioned.fill(child: GrainOverlay()),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: NavBar(
            scrolled: _scrolled,
            entries: entries,
            onLogoTap: () => _scrollTo(_topKey),
            onResume: _openResume,
          ),
        ),
        if (showLoader)
          Positioned.fill(
            child: IntroLoader(
              onRevealStart: () => setState(() => _heroPlay = true),
              onRevealComplete: () => setState(() => _showLoader = false),
            ),
          ),
      ],
    );

    if (useCursor) {
      page = MouseRegion(
        cursor: SystemMouseCursors.none,
        onHover: (e) => _cursor.moveTo(e.position),
        onExit: (_) => _cursor.hide(),
        child: Stack(
          children: [
            page,
            Positioned.fill(child: CustomCursorLayer(controller: _cursor)),
          ],
        ),
      );
    }

    return CursorScope(
      controller: _cursor,
      child: Scaffold(body: page),
    );
  }
}
