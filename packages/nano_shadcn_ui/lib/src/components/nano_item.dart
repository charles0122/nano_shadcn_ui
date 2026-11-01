import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Surface item container — shadcn `Item`: rounded surface with control
/// padding, used for list rows and settings cards. Compose with
/// [NanoItemMedia], [NanoItemContent], [NanoItemTitle],
/// [NanoItemDescription], [NanoItemActions].
class NanoItem extends StatelessWidget {
  const NanoItem({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.variant = NanoItemVariant.surface,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;

  /// `surface` = card-like; `outline` = hairline border; `muted` = subtle fill.
  final NanoItemVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final body = NanoInteractive(
      onTap: onTap,
      enabled: onTap != null,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered) && onTap != null;
        final (bg, border) = switch (variant) {
          NanoItemVariant.surface => (
            selected ? theme.colors.surfaceSubtle : theme.colors.surface,
            selected ? theme.colors.borderStrong : theme.colors.border,
          ),
          NanoItemVariant.outline => (
            hovered ? theme.colors.surfaceSubtle : theme.colors.surface,
            selected ? theme.colors.borderFocus : theme.colors.border,
          ),
          NanoItemVariant.muted => (
            theme.colors.surfaceSubtle,
            selected ? theme.colors.borderFocus : theme.colors.border,
          ),
        };
        return AnimatedContainer(
          duration: theme.motion.durationFast,
          padding: EdgeInsets.all(theme.spacing.insetControl),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.radius.controlInput),
            border: Border.all(
              color: border,
              width: selected
                  ? theme.borders.controlFocusWidth
                  : theme.borders.controlWidth,
            ),
          ),
          child: child,
        );
      },
    );
    return body;
  }
}

enum NanoItemVariant { surface, outline, muted }

/// Leading media slot (icon, avatar) of a [NanoItem].
class NanoItemMedia extends StatelessWidget {
  const NanoItemMedia({
    super.key,
    required this.child,
    this.variant = NanoItemMediaVariant.icon,
  });

  final Widget child;
  final NanoItemMediaVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    if (variant == NanoItemMediaVariant.bare) return child;
    return Container(
      width: theme.size.avatarCompact,
      height: theme.size.avatarCompact,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colors.surfaceSubtle,
        border: variant == NanoItemMediaVariant.bordered
            ? Border.all(
                color: theme.colors.border,
                width: theme.borders.controlWidth,
              )
            : null,
      ),
      child: child,
    );
  }
}

enum NanoItemMediaVariant { icon, bordered, bare }

/// Title + description column of a [NanoItem].
class NanoItemContent extends StatelessWidget {
  const NanoItemContent({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NanoText(title, role: NanoTextRole.labelAction),
          if (description != null) ...[
            SizedBox(height: theme.spacing.stackLabelContent / 2),
            NanoText(description!, role: NanoTextRole.bodySupporting),
          ],
        ],
      ),
    );
  }
}

/// Trailing actions row of a [NanoItem].
class NanoItemActions extends StatelessWidget {
  const NanoItemActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: theme.spacing.inlineActions / 2),
          children[i],
        ],
      ],
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoItemSpec = NanoComponentSpec(
  name: 'NanoItem',
  description: 'Surface item row; children stack vertically.',
  propsSchema: {},
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final theme = NanoTheme.of(context);
  return NanoItem(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < node.children.length; i++) ...[
          if (i > 0) SizedBox(height: theme.spacing.stackDefault),
          scope.renderChild(context, node.children[i]),
        ],
      ],
    ),
  );
}
