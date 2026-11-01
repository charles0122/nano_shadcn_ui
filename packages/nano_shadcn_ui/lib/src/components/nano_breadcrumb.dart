import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// One breadcrumb entry: a link or the current page.
class NanoBreadcrumbItem {
  const NanoBreadcrumbItem(this.label, {this.onTap});

  final String label;
  final VoidCallback? onTap;

  /// The last crumb (current page) — rendered as plain text.
  const NanoBreadcrumbItem.page(String label) : this(label);
}

/// Breadcrumb trail — shadcn `Breadcrumb`: links separated by chevrons.
class NanoBreadcrumb extends StatelessWidget {
  const NanoBreadcrumb({super.key, required this.items});

  final List<NanoBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) ...[
            SizedBox(width: theme.spacing.inlineIconLabel / 2),
            NanoIcon(
              NanoIcons.chevronRight,
              size: theme.size.iconInline,
              color: theme.colors.textSecondary,
            ),
            SizedBox(width: theme.spacing.inlineIconLabel / 2),
          ],
          _crumb(context, items[i], isLast: i == items.length - 1),
        ],
      ],
    );
  }

  Widget _crumb(
    BuildContext context,
    NanoBreadcrumbItem item, {
    required bool isLast,
  }) {
    final theme = NanoTheme.of(context);
    if (isLast || item.onTap == null) {
      return NanoText(
        item.label,
        role: NanoTextRole.body,
        color: isLast ? theme.colors.textPrimary : theme.colors.textSecondary,
      );
    }
    return NanoInteractive(
      onTap: item.onTap,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        return Text(
          item.label,
          style: theme.type.bodyDefault.copyWith(
            color: hovered
                ? theme.colors.textPrimary
                : theme.colors.textSecondary,
            decoration: hovered ? TextDecoration.underline : null,
          ),
        );
      },
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoBreadcrumbSpec = NanoComponentSpec(
  name: 'NanoBreadcrumb',
  description: 'Breadcrumb trail; crumbs separated by chevrons.',
  propsSchema: {
    'items': {'type': 'string', 'description': 'Slash-separated labels.'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final labels = ((node.props['items'] as String?) ?? '')
      .split('/')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  return NanoBreadcrumb(
    items: [for (final label in labels) NanoBreadcrumbItem(label)],
  );
}
