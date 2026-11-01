import 'package:flutter/widgets.dart';

import '../foundation/nano_icons.dart';
import '../foundation/nano_interactive.dart';
import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// Button variants — the shadcn/ui set. Colors are role lookups, never
/// literals: `primary → color.action.primary.*`, `destructive →
/// color.status.danger.*`, `outline/secondary/ghost → surface + border`,
/// `link → color.foreground.link.default`.
enum NanoButtonVariant { primary, secondary, ghost, destructive, outline, link }

/// Control heights from the `size.control.height.*` tokens; [icon] renders a
/// square button for a lone icon.
enum NanoButtonSize { compact, medium, large, icon }

class NanoButton extends StatelessWidget {
  const NanoButton({
    super.key,
    required this.label,
    this.variant = NanoButtonVariant.primary,
    this.size = NanoButtonSize.medium,
    this.icon,
    this.onPressed,
    this.enabled = true,
  });

  final String label;
  final NanoButtonVariant variant;
  final NanoButtonSize size;

  /// Optional leading icon (lucide set).
  final NanoIconData? icon;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return NanoInteractive(
      onTap: onPressed,
      enabled: enabled,
      builder: (context, states) {
        final theme = NanoTheme.of(context);
        final colors = theme.colors;
        final disabled = states.contains(WidgetState.disabled);
        final focused = states.contains(WidgetState.focused);
        final emphasized =
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered);

        final Color background;
        final Color foreground;
        Color? borderColor;
        double borderWidth = 0;
        switch (variant) {
          case NanoButtonVariant.primary:
            background = disabled
                ? colors.actionDisabledBackground
                : colors.actionPrimaryBackground;
            foreground = disabled
                ? colors.actionDisabledForeground
                : colors.actionPrimaryForeground;
            if (focused) {
              borderColor = colors.borderFocus;
              borderWidth = theme.borders.controlFocusWidth;
            }
          case NanoButtonVariant.destructive:
            background = disabled
                ? colors.actionDisabledBackground
                : colors.danger.foreground;
            foreground = disabled
                ? colors.actionDisabledForeground
                : colors.onAccent;
            if (focused) {
              borderColor = colors.borderFocus;
              borderWidth = theme.borders.controlFocusWidth;
            }
          case NanoButtonVariant.outline:
            background = disabled
                ? colors.actionDisabledBackground
                : emphasized
                ? colors.surfaceSubtle
                : colors.surface;
            foreground = disabled
                ? colors.actionDisabledForeground
                : colors.textPrimary;
            borderColor = focused
                ? colors.borderFocus
                : (disabled ? null : colors.border);
            borderWidth = focused
                ? theme.borders.controlFocusWidth
                : theme.borders.controlWidth;
          case NanoButtonVariant.secondary:
            background = disabled
                ? colors.actionDisabledBackground
                : emphasized
                ? colors.border
                : colors.surfaceSubtle;
            foreground = disabled
                ? colors.actionDisabledForeground
                : colors.textPrimary;
            if (focused) {
              borderColor = colors.borderFocus;
              borderWidth = theme.borders.controlFocusWidth;
            }
          case NanoButtonVariant.ghost:
            background = emphasized && !disabled
                ? colors.surfaceSubtle
                : const Color(0x00000000);
            foreground = disabled ? colors.textDisabled : colors.textPrimary;
            if (focused) {
              borderColor = colors.borderFocus;
              borderWidth = theme.borders.controlFocusWidth;
            }
          case NanoButtonVariant.link:
            background = const Color(0x00000000);
            foreground = disabled ? colors.textDisabled : colors.link;
            if (focused) {
              borderColor = colors.borderFocus;
              borderWidth = theme.borders.controlFocusWidth;
            }
        }

        final minHeight = switch (size) {
          NanoButtonSize.compact => theme.size.controlHeightCompact,
          NanoButtonSize.medium => theme.size.controlHeightDefault,
          NanoButtonSize.large => theme.size.controlHeightLarge,
          NanoButtonSize.icon => theme.size.controlHeightDefault,
        };
        final isIcon = size == NanoButtonSize.icon;
        final horizontalPadding = isIcon
            ? minHeight
            : theme.spacing.insetDefault;

        final labelWidget = Text(
          label,
          style: theme.type.labelAction.copyWith(color: foreground),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

        return AnimatedContainer(
          duration: theme.motion.durationFast,
          curve: theme.motion.curveStandard,
          constraints: BoxConstraints(
            minHeight: minHeight,
            minWidth: minHeight,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radius.controlButton),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor, width: borderWidth),
          ),
          // Hug the content width; Center with a width factor keeps the
          // label centered inside the min-height box without stretching.
          child: Center(
            widthFactor: 1.0,
            child: icon == null
                ? labelWidget
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NanoIcon(
                        icon!,
                        size: theme.size.iconInline,
                        color: foreground,
                      ),
                      SizedBox(width: theme.spacing.inlineIconLabel / 2),
                      labelWidget,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoButtonSpec = NanoComponentSpec(
  name: 'NanoButton',
  description:
      'A tappable button. Dispatches its actionId when activated. '
      'Colors come from the semantic token set.',
  propsSchema: {
    'label': {'type': 'string'},
    'icon': {'type': 'string', 'description': 'NanoIcons name, e.g. "plus".'},
    'variant': {
      'type': 'enum',
      'values': [
        'primary',
        'secondary',
        'ghost',
        'destructive',
        'outline',
        'link',
      ],
    },
    'size': {
      'type': 'enum',
      'values': ['compact', 'medium', 'large', 'icon'],
    },
  },
  builder: _buildFromNode,
);

NanoIconData? _iconByName(String? name) => switch (name) {
  'plus' => NanoIcons.plus,
  'trash' => NanoIcons.trash,
  'mail' => NanoIcons.mail,
  'chevronRight' => NanoIcons.chevronRight,
  'loaderCircle' => NanoIcons.loaderCircle,
  _ => null,
};

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final variant = NanoButtonVariant.values.firstWhere(
    (v) => v.name == node.props['variant'],
    orElse: () => NanoButtonVariant.primary,
  );
  final size = NanoButtonSize.values.firstWhere(
    (v) => v.name == node.props['size'],
    orElse: () => NanoButtonSize.medium,
  );
  return NanoButton(
    label: (node.props['label'] as String?) ?? '',
    variant: variant,
    size: size,
    icon: _iconByName(node.props['icon'] as String?),
    onPressed: node.actionId == null
        ? null
        : () => scope.dispatch(node.actionId!),
  );
}
