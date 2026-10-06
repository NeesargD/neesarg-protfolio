import 'package:flutter/material.dart';

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

  bool _scrolled = false;
  bool _heroPlay = false;
  bool _showLoader = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 40;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
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

    Widget page = Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(key: _topKey, height: 0),
                HeroSection(play: heroPlay),
                KeyedSubtree(key: _aboutKey, child: const AboutSection()),
                KeyedSubtree(key: _skillsKey, child: const SkillsSection()),
                KeyedSubtree(key: _workKey, child: const WorkSection()),
                const ExperienceSection(),
                KeyedSubtree(key: _contactKey, child: const ContactSection()),
              ],
            ),
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
