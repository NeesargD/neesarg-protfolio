import 'package:flutter/material.dart';

import '../core/utils/responsive.dart';

/// Wraps section content with the page's horizontal gutter, a max width and
/// consistent vertical rhythm.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    this.verticalPadding = 140,
  });

  final Widget child;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final gutter = Responsive.gutter(context);
    final vPad = Responsive.value(
      context,
      mobile: verticalPadding * 0.5,
      tablet: verticalPadding * 0.75,
      desktop: verticalPadding,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter, vertical: vPad),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}
