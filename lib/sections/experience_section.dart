import 'package:flutter/material.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/cursor/cursor_region.dart';
import '../widgets/reveal.dart';
import '../widgets/section_header.dart';
import '../widgets/section_shell.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    return SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(index: '04', label: 'Experience'),
          const SizedBox(height: 44),
          Reveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ResumeData.company,
                    style: AppText.sans(
                      size: Responsive.value(context,
                          mobile: 16, tablet: 18, desktop: 20),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!Responsive.isMobile(context))
                  Text(
                    ResumeData.companyRole,
                    style: AppText.mono(size: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          for (final item in ResumeData.experience)
            Reveal(offset: 32, child: _ExperienceRow(item: item)),
        ],
      ),
    );
  }
}

class _ExperienceRow extends StatefulWidget {
  const _ExperienceRow({required this.item});
  final ExperienceItem item;

  @override
  State<_ExperienceRow> createState() => _ExperienceRowState();
}

class _ExperienceRowState extends State<_ExperienceRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    final isMobile = Responsive.isMobile(context);
    final titleSize = Responsive.value(
      context,
      mobile: 34.0,
      tablet: 52.0,
      desktop: 74.0,
    );

    return CursorRegion(
      label: _open ? 'close' : 'open',
      onTap: () => setState(() => _open = !_open),
      child: MouseRegion(
        // On desktop, hovering opens the row; tapping still toggles.
        onEnter: (_) {
          if (!isMobile) setState(() => _open = true);
        },
        onExit: (_) {
          if (!isMobile) setState(() => _open = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line)),
            color: _open
                ? AppColors.ink.withValues(alpha: 0.02)
                : Colors.transparent,
          ),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 22 : 30,
            horizontal: _open ? (isMobile ? 4 : 16) : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(titleSize, isMobile),
              _expandable(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(double titleSize, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isMobile) ...[
          SizedBox(
            width: 70,
            child: Text(
              widget.item.index,
              style: AppText.mono(
                size: 14,
                color: _open ? AppColors.accent : AppColors.faint,
              ),
            ),
          ),
        ],
        Expanded(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            offset: _open && !isMobile ? const Offset(0.02, 0) : Offset.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    widget.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(
                      size: titleSize,
                      weight: FontWeight.w600,
                      letterSpacing: -titleSize * 0.02,
                      color: _open ? AppColors.accent : AppColors.ink,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 20),
                  Text(
                    widget.item.subtitle,
                    style: AppText.sans(size: 16, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _Tag(label: widget.item.tag, active: _open),
        const SizedBox(width: 16),
        AnimatedRotation(
          turns: _open ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.add,
            color: _open ? AppColors.accent : AppColors.muted,
            size: isMobile ? 22 : 28,
          ),
        ),
      ],
    );
  }

  Widget _expandable(bool isMobile) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: _open ? double.infinity : 0,
        ),
        child: AnimatedOpacity(
          opacity: _open ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: isMobile ? 0 : 70,
              right: isMobile ? 0 : 80,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final b in widget.item.bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 9, right: 14),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            b,
                            style: AppText.sans(
                              size: isMobile ? 15 : 17,
                              height: 1.5,
                              color: AppColors.muted,
                            ),
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
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    context.watchTheme();
    if (Responsive.isMobile(context)) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: active ? AppColors.accent : AppColors.line,
        ),
      ),
      child: Text(
        label,
        style: AppText.mono(
          size: 11,
          color: active ? AppColors.accent : AppColors.muted,
        ),
      ),
    );
  }
}
