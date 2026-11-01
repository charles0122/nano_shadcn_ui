import 'package:flutter/widgets.dart';

import '../foundation/nano_icons.dart';
import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// Badge variants — `default` (primary fill), `secondary` (muted fill),
/// `destructive` (danger fill), `outline` (border only).
enum NanoBadgeVariant { primary, secondary, destructive, outline }

/// Small status pill — shadcn `Badge`: label style, pill radius, tight
/// padding. The 2px vertical inset is the badge's own geometry (py-0.5),
/// intentionally below the spacing scale.
class NanoBadge extends StatelessWidget {
  const NanoBadge(
    this.label, {
    super.key,
    this.variant = NanoBadgeVariant.primary,
    this.icon,
  });

  final String label;
  final NanoBadgeVariant variant;

  /// Optional leading icon, colored with the badge foreground.
  final NanoIconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final colors = theme.colors;
    final (background, foreground, borderColor) = switch (variant) {
      NanoBadgeVariant.primary => (
        colors.actionPrimaryBackground,
        colors.actionPrimaryForeground,
        null,
      ),
      NanoBadgeVariant.secondary => (
        colors.surfaceSubtle,
        colors.textPrimary,
        null,
      ),
      NanoBadgeVariant.destructive => (
        colors.danger.foreground,
        colors.onAccent,
        null,
      ),
      NanoBadgeVariant.outline => (
        const Color(0x00000000),
        colors.textPrimary,
        colors.border,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(theme.radius.controlDefault),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor, width: theme.borders.controlWidth),
      ),
      child: Text(
        label,
        style: theme.type.labelMetadata.copyWith(color: foreground),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoBadgeSpec = NanoComponentSpec(
  name: 'NanoBadge',
  description: 'Small status pill. Fill and text come from token roles.',
  propsSchema: {
    'label': {'type': 'string'},
    'variant': {
      'type': 'enum',
      'values': ['primary', 'secondary', 'destructive', 'outline'],
    },
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final variant = NanoBadgeVariant.values.firstWhere(
    (v) => v.name == node.props['variant'],
    orElse: () => NanoBadgeVariant.primary,
  );
  return NanoBadge((node.props['label'] as String?) ?? '', variant: variant);
}
