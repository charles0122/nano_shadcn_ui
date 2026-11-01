import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Empty state — shadcn `Empty`: muted icon disc, title, description and an
/// optional action row.
class NanoEmpty extends StatelessWidget {
  const NanoEmpty({
    super.key,
    required this.title,
    this.description,
    this.icon = NanoIcons.inbox,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final NanoIconData icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.insetDialog),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: theme.size.avatarCompact,
            height: theme.size.avatarCompact,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colors.surfaceSubtle,
              border: Border.all(
                color: theme.colors.border,
                width: theme.borders.controlWidth,
              ),
            ),
            child: NanoIcon(
              icon,
              size: theme.size.iconStatus,
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          NanoText(title, role: NanoTextRole.labelAction),
          if (description != null) ...[
            SizedBox(height: theme.spacing.stackLabelContent / 2),
            NanoText(description!, role: NanoTextRole.bodySupporting),
          ],
          if (actions.isNotEmpty) ...[
            SizedBox(height: theme.spacing.stackDefault),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) SizedBox(width: theme.spacing.inlineActions),
                  actions[i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoEmptySpec = NanoComponentSpec(
  name: 'NanoEmpty',
  description: 'Empty state with icon, title and description.',
  propsSchema: {
    'title': {'type': 'string'},
    'description': {'type': 'string'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoEmpty(
    title: (node.props['title'] as String?) ?? '',
    description: node.props['description'] as String?,
  );
}
