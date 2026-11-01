import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_menu.dart';

/// Dropdown menu — shadcn `Dropdown Menu`: a trigger (ghost button with
/// chevron by default) that opens the [NanoMenuPanel] anchored below.
class NanoDropdownMenu extends StatefulWidget {
  const NanoDropdownMenu({
    super.key,
    required this.items,
    this.label,
    this.trigger,
    this.enabled = true,
  });

  final List<NanoMenuEntry> items;

  /// Simple text trigger; leave null with [trigger] for a custom one.
  final String? label;

  /// Fully custom trigger widget.
  final Widget? trigger;
  final bool enabled;

  @override
  State<NanoDropdownMenu> createState() => _NanoDropdownMenuState();
}

class _NanoDropdownMenuState extends State<NanoDropdownMenu>
    with NanoOverlayHost {
  void _toggle() {
    if (isOverlayOpen) {
      closeOverlay();
      return;
    }
    openOverlay(
      triggerContext: context,
      contentBuilder: (overlayContext) =>
          _ClosingPanel(items: widget.items, controller: overlayController!),
      matchTriggerWidth: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final trigger =
        widget.trigger ??
        Container(
          height: theme.size.controlHeightDefault,
          padding: EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label ?? '',
                style: theme.type.labelAction.copyWith(
                  color: theme.colors.textPrimary,
                ),
              ),
              SizedBox(width: theme.spacing.inlineIconLabel / 2),
              NanoIcon(
                NanoIcons.chevronDown,
                size: theme.size.iconInline,
                color: theme.colors.textSecondary,
              ),
            ],
          ),
        );
    return GestureDetector(
      onTap: widget.enabled ? _toggle : null,
      child: trigger,
    );
  }
}

/// Wraps the panel so selecting an item dismisses the menu first.
class _ClosingPanel extends StatelessWidget {
  const _ClosingPanel({required this.items, required this.controller});

  final List<NanoMenuEntry> items;
  final NanoOverlayController controller;

  List<NanoMenuEntry> _wire(List<NanoMenuEntry> entries) => [
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
          items: _wire(s.items),
        ),
        _ => entry,
      },
  ];

  @override
  Widget build(BuildContext context) {
    return NanoMenuPanel(entries: _wire(items));
  }
}
