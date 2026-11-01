import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Alert kinds. `neutral` is the shadcn default (card surface), the rest use
/// the `color.status.*` triads.
enum NanoAlertVariant { neutral, danger, success, warning, info }

/// Inline callout — shadcn `Alert`: icon column, title + description.
class NanoAlert extends StatelessWidget {
  const NanoAlert({
    super.key,
    required this.title,
    this.description,
    this.variant = NanoAlertVariant.neutral,
    this.icon,
  });

  final String title;
  final String? description;
  final NanoAlertVariant variant;
  final NanoIconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final colors = theme.colors;
    final triad = switch (variant) {
      NanoAlertVariant.neutral => null,
      NanoAlertVariant.danger => colors.danger,
      NanoAlertVariant.success => colors.success,
      NanoAlertVariant.warning => colors.warning,
      NanoAlertVariant.info => colors.info,
    };
    final fg = triad?.foreground ?? colors.textPrimary;
    final effectiveIcon =
        icon ??
        switch (variant) {
          NanoAlertVariant.neutral => NanoIcons.info,
          NanoAlertVariant.danger => NanoIcons.circleAlert,
          NanoAlertVariant.success => NanoIcons.circleCheck,
          NanoAlertVariant.warning => NanoIcons.circleAlert,
          NanoAlertVariant.info => NanoIcons.info,
        };

    return Container(
      padding: EdgeInsets.all(theme.spacing.insetCard),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(theme.radius.controlInput),
        border: Border.all(
          color: triad?.border ?? colors.border,
          width: theme.borders.controlWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NanoIcon(effectiveIcon, size: theme.size.iconStatus, color: fg),
          SizedBox(width: theme.spacing.inlineIconLabel),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NanoText(title, role: NanoTextRole.labelAction, color: fg),
                if (description != null) ...[
                  SizedBox(height: theme.spacing.stackLabelContent / 2),
                  NanoText(
                    description!,
                    role: NanoTextRole.bodySupporting,
                    color: triad?.foreground ?? colors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoAlertSpec = NanoComponentSpec(
  name: 'NanoAlert',
  description: 'Inline callout with an icon, title and description.',
  propsSchema: {
    'title': {'type': 'string'},
    'description': {'type': 'string'},
    'variant': {
      'type': 'enum',
      'values': ['neutral', 'danger', 'success', 'warning', 'info'],
    },
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final variant = NanoAlertVariant.values.firstWhere(
    (v) => v.name == node.props['variant'],
    orElse: () => NanoAlertVariant.neutral,
  );
  return NanoAlert(
    title: (node.props['title'] as String?) ?? '',
    description: node.props['description'] as String?,
    variant: variant,
  );
}
