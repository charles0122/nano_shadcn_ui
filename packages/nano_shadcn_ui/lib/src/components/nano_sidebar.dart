import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_popover.dart';

/// One sidebar link.
class NanoSidebarItem {
  const NanoSidebarItem({
    required this.id,
    required this.label,
    this.icon,
    this.badge,
  });

  final String id;
  final String label;
  final NanoIconData? icon;
  final String? badge;
}

/// A labeled group of sidebar links.
class NanoSidebarGroup {
  const NanoSidebarGroup({this.label, required this.items});

  final String? label;
  final List<NanoSidebarItem> items;
}

/// Collapsible navigation rail — shadcn `Sidebar`: header (with the collapse
/// toggle), grouped links with icons and badges, footer slot. Expanded
/// width 16rem, collapsed icon rail.
class NanoSidebar extends StatefulWidget {
  const NanoSidebar({
    super.key,
    required this.groups,
    required this.activeId,
    required this.onItemTap,
    this.header,
    this.footer,
    this.expandedWidth = 256,
    this.collapsedWidth = 56,
    this.initiallyCollapsed = false,
  });

  final List<NanoSidebarGroup> groups;
  final String activeId;
  final ValueChanged<String> onItemTap;
  final Widget? header;
  final Widget? footer;

  /// Rail widths in logical pixels (the shadcn sidebar geometry).
  final double expandedWidth;
  final double collapsedWidth;
  final bool initiallyCollapsed;

  @override
  State<NanoSidebar> createState() => NanoSidebarState();
}

class NanoSidebarState extends State<NanoSidebar> {
  late bool _collapsed = widget.initiallyCollapsed;

  void toggle() => setState(() => _collapsed = !_collapsed);

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return AnimatedContainer(
      duration: theme.motion.durationBase,
      curve: theme.motion.curveStandard,
      width: _collapsed ? widget.collapsedWidth : widget.expandedWidth,
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: BorderDirectional(
          end: BorderSide(
            color: theme.colors.border,
            width: theme.borders.controlWidth,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_collapsed)
            // The only way back out when collapsed — user header/footer are
            // hidden because they cannot fit the rail width.
            Padding(
              padding: EdgeInsets.all(theme.spacing.insetControl / 2),
              child: NanoInteractive(
                onTap: toggle,
                builder: (context, states) {
                  final hovered = states.contains(WidgetState.hovered);
                  return Container(
                    width: double.infinity,
                    height: theme.size.controlHeightDefault,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hovered ? theme.colors.surfaceSubtle : null,
                      borderRadius: BorderRadius.circular(
                        theme.radius.controlDefault / 2,
                      ),
                    ),
                    child: NanoIcon(
                      NanoIcons.chevronsRight,
                      size: theme.size.iconDefault,
                      color: theme.colors.textPrimary,
                    ),
                  );
                },
              ),
            )
          else if (widget.header != null)
            Padding(
              padding: EdgeInsets.all(theme.spacing.insetControl),
              child: widget.header!,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: _collapsed
                    ? theme.spacing.stackDefault / 2
                    : theme.spacing.insetControl,
                vertical: theme.spacing.stackDefault,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final group in widget.groups) ...[
                    if (group.label != null && !_collapsed)
                      Padding(
                        padding: EdgeInsets.only(
                          left: theme.spacing.insetControl / 2,
                          bottom: theme.spacing.stackDefault / 2,
                          top: theme.spacing.stackDefault,
                        ),
                        child: NanoText(
                          group.label!,
                          role: NanoTextRole.labelMetadata,
                        ),
                      ),
                    for (final item in group.items)
                      _SidebarRow(
                        item: item,
                        active: item.id == widget.activeId,
                        collapsed: _collapsed,
                        onTap: () => widget.onItemTap(item.id),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (!_collapsed && widget.footer != null)
            Padding(
              padding: EdgeInsets.all(theme.spacing.insetControl),
              child: widget.footer!,
            ),
        ],
      ),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.item,
    required this.active,
    required this.collapsed,
    required this.onTap,
  });

  final NanoSidebarItem item;
  final bool active;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    if (collapsed) {
      return NanoTooltip(
        message: item.label,
        placement: NanoPlacement.bottomStart,
        child: NanoInteractive(
          onTap: onTap,
          builder: (context, states) {
            final hovered = states.contains(WidgetState.hovered);
            return Container(
              width: double.infinity,
              height: theme.size.controlHeightDefault,
              margin: EdgeInsets.symmetric(
                vertical: theme.spacing.stackDefault / 4,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? theme.colors.surfaceSubtle
                    : hovered
                    ? theme.colors.surfaceSubtle
                    : null,
                borderRadius: BorderRadius.circular(
                  theme.radius.controlDefault / 2,
                ),
              ),
              child: NanoIcon(
                item.icon ?? NanoIcons.circle,
                size: theme.size.iconDefault,
                color: active
                    ? theme.colors.textPrimary
                    : theme.colors.textSecondary,
              ),
            );
          },
        ),
      );
    }
    return NanoInteractive(
      onTap: onTap,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        return Container(
          height: theme.size.controlHeightDefault,
          margin: EdgeInsets.symmetric(
            vertical: theme.spacing.stackDefault / 4,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.insetControl / 2,
          ),
          decoration: BoxDecoration(
            color: active || hovered ? theme.colors.surfaceSubtle : null,
            borderRadius: BorderRadius.circular(
              theme.radius.controlDefault / 2,
            ),
          ),
          child: Row(
            children: [
              if (item.icon != null) ...[
                NanoIcon(
                  item.icon!,
                  size: theme.size.iconDefault,
                  color: active
                      ? theme.colors.textPrimary
                      : theme.colors.textSecondary,
                ),
                SizedBox(width: theme.spacing.inlineIconLabel),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: theme.type.bodyDefault.copyWith(
                    color: active
                        ? theme.colors.textPrimary
                        : theme.colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.badge != null)
                NanoBadge(item.badge!, variant: NanoBadgeVariant.secondary),
            ],
          ),
        );
      },
    );
  }
}
