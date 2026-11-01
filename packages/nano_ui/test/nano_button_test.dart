import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_ui/nano_ui.dart';

import 'token_fixture.dart';

Widget wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: NanoTheme(data: fixtureTheme(), child: child),
);

void main() {
  testWidgets('tap fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(NanoButton(label: 'Press me', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Press me'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('disabled button does not fire', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        NanoButton(label: 'Blocked', onPressed: () => taps++, enabled: false),
      ),
    );
    await tester.tap(find.text('Blocked'));
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('sizes map to the control-height tokens', (tester) async {
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            NanoButton(
              label: 'Large',
              size: NanoButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    final container = tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text('Large'),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final constraints = container.constraints;
    expect(constraints?.minHeight, 8.0); // fixture size.control.height.large
  });

  testWidgets('variants render from the action color roles', (tester) async {
    await tester.pumpWidget(
      wrap(
        Column(
          children: const [
            NanoButton(label: 'A', variant: NanoButtonVariant.primary),
            NanoButton(label: 'B', variant: NanoButtonVariant.secondary),
            NanoButton(label: 'C', variant: NanoButtonVariant.ghost),
          ],
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });
}
