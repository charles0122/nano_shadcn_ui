import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';
import 'nano_text.dart';

/// Raised surface — `color.background.surface.default`,
/// `radii.surface.card`, `border.width.surface.card`, `spacing.inset.card`.
class NanoCard extends StatelessWidget {
  const NanoCard({super.key, required this.child, this.elevated = false});

  /// Adds the `Elevation.shadow.raised` shadow.
  final bool elevated;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      padding: EdgeInsets.all(theme.spacing.insetCard),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(theme.radius.surfaceCard),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.surfaceCardWidth,
        ),
        boxShadow: elevated ? theme.elevation.raised : null,
      ),
      child: child,
    );
  }
}

/// Registry contract: renders `children` nodes vertically inside a card.
const NanoComponentSpec nanoCardSpec = NanoComponentSpec(
  name: 'NanoCard',
  description: 'Raised surface container; children stack vertically.',
  propsSchema: {
    'elevated': {'type': 'boolean'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final theme = NanoTheme.of(context);
  return NanoCard(
    elevated: node.props['elevated'] == true,
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

// --- Card parts (the shadcn Card composition) -------------------------------

/// Card header row: title/description block with a trailing action slot
/// (`CardHeader` + `CardAction`).
class NanoCardHeader extends StatelessWidget {
  const NanoCardHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
  });

  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NanoText(title, role: NanoTextRole.h4),
              if (description != null) ...[
                SizedBox(height: theme.spacing.stackLabelContent / 2),
                NanoText(description!, role: NanoTextRole.bodySupporting),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          SizedBox(width: theme.spacing.inlineActions),
          action!,
        ],
      ],
    );
  }
}

/// Card body content — the default gap rhythm between stacked children.
class NanoCardContent extends StatelessWidget {
  const NanoCardContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Card footer: actions row separated by the section gap.
class NanoCardFooter extends StatelessWidget {
  const NanoCardFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: theme.spacing.inlineActions),
          children[i],
        ],
      ],
    );
  }
}
