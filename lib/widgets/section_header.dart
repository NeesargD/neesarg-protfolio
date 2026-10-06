import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'reveal.dart';

/// A consistent section label: a mono index/eyebrow with a drawn accent rule,
/// used at the top of every major section.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.index,
    required this.label,
  });

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      offset: 24,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          Text('$index — ', style: AppText.mono(color: AppColors.accent)),
          Text(
            label.toUpperCase(),
            style: AppText.mono(color: AppColors.muted),
          ),
          const SizedBox(width: 20),
          const Expanded(child: Divider(color: AppColors.line, height: 1)),
        ],
      ),
    );
  }
}
