import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_checkbox.dart';

// ---------------------------------------------------------------------------
// Declarative menu model
// ---------------------------------------------------------------------------

/// One entry of a nano menu (dropdown / context menu / menubar / select).
/// The same model renders from Dart lists and from the registry.
sealed class NanoMenuEntry {
  const NanoMenuEntry();
}

class NanoMenuItemEntry extends NanoMenuEntry {
  const NanoMenuItemEntry({
    required this.label,
    this.icon,
    this.trailing,
    this.shortcut,
    this.onSelect,
    this.enabled = true,
    this.destructive = false,
  });

  final String label;
  final NanoIconData? icon;
  final Widget? trailing;
  final List<String>? shortcut;
  final VoidCallback? onSelect;
  final bool enabled;
  final bool destructive;
}

/// Checkbox item — shows a check mark slot on the left.
class NanoMenuCheckboxEntry extends NanoMenuEntry {
  const NanoMenuCheckboxEntry({
    required this.label,
    required this.checked,
    this.onSelect,
    this.enabled = true,
  });

  final String label;
  final bool checked;
  final VoidCallback? onSelect;
  final bool enabled;
}

/// Radio item — dot slot on the left; belongs to a [NanoMenuRadioGroup].
class NanoMenuRadioEntry extends NanoMenuEntry {
  const NanoMenuRadioEntry({required this.value, required this.label});

  final String value;
  final String label;
}

class NanoMenuRadioGroup extends NanoMenuEntry {
  const NanoMenuRadioGroup({required this.value, required this.items});

  final String value;
  final List<NanoMenuRadioEntry> items;
}

class NanoMenuSubmenu extends NanoMenuEntry {
  const NanoMenuSubmenu({required this.label, required this.items, this.icon});

  final String label;
  final List<NanoMenuEntry> items;
  final NanoIconData? icon;
}

class NanoMenuLabelEntry extends NanoMenuEntry {
  const NanoMenuLabelEntry(this.label);

  final String label;
}

class NanoMenuSeparator extends NanoMenuEntry {
  const NanoMenuSeparator();
}

// ---------------------------------------------------------------------------
// Panel + items
// ---------------------------------------------------------------------------

/// The floating surface of a menu (shadcn `DropdownMenuContent`): popover
/// radius + floating shadow + tight padding, min width 12rem.
class NanoMenuPanel extends StatelessWidget {
  const NanoMenuPanel({
    super.key,
    required this.entries,
    this.minWidth = 192,
    this.maxWidth = 320,
  });

  final List<NanoMenuEntry> entries;

  /// Null = inherit the anchor constraints (e.g. match-trigger-width panels).
  final double? minWidth;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      constraints: minWidth == null && maxWidth == null
          ? null
          : BoxConstraints(
              minWidth: minWidth ?? 0,
              maxWidth: maxWidth ?? double.infinity,
            ),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(theme.radius.surfacePopover),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
        boxShadow: theme.elevation.floating,
      ),
      padding: EdgeInsets.all(theme.spacing.stackDefault / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0 &&
                entries[i] is NanoMenuSeparator &&
                entries[i - 1] is! NanoMenuSeparator)
              SizedBox(height: theme.spacing.stackDefault / 2),
            if (entries[i] is NanoMenuSeparator)
              NanoMenuSeparatorView()
            else ...[
              _entry(context, entries[i]),
              if (i + 1 < entries.length && entries[i + 1] is NanoMenuSeparator)
                SizedBox(height: theme.spacing.stackDefault / 2),
            ],
          ],
        ],
      ),
    );
  }

  Widget _entry(BuildContext context, NanoMenuEntry entry) {
    return switch (entry) {
      NanoMenuRadioEntry() => const SizedBox.shrink(),
      NanoMenuItemEntry e => NanoMenuItemRow(
        leading: e.icon == null
            ? null
            : NanoIcon(e.icon!, size: NanoTheme.of(context).size.iconInline),
        label: e.label,
        trailing: e.shortcut != null ? NanoKbd(e.shortcut!) : e.trailing,
        enabled: e.enabled,
        destructive: e.destructive,
        onTap: e.onSelect,
      ),
      NanoMenuCheckboxEntry e => NanoMenuItemRow(
        checkState: e.checked ? NanoTristate.checked : NanoTristate.unchecked,
        label: e.label,
        enabled: e.enabled,
        onTap: e.onSelect,
      ),
      NanoMenuRadioGroup g => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in g.items)
            NanoMenuItemRow(
              checkState: g.value == item.value
                  ? NanoTristate.checked
                  : NanoTristate.unchecked,
              radio: true,
              label: item.label,
              onTap: () {},
            ),
        ],
      ),
      NanoMenuSubmenu s => _NanoSubmenuRow(entry: s),
      NanoMenuLabelEntry l => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: NanoTheme.of(context).spacing.insetControl / 2,
          vertical: NanoTheme.of(context).spacing.stackDefault / 2,
        ),
        child: NanoText(l.label, role: NanoTextRole.labelMetadata),
      ),
      NanoMenuSeparator() => const SizedBox.shrink(),
    };
  }
}

/// Horizontal rule inside a menu panel.
class NanoMenuSeparatorView extends StatelessWidget {
  const NanoMenuSeparatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      height: theme.borders.dividerWidth,
      color: theme.colors.border,
      margin: EdgeInsets.symmetric(vertical: theme.spacing.stackDefault / 4),
    );
  }
}

/// One interactive menu row — hover/focus fill from the muted surface, left
/// check/radio slot, icon, label, trailing shortcut, destructive tint.
class NanoMenuItemRow extends StatefulWidget {
  const NanoMenuItemRow({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.checkState,
    this.radio = false,
    this.enabled = true,
    this.destructive = false,
    this.onTap,
    this.submenuOpen = false,
  });

  final String label;
  final Widget? leading;
  final Widget? trailing;
  final NanoTristate? checkState;
  final bool radio;
  final bool enabled;
  final bool destructive;
  final VoidCallback? onTap;
  final bool submenuOpen;

  @override
  State<NanoMenuItemRow> createState() => _NanoMenuItemRowState();
}

class _NanoMenuItemRowState extends State<NanoMenuItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final emphasized = _hovered && widget.enabled;
    final foreground = !widget.enabled
        ? theme.colors.textDisabled
        : widget.destructive
        ? theme.colors.danger.foreground
        : theme.colors.textPrimary;
    final slot = theme.size.iconInline;

    Widget? leadingSlot;
    if (widget.checkState != null) {
      leadingSlot = SizedBox(
        width: slot,
        height: slot,
        child: widget.checkState == NanoTristate.checked
            ? NanoIcon(
                widget.radio ? NanoIcons.circleDot : NanoIcons.check,
                size: slot,
                color: theme.colors.textPrimary,
              )
            : null,
      );
    } else if (widget.leading != null) {
      leadingSlot = SizedBox(
        width: slot,
        height: slot,
        child: Center(child: widget.leading),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.enabled && widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          button: true,
          enabled: widget.enabled,
          child: AnimatedContainer(
            duration: theme.motion.durationFast,
            curve: theme.motion.curveStandard,
            height: theme.size.controlHeightCompact,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.insetControl / 2,
            ),
            decoration: BoxDecoration(
              color: emphasized ? theme.colors.surfaceSubtle : null,
              borderRadius: BorderRadius.circular(
                theme.radius.controlDefault / 2,
              ),
            ),
            child: Row(
              children: [
                if (leadingSlot != null) ...[
                  leadingSlot,
                  SizedBox(width: theme.spacing.inlineIconLabel / 2),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.type.bodyDefault.copyWith(color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.trailing != null) ...[
                  SizedBox(width: theme.spacing.inlineIconLabel),
                  widget.trailing!,
                ],
                if (widget.submenuOpen) ...[
                  SizedBox(width: theme.spacing.inlineIconLabel / 2),
                  NanoIcon(
                    NanoIcons.chevronRight,
                    size: theme.size.iconInline,
                    color: foreground,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submenu row
// ---------------------------------------------------------------------------

class _NanoSubmenuRow extends StatefulWidget {
  const _NanoSubmenuRow({required this.entry});

  final NanoMenuSubmenu entry;

  @override
  State<_NanoSubmenuRow> createState() => _NanoSubmenuRowState();
}

class _NanoSubmenuRowState extends State<_NanoSubmenuRow> with NanoOverlayHost {
  Timer? _hoverTimer;

  void _open() {
    openOverlay(
      triggerContext: context,
      contentBuilder: (context) => NanoMenuPanel(entries: widget.entry.items),
      placement: NanoPlacement.bottomStart,
      offset: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return MouseRegion(
      onEnter: (_) {
        _hoverTimer?.cancel();
        _hoverTimer = Timer(const Duration(milliseconds: 200), _open);
      },
      onExit: (_) => _hoverTimer?.cancel(),
      child: NanoMenuItemRow(
        label: widget.entry.label,
        leading: widget.entry.icon == null
            ? null
            : NanoIcon(widget.entry.icon!, size: theme.size.iconInline),
        submenuOpen: true,
        onTap: () {
          _hoverTimer?.cancel();
          isOverlayOpen ? closeOverlay() : _open();
        },
      ),
    );
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Imperative opening helpers
// ---------------------------------------------------------------------------

/// Opens a menu panel anchored to [anchorRect] (global coordinates).
NanoOverlayController showNanoMenu(
  BuildContext context, {
  required Rect anchorRect,
  required List<NanoMenuEntry> entries,
  NanoPlacement placement = NanoPlacement.bottomStart,
  bool matchAnchorWidth = false,
  double minWidth = 192,
}) {
  return showNanoOverlay(
    context,
    anchorRect: anchorRect,
    placement: placement,
    matchAnchorWidth: matchAnchorWidth,
    builder: (overlayContext) =>
        NanoMenuPanel(entries: entries, minWidth: minWidth),
  );
}
