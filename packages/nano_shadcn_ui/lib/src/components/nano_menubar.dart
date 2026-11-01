import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_menu.dart';

/// One top-level menu of a [NanoMenubar].
class NanoMenubarMenu {
  const NanoMenubarMenu({required this.label, required this.items});

  final String label;
  final List<NanoMenuEntry> items;
}

/// Horizontal menu bar — shadcn `Menubar`: labels in a row; clicking opens a
/// dropdown, and hovering another label switches while one is open.
class NanoMenubar extends StatefulWidget {
  const NanoMenubar({super.key, required this.menus});

  final List<NanoMenubarMenu> menus;

  @override
  State<NanoMenubar> createState() => _NanoMenubarState();
}

class _NanoMenubarState extends State<NanoMenubar> with NanoOverlayHost {
  int? _openIndex;
  bool _switching = false;

  void _toggle(int index) {
    if (_openIndex == index) {
      closeOverlay();
      setState(() => _openIndex = null);
      return;
    }
    closeOverlay();
    _open(index);
  }

  void _open(int index) {
    setState(() => _openIndex = index);
    openOverlay(
      triggerContext: context,
      contentBuilder: (overlayContext) => _SwitchablePanel(
        items: widget.menus[index].items,
        controller: overlayController!,
      ),
    );
  }

  /// Hovering a different label while a menu is open swaps the panel.
  void _hover(int index) {
    if (_openIndex == null || _openIndex == index || _switching) return;
    _switching = true;
    closeOverlay();
    _open(index);
    _switching = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      padding: EdgeInsets.all(theme.spacing.stackDefault / 2),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(theme.radius.controlInput),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.menus.length; i++)
            _MenubarTrigger(
              label: widget.menus[i].label,
              open: _openIndex == i,
              onTap: () => _toggle(i),
              onHover: () => _hover(i),
            ),
        ],
      ),
    );
  }
}

class _MenubarTrigger extends StatefulWidget {
  const _MenubarTrigger({
    required this.label,
    required this.open,
    required this.onTap,
    required this.onHover,
  });

  final String label;
  final bool open;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  State<_MenubarTrigger> createState() => _MenubarTriggerState();
}

class _MenubarTriggerState extends State<_MenubarTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final active = widget.open || _hovered;
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: theme.motion.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.insetControl,
            vertical: theme.spacing.stackDefault / 2,
          ),
          decoration: BoxDecoration(
            color: active ? theme.colors.surfaceSubtle : null,
            borderRadius: BorderRadius.circular(
              theme.radius.controlDefault / 2,
            ),
          ),
          child: Text(
            widget.label,
            style: theme.type.labelAction.copyWith(
              color: theme.colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel variant whose item activation closes the bar's overlay.
class _SwitchablePanel extends StatelessWidget {
  const _SwitchablePanel({required this.items, required this.controller});

  final List<NanoMenuEntry> items;
  final NanoOverlayController controller;

  @override
  Widget build(BuildContext context) {
    return NanoMenuPanel(
      entries: [
        for (final entry in items)
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
            _ => entry,
          },
      ],
    );
  }
}
