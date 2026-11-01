import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Fixed aspect-ratio box — shadcn `Aspect Ratio` (Radix AspectRatio): the
/// child is letterboxed into `width / height`, clipped to the card radius.
class NanoAspectRatio extends StatelessWidget {
  const NanoAspectRatio({
    super.key,
    required this.aspectRatio,
    required this.child,
    this.clip = true,
  });

  final double aspectRatio;
  final Widget child;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final box = AspectRatio(aspectRatio: aspectRatio, child: child);
    return clip
        ? ClipRRect(
            borderRadius: BorderRadius.circular(theme.radius.surfaceCard),
            child: box,
          )
        : box;
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoAspectRatioSpec = NanoComponentSpec(
  name: 'NanoAspectRatio',
  description: 'Fixed aspect-ratio box.',
  propsSchema: {
    'aspectRatio': {'type': 'number'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final theme = NanoTheme.of(context);
  return NanoAspectRatio(
    aspectRatio: (node.props['aspectRatio'] as num?)?.toDouble() ?? 16 / 9,
    child: ColoredBox(color: theme.colors.surfaceSubtle),
  );
}
