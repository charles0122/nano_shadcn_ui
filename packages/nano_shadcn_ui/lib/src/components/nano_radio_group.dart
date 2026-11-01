import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Radio dot — shadcn `Radio Group` item. Always used inside a
/// [NanoRadioGroup], which owns the selected value.
class NanoRadio<T> extends StatelessWidget {
  const NanoRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  bool get _selected => groupValue == value;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final disabled = enabled == false || onChanged == null;
    return NanoInteractive(
      onTap: disabled ? null : () => onChanged!(value),
      enabled: !disabled,
      builder: (context, states) {
        final focused = states.contains(WidgetState.focused);
        return Opacity(
          opacity: disabled ? theme.opacity.stateDisabled : 1,
          child: AnimatedContainer(
            duration: theme.motion.durationFast,
            curve: theme.motion.curveStandard,
            width: theme.size.iconInline,
            height: theme.size.iconInline,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _selected
                  ? theme.colors.actionPrimaryBackground
                  : theme.colors.surface,
              border: Border.all(
                color: focused
                    ? theme.colors.borderFocus
                    : _selected
                    ? theme.colors.actionPrimaryBackground
                    : theme.colors.border,
                width: theme.borders.controlWidth,
              ),
            ),
            child: _selected
                ? NanoIcon(
                    NanoIcons.circleDot,
                    size: theme.size.iconInline - 2,
                    color: theme.colors.actionPrimaryForeground,
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Owns the selected radio value and lays out its items vertically.
///
/// ```dart
/// NanoRadioGroup<String>(
///   value: plan,
///   onChanged: (v) => setState(() => plan = v),
///   children: [
///     NanoRadioTile(value: 'free', title: 'Free', subtitle: '…'),
///     NanoRadioTile(value: 'pro', title: 'Pro', subtitle: '…'),
///   ],
/// )
/// ```
class NanoRadioGroup<T> extends StatelessWidget {
  const NanoRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.children,
    this.enabled = true,
    this.axis = Axis.vertical,
    this.spacing,
  });

  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<Widget> children;
  final bool enabled;
  final Axis axis;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final gap = spacing ?? theme.spacing.stackDefault;
    return NanoRadioGroupScope<T>(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      child: axis == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(height: gap),
                  children[i],
                ],
              ],
            )
          : Wrap(spacing: gap, runSpacing: gap, children: children),
    );
  }
}

/// Hands the group's value down so plain [NanoRadio]s and composed tiles
/// resolve their checked state without wiring every prop by hand.
class NanoRadioGroupScope<T> extends InheritedWidget {
  const NanoRadioGroupScope({
    super.key,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required super.child,
  });

  final T? value;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  static NanoRadioGroupScope<T>? maybeOf<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NanoRadioGroupScope<T>>();

  @override
  bool updateShouldNotify(NanoRadioGroupScope<T> oldWidget) =>
      oldWidget.value != value ||
      oldWidget.enabled != enabled ||
      oldWidget.onChanged != onChanged;
}

/// A labeled row built around a radio — the shadcn radio-group card recipe.
class NanoRadioTile<T> extends StatelessWidget {
  const NanoRadioTile({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final T value;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final scope = NanoRadioGroupScope.maybeOf<T>(context);
    return NanoInteractive(
      onTap: (scope?.enabled ?? false)
          ? () => scope?.onChanged?.call(value)
          : null,
      enabled: scope?.enabled ?? true,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        final selected = scope?.value == value;
        return Container(
          padding: EdgeInsets.all(theme.spacing.insetControl),
          decoration: BoxDecoration(
            color: hovered && !selected
                ? theme.colors.surfaceSubtle
                : theme.colors.surface,
            borderRadius: BorderRadius.circular(theme.radius.controlInput),
            border: Border.all(
              color: selected ? theme.colors.borderFocus : theme.colors.border,
              width: selected
                  ? theme.borders.controlFocusWidth
                  : theme.borders.controlWidth,
            ),
          ),
          child: Row(
            children: [
              NanoRadio<T>(
                value: value,
                groupValue: scope?.value,
                onChanged: scope?.onChanged,
                enabled: scope?.enabled ?? true,
              ),
              SizedBox(width: theme.spacing.inlineIconLabel),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.type.labelAction.copyWith(
                        color: theme.colors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.type.bodySupporting.copyWith(
                          color: theme.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        );
      },
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoRadioSpec = NanoComponentSpec(
  name: 'NanoRadio',
  description: 'Radio dot; selection is owned by the host app.',
  propsSchema: {
    'selected': {'type': 'boolean'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoRadio<bool>(
    value: true,
    groupValue: node.props['selected'] == true,
    onChanged: node.actionId == null
        ? null
        : (_) => scope.dispatch(node.actionId!),
  );
}
