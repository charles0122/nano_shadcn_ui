import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';
import 'nano_text.dart';

/// Status kinds backed by the `color.status.*` triads.
enum NanoStatusType { danger, success, warning, info }

/// Inline status message using the full status triad:
/// background fill, border stroke and foreground text/dot.
class NanoStatusBanner extends StatelessWidget {
  const NanoStatusBanner({
    super.key,
    required this.message,
    this.title,
    this.status = NanoStatusType.info,
  });

  final String message;
  final String? title;
  final NanoStatusType status;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final triad = switch (status) {
      NanoStatusType.danger => theme.colors.danger,
      NanoStatusType.success => theme.colors.success,
      NanoStatusType.warning => theme.colors.warning,
      NanoStatusType.info => theme.colors.info,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.insetCard,
        vertical: theme.spacing.insetControl,
      ),
      decoration: BoxDecoration(
        color: triad.background,
        borderRadius: BorderRadius.circular(theme.radius.surfacePopover),
        border: Border.all(
          color: triad.border,
          width: theme.borders.controlWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: theme.size.indicatorDot,
            height: theme.size.indicatorDot,
            margin: EdgeInsets.only(top: theme.spacing.inlineIconLabel),
            decoration: BoxDecoration(
              color: triad.foreground,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: theme.spacing.inlineIconLabel),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  NanoText(
                    title!,
                    role: NanoTextRole.body,
                    color: triad.foreground,
                  ),
                NanoText(
                  message,
                  role: NanoTextRole.bodySupporting,
                  color: triad.foreground,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoStatusBannerSpec = NanoComponentSpec(
  name: 'NanoStatusBanner',
  description:
      'Inline status message. Fill, stroke and text come from the '
      'color.status.* triad of the given status.',
  propsSchema: {
    'message': {'type': 'string'},
    'title': {'type': 'string'},
    'status': {
      'type': 'enum',
      'values': ['danger', 'success', 'warning', 'info'],
    },
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final status = NanoStatusType.values.firstWhere(
    (s) => s.name == node.props['status'],
    orElse: () => NanoStatusType.info,
  );
  return NanoStatusBanner(
    message: (node.props['message'] as String?) ?? '',
    title: node.props['title'] as String?,
    status: status,
  );
}
