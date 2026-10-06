import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/cursor/cursor_region.dart';
import '../widgets/magnetic.dart';
import '../widgets/reveal.dart';
import '../widgets/section_header.dart';
import '../widgets/section_shell.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ResumeData.contact;
    final isMobile = Responsive.isMobile(context);
    final hugeSize = Responsive.value(
      context,
      mobile: 48.0,
      tablet: 92.0,
      desktop: 150.0,
    );

    return SectionShell(
      verticalPadding: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(index: '05', label: 'Contact'),
          const SizedBox(height: 72),
          Reveal(
            child: Text(
              "Let's build\nsomething stable.",
              style: AppText.display(
                size: hugeSize,
                weight: FontWeight.w600,
                height: 0.98,
                letterSpacing: -hugeSize * 0.025,
              ),
            ),
          ),
          const SizedBox(height: 56),
          Reveal(
            delay: const Duration(milliseconds: 120),
            child: Magnetic(
              child: CursorRegion(
                label: 'say hi',
                onTap: () => _open('mailto:${c.email}'),
                child: _EmailPill(email: c.email, isMobile: isMobile),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 80 : 140),
          Reveal(
            child: _ContactMeta(
              contact: c,
              isMobile: isMobile,
              onOpen: _open,
            ),
          ),
          const SizedBox(height: 72),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 28),
          _FooterBar(education: ResumeData.education, isMobile: isMobile),
        ],
      ),
    );
  }
}

class _EmailPill extends StatefulWidget {
  const _EmailPill({required this.email, required this.isMobile});
  final String email;
  final bool isMobile;

  @override
  State<_EmailPill> createState() => _EmailPillState();
}

class _EmailPillState extends State<_EmailPill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.soft,
        padding: EdgeInsets.fromLTRB(
          widget.isMobile ? 24 : 40,
          widget.isMobile ? 12 : 16,
          widget.isMobile ? 12 : 16,
          widget.isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: _hover ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.accent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.email,
              style: AppText.sans(
                size: widget.isMobile ? 18 : 28,
                weight: FontWeight.w500,
                color: _hover ? AppColors.background : AppColors.ink,
              ),
            ),
            SizedBox(width: widget.isMobile ? 16 : 28),
            // "Button-in-button": the arrow lives in its own circular wrapper,
            // flush with the pill's right padding, and shifts on hover.
            AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.soft,
              width: widget.isMobile ? 40 : 54,
              height: widget.isMobile ? 40 : 54,
              transform: Matrix4.translationValues(_hover ? 3 : 0, 0, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hover
                    ? AppColors.background
                    : AppColors.accent.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.arrow_outward,
                size: widget.isMobile ? 18 : 24,
                color: _hover ? AppColors.accent : AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMeta extends StatelessWidget {
  const _ContactMeta({
    required this.contact,
    required this.isMobile,
    required this.onOpen,
  });

  final Contact contact;
  final bool isMobile;
  final Future<void> Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final columns = <Widget>[
      _MetaColumn(
        label: 'EMAIL',
        value: contact.email,
        onTap: () => onOpen('mailto:${contact.email}'),
      ),
      _MetaColumn(
        label: 'PHONE',
        value: contact.phone,
        onTap: () => onOpen('tel:${contact.phone.replaceAll(' ', '')}'),
      ),
      _MetaColumn(
        label: 'LINKEDIN',
        value: 'in/neesarg-darji',
        onTap: () => onOpen(contact.linkedIn),
      ),
      _MetaColumn(
        label: 'LOCATION',
        value: contact.location,
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in columns)
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: c,
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns.length; i++) ...[
          Expanded(child: columns[i]),
          if (i != columns.length - 1) const SizedBox(width: 24),
        ],
      ],
    );
  }
}

class _MetaColumn extends StatefulWidget {
  const _MetaColumn({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  State<_MetaColumn> createState() => _MetaColumnState();
}

class _MetaColumnState extends State<_MetaColumn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppText.mono(size: 11)),
        const SizedBox(height: 12),
        Text(
          widget.value,
          style: AppText.sans(
            size: 17,
            weight: FontWeight.w500,
            color: _hover && interactive ? AppColors.accent : AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          height: 1,
          width: _hover && interactive ? 48 : 0,
          color: AppColors.accent,
        ),
      ],
    );

    if (!interactive) return content;

    return CursorRegion(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: content,
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({required this.education, required this.isMobile});
  final String education;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final edu = Text(
      education,
      style: AppText.mono(size: 11, color: AppColors.faint),
    );
    final credit = Text(
      '© 2026 · Built in Flutter',
      style: AppText.mono(size: 11, color: AppColors.faint),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [edu, const SizedBox(height: 12), credit],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Flexible(child: edu), const SizedBox(width: 24), credit],
    );
  }
}
