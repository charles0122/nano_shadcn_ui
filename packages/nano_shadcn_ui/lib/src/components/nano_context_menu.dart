import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_menu.dart';

/// Right-click menu — shadcn `Context Menu`: opens the shared menu panel at
/// the pointer position on secondary tap.
class NanoContextMenu extends StatelessWidget {
  const NanoContextMenu({super.key, required this.items, required this.child});

  final List<NanoMenuEntry> items;
  final Widget child;

  void _show(BuildContext context, Offset globalPosition) {
    showNanoMenu(
      context,
      anchorRect: Rect.fromPoints(globalPosition, globalPosition),
      entries: _wire(items, NanoOverlayScope.of(context)),
      minWidth: 192,
    );
  }

  /// Selecting an item dismisses the menu first, then runs the callback.
  static List<NanoMenuEntry> _wire(
    List<NanoMenuEntry> entries,
    NanoOverlayController? controller,
  ) {
    if (controller == null) return entries;
    return [
      for (final entry in entries)
        switch (entry) {
          NanoMenuItemEntry e => NanoMenuItemEntry(
            label: e.label,
            icon: e.icon,
            trailing: e.trailing,
            shortcut: e.shortcut,
            enabled: e.enabled,
            destructive: e.destructive,
            onSelect: e.onSelect == null
                ? null
                : () {
                    controller.close();
                    e.onSelect!();
                  },
          ),
          NanoMenuCheckboxEntry e => NanoMenuCheckboxEntry(
            label: e.label,
            checked: e.checked,
            enabled: e.enabled,
            onSelect: e.onSelect == null
                ? null
                : () {
                    controller.close();
                    e.onSelect!();
                  },
          ),
          NanoMenuSubmenu s => NanoMenuSubmenu(
            label: s.label,
            icon: s.icon,
            items: _wire(s.items, controller),
          ),
          _ => entry,
        },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapUp: (details) => _show(context, details.globalPosition),
      child: child,
    );
  }
}
