import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Checkbox states: unchecked, checked, and mixed (indeterminate).
enum NanoTristate { unchecked, checked, mixed }

/// Square check control — shadcn `Checkbox`: 16px box (`size.icon.inline`),
/// primary fill with an on-accent check when selected, danger border when
/// the enclosing form item reports an error.
class NanoCheckbox extends StatelessWidget {
  const NanoCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.label,
  });

  final NanoTristate value;
  final ValueChanged<NanoTristate>? onChanged;
  final bool enabled;

  /// Optional trailing label; tapping it toggles the box too.
  final String? label;

  static NanoTristate of(bool checked) =>
      checked ? NanoTristate.checked : NanoTristate.unchecked;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final disabled = enabled == false || onChanged == null;
    final checked = value == NanoTristate.checked;
    final mixed = value == NanoTristate.mixed;

    Widget box({bool inRow = false}) => NanoInteractive(
      onTap: disabled
          ? null
          : () {
              final next = mixed || checked
                  ? NanoTristate.unchecked
                  : NanoTristate.checked;
              onChanged!(next);
            },
      enabled: !disabled,
      builder: (context, states) {
        final focused = states.contains(WidgetState.focused);
        final hovered = states.contains(WidgetState.hovered);
        final hasError = NanoFormFieldScope.maybeOf(context)?.hasError ?? false;
        final borderColor = focused
            ? theme.colors.borderFocus
            : hasError
            ? theme.colors.danger.foreground
            : hovered && !disabled
            ? theme.colors.borderStrong
            : theme.colors.border;
        return Opacity(
          opacity: disabled ? theme.opacity.stateDisabled : 1,
          child: AnimatedContainer(
            duration: theme.motion.durationFast,
            curve: theme.motion.curveStandard,
            width: theme.size.iconInline,
            height: theme.size.iconInline,
            margin: inRow ? null : null,
            decoration: BoxDecoration(
              color: checked || mixed
                  ? theme.colors.actionPrimaryBackground
                  : theme.colors.surface,
              borderRadius: BorderRadius.circular(
                theme.radius.controlDefault / 2,
              ),
              border: Border.all(
                color: checked || mixed
                    ? theme.colors.actionPrimaryBackground
                    : borderColor,
                width: theme.borders.controlWidth,
              ),
            ),
            child: checked || mixed
                ? NanoIcon(
                    mixed ? NanoIcons.minus : NanoIcons.check,
                    size: theme.size.iconInline - 4,
                    color: theme.colors.actionPrimaryForeground,
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );

    if (label == null) return box();
    return Semantics(
      checked: checked,
      mixed: mixed,
      enabled: !disabled,
      child: NanoInteractive(
        onTap: disabled
            ? null
            : () {
                final next = mixed || checked
                    ? NanoTristate.unchecked
                    : NanoTristate.checked;
                onChanged!(next);
              },
        enabled: !disabled,
        builder: (context, states) {
          final theme = NanoTheme.of(context);
          return Opacity(
            opacity: disabled ? theme.opacity.stateDisabled : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                box(inRow: true),
                SizedBox(width: theme.spacing.inlineIconLabel / 2),
                Flexible(
                  child: Text(
                    label!,
                    style: theme.type.bodyDefault.copyWith(
                      color: theme.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoCheckboxSpec = NanoComponentSpec(
  name: 'NanoCheckbox',
  description: 'Checkbox with checked / unchecked / mixed states.',
  propsSchema: {
    'label': {'type': 'string'},
    'value': {
      'type': 'enum',
      'values': ['checked', 'unchecked', 'mixed'],
    },
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final value = NanoTristate.values.firstWhere(
    (v) => v.name == node.props['value'],
    orElse: () => NanoTristate.unchecked,
  );
  return NanoCheckbox(
    value: value,
    label: node.props['label'] as String?,
    onChanged: (_) {},
  );
}
