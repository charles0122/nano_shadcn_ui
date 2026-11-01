import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// A pressed-state button — shadcn `Toggle`: ghost-like surface that stays
/// filled while active. Icon-only when [icon] is given without a label.
class NanoToggle extends StatelessWidget {
  const NanoToggle({
    super.key,
    required this.pressed,
    this.onPressed,
    this.icon,
    this.label,
    this.enabled = true,
    this.outline = false,
  });

  final bool pressed;
  final VoidCallback? onPressed;

  /// Lucide icon (preferred: icon-only toggle).
  final NanoIconData? icon;
  final String? label;
  final bool enabled;

  /// Outlined variant from the toggle group.
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final minHeight = theme.size.controlHeightDefault;
    return NanoInteractive(
      onTap: onPressed,
      enabled: enabled,
      builder: (context, states) {
        final disabled = !enabled || onPressed == null;
        final focused = states.contains(WidgetState.focused);
        final hovered = states.contains(WidgetState.hovered) && !disabled;
        final foreground = disabled
            ? theme.colors.textDisabled
            : pressed
            ? theme.colors.actionPrimaryForeground
            : theme.colors.textPrimary;
        final background = pressed
            ? theme.colors.actionPrimaryBackground
            : hovered
            ? theme.colors.surfaceSubtle
            : const Color(0x00000000);
        final borderColor = focused
            ? theme.colors.borderFocus
            : outline
            ? theme.colors.border
            : null;
        final content = <Widget>[
          if (icon != null)
            NanoIcon(icon!, size: theme.size.iconInline, color: foreground),
          if (label != null)
            Flexible(
              child: Text(
                label!,
                style: theme.type.labelAction.copyWith(color: foreground),
                maxLines: 1,
              ),
            ),
        ];
        return AnimatedContainer(
          duration: theme.motion.durationFast,
          curve: theme.motion.curveStandard,
          constraints: BoxConstraints(
            minHeight: minHeight,
            minWidth: minHeight,
          ),
          padding: EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radius.controlButton),
            border: borderColor == null
                ? null
                : Border.all(
                    color: borderColor,
                    width: focused
                        ? theme.borders.controlFocusWidth
                        : theme.borders.controlWidth,
                  ),
          ),
          child: Center(
            widthFactor: 1.0,
            child: content.length == 1
                ? content.single
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < content.length; i++) ...[
                        if (i > 0)
                          SizedBox(width: theme.spacing.inlineIconLabel / 2),
                        content[i],
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Selection mode of a [NanoToggleGroup].
enum NanoToggleGroupMode { single, multiple }

/// Row of connected [NanoToggle]s — shadcn `Toggle Group`, outline variant:
/// shared borders with merged corner radii.
class NanoToggleGroup extends StatelessWidget {
  const NanoToggleGroup({
    super.key,
    required this.children,
    this.mode = NanoToggleGroupMode.single,
    this.value = const [],
    this.onChanged,
    this.enabled = true,
  });

  /// Toggles with their [NanoToggle.pressed] preset; the group overrides it
  /// from [value]. Give each toggle an [UniqueKey]-able identity by order.
  final List<NanoToggle> children;
  final NanoToggleGroupMode mode;
  final List<int> value;
  final ValueChanged<List<int>>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = Set.of(value);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++)
          _ConnectedToggle(
            index: i,
            count: children.length,
            child: NanoToggle(
              pressed: active.contains(i),
              icon: children[i].icon,
              label: children[i].label,
              enabled: enabled,
              outline: true,
              onPressed: onChanged == null
                  ? null
                  : () {
                      final next = Set.of(active);
                      if (mode == NanoToggleGroupMode.single) {
                        next
                          ..clear()
                          ..add(i);
                      } else {
                        next.contains(i) ? next.remove(i) : next.add(i);
                      }
                      onChanged!(next.toList()..sort());
                    },
            ),
          ),
      ],
    );
  }
}

class _ConnectedToggle extends StatelessWidget {
  const _ConnectedToggle({
    required this.index,
    required this.count,
    required this.child,
  });

  final int index;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final radius = theme.radius.controlButton;
    final first = index == 0;
    final last = index == count - 1;
    return Transform.translate(
      offset: Offset(first ? 0 : -theme.borders.controlWidth, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.horizontal(
          left: first ? Radius.circular(radius) : Radius.zero,
          right: last ? Radius.circular(radius) : Radius.zero,
        ),
        child: child,
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoToggleSpec = NanoComponentSpec(
  name: 'NanoToggle',
  description: 'Pressed-state button (toggle). Dispatches actionId on tap.',
  propsSchema: {
    'label': {'type': 'string'},
    'pressed': {'type': 'boolean'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoToggle(
    label: node.props['label'] as String?,
    pressed: node.props['pressed'] == true,
    onPressed: node.actionId == null
        ? null
        : () => scope.dispatch(node.actionId!),
  );
}
