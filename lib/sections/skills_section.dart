import 'package:flutter/material.dart';

import '../core/data/resume_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/cursor/cursor_region.dart';
import '../widgets/reveal.dart';
import '../widgets/section_header.dart';
import '../widgets/section_shell.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(index: '02', label: 'Capabilities'),
          const SizedBox(height: 56),
          Reveal(
            child: Text(
              'The stack I build with.',
              style: AppText.display(
                size: Responsive.value(context,
                    mobile: 32, tablet: 44, desktop: 56),
                weight: FontWeight.w600,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 64),
          ...[
            for (var i = 0; i < ResumeData.skillGroups.length; i++)
              Reveal(
                delay: Duration(milliseconds: 60 * i),
                child: _SkillGroupRow(
                  group: ResumeData.skillGroups[i],
                  isLast: i == ResumeData.skillGroups.length - 1,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SkillGroupRow extends StatelessWidget {
  const _SkillGroupRow({required this.group, required this.isLast});
  final SkillGroup group;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final title = Text(
      group.title,
      style: AppText.mono(
        size: 13,
        color: AppColors.accent,
        weight: FontWeight.w600,
      ),
    );

    final chips = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [for (final s in group.skills) _SkillChip(label: s)],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: AppColors.line),
          bottom: isLast
              ? const BorderSide(color: AppColors.line)
              : BorderSide.none,
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 18), chips],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 240, child: title),
                Expanded(child: chips),
              ],
            ),
    );
  }
}

class _SkillChip extends StatefulWidget {
  const _SkillChip({required this.label});
  final String label;

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return CursorRegion(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: _hover ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: _hover ? AppColors.accent : AppColors.lineStrong,
            ),
          ),
          child: Text(
            widget.label,
            style: AppText.sans(
              size: 15,
              weight: FontWeight.w500,
              color: _hover ? AppColors.background : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
