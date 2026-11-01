import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Single disclosure toggle — shadcn `Collapsible`: a trigger row with a
/// rotating chevron that reveals [child] with an animated height.
class NanoCollapsible extends StatefulWidget {
  const NanoCollapsible({
    super.key,
    required this.trigger,
    required this.child,
    this.initiallyOpen = false,
  });

  /// Widget rendered inside the tappable trigger row (chevron appended).
  final Widget trigger;
  final Widget child;
  final bool initiallyOpen;

  @override
  State<NanoCollapsible> createState() => _NanoCollapsibleState();
}

class _NanoCollapsibleState extends State<NanoCollapsible> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoInteractive(
          onTap: () => setState(() => _open = !_open),
          builder: (context, states) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.insetControl,
                vertical: theme.spacing.insetControl / 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.trigger,
                  SizedBox(width: theme.spacing.inlineIconLabel),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: theme.motion.durationBase,
                    curve: theme.motion.curveStandard,
                    child: NanoIcon(
                      NanoIcons.chevronDown,
                      size: theme.size.iconInline,
                      color: theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AnimatedCrossFade(
          duration: theme.motion.durationBase,
          sizeCurve: theme.motion.curveStandard,
          crossFadeState: _open
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: EdgeInsets.only(
              left: theme.spacing.insetControl,
              bottom: theme.spacing.insetControl / 2,
            ),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoCollapsibleSpec = NanoComponentSpec(
  name: 'NanoCollapsible',
  description: 'Disclosure toggle with animated reveal.',
  propsSchema: {
    'trigger': {'type': 'string'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoCollapsible(
    trigger: Text((node.props['trigger'] as String?) ?? 'Details'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final child in node.children) scope.renderChild(context, child),
      ],
    ),
  );
}
