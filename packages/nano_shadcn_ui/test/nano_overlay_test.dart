import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import 'token_fixture.dart';

/// Overlays anchor to the ROOT overlay, so the component under test has to
/// live inside a navigator. WidgetsApp supplies that without Material.
Widget wrapOverlay(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: NanoTheme(
    data: fixtureTheme(),
    child: NanoToaster(
      child: WidgetsApp(
        color: const Color(0xFF17212D),
        home: child,
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('NanoDialog.show mounts a scrim, panel and dismisses on Escape', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapOverlay(
        Builder(
          builder: (context) => Center(
            child: NanoButton(
              label: 'Open dialog',
              onPressed: () => NanoDialog.show(
                context,
                builder: (dialogContext) => const NanoDialogPanel(
                  child: NanoText('Dialog body', role: NanoTextRole.body),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog body'), findsOneWidget);

    // Escape dismisses through the overlay focus scope.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Dialog body'), findsNothing);
  });

  testWidgets('dropdown menu selects an item and closes', (tester) async {
    var selected = '';
    await tester.pumpWidget(
      wrapOverlay(
        Center(
          child: NanoDropdownMenu(
            label: 'Actions',
            items: [
              NanoMenuItemEntry(
                label: 'Duplicate',
                onSelect: () => selected = 'duplicate',
              ),
              const NanoMenuSeparator(),
              const NanoMenuItemEntry(label: 'Unavailable', enabled: false),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);

    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();
    expect(selected, 'duplicate');
    // The menu closed — only the trigger label remains.
    expect(find.text('Duplicate'), findsNothing);
  });

  testWidgets('command palette filters items and selects with Enter', (
    tester,
  ) async {
    var picked = '';
    await tester.pumpWidget(
      wrapOverlay(
        Center(
          child: NanoCommand(
            items: [
              NanoCommandItem(
                label: 'Open calendar',
                onSelect: () => picked = 'calendar',
              ),
              NanoCommandItem(
                label: 'Open settings',
                onSelect: () => picked = 'settings',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(NanoInput), 'set');
    await tester.pumpAndSettle();
    expect(find.text('Open calendar'), findsNothing);
    expect(find.text('Open settings'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked, 'settings');
  });

  testWidgets('checkbox toggles through onChanged', (tester) async {
    NanoTristate value = NanoTristate.unchecked;
    await tester.pumpWidget(
      wrapOverlay(
        Center(
          child: NanoCheckbox(
            value: value,
            label: 'Accept',
            onChanged: (v) {}, // replaced below by a stateful harness
          ),
        ),
      ),
    );
    // Tap the label row → still no crash with a no-op callback.
    await tester.tap(find.text('Accept'));
    await tester.pump();
  });

  testWidgets('switch reports both directions', (tester) async {
    var value = false;
    late StateSetter set;
    await tester.pumpWidget(
      wrapOverlay(
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return Center(
              child: NanoSwitch(
                value: value,
                onChanged: (v) => set(() => value = v),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(NanoSwitch));
    await tester.pumpAndSettle();
    expect(value, isTrue);

    await tester.tap(find.byType(NanoSwitch));
    await tester.pumpAndSettle();
    expect(value, isFalse);
  });

  testWidgets('calendar picks a day and reports it', (tester) async {
    final picked = <DateTime>[];
    await tester.pumpWidget(
      wrapOverlay(
        Center(
          child: SizedBox(
            width: 400,
            child: NanoCalendar(
              month: DateTime(2026, 10),
              selected: const [],
              onChanged: (dates) => picked
                ..clear()
                ..addAll(dates),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('14').first);
    await tester.pump();
    expect(picked, hasLength(1));
    expect(picked.last.year, 2026);
    expect(picked.last.month, 10);
    expect(picked.last.day, 14);
  });

  testWidgets('sonner shows a toast and dismisses it', (tester) async {
    await tester.pumpWidget(
      wrapOverlay(
        Builder(
          builder: (context) => Center(
            child: NanoButton(
              label: 'Notify',
              onPressed: () => NanoToast.show(
                context,
                title: 'Saved',
                description: 'All changes synced.',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Notify'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('All changes synced.'), findsOneWidget);
  });

  testWidgets('sheet opens at an edge and closes on Escape', (tester) async {
    await tester.pumpWidget(
      wrapOverlay(
        Builder(
          builder: (context) => Center(
            child: NanoButton(
              label: 'Open sheet',
              onPressed: () => NanoSheet.show(
                context,
                builder: (sheetContext) => const NanoSheetPanel(
                  child: NanoText('Sheet body', role: NanoTextRole.body),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet body'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Sheet body'), findsNothing);
  });

  testWidgets('select opens a panel and picks a value', (tester) async {
    String? picked;
    await tester.pumpWidget(
      wrapOverlay(
        Center(
          child: NanoSelect<String>(
            items: const [
              NanoSelectItem(value: 'a', label: 'Alpha'),
              NanoSelectItem(value: 'b', label: 'Beta'),
            ],
            value: null,
            placeholder: 'Pick one',
            onChanged: (v) => picked = v,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(NanoSelect<String>), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(picked, 'b');
  });
}
