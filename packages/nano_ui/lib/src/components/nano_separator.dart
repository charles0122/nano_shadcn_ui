import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// A thin rule in `color.border.default` — shadcn `Separator`.
class NanoSeparator extends StatelessWidget {
  const NanoSeparator({
    super.key,
    this.axis = Axis.horizontal,
    this.color,
    this.thickness,
  });

  final Axis axis;

  /// Overrides `color.border.default`.
  final Color? color;

  /// Overrides `border.width.divider.default`.
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final t = thickness ?? theme.borders.dividerWidth;
    return axis == Axis.horizontal
        ? Container(
            height: t,
            width: double.infinity,
            color: color ?? theme.colors.border,
          )
        : Container(
            width: t,
            height: double.infinity,
            color: color ?? theme.colors.border,
          );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoSeparatorSpec = NanoComponentSpec(
  name: 'NanoSeparator',
  description: 'Thin divider line in the default border color.',
  propsSchema: {
    'axis': {
      'type': 'enum',
      'values': ['horizontal', 'vertical'],
    },
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoSeparator(
    axis: node.props['axis'] == 'vertical' ? Axis.vertical : Axis.horizontal,
  );
}
