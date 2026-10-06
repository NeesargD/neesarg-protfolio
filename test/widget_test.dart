// Smoke test for the portfolio shell.
//
// The app runs several infinite animations (grain, aurora, marquee), so we
// pump a few fixed frames rather than pumpAndSettle, and assert the always-on
// navigation branding is present.

import 'package:flutter_test/flutter_test.dart';
import 'package:neesarg_portfolio/main.dart';

void main() {
  testWidgets('Portfolio boots and shows nav branding', (tester) async {
    await tester.pumpWidget(const PortfolioApp());
    // Advance a few frames past the first paint without settling animations.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Neesarg Darji'), findsWidgets);
  });
}
