import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import 'token_fixture.dart';

Widget wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: NanoTheme(data: fixtureTheme(), child: child),
);

Finder iconOf(NanoIconData data) => find.byWidgetPredicate(
  (widget) => widget is NanoIcon && widget.icon == data,
);

void main() {
  testWidgets('sidebar collapses and expands back through the rail button', (
    tester,
  ) async {
    final sidebarKey = GlobalKey<NanoSidebarState>();
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 600,
          height: 400,
          child: NanoSidebar(
            key: sidebarKey,
            initiallyCollapsed: false,
            activeId: 'a',
            onItemTap: (_) {},
            header: const Text('Header'),
            groups: const [
              NanoSidebarGroup(
                items: [
                  NanoSidebarItem(
                    id: 'a',
                    label: 'Alpha',
                    icon: NanoIcons.circle,
                  ),
                  NanoSidebarItem(
                    id: 'b',
                    label: 'Beta',
                    icon: NanoIcons.circle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Header is visible while expanded.
    expect(find.text('Header'), findsOneWidget);

    // Collapse through the public state API. Apps may expose this from any
    // header layout; the collapsed rail itself owns the recovery affordance.
    sidebarKey.currentState!.toggle();
    await tester.pumpAndSettle();

    // Collapsed: header hidden, chevrons-right expander present.
    expect(find.text('Header'), findsNothing);
    expect(iconOf(NanoIcons.chevronsRight), findsOneWidget);

    // Expand back.
    await tester.tap(iconOf(NanoIcons.chevronsRight));
    await tester.pumpAndSettle();
    expect(find.text('Header'), findsOneWidget);
    expect(iconOf(NanoIcons.chevronsRight), findsNothing);
  });

  testWidgets('collapsed rail still navigates via item taps', (tester) async {
    String active = 'a';
    late StateSetter set;
    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return SizedBox(
              width: 600,
              height: 400,
              child: NanoSidebar(
                initiallyCollapsed: true,
                activeId: active,
                onItemTap: (id) => set(() => active = id),
                groups: const [
                  NanoSidebarGroup(
                    items: [
                      NanoSidebarItem(
                        id: 'a',
                        label: 'Alpha',
                        icon: NanoIcons.circle,
                      ),
                      NanoSidebarItem(
                        id: 'b',
                        label: 'Beta',
                        icon: NanoIcons.chevronDown,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Labels are hidden in the rail; icons remain tappable.
    expect(find.text('Alpha'), findsNothing);
    await tester.tap(iconOf(NanoIcons.chevronDown));
    await tester.pumpAndSettle();
    expect(active, 'b');
  });

  testWidgets('resizable handle drags without visual overflow', (tester) async {
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 400,
          height: 200,
          child: NanoResizable(
            initialRatio: 0.5,
            first: const Text('One'),
            second: const Text('Two'),
          ),
        ),
      ),
    );

    // Drag the handle (the MouseRegion wrapping the divider bar) rightward.
    final handle = find.byType(MouseRegion).first;
    final before = tester.getCenter(handle).dx;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    // The divider itself moved right as the first pane grew.
    final after = tester.getCenter(handle).dx;
    expect(after, greaterThan(before));

    // No RenderFlex overflow errors were thrown during the drag.
    expect(tester.takeException(), isNull);
  });
}
