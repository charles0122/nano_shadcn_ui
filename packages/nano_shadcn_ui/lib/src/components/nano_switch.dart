import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// On/off track-and-thumb switch — shadcn `Switch`: 44×24 track
/// (component geometry), 16px thumb (`size.icon.inline`), primary fill when
/// on, muted fill when off.
class NanoSwitch extends StatelessWidget {
  const NanoSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  static const double _trackWidth = 44;
  static const double _trackHeight = 24;
  static const double _thumb = 16;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final disabled = enabled == false || onChanged == null;
    return NanoInteractive(
      onTap: disabled ? null : () => onChanged!(!value),
      enabled: !disabled,
      builder: (context, states) {
        final focused = states.contains(WidgetState.focused);
        return Opacity(
          opacity: disabled ? theme.opacity.stateDisabled : 1,
          child: Semantics(
            toggled: value,
            enabled: !disabled,
            child: AnimatedContainer(
              duration: theme.motion.durationBase,
              curve: theme.motion.curveStandard,
              width: _trackWidth,
              height: _trackHeight,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: value
                    ? theme.colors.actionPrimaryBackground
                    : theme.colors.border,
                borderRadius: BorderRadius.circular(theme.radius.pill),
                border: focused
                    ? Border.all(
                        color: theme.colors.borderFocus,
                        width: theme.borders.controlFocusWidth,
                      )
                    : null,
              ),
              child: AnimatedAlign(
                duration: theme.motion.durationBase,
                curve: theme.motion.curveStandard,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: _thumb,
                  height: _thumb,
                  decoration: BoxDecoration(
                    color: value
                        ? theme.colors.actionPrimaryForeground
                        : theme.colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: theme.elevation.raised,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoSwitchSpec = NanoComponentSpec(
  name: 'NanoSwitch',
  description: 'On/off switch; dispatches actionId on toggle.',
  propsSchema: {
    'value': {'type': 'boolean'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoSwitch(
    value: node.props['value'] == true,
    onChanged: node.actionId == null
        ? null
        : (_) => scope.dispatch(node.actionId!),
  );
}
